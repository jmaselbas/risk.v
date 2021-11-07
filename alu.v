`include "rv32i.vh"

module alu(rst, clk, op, in1, in2, out);
input rst, clk;
input [3:0] op;
input [31:0] in1, in2;
output reg [31:0] out;

always @(posedge clk) begin
	if (rst) begin
		out <= 32'b0;
	end else begin
		case (op)
		`ALU_ADD:
		  out <= in1 + in2;
		`ALU_SUB:
		  out <= in1 - in2;
		`ALU_SLL:
		  out <= in1 << in2[4:0];
		`ALU_SLT:
		  out <= $signed(in1) < $signed(in2);
		`ALU_SLTU:
		  out <= in1 < in2;
		`ALU_XOR:
		  out <= in1 ^ in2;
		`ALU_SRL:
		  out <= in1 >> in2[4:0];
		`ALU_SRA:
		  out <= in1 >>> in2[4:0];
		`ALU_OR:
		  out <= in1 | in2;
		`ALU_AND:
		  out <= in1 & in2;
		default:
		  out <= 32'b0;
		endcase
	end
end
endmodule
