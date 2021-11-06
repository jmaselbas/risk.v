CROSS_COMPILE?=riscv32-buildroot-linux-gnu-
ifneq ($(CROSS_COMPILE),)
CC=$(CROSS_COMPILE)gcc
OBJCOPY=$(CROSS_COMPILE)objcopy
endif

all: romcode.hex

%.elf: %.s
%.elf: %.S
	$(CC) -march=rv32i -mabi=ilp32 -nostdlib $^ -o $@

%.bin: %.elf
	$(OBJCOPY) -j .text -O binary $^ $@ && truncate -s %4 $@ && $(OBJCOPY) -I binary --reverse-bytes=4 $@

%.hex: %.bin
	xxd -c4 $< | sed 's/[0-9]\+: //; s/ //; s/\(........\).*/\1/' >$@

clean:
	rm -f romcode.hex

.PHONY: all clean
