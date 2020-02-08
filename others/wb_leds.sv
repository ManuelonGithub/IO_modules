/*
 *	file: wb_leds.sv
 *	author: Manuel Burnay
 * 	Last Modified: 2020.02.08
 */


/*
 *	Simple wishbone slave module.
 *	Contains a single register that is really just an output buffer.
 * 	.... Really not much to say about this fella.
 * 	todo: Implement address decoding & parameter that specifies the devices' address.
 */
module wb_leds 
#(
	parameter WORD = 16,	// Word size of the system
	parameter LEDS = WORD 	// Amount of leds being drivent by the module.
 )
(
	input wire clk_i, rst_i,

	input wire stb_i, cyc_i, we_i,
	input wire[WORD/8-1:0] sel_i,
	input wire[WORD-1:0] dat_i,

	output reg ack_o,
	output reg[WORD-1:0] dat_o, 
	output reg[LEDS-1:0] leds_o
);

localparam BYTE = 8;
localparam WORD_GL = (WORD/BYTE);    // Word Granularity level (# of bytes in the word)

assign leds_o = dat_o[LEDS-1:0];	// led output (technically different from dat_o)

wire en = stb_i & cyc_i;
wire wr_en = en & we_i;

assign ack_o = en;

integer wr_byte;

initial begin
	dat_o = -1;
end

// dat_o is used as the module's data register as well
always @ (negedge clk_i) begin
	if (rst_i)
		dat_o <= 0;
	else begin
		if (wr_en) begin
			for (wr_byte = 0; wr_byte < WORD_GL; wr_byte = wr_byte + 1) begin
                if (sel_i[wr_byte])    
                    dat_o[BYTE*wr_byte +: BYTE] <= dat_i[BYTE*wr_byte +: BYTE];
            end
		end
	end
end

endmodule