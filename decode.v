 `include "rv32i.vh"

module decode(insn, opcode, funct7, funct3, invalid, rd, rs1, rs2, imm);
input [31:0] insn;
output [4:0] opcode;
output [6:0] funct7;
output [2:0] funct3;
output 	     invalid;
output [4:0] rd;
output [4:0] rs1;
output [4:0] rs2;
output [31:0] imm;

assign invalid = insn[1:0] != 2'b11;
assign opcode = insn[6:2];
assign funct7 = insn[31:25];
assign funct3 = insn[14:12];
assign rd = insn[11:7];
assign rs1 = insn[19:15];
assign rs2 = insn[24:20];

wire [31:0]   imm_i;
wire [31:0]   imm_s;
wire [31:0]   imm_b;
wire [31:0]   imm_u;
wire [31:0]   imm_j;
assign imm_i = {{21{insn[31]}},insn[30:25],insn[24:21],insn[20]};
assign imm_s = {{21{insn[31]}},insn[30:25],insn[11:8],insn[7]};
assign imm_b = {{20{insn[31]}},insn[7],insn[30:25],insn[11:8],1'b0};
assign imm_u = {insn[31],insn[30:20],insn[19:12],12'b0};
assign imm_j = {{16{insn[31]}},insn[19:12],insn[30:25],insn[24:21],1'b0};

assign imm = (opcode == `OP_LUI)    ? imm_u :
	     (opcode == `OP_AUIPC)  ? imm_u :
	     (opcode == `OP_JAL)    ? imm_j :
	     (opcode == `OP_JALR)   ? imm_i :
	     (opcode == `OP_BRANCH) ? imm_b :
	     (opcode == `OP_LOAD)   ? imm_i :
	     (opcode == `OP_STORE)  ? imm_s :
	     (opcode == `OP_ALUIMM) ? imm_i :
	     32'b0;

endmodule
