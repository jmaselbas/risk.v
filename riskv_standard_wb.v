module Riskv (input clk,
	    input reset,
	    output [29:0] iBusWishbone_ADR,
	    output [3:0] iBusWishbone_SEL,
	    output iBusWishbone_CYC,
	    output iBusWishbone_STB,
	    input [31:0] iBusWishbone_DAT_MISO,
	    input iBusWishbone_ACK,
	    input iBusWishbone_ERR,

	    output [29:0] dBusWishbone_ADR,
	    output [31:0] dBusWishbone_DAT_MOSI,
	    output [3:0] dBusWishbone_SEL,
	    output dBusWishbone_CYC,
	    output dBusWishbone_STB,
	    output dBusWishbone_WE,
	    input [31:0] dBusWishbone_DAT_MISO,
	    input dBusWishbone_ACK,
	    input dBusWishbone_ERR,
	    input [31:0] externalResetVector
);

wire [31:0] mem_i_addr;
wire        mem_i_rstrb;
wire [31:0] mem_i_rdata;
wire        mem_i_rbusy;
wire [31:0]  mem_i_wdata;
wire [3:0]   mem_i_wmask;
wire 	    mem_i_wstrb;
wire 	    mem_i_wbusy;

wire [31:0] mem_d_addr;
wire [31:0] mem_d_wdata;
wire [3:0]  mem_d_wmask;
wire        mem_d_wstrb;
wire        mem_d_rstrb;
wire [31:0] mem_d_rdata;

reg dBusWishbone_STB;
reg dBusWishbone_WE;
reg mem_d_rbusy;
reg mem_d_wbusy;
reg [31:0] mem_d_rdata_reg;

/* Wishbone master interface for Insn Fetch */
assign mem_i_rbusy = iBusWishbone_CYC & iBusWishbone_STB & ~(iBusWishbone_ACK | iBusWishbone_ERR);
assign iBusWishbone_STB = iBusWishbone_CYC;
assign iBusWishbone_CYC = mem_i_rstrb;
assign mem_i_rdata = iBusWishbone_DAT_MISO;
assign iBusWishbone_ADR = mem_i_addr[31:2];
assign iBusWishbone_SEL = 4'b1111;

/* Wishbone master interface for Data load/store */
assign dBusWishbone_CYC = dBusWishbone_STB;
assign mem_d_rdata = mem_d_rdata_reg;
assign dBusWishbone_DAT_MOSI = mem_d_wdata;
assign dBusWishbone_SEL = mem_d_wmask;
assign dBusWishbone_ADR = mem_d_addr[31:2];

always @(posedge clk) begin
	if (mem_d_rstrb | mem_d_wstrb | dBusWishbone_STB) begin
		dBusWishbone_STB <= ~dBusWishbone_ACK;
		mem_d_rbusy <= ~dBusWishbone_ACK;
		mem_d_wbusy <= ~dBusWishbone_ACK;
		if (~dBusWishbone_WE && dBusWishbone_ACK)
			mem_d_rdata_reg <= dBusWishbone_DAT_MISO;
		if (mem_d_wstrb)
			dBusWishbone_WE <= 1;
		else if (dBusWishbone_WE)
			dBusWishbone_WE <= ~dBusWishbone_ACK;
	end else begin
		mem_d_rbusy <= 0;
		mem_d_wbusy <= 0;
		dBusWishbone_STB <= 0;
		dBusWishbone_WE <= 0;
	end
end

rv32i cpu(reset, clk,
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
	  externalResetVector);

endmodule
