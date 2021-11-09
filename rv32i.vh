`define OP_ALU    5'b01100
`define OP_ALUIMM 5'b00100
`define OP_LUI    5'b01101
`define OP_AUIPC  5'b00101
`define OP_JAL    5'b11011
`define OP_JALR   5'b11001
`define OP_BRANCH 5'b11000
`define OP_LOAD   5'b00000
`define OP_STORE  5'b01000
`define OP_MISC   5'b00011
`define OP_SYSTEM 5'b11100

/* pseudo decoded alu opcode {funct7[5],funct3} */
`define ALU_ADD  4'b0000
`define ALU_SUB  4'b1000
`define ALU_SLL  4'b0001
`define ALU_SLT  4'b0010
`define ALU_SLTU 4'b0011
`define ALU_XOR  4'b0100
`define ALU_SRL  4'b0101
`define ALU_SRA  4'b1101
`define ALU_OR   4'b0110
`define ALU_AND  4'b0111
/* MAU is selected with funct7[0] == 1 */
`define F_MULDIV   7'b0000001
`define MAU_MUL    3'b000
`define MAU_MULH   3'b001
`define MAU_MULHSU 3'b010
`define MAU_MULHU  3'b011
`define MAU_DIV    3'b100
`define MAU_DIVU   3'b101
`define MAU_REM    3'b110
`define MAU_REMU   3'b111

/* encoding for comparison from funct3 */
`define COMP_BEQ  3'b000
`define COMP_BNE  3'b001
`define COMP_BLT  3'b100
`define COMP_BGE  3'b101
`define COMP_BLTU 3'b110
`define COMP_BGEU 3'b111
`define BCU_DISABLE 3'b010
`define BCU_TAKEN   3'b011

/* encoding for load/store from funct3 */
`define LSU_LB  3'b000
`define LSU_LH  3'b001
`define LSU_LW  3'b010
`define LSU_LBU 3'b100
`define LSU_LHU 3'b101
`define LSU_SB  3'b000
`define LSU_SH  3'b001
`define LSU_SW  3'b010
