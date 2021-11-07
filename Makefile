CROSS_COMPILE?=riscv32-buildroot-linux-gnu-
ifneq ($(CROSS_COMPILE),)
CC=$(CROSS_COMPILE)gcc
OBJCOPY=$(CROSS_COMPILE)objcopy
endif

all: cpu.vcd

cpu.vcd: a.out
	./a.out

a.out: romcode.hex cpu.v cpu_t.v regfile.v rom.v alu.v decode.v bcu.v
	iverilog cpu.v cpu_t.v regfile.v rom.v alu.v decode.v bcu.v

%.elf: %.s
%.elf: %.S
	$(CC) -march=rv32i -mabi=ilp32 -nostdlib $^ -o $@

%.bin: %.elf
	$(OBJCOPY) -j .text -O binary $^ $@ && truncate -s %4 $@ && $(OBJCOPY) -I binary --reverse-bytes=4 $@

%.hex: %.bin
	xxd -c4 $< | sed 's/[0-9a-fA-F]\+: //; s/ //; s/\(........\).*/\1/' >$@

clean:
	rm -f *.elf *.bin *.hex a.out

.PHONY: all clean
.SECONDARY: romcode.elf romcode.bin
