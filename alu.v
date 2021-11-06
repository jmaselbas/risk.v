module alu(rst, clk, op, in1, in2, out);
   input rst, clk;
   input [3:0] op;
   input [31:0] in1, in2;
   output reg [31:0] out;

   parameter OP_ADD  = 4'b0000;
   parameter OP_SUB  = 4'b1000;
   parameter OP_SLL  = 4'b0001;
   parameter OP_SLT  = 4'b0010;
   parameter OP_SLTU = 4'b0011;
   parameter OP_XOR  = 4'b0100;
   parameter OP_SRL  = 4'b0101;
   parameter OP_SRA  = 4'b1101;
   parameter OP_OR   = 4'b0110;
   parameter OP_AND  = 4'b0111;

   always @(posedge clk) begin
      if (rst) begin
	 out <= 32'b0;
      end else begin
	 case (op)
	   OP_ADD:
	     out <= in1 + in2;
	   OP_SUB:
	     out <= in1 - in2;
	   OP_SLL:
	     out <= in1 << in2;
	   OP_SLT:
	     out <= $signed(in1) < $signed(in2);
	   OP_SLTU:
	     out <= in1 < in2;
	   OP_XOR:
	     out <= in1 ^ in2;
	   OP_SRL:
	     out <= in1 >> in2;
	   OP_SRA:
	     out <= in1 >>> in2;
	   OP_OR:
	     out <= in1 | in2;
	   OP_AND:
	     out <= in1 & in2;
	   default:
	     out <= 32'b0;
	 endcase
      end
   end
endmodule
