module cpu(rst, clk);
   input rst, clk;

   reg rden, wren;

   reg [31:0]  ninsn;
   wire [31:0] out;

   /* decode output */
   wire [4:0]  opcode;
   wire [3:0]   alu_op;
   wire        invalid;
   wire [4:0]  d_rs1, d_rs2, d_rd;
   wire [31:0] d_reg1, d_reg2, d_imm;
   reg [31:0]  d_val1, d_val2;
   reg [4:0]   d_opcode;
   reg [3:0]   d_alu_op;

   /* execute output */
   wire [31:0] x_out;
   reg [31:0]  x_val;
   reg [6:0] fetch_addr;
   wire [31:0] fetch_insn;
   reg [31:0] pc;
   wire [31:0] data_o;

   parameter IDLE = 0;
   parameter FETCH = 1;
   parameter DECODE = 2;
   parameter EXECUTE = 3;
   parameter WRITE_BACK = 4;

   decode decode(ninsn, opcode, alu_op, invalid, d_rd, d_rs1, d_rs2, d_imm);
   regfile regfile(rst, clk, wren, rden, d_rd, d_rs1, d_rs2, x_out, d_reg1, d_reg2);
   alu alu(rst, clk, d_alu_op, d_val1, d_val2, x_out);
   rom rom(clk, rst, fetch_addr, data_o);

   reg [2:0]   state;
   always @(posedge clk) begin
      if (rst) begin
	 state <= 0;
         pc <= 0;
         fetch_addr <= 0;
      end else begin
	 case (state)
	   IDLE: begin
	      wren <= 0;
	      rden <= 1;
              fetch_addr <= pc[8:2];
	      state <= FETCH;
	   end
	   FETCH: begin
              ninsn <= data_o;
	      state <= DECODE;
	   end
	   DECODE: begin
	      d_opcode <= opcode;
	      d_alu_op <= alu_op;
	      d_val1 <= d_reg1;
	      if (opcode == 5'b00100) begin
		 d_val2 <= d_imm;
	      end else if (opcode == 5'b01100) begin
		 d_val2 <= d_reg2;
	      end
	      state <= EXECUTE;
	   end
	   EXECUTE: begin
	      x_val <= x_out;
	      state <= WRITE_BACK;
	   end
	   WRITE_BACK: begin
	      wren <= 1;
	      state <= IDLE;
	      pc <= pc + 4;
	   end
	 endcase
      end
   end
endmodule
