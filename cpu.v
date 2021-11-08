`include "rv32i.vh"

module cpu(rst, clk);
input rst, clk;

reg [31:0] regfile [0:31];
reg [31:0] pc;

/* fetch output */
reg [6:0]   fetch_addr;
wire [31:0]  f_insn;

/* decode internal wire */
wire [4:0]  opcode_w;
wire [3:0]  alu_op_w;
wire [2:0]  bcu_op_w;
wire [2:0]  lsu_op_w;
wire        invalid_w;
wire [4:0]  rs1_w, rs2_w, rd_w;
wire [31:0] reg1_w, reg2_w, imm_w;
assign reg1_w = regfile[rs1_w];
assign reg2_w = regfile[rs2_w];
/* decode output values */
reg [4:0]   d_opcode;
reg [31:0]  d_op_val1, d_op_val2;
reg [3:0]   d_alu_op;
reg [31:0]  d_bcu_val1, d_bcu_val2;
reg [2:0]   d_bcu_op;
reg [2:0]   d_lsu_op;
reg [4:0]   d_rd;

/* execute output */
reg [31:0]  x_out, x_npc;
reg [4:0]   x_rd;
reg [2:0]   x_lsu_op;
reg [31:0]  x_lsu_val;
reg         x_taken, x_link, x_load, x_store;

/* memory output */
reg [31:0]  m_out, m_npc;
reg [4:0]   m_rd;
reg [2:0]   m_lsu_op;
reg         m_taken, m_link, m_load;

wire [31:0] lsu_out;
wire [6:0]  lsu_ram_addr;
wire lsu_wren;

assign lsu_ram_addr = x_out[8:2];
assign lsu_wren = m_en && x_store; /* true during memory state and x_store */

decode decode(f_insn, opcode_w, alu_op_w, bcu_op_w, lsu_op_w, invalid, rd_w, rs1_w, rs2_w, imm_w);
rom rom(clk, rst, fetch_addr, f_insn);
ram ram(clk, rst, lsu_wren, lsu_ram_addr, x_lsu_val, lsu_out);

reg [5:0]   state;
wire 	    f_en, d_en, x_en, m_en, w_en;
assign f_en = state[0];
assign d_en = state[1];
assign x_en = state[2];
assign m_en = state[3];
assign w_en = state[4];
parameter FETCH_INSN = 1 << 0;
parameter DECODE_AND_REGFILE_FETCH = 1 << 1;
parameter EXECUTE = 1 << 2;
parameter MEMORY = 1 << 3;
parameter WRITE_BACK = 1 << 4;

integer     i;

always @(posedge clk) begin
	if (rst) begin
		state <= FETCH_INSN;
		pc <= 0;
		fetch_addr <= 0;
		d_opcode <= 0;
		d_op_val1 <= 0;
		d_op_val2 <= 0;
		d_alu_op <= 0;
		d_rd <= 0;
		x_rd <= 0;
		x_taken <= 0;
		x_link <= 0;
		x_lsu_val <= 0;
		for (i = 0; i < 32; i = i + 1) regfile[i] <= 0;
	end else begin // if (rst)
		state <= (state != WRITE_BACK) ? state << 1 : FETCH_INSN;
		if (f_en) begin
			$display("fetching pc = %x", pc);
		end
		/* {f_insn} */
		if (d_en) begin
			d_opcode <= opcode_w;
			if (opcode_w == `OP_ALUIMM) begin
				d_bcu_op <= `BCU_DISABLE;
				d_alu_op <= alu_op_w;
				d_op_val1 <= reg1_w;
				d_op_val2 <= imm_w;
				d_rd <= rd_w;
			end else if (opcode_w == `OP_ALU) begin
				d_bcu_op <= `BCU_DISABLE;
				d_alu_op <= alu_op_w;
				d_op_val1 <= reg1_w;
				d_op_val2 <= reg2_w;
				d_rd <= rd_w;
			end else if (opcode_w == `OP_JAL) begin
				d_bcu_op <= `BCU_TAKEN;
				d_alu_op <= `ALU_ADD;
				d_op_val1 <= pc;
				d_op_val2 <= imm_w;
				d_rd <= rd_w;
			end else if (opcode_w == `OP_JALR) begin
				d_bcu_op <= `BCU_TAKEN;
				d_alu_op <= `ALU_ADD;
				d_op_val1 <= reg1_w;
				d_op_val2 <= imm_w;
				d_rd <= rd_w;
			end else if (opcode_w == `OP_AUIPC) begin
				d_bcu_op <= `BCU_DISABLE;
				d_alu_op <= `ALU_ADD;
				d_op_val1 <= pc;
				d_op_val2 <= imm_w;
				d_rd <= rd_w;
			end else if (opcode_w == `OP_BRANCH) begin
				d_bcu_op <= bcu_op_w;
				d_bcu_val1 <= reg1_w;
				d_bcu_val2 <= reg2_w;
				d_alu_op <= `ALU_ADD;
				d_op_val1 <= pc;
				d_op_val2 <= imm_w;
				d_rd <= 0; /* do not write back */
			end else if (opcode_w == `OP_LOAD) begin
				d_lsu_op <= lsu_op_w;
				d_bcu_op <= `BCU_DISABLE;
				d_alu_op <= `ALU_ADD;
				d_op_val1 <= reg1_w;
				d_op_val2 <= imm_w;
				d_rd <= rd_w;
			end else if (opcode_w == `OP_STORE) begin
				d_lsu_op <= lsu_op_w;
				d_bcu_op <= `BCU_DISABLE;
				d_alu_op <= `ALU_ADD;
				d_op_val1 <= reg1_w;
				d_op_val2 <= imm_w;
				d_bcu_val2 <= reg2_w; /* store value */
				d_rd <= 0; /* do not write back */
			end else if (opcode_w == `OP_MISC) begin
				/* there is only fence in OP_MISC */
				/* insert a nop instruction */
				d_bcu_op <= `BCU_DISABLE;
				d_alu_op <= `ALU_ADD;
				d_rd <= 0; /* do not write back */
			end else if (opcode_w == `OP_SYSTEM) begin
				if (f_insn == 32'b000000000001_00000_000_00000_1110011) begin
					$display("EBREAK taken pc@%x", pc);
					$finish;
				end

			end
		end
		/* {d_opcode, d_rd, d_alu_op, d_op_val1, d_op_val2, d_bcu_op, d_bcu_val1, d_bcu_val2} */
		if (x_en) begin
			case (d_bcu_op)
			`COMP_BEQ:	x_taken <= d_bcu_val1 == d_bcu_val2;
			`COMP_BNE:	x_taken <= d_bcu_val1 != d_bcu_val2;
			`COMP_BLT:	x_taken <= $signed(d_bcu_val1) < $signed(d_bcu_val2);
			`COMP_BGE:	x_taken <= $signed(d_bcu_val1) > $signed(d_bcu_val2);
			`COMP_BLTU:	x_taken <= d_bcu_val1 < d_bcu_val2;
			`COMP_BGEU:	x_taken <= d_bcu_val1 > d_bcu_val2;
			`BCU_TAKEN:	x_taken <= 1;
			default:	x_taken <= 0;
			endcase
			case (d_alu_op)
			`ALU_ADD:	x_out <= d_op_val1 + d_op_val2;
			`ALU_SUB:	x_out <= d_op_val1 - d_op_val2;
			`ALU_SLL:	x_out <= d_op_val1 << d_op_val2[4:0];
			`ALU_SLT:	x_out <= $signed(d_op_val1) < $signed(d_op_val2);
			`ALU_SLTU:	x_out <= d_op_val1 < d_op_val2;
			`ALU_XOR:	x_out <= d_op_val1 ^ d_op_val2;
			`ALU_SRL:	x_out <= d_op_val1 >> d_op_val2[4:0];
			`ALU_SRA:	x_out <= d_op_val1 >>> d_op_val2[4:0];
			`ALU_OR:	x_out <= d_op_val1 | d_op_val2;
			`ALU_AND:	x_out <= d_op_val1 & d_op_val2;
			default:	x_out <= 0;
			endcase
			x_link <= d_opcode == `OP_JAL || d_opcode == `OP_JALR;
			x_lsu_op <= d_lsu_op;
			x_lsu_val <= d_bcu_val2;
			x_load <= d_opcode == `OP_LOAD;
			x_store <= d_opcode == `OP_STORE;
			x_npc <= pc + 4;
			x_rd <= d_rd;
		end
		/* {x_npc, x_rd, x_out, x_link, x_taken, x_load, x_store} */
		if (m_en) begin
			if (x_store) begin
				$display("store @%x: %x", x_out, x_lsu_val);
			end
			m_npc <= x_npc;
			m_rd <= x_rd;
			m_link <= x_link;
			m_taken <= x_taken;
			m_load <= x_load;
			m_lsu_op <= x_lsu_op;
			m_out <= x_out;
		end
		/* {m_npc, m_rd, m_out, m_link, m_taken, m_load, m_lsu_op, m_out} */
		if (w_en) begin
			if (m_rd != 0 && x_load) begin
				$display("load  @%x: %x", m_out, lsu_out);
				case (m_lsu_op)
				`LSU_LB:	regfile[m_rd] <= $signed(lsu_out[7:0]);
				`LSU_LH:	regfile[m_rd] <= $signed(lsu_out[15:0]);
				`LSU_LW:	regfile[m_rd] <= lsu_out;
				`LSU_LBU:	regfile[m_rd] <= lsu_out[7:0];
				`LSU_LHU:	regfile[m_rd] <= lsu_out[15:0];
				default:	regfile[m_rd] <= 0; /* invalid */
				endcase
			end else if (m_rd != 0) begin
				regfile[m_rd] <= (m_link) ? m_npc : m_out;
			end
			if (m_taken) begin
				$display("branch taken to %x", m_out);
				pc <= m_out;
				fetch_addr <= m_out >> 2;
			end else begin
				pc <= x_npc;
				fetch_addr <= m_npc >> 2;
			end
		end
	end
end
endmodule
