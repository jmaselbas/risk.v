module rom(
	   input 	 clk,
	   input 	 rst,
	   input [6:0] 	 addr,
	   output [31:0] data_o
	   );

reg [31:0] memory [0:127];
reg [31:0] data_r;

assign data_o = data_r;

initial begin
	$readmemh("romcode.hex", memory);
end

always @(posedge clk) begin
	if (rst) begin
		data_r <= 0;
	end else begin
		data_r <= memory[addr];
	end
end

endmodule
