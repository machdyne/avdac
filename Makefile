RTL=rtl/avdac.v rtl/spiflashro32.v rtl/pll.v

avdac_schoko:
	mkdir -p output
	yosys -DECP5 -q -p "synth_ecp5 -top avdac -json output/avdac.json" $(RTL)
	nextpnr-ecp5 --45k --package CABGA256 --lpf boards/schoko.lpf --json output/avdac.json --textcfg output/avdac_out.config
	ecppack -v --compress --freq 2.4 output/avdac_out.config --bit output/avdac.bit

avdac_riegel:
	mkdir -p output
	yosys -q -p "synth_ice40 -top avdac -json output/avdac.json" $(RTL)
	nextpnr-ice40 --hx4k --package bg121 --pcf boards/riegel.pcf \
		--asc output/avdac.txt --json output/avdac.json
	icebox_explain output/avdac.txt > output/avdac.ex
	icetime -d u4k -c 24 -mtr output/avdac.rpt output/avdac.txt
	icepack output/avdac.txt output/avdac.bin

prog_schoko:
	openFPGALoader -c usb-blaster output/avdac.bit

prog_riegel:
	ldprog -s output/avdac.bin

gen_sine:
	ffmpeg -f lavfi -i "sine=frequency=1000:duration=5" -ac 2 -ar 48000 -f s16le -c:a pcm_s16le sine.pcm

clean:
	rm -f output/*
