module cpu(rst, clk);
   input rst, clk;

   reg rden, wren;

   wire [31:0] out;

   /* fetch output */
   wire [31:0] data_o;

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
   reg [6:0] fetch_addr;
   wire [31:0] fetch_insn;
   reg [31:0] pc;

   reg [31:0]  wb_val;

   parameter IDLE = 0;
   parameter FETCH = 1;
   parameter DECODE = 2;
   parameter SELECT = 3;
   parameter EXECUTE = 4;
   parameter WRITE_BACK = 5;

   decode decode(data_o, opcode, alu_op, invalid, d_rd, d_rs1, d_rs2, d_imm);
   regfile regfile(rst, clk, wren, rden, d_rd, d_rs1, d_rs2, wb_val, d_reg1, d_reg2);
   alu alu(rst, clk, d_alu_op, d_val1, d_val2, x_out);
   rom rom(clk, rst, fetch_addr, data_o);

   reg [2:0]   state;
   always @(posedge clk) begin
      if (rst) begin
	 rden <= 0;
	 wren <= 0;
	 state <= IDLE;
	 pc <= 0;
	 fetch_addr <= 0;
	 d_val1 <= 0;
	 d_val2 <= 0;
	 d_opcode <= 0;
	 d_alu_op <= 0;
	 wb_val <= 0;
      end else begin
	 case (state)
	   IDLE: begin
	      wren <= 0;
	      rden <= 0;
	      fetch_addr <= pc[8:2];
	      state <= FETCH;
	   end
	   FETCH: begin
	      rden <= 1;
	      state <= DECODE;
	   end
	   DECODE: begin
	      rden <= 0;
	      d_opcode <= opcode;
	      d_alu_op <= alu_op;
	      state <= SELECT;
	   end
	   SELECT: begin
	      d_val1 <= d_reg1;
	      if (opcode == 5'b00100) begin
		 d_val2 <= d_imm;
	      end else if (opcode == 5'b01100) begin
		 d_val2 <= d_reg2;
	      end else begin
		 d_val2 <= 0;
	      end
	      state <= EXECUTE;
	   end
	   EXECUTE: begin
	      state <= WRITE_BACK;
	   end
	   WRITE_BACK: begin
	      wren <= 1;
	      if (d_opcode == 5'b11011) begin
		 pc <= pc + d_imm;
		 wb_val <= pc + 4;
	      end else begin
		 pc <= pc + 4;
		 wb_val <= x_out;
	      end
	      state <= IDLE;
	   end
	 endcase
      end
   end
endmodule
