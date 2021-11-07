module regfile(rst, clk, wr, rd, selwr, selrd1, selrd2, in, out1, out2);
   input rst, clk;
   input wr, rd;
   input [4:0] selwr, selrd1, selrd2;
   input [31:0] in;
   output [31:0] out1, out2;

   output reg [31:0] rfile [0:31];
   integer    i;

   always @(posedge clk) begin
      if (rst) begin
	 for (i = 0; i < 32; i = i + 1) begin
	    rfile[i] <= i;
	 end
      end else begin
	 if (wr) begin
	    rfile[selwr] <= in;
	 end
      end
   end
   assign out1 = rfile[selrd1];
   assign out2 = rfile[selrd2];
endmodule
