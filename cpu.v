module cpu(rst, clk);
input rst, clk;

reg   rden, wren;

wire [31:0] out;

/* fetch output */
wire [31:0] data_o;

/* decode output */
wire [4:0]  opcode;
wire [3:0]  alu_op;
wire        invalid;
wire [4:0]  d_rs1, d_rs2, d_rd;
wire [31:0] d_reg1, d_reg2, d_imm;
reg [31:0]  d_val1, d_val2;
reg [4:0]   d_opcode;
reg [3:0]   d_alu_op;
wire [31:0] alu_in1;
wire [31:0] alu_in2;
reg [31:0]  d_imm_reg;
reg [31:0]  reg1_val;

/* execute output */
wire [31:0] alu_out;
reg [6:0]   fetch_addr;
wire [31:0] fetch_insn;
reg [31:0]  pc;
wire [31:0] rf_in;

reg [31:0]  wb_val;

parameter FETCH_INSN = 0;
parameter DECODE_AND_REGFILE_FETCH = 1;
parameter EXECUTE = 2;
parameter WRITE_BACK = 3;

decode decode(data_o, opcode, alu_op, invalid, d_rd, d_rs1, d_rs2, d_imm);
regfile regfile(rst, clk, wren, rden, d_rd, d_rs1, d_rs2, rf_in, d_reg1, d_reg2);
alu alu(rst, clk, alu_op, alu_in1, alu_in2, alu_out);
rom rom(clk, rst, fetch_addr, data_o);

assign alu_in1 = d_reg1;
assign alu_in2 = (opcode == 5'b00100) ? d_imm : d_reg2;

/* we write back alu_out in RF in the general case
 Except when:
  * executing JAL or JALR => we write pc + 4
  * executing AUIPC       => we write pc + imm
 */
assign rf_in = (d_opcode == 5'b11011 || d_opcode == 5'b11001) ? pc + 4 : (d_opcode == 5'b00101) ? pc + $signed(d_imm_reg) : alu_out;

reg [2:0]   state;
always @(posedge clk) begin
	if (rst) begin
		rden <= 0;
		wren <= 0;
		state <= FETCH_INSN;
		pc <= 0;
		fetch_addr <= 0;
		d_opcode <= 0;
		d_alu_op <= 0;
	end else begin
		case (state)
		FETCH_INSN: begin
			wren <= 0;
			rden <= 1;
			$display("fetching pc = %x\n", pc);
			state <= DECODE_AND_REGFILE_FETCH;
		end
		DECODE_AND_REGFILE_FETCH: begin
			rden <= 0;
			state <= EXECUTE;
		end
		EXECUTE: begin
			d_opcode <= opcode;
			d_alu_op <= alu_op;
			d_imm_reg <= d_imm;
			reg1_val <= d_reg1;
			wren <= d_rd != 0;
			state <= WRITE_BACK;
		end
		WRITE_BACK: begin
			if (d_opcode == 5'b11011) begin // JAL
				pc <= pc + d_imm_reg;
				fetch_addr <= (pc + d_imm_reg) >> 2;
				$display("JAL branching to pc = %x\n", pc + d_imm_reg);
			end else if (d_opcode == 5'b11001) begin // JALR
				pc <= reg1_val + d_imm_reg;
				fetch_addr <= (reg1_val + d_imm_reg) >> 2;
				$display("JALR branching to pc = %x\n", reg1_val + d_imm_reg);
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
