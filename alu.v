module alu(rst, clk, opcode, funct3, funct7, in1, in2, out);
   input rst, clk;
   input [6:0] funct7;
   input [2:0] funct3;
   input [4:0] opcode;
   input [31:0] in1, in2;
   output reg [31:0] out;

   wire [14:0] 	     op = {funct7, funct3, opcode};

   always @(posedge clk) begin
      if (rst) begin
	 out <= 32'b0;
      end else begin
	 case (op)
	   15'b0000000_000_01100: /* R-ADD */
	     out <= in1 + in2;
	   15'b0100000_000_01100: /* R-SUB */
	     out <= in1 - in2;
	   15'b0000000_001_01100: /* R-SLL */
	     out <= in1 << in2;
	   15'b0000000_010_01100: /* R-SLT */
	     out <= $signed(in1) < $signed(in2);
	   15'b0000000_011_01100: /* R-SLTU */
	     out <= in1 < in2;
	   15'b0000000_100_01100: /* R-XOR */
	     out <= in1 ^ in2;
	   15'b0000000_101_01100: /* R-SRL */
	     out <= in1 >> in2;
	   15'b0100000_101_01100: /* R-SRA */
	     out <= in1 >>> in2;
	   15'b0000000_110_01100: /* R-OR */
	     out <= in1 | in2;
	   15'b0000000_111_01100: /* R-AND */
	     out <= in1 & in2;
	   default:
	     out <= 32'b0;
	 endcase
      end
   end
endmodule
