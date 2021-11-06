module cpu(rst, clk);
   input rst, clk;

   reg rden, wren;

   reg [31:0]  ninsn;
   wire [31:0] out;

   /* decode output */
   wire [4:0]  opcode;
   wire [2:0]  funct3;
   wire [6:0]  funct7;
   wire        invalid;
   wire [4:0]  d_rs1, d_rs2, d_rd;
   wire [31:0] d_val1, d_val2;
   reg [4:0]   d_opcode;
   reg [2:0]   d_funct3;
   reg [6:0]   d_funct7;

   /* execute output */
   wire [31:0] x_out;
   reg [31:0]  x_val;

   parameter IDLE = 0;
   parameter FETCH = 1;
   parameter DECODE = 2;
   parameter EXECUTE = 3;
   parameter WRITE_BACK = 4;

   decode decode(ninsn, opcode, funct3, funct7, invalid, d_rd, d_rs1, d_rs2);
   regfile regfile(rst, clk, wren, rden, d_rd, d_rs1, d_rs2, x_out, d_val1, d_val2);
   alu alu(rst, clk, d_opcode, d_funct3, d_funct7, d_val1, d_val2, x_out);

   reg [2:0]   state;
   always @(posedge clk) begin
      if (rst == 1'b1) begin
	 state <= 0;
      end else begin
	 case (state)
	   IDLE: begin
	      wren <= 0;
	      rden <= 1;
	      state <= FETCH;
	   end
	   FETCH: begin
	      /* add r0 <- r0 + r1 */
	      ninsn <= 32'b0000000_00000_00001_000_00000_0110011;
	      state <= DECODE;
	   end
	   DECODE: begin
	      d_opcode <= opcode;
	      d_funct3 <= funct3;
	      d_funct7 <= funct7;
	      state <= EXECUTE;
	   end
	   EXECUTE: begin
	      x_val <= x_out;
	      state <= WRITE_BACK;
	   end
	   WRITE_BACK: begin
	      wren <= 1;
	      state <= IDLE;
	   end
	 endcase
      end
   end
endmodule
