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

runtest: $(TESTFILE).hex $(TESTFILE)_data.hex
	cp $(TESTFILE).hex mem.init # ROM code (.text .rodata) starting @ 0x0
	cp $(TESTFILE)_data.hex mem_1.init # SRAM data (.data .bss) starting @ 0x01000000
	iverilog cpu.v gsd_orangecrab.v riskv_standard_wb.v decode.v -o litex
	./litex

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
	$(CC) -static -march=rv32i -mabi=ilp32 -nostdlib -T linker.ld $^ -o $@

%.bin: %.elf
	$(OBJCOPY) -O binary -j '.text.*' -j .text -j .rodata $^ $@ && truncate -s %4 $@ && $(OBJCOPY) -I binary --reverse-bytes=4 $@

%_data.hex: %
	$(OBJCOPY) -O binary -j .data -j .bss $^ $@.tmp || true > /dev/null 2>&1
	truncate -s %4 $@.tmp
	$(OBJCOPY) -I binary --reverse-bytes=4 $@.tmp || true > /dev/null 2>&1
	xxd -c4 -p $@.tmp $@

%.hex: %.bin
	xxd -c4 -p $< >$@

clean:
	rm -f *.elf *.bin *.hex a.out

.PHONY: all synth flash clean
.SECONDARY: romcode.elf romcode.bin
