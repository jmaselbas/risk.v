#!/bin/bash
set -e

tests=(rv32ui-p-add rv32ui-p-addi rv32ui-p-and rv32ui-p-andi rv32ui-p-auipc rv32ui-p-beq rv32ui-p-bge rv32ui-p-bgeu rv32ui-p-blt rv32ui-p-bltu rv32ui-p-bne rv32ui-p-jal rv32ui-p-jalr rv32ui-p-lb rv32ui-p-lbu rv32ui-p-lh rv32ui-p-lhu rv32ui-p-lui rv32ui-p-lw rv32ui-p-or rv32ui-p-ori rv32ui-p-sb rv32ui-p-sh rv32ui-p-simple rv32ui-p-sll rv32ui-p-slli rv32ui-p-slt rv32ui-p-slti rv32ui-p-sltiu rv32ui-p-sltu rv32ui-p-sra rv32ui-p-srai rv32ui-p-srl rv32ui-p-srli rv32ui-p-sub rv32ui-p-sw  rv32ui-p-xor rv32ui-p-xori rv32ui-p-fence_i)

function show_failing_test() {
	echo "test $CURRENT_TEST failed"
	cat $CURRENT_TEST.out
}

trap show_failing_test ERR

for test in ${tests[@]}; do
	CURRENT_TEST=$test
	cp $test $test.elf
	echo "Running $test "
	make runtest TESTFILE=$test > $test.out
	grep "test succeeded" $test.out > /dev/null
	echo "Ok."
done
