riscv32-buildroot-linux-gnu-gcc code.S -nostdlib -o romcode.elf
riscv32-buildroot-linux-gnu-objcopy -O binary --reverse-bytes=4 romcode.elf romcode.bin
xxd -c4 romcode.bin | sed 's/[0-9]\+: //; s/ //; s/\(........\).*/\1/' > romcode.hex
