module decode(insn, opcode, alu_op, invalid, rd, rs1, rs2, imm);
input [31:0] insn;
output [4:0] opcode;
output [3:0] alu_op;
output 	     invalid;
output [4:0] rd;
output [4:0] rs1;
output [4:0] rs2;
output [31:0] imm;

assign invalid = insn[1:0] != 2'b11;
assign opcode = insn[6:2];

assign alu_op = (opcode == 5'b01100) ? {insn[30],insn[14:12]}:
		{1'b0,insn[14:12]};

assign rd = insn[11:7];
assign rs1 = insn[19:15];
assign rs2 = insn[24:20];

wire [31:0]   imm_i;
wire [31:0]   imm_s;
wire [31:0]   imm_b;
wire [31:0]   imm_u;
wire [31:0]   imm_j;
assign imm_i = {{20{insn[31]}},insn[30:25],insn[24:21],insn[20]};
assign imm_s = {{20{insn[31]}},insn[30:25],insn[11:8],insn[7]};
assign imm_b = {{19{insn[31]}},insn[7],insn[30:25],insn[11:8],1'b0};
assign imm_u = {insn[31],insn[30:20],insn[19:12],12'b0};
assign imm_j = {{16{insn[31]}},insn[19:12],insn[30:25],insn[24:21],1'b0};

assign imm = (opcode == 5'b01101) ? imm_u : /* LUI */
	     (opcode == 5'b00101) ? imm_u : /* AUIPC */
	     (opcode == 5'b11011) ? imm_j : /* JAL */
	     (opcode == 5'b11001) ? imm_i : /* JALR */
	     (opcode == 5'b11000) ? imm_b : /* BRANCH */
	     (opcode == 5'b00000) ? imm_i : /* LOAD */
	     (opcode == 5'b10000) ? imm_s : /* STORE */
	     (opcode == 5'b00100) ? imm_i : /* ALU OP */
	     32'b0;

endmodule
