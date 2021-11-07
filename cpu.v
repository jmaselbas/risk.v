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
wire        invalid_w;
wire [4:0]  rs1_w, rs2_w, rd_w;
wire [31:0] reg1_w, reg2_w, imm_w;
/* decode output values */
reg [4:0]   d_opcode;
reg [31:0]  d_op_val1, d_op_val2;
reg [3:0]   d_alu_op;
reg [4:0]   d_rd;
reg [31:0]  d_imm;

/* execute output */
wire [31:0] alu_out;
reg [4:0]   x_opcode;
reg [4:0]   x_rd;
reg [31:0]  x_imm;
wire [31:0] rf_in;
reg [31:0]  wb_val;

parameter FETCH_INSN = 0;
parameter DECODE_AND_REGFILE_FETCH = 1;
parameter EXECUTE = 2;
parameter WRITE_BACK = 3;

decode decode(f_insn, opcode_w, alu_op_w, invalid, rd_w, rs1_w, rs2_w, imm_w);
regfile regfile(rst, clk, wren, rden, x_rd, rs1_w, rs2_w, rf_in, reg1_w, reg2_w);
alu alu(rst, clk, d_alu_op, d_op_val1, d_op_val2, alu_out);
rom rom(clk, rst, fetch_addr, f_insn);

/* we write back alu_out in RF in the general case
 Except when:
  * executing JAL or JALR => we write pc + 4
  * executing AUIPC       => we write pc + imm
 */
assign rf_in = (x_opcode == 5'b11011 || x_opcode == 5'b11001) ? pc + 4 :
	       (x_opcode == 5'b00101) ? pc + $signed(x_imm) :
	       alu_out;

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
		d_imm <= 0;
		d_opcode <= 0;
		d_alu_op <= 0;
		x_opcode <= 0;
		x_rd <= 0;
		x_imm <= 0;
	end else begin
		case (state)
		FETCH_INSN: begin
			wren <= 0;
			rden <= 1;
			$display("fetching pc = %x\n", pc);
			state <= DECODE_AND_REGFILE_FETCH;
		end
		/* {f_insn} */
		DECODE_AND_REGFILE_FETCH: begin
			d_opcode <= opcode_w;
			d_rd <= rd_w;
			d_imm <= imm_w;
			d_alu_op <= alu_op_w;
			d_op_val1 <= reg1_w;
			if (opcode_w == 5'b00100) begin
				d_op_val2 <= imm_w;
			end else begin
				d_op_val2 <= reg2_w;
			end
			rden <= 0;
			state <= EXECUTE;
		end
		/* {d_opcode, d_rd, d_alu_op, d_op_val1, d_op_val2} */
		EXECUTE: begin
			x_opcode <= d_opcode;
			x_rd <= d_rd;
			x_imm <= d_imm;
			wren <= d_rd != 0;
			state <= WRITE_BACK;
		end
		/* {x_opcode, x_rd, alu_out} */
		WRITE_BACK: begin
			if (x_opcode == 5'b11011) begin // JAL
				pc <= pc + x_imm;
				fetch_addr <= (pc + x_imm) >> 2;
				$display("JAL branching to pc = %x\n", pc + x_imm);
			end else if (x_opcode == 5'b11001) begin // JALR
				pc <= alu_out + x_imm;
				fetch_addr <= (alu_out + x_imm) >> 2;
				$display("JALR branching to pc = %x\n", alu_out + x_imm);
			end else begin
				pc <= pc + 4;
				fetch_addr <= (pc + 4) >> 2;
			end
			wren <= 0;
			state <= FETCH_INSN;
		end
		endcase
	end
end
endmodule
