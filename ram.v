module ram(
input		rst,
input		clk,
input [31:0]	addr,
input [3:0]	wmask,
input		rstrb,
input		wstrb,
output [31:0]	rdata,
input [31:0]	wdata,
output		rbusy,
output		wbusy
);

reg [31:0] mem [0:127];
wire [6:0] ram_addr;
assign ram_addr = addr[8:2];

reg [31:0] data_r;
assign rdata = data_r;

reg rbusy_r;
reg wbusy_r;
assign rbusy = rbusy_r;
assign wbusy = wbusy_r;

initial begin
	$readmemh("romcode.hex", mem);
end

always @(posedge clk) begin
	if (rst) begin
		data_r <= 0;
		rbusy_r <= 1;
		wbusy_r <= 1;
	end else begin
		rbusy_r <= !rstrb;
		if (rstrb) begin
			data_r <= mem[ram_addr];
		end
		wbusy_r <= !wstrb;
		if (wstrb) begin
			if (wmask[0]) mem[ram_addr][7:0]   <= wdata[7:0];
			if (wmask[1]) mem[ram_addr][15:8]  <= wdata[15:8];
			if (wmask[2]) mem[ram_addr][23:16] <= wdata[23:16];
			if (wmask[3]) mem[ram_addr][31:24] <= wdata[31:24];
		end
	end
end

endmodule
