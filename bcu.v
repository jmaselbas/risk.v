module bcu(rst, clk, comp_type, comp_reg1, comp_reg2, branch_taken); 
input rst, clk;
input [2:0] comp_type;
input [31:0] comp_reg1;
input [31:0] comp_reg2;
output reg branch_taken;

`include "rv32i.vh"

always @(posedge clk) begin
	if (rst) begin
		branch_taken <= 0;
	end else begin
		case (comp_type)
			`COMP_BEQ:
				branch_taken <= comp_reg1 == comp_reg2;
			`COMP_BNE:
				branch_taken <= comp_reg1 != comp_reg2;
			`COMP_BLT:
				branch_taken <= $signed(comp_reg1) < $signed(comp_reg2);
			`COMP_BGE:
				branch_taken <= $signed(comp_reg1) > $signed(comp_reg2);
			`COMP_BLTU:
				branch_taken <= comp_reg1 < comp_reg2;
			`COMP_BGEU:
				branch_taken <= comp_reg1 > comp_reg2;
				
		default:
			branch_taken <= 0;
		endcase
	end
end

endmodule
