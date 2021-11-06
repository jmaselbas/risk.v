module cpu_test;
   reg clk, rst;

   cpu test_cpu (rst, clk);

   initial begin
      $dumpfile("cpu.vcd");
      $dumpvars(0, test_cpu);
   end

   initial begin
      rst = 1'b1;
      clk = 1'b0;
      #4;
      rst = 1'b0;
      #100;
      $finish;
   end
   always begin
      #1;
      clk = ~clk;
   end

endmodule
