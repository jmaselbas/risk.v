module cpu_test;
reg clk, rst;

wire [31:0] mem_i_addr;
wire        mem_i_rstrb;
wire [31:0] mem_i_rdata;
wire        mem_i_rbusy;
wire [31:0] mem_i_wdata = 0;
wire [3:0]  mem_i_wmask = 0;
wire        mem_i_wstrb = 0;
wire        mem_i_busy;

wire [31:0] mem_d_addr;
wire [31:0] mem_d_wdata;
wire [3:0]  mem_d_wmask;
wire        mem_d_wstrb;
wire        mem_d_rstrb;
wire [31:0] mem_d_rdata;
wire        mem_d_rbusy;
wire        mem_d_wbusy;

wire [31:0] rst_vector = 0;

rv32i cpu (rst, clk,
	   mem_i_addr,
	   mem_i_rstrb,
	   mem_i_rdata,
	   mem_i_rbusy,
	   mem_d_addr,
	   mem_d_wdata,
	   mem_d_wmask,
	   mem_d_wstrb,
	   mem_d_rstrb,
	   mem_d_rdata,
	   mem_d_rbusy,
	   mem_d_wbusy,
	   rst_vector
);

ram rom(rst, clk,
	mem_i_addr,
	mem_i_wmask,
	mem_i_rstrb,
	mem_i_wstrb,
	mem_i_rdata,
	mem_i_wdata,
	mem_i_rbusy,
	mem_i_wbusy);
ram ram(rst, clk,
	mem_d_addr,
	mem_d_wmask,
	mem_d_rstrb,
	mem_d_wstrb,
	mem_d_rdata,
	mem_d_wdata,
	mem_d_rbusy,
	mem_d_wbusy);

initial begin
	$dumpfile("cpu.vcd");
	$dumpvars(0, cpu);
end

initial begin
	rst = 1'b1;
	clk = 1'b0;
	#4;
	rst = 1'b0;
	#400;
	$finish;
end
always begin
	#1;
	clk = ~clk;
end
endmodule
