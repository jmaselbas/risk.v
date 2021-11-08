.global _start
_start:
	nop
	mv x7, x0
	call end
loop:
	beq x7, x8, done
	lw x6, 0(x7)
	sw x6, 64(x7)
	lw x6, 64(x7)
	addi x7, x7, 4
	j loop
done:
	j _start
end:
	li x8, -1
	srai x9, x8, 16 /* SRA do sign extension */
	bne x9, x8, fail /* x9 must equal x8 */
	auipc x8, 4
	ret
fail:
	ebreak
	j fail
