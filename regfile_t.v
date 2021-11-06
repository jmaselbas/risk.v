module regfile_test;
   reg clk, rst;
   reg wr, rd;
   reg [4:0] selwr, selrd1, selrd2;
   reg [31:0] wrval;
   wire [31:0] rdval1, rdval2;

   regfile test_regfile (rst, clk, wr, rd, selwr, selrd1, selrd2, wrval, rdval1, rdval2);

   initial begin
      $dumpfile("regfile.vcd");
      $dumpvars(0, test_regfile);
   end

   initial begin
      rst = 1'b1;
      clk = 1'b0;
      wr = 1'b0;
      rd = 1'b0;
      selwr = 5'b0;
      selrd1 = 5'b0;
      selrd2 = 5'b0;
      wrval = 32'b0;
      #4;
      rst = 1'b0;
      #4;
      selwr = 5'h1;
      wrval = wrval + 10;
      wr = 1'b1; #2; wr = 1'b0;
      #4;
      selwr = 5'h2;
      wrval = wrval + 11;
      wr = 1'b1; #2; wr = 1'b0;
      #4;
      selrd1 = 5'h1;
      selrd2 = 5'h2;
      rd = 1'b1; #2; rd = 1'b0;
      #4;
      $finish;
   end
   always begin
      #1;
      clk = ~clk;
   end

endmodule
