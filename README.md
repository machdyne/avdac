# AVDAC Pmod&trade; compatible module

AVDAC is a 12-pin Pmod™ compatible module with a 16-bit stereo audio DAC and a 5-bit video DAC.

![AVDAC](https://github.com/machdyne/AVDAC/blob/388016643eea4f7693c8ceec7313cb7d4b44f4a2/avdac.png)

This repo contains schematics, pinouts and example gateware.

## Verilog Demo

The demo plays a loop of 5 seconds of 48KHz 16-bit (LE) signed PCM stereo audio from flash memory.

An example of video output will be added soon, in the meantime please see the resources section below.

Building the example requires [Yosys](https://github.com/YosysHQ/yosys), [nextpnr-ice40](https://github.com/YosysHQ/nextpnr) and [IceStorm](https://github.com/YosysHQ/icestorm).

Assuming they are installed, you can simply type `make` to build the gateware, which will be written to output/avdac.bin. This example targets the Schoko and Riegel FPGA boards but can be easily adapted to other FPGA boards with a 12-pin PMOD connector.

## Resources

 * [NTSC-FPGA](https://github.com/uXeBoy/NTSC-FPGA)
 * [up5k_basic](https://github.com/emeb/up5k_basic)

## Pinout

| Signal | Pin |
| ------ | --- |
| AUD\_DIN | 1 |
| AUD\_WS | 2 |
| AUD\_BCK | 3 |
| VID\_D0 | 4 |
| GND | 5 |
| 3V3 | 6 |
| VID\_D1 | 7 |
| VID\_D2 | 8 |
| VID\_D3 | 9 |
| VID\_D4 | 10 |
| GND | 11 |
| 3V3 | 12 |
