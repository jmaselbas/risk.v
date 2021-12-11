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
`define ALU_ANDN 4'b1111 /* Zbb v0.90 */

/* encoding for comparison from funct3 */
`define COMP_BEQ  3'b000
`define COMP_BNE  3'b001
`define COMP_BLT  3'b100
`define COMP_BGE  3'b101
`define COMP_BLTU 3'b110
`define COMP_BGEU 3'b111
`define BCU_TAKEN   3'b011
`define BCU_DISABLE 3'b010

/* encoding for load/store from funct3 */
`define LSU_LB  3'b000
`define LSU_LH  3'b001
`define LSU_LW  3'b010
`define LSU_LBU 3'b100
`define LSU_LHU 3'b101
`define LSU_SB  3'b000
`define LSU_SH  3'b001
`define LSU_SW  3'b010

/* Zicsr CSR instructions */
`define CSR_RW  3'b001
`define CSR_RS  3'b010
`define CSR_RC  3'b011
`define CSR_RWI 3'b101
`define CSR_RSI 3'b110
`define CSR_RCI 3'b111

`define CSR_FFLAGS    12'h001 /* floating-point accrued exceptions */
`define CSR_FRM       12'h002 /* floating-point dynamic rounding mode */
`define CSR_FCSR      12'h003 /* floating-point control and status register */

/* Hardware performance counter */
`define CSR_RDCYCLE    12'hc00 /* cycle counter */
`define CSR_RDTIME     12'hc01 /* timer */
`define CSR_RDINSTRET  12'hc02 /* instruction-retired counter */
`define CSR_RDCYCLEH   12'hc80 /* upper-32bits, rv32i only */
`define CSR_RDTIMEH    12'hc81 /* upper-32bits, rv32i only */
`define CSR_RDINSTRETH 12'hc82 /* upper-32bits, rv32i only */

/* N extension for Machine-Level CSR */
`define CSR_MVENDORID  12'hf11 /* vendor id */
`define CSR_MARCHID    12'hf12 /* architecture id */
`define CSR_MIMPID     12'hf13 /* implementation id */
`define CSR_MHARTID    12'hf14 /* hardware thread id */

`define CSR_MSTATUS    12'h300 /* machine status register */
`define CSR_MISA       12'h301 /* ISA and extensions */
`define CSR_MEDELEG    12'h302 /* machine exception delegation register */
`define CSR_MIDELEG    12'h303 /* machine interrupt delegation register */
`define CSR_MIE        12'h304 /* machine interrupt enable register */
`define CSR_MTVEC      12'h305 /* machine trap-handler base address */
`define CSR_MCOUNTEREN 12'h306 /* machine counter enable */

`define CSR_MSCRATCH   12'h340 /* machine scratch register for trap handlers */
`define CSR_MEPC       12'h341 /* machine exception program counter */
`define CSR_MCAUSE     12'h342 /* machine trap cause */
`define CSR_MTVAL      12'h343 /* machine bad address or instruction */
`define CSR_MIP        12'h344 /* machine interrupt pending */

/* N extension for User-Level Interrupts, v1.1 */
`define CSR_USTATUS    12'h000 /* user status register */
`define CSR_UIE        12'h004 /* user interrupt-enable register */
`define CSR_UTVEC      12'h005 /* user trap handler base addres */
`define CSR_USCRATCH   12'h040 /* scratch register for user trap handler */
`define CSR_UEPC       12'h041 /* user exception program counter */
`define CSR_UCAUSE     12'h042 /* user trap cause */
`define CSR_UTVAL      12'h043 /* user bad address or instruction */
`define CSR_UIP        12'h044 /* user interrupt pending */
