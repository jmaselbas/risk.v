module decode(insn, opcode, funct3, funct7, invalid, rd, rs1, rs2);
   input [31:0] insn;
   output [4:0] opcode;
   output [2:0] funct3;
   output [6:0] funct7;
   output 	invalid;
   output [4:0] rd;
   output [4:0] rs1;
   output [4:0] rs2;

   assign invalid = insn[1:0] != 2'b11;
   assign opcode = insn[6:2];
   assign funct3 = insn[14:12];
   assign funct7 = insn[31:25];

   assign rd = insn[11:7];
   assign rs1 = insn[19:15];
   assign rs2 = insn[24:20];

endmodule

