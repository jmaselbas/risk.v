-include config.mk
ifneq ($(CROSS_COMPILE),)
CC=$(CROSS_COMPILE)gcc
OBJCOPY=$(CROSS_COMPILE)objcopy
endif

SRC=cpu.v ram.v decode.v

all: cpu.vcd

synth: top.bit

flash: top.dfu
	dfu-util -a 0 -D $^

cpu.vcd: a.out
	./a.out

a.out: romcode.hex cpu_t.v $(SRC)
	iverilog cpu_t.v $(SRC)

%.json: %.v $(SRC)
	yosys -p "synth_ecp5 -json $@" $^

PCF = orangecrab_r0.2.pcf
%_out.config: %.json
	nextpnr-ecp5 --json $< --textcfg $@ --85k --package CSFBGA285 --lpf $(PCF)

%.bit: %_out.config
	ecppack --compress --input $< --bit $@

%.dfu: %.bit
	cp -a $< $@
	dfu-suffix -v 1209 -p 5af0 -a $@

%.elf: %.s
%.elf: %.S
	$(CC) -march=rv32i -mabi=ilp32 -nostdlib $^ -o $@

%.bin: %.elf
	$(OBJCOPY) -j .text -O binary $^ $@ && truncate -s %4 $@ && $(OBJCOPY) -I binary --reverse-bytes=4 $@

%.hex: %.bin
	xxd -c4 $< | sed 's/[0-9a-fA-F]\+: //; s/ //; s/\(........\).*/\1/' >$@

clean:
	rm -f *.elf *.bin *.hex a.out

.PHONY: all synth flash clean
.SECONDARY: romcode.elf romcode.bin
