module decode(insn, opcode, alu_op, invalid, rd, rs1, rs2);
   input [31:0] insn;
   output [4:0] opcode;
   output [3:0] alu_op;
   output 	invalid;
   output [4:0] rd;
   output [4:0] rs1;
   output [4:0] rs2;

   assign invalid = insn[1:0] != 2'b11;
   assign opcode = insn[6:2];

   assign alu_op = (opcode == 5'b01100) ? {insn[30],insn[14:12]}:
		   {1'b0,insn[14:12]};

   assign rd = insn[11:7];
   assign rs1 = insn[19:15];
   assign rs2 = insn[24:20];

endmodule

