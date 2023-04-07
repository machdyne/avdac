/*
 * AVDAC DEMO
 * Copyright (c) 2023 Lone Dynamics Corporation. All rights reserved.
 *
 * Expects 48KHz 16-bit (LE) signed PCM stereo audio in SPI flash @ 0x000000.
 *
 * TODO: composite video output example
 *
 */

module avdac
(

	input CLK_48,

	output SPI_SS_FLASH,
	input SPI_MISO,
	output SPI_MOSI,
`ifndef ECP5
	output SPI_SCK,
`endif

	output AUD_BCK,
	output AUD_WS,
	output AUD_DIN,

	output VID_D0,
	output VID_D1,
	output VID_D2,
	output VID_D3,
	output VID_D4,

);

	localparam FLASH_AUDIO_ADDR = 24'h000000;
	localparam FLASH_AUDIO_SIZE = 24'h0ea600;

`ifdef ECP5
	wire SPI_SCK;
	USRMCLK usrmclk_i (.USRMCLKI(SPI_SCK), .USRMCLKTS(1'b0));
`endif

	// clocks

	wire clk = CLK_48;
	wire clk153_6;
	wire pll_locked;

   pll #() pll_i
   (
      .clkin(clk),
      .clkout0(clk153_6),
      .locked(pll_locked),
   );

	// reset generator

   reg [11:0] resetn_counter = 0;
   wire resetn = &resetn_counter;

   always @(posedge clk) begin
      if (!pll_locked)
         resetn_counter <= 0;
      else if (!resetn)
         resetn_counter <= resetn_counter + 1;
   end

	// flash reader

	reg [23:0] flash_addr;
	reg [31:0] flash_data;

	wire flash_ready;

	spiflashro #() flash_i (
		.clk(clk),
		.resetn(resetn),
		.valid(1'b1),
		.ready(flash_ready),
		.addr(flash_addr),
		.rdata(flash_data),
		.ss(SPI_SS_FLASH),
		.sck(SPI_SCK),
		.mosi(SPI_MOSI),
		.miso(SPI_MISO)
	);

	reg [23:0] audio_addr;
	reg [31:0] audio_data;

	always @(posedge clk) begin

		flash_addr <= audio_addr;

		if (flash_ready) begin
			audio_data <= flash_data;
		end

	end

	// generate audio & flash clock

	reg clk_audio;	// 1.536MHz
	reg [9:0] clk_audio_ctr;

	always @(posedge clk153_6) begin

		if (!resetn) begin

			clk_audio_ctr <= 0;

		end else begin

			clk_audio_ctr <= clk_audio_ctr + 1;

			if (clk_audio_ctr == 49) begin
				clk_audio_ctr <= 0;
				clk_audio <= ~clk_audio;
			end

		end

	end

	reg ws;
	reg [4:0] seq;
	reg [3:0] idx;

	reg [15:0] data;
	reg [15:0] data_l;
	reg [15:0] data_r;

	// 1.536MHz / 32 samples = 48KHz
	always @(negedge clk_audio) begin

		if (!resetn) begin

			audio_addr <= FLASH_AUDIO_ADDR;
			data <= 0;
			seq <= 0;
			idx <= 0;
			ws <= 0;

		end else begin

			if (seq == 31) begin

				data_l <= audio_data[31:16];
				data_r <= audio_data[15:0];

				if (audio_addr >= FLASH_AUDIO_ADDR + FLASH_AUDIO_SIZE) begin
					audio_addr <= FLASH_AUDIO_ADDR;
				end else begin
					audio_addr <= audio_addr + 4;
				end

			end

			if (idx == 0) begin
				if (ws) data <= data_r; else data <= data_l;
				ws <= ~ws;
			end

			idx <= idx - 1;
			seq <= seq + 1;

		end

	end

	assign AUD_DIN = data[idx];
	assign AUD_BCK = clk_audio;
	assign AUD_WS = ws;

endmodule
