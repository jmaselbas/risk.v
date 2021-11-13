.global _start
_start:
	nop
	call test_sb
	call test_sra
	call end
	mv x7, x0
loop:
	beq x7, x8, done
	lw x6, 0(x7)
	sw x6, 64(x7)
	lw x6, 64(x7)
	addi x7, x7, 4
	j loop
done:
	j _start
test_sb:
	li x7, 0x41
	sb x7, 128(x0)
	ret
test_sra:
	li x8, -1
	srai x9, x8, 16 /* SRA do sign extension */
	bne x9, x8, fail /* x9 must equal x8 */
	ret
end:
	auipc x8, 4
	ret
fail:
	ebreak
	j fail
