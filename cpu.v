`include "rv32i.vh"

module cpu(rst, clk);
input rst, clk;

reg   rden, wren;
reg [31:0] pc;

/* fetch output */
reg [6:0]   fetch_addr;
wire [31:0]  f_insn;

/* decode internal wire */
wire [4:0]  opcode_w;
wire [3:0]  alu_op_w;
wire [2:0]  bcu_op_w;
wire        invalid_w;
wire [4:0]  rs1_w, rs2_w, rd_w;
wire [31:0] reg1_w, reg2_w, imm_w;
/* decode output values */
reg [4:0]   d_opcode;
reg [31:0]  d_op_val1, d_op_val2;
reg [3:0]   d_alu_op;
reg [31:0]  d_bcu_val1, d_bcu_val2;
reg [2:0]   d_bcu_op;
reg [4:0]   d_rd;

/* execute output */
reg [31:0]  x_out, x_npc;
reg [4:0]   x_rd;
reg 	    x_taken, x_link;

wire [31:0] rf_in;

parameter FETCH_INSN = 0;
parameter DECODE_AND_REGFILE_FETCH = 1;
parameter EXECUTE = 2;
parameter WRITE_BACK = 3;

decode decode(f_insn, opcode_w, alu_op_w, bcu_op_w, invalid, rd_w, rs1_w, rs2_w, imm_w);
regfile regfile(rst, clk, wren, rden, x_rd, rs1_w, rs2_w, rf_in, reg1_w, reg2_w);
rom rom(clk, rst, fetch_addr, f_insn);

/* write back the execution out value (x_out) in the register file except
 * for link instructions (JAL,JALR) where next pc (x_npc) is written.
 */
assign rf_in = (x_link) ? x_npc : x_out;

reg [2:0]   state;
always @(posedge clk) begin
	if (rst) begin
		rden <= 0;
		wren <= 0;
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
	end else begin
		case (state)
		FETCH_INSN: begin
			wren <= 0;
			rden <= 1;
			$display("fetching pc = %x", pc);
			state <= DECODE_AND_REGFILE_FETCH;
		end
		/* {f_insn} */
		DECODE_AND_REGFILE_FETCH: begin
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
			end
			rden <= 0;
			state <= EXECUTE;
		end
		/* {d_opcode, d_rd, d_alu_op, d_op_val1, d_op_val2, d_bcu_op, d_bcu_val1, d_bcu_val2} */
		EXECUTE: begin
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
			x_npc <= pc + 4;
			x_rd <= d_rd;
			wren <= d_rd != 0;
			state <= WRITE_BACK;
		end
		/* {x_npc, x_rd, x_out, x_link, x_taken } */
		WRITE_BACK: begin
			if (x_taken) begin
				$display("branch taken to %x", x_out);
				pc <= x_out;
				fetch_addr <= x_out >> 2;
			end else begin
				pc <= x_npc;
				fetch_addr <= x_npc >> 2;
			end
			wren <= 0;
			state <= FETCH_INSN;
		end
		endcase
	end
end
endmodule
