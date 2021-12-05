module top (input clk48,

	    output rgb_led0_r,
	    output rgb_led0_g,
	    output rgb_led0_b,

	    output rst_n,
	    input  usr_btn
);

reg [31:0] led_reg = 0;
assign rgb_led0_r = ~led_reg[20];
assign rgb_led0_g = ~led_reg[21];
assign rgb_led0_b = ~led_reg[22];

reg rst = 1;
reg btn = 0;
reg btn_n = 1;
always @(posedge clk48) begin
	btn <= usr_btn;
end
always @(posedge clk48) begin
	btn_n <= ~btn;
	rst <= btn_n;
	if (rst) begin
		led_reg <= 0;
	end else if (mem_d_rstrb) begin
		led_reg <= led_reg + 1;
	end
end

wire [31:0] rst_vector = 0;

wire [31:0] mem_i_addr;
wire        mem_i_rstrb;
wire [31:0] mem_i_rdata;
wire        mem_i_rbusy;
reg [31:0]  mem_i_wdata;
reg [3:0]   mem_i_wmask;
reg 	    mem_i_wstrb;
wire 	    mem_i_wbusy;
initial begin
	mem_i_wdata <= 0;
	mem_i_wmask <= 0;
        mem_i_wstrb <= 0;
end

wire [31:0] mem_d_addr;
wire [31:0] mem_d_wdata;
wire [3:0]  mem_d_wmask;
wire        mem_d_wstrb;
wire        mem_d_rstrb;
wire [31:0] mem_d_rdata;
wire        mem_d_rbusy;
wire        mem_d_wbusy;

rv32i cpu(rst, clk48,
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

ram rom(rst, clk48,
	mem_i_addr,
	mem_i_wmask,
	mem_i_rstrb,
	mem_i_wstrb,
	mem_i_rdata,
	mem_i_wdata,
	mem_i_rbusy,
	mem_i_wbusy);
ram ram(rst, clk48,
	mem_d_addr,
	mem_d_wmask,
	mem_d_rstrb,
	mem_d_wstrb,
	mem_d_rdata,
	mem_d_wdata,
	mem_d_rbusy,
	mem_d_wbusy);

endmodule
