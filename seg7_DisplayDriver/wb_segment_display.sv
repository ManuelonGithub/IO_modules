/*
 *	file: wb_segment_display.sv
 *	author: Manuel Burnay
 *	Last Modified: 2020.02.08
 */


/*
 * 	This module controls a common-anode configuration seven segment display.
 * 	It contains a simple state machine that cycles each display 
 *	and configures the output to match the designated display.
 *	
 * 	The cathode signals is the disp_o.
 * 	The signal is ordered from low to high cathode.
 * 	So disp_o[0] <-> segA
 *	   disp_o[1] <-> segB
 *	   ...
 *	   disp_0[6] <-> segG
 *
 * 	This particular module has been designed to be wishbone compliant.
 * 	Currently it's only *mostly* wishbone compliant, as it doesn't take in an address input.
 * 	This was because it was implemented in a system that had a "chip-select" style bus arbiter,
 * 	and because it only has one register the address line was unneccessary.
 * 	The address decoding will be transfered to this module and the address line will be implemented,
 * 	so this module is fully wishbone compliant.
 *
 *	todo: 	Implement address decoding & parameter that indicates the module's address
 *	todo: 	Implement control register to enable configuration of which displays are enabled,
 *			interrupts, and other "cool" stuff.
 */
module wb_segment_display 
#(
	parameter WORD = 16,	// Specicies system's word size.
	parameter DISPLAYS = 4	// Specifies how many displays this module is driving.
 )
(
	input wire clk_i, rst_i,

	input wire stb_i, cyc_i, we_i,
	input wire[WORD/8-1:0] sel_i,
	input wire[WORD-1:0] dat_i,

	output reg ack_o,
	output reg[WORD-1:0] dat_o,

	output reg[DISPLAYS-1:0] dispSel_o,
	output reg[6:0] disp_o
);

localparam BYTE = 8;
localparam WORD_GL = (WORD/BYTE);    // Word Granularity level (# of bytes in the word)
localparam NIBBLE = 4;

wire en = (stb_i & cyc_i);

reg[WORD-1:0] dispReg;
reg[3:0] dispData[DISPLAYS];

reg[$clog2(DISPLAYS)-1:0] dispCycle;

// Display driver Rom.
// Handles Hex to 7-segment signal driving.
// Just like most configurations, a '1' means that segment is off.
reg[6:0] dispROM[NIBBLE**2] = {
	7'b1000000,
	7'b1111001,
	7'b0100100,
	7'b0110000,
	7'b0011001,
	7'b0010010,
	7'b0000010,
	7'b1111000,
	7'b0000000,
	7'b0011000,
	7'b0001000,
	7'b0000011,
	7'b1000110,
	7'b0100001,
	7'b0000110,
	7'b0001110
};

// Initializes display cycle register and data register.
initial begin
	dispCycle = 0;
	dispReg = 16'hABCD;
end

// Asynchronous signals and components' behaviour
always @ (*) begin
	ack_o <= en;
	dat_o <= dispReg;

	// Split the data input into distinct nibbles.
	// Each nibble contains the data for a single display
	for (int i = 0; i < DISPLAYS; i = i + 1) begin
		dispData[i] <= dispReg[i*NIBBLE +: NIBBLE];
	end

	// Display selection.
	// '0' means that display is on.
	dispSel_o <= 4'b1111;
	dispSel_o[dispCycle] <= 0;

	// Drive output with the display ROM output,
	// whose input address is the nibble pertaining
	// the current display being driven.
	disp_o <= dispROM[dispData[dispCycle]];
end

// Synchronous components' behaviour.
// Not quite sure if having the module read the bus on a negative make it non-compliant.
// Gotta look into that...
// Module has a synchronous reset to make it wishbone-compliant.
always @ (negedge clk_i) begin
    if (rst_i) begin
        dispCycle <= 0;
        dispReg <= 0;
    end
    else begin
        dispCycle++;
        
        if (en & we_i)
            for (int i = 0; i < WORD_GL; i++) begin
                if (sel_i[i])    
                    dispReg[BYTE*i +: BYTE] <= dat_i[BYTE*i +: BYTE];	// Byte-addressable write.
            end
    end
end
endmodule