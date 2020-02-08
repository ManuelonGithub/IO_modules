/*
 *	file: segment_display.sv
 *	author: Manuel Burnay
 *	Last Modified: 2020.02.08
 */


/*
 * 	This module controls a common-anode configuration seven segment display.
 * 	It contains a simple state machine that cycles each display 
 *	and configures the output to match the designated display.
 *	
 * The cathode signals is the disp_o.
 * The signal is ordered from low to high cathode.
 * So disp_o[0] <-> segA
 *	  disp_o[1] <-> segB
 *	  ...
 *	  disp_0[6] <->	segG
 */
module segment_display 
#(
	parameter DISPLAYS = 4	// Number of displays the module is driving
 )
(
	input wire clk_i, rst_i,

	input wire en_i,
	input wire[(DISPLAYS*4)-1:0] dat_i,

	output reg[DISPLAYS-1:0] dispSel_o,
	output reg[6:0] disp_o
);

localparam NIBBLE = 4;

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

// Initialize display cycle register
initial begin
	dispCycle = 0;
end

// Asynchronous signals behaviour
always @ (*) begin
	// Split the data input into distinct nibbles.
	// Each nibble contains the data for a single display
	for (int i = 0; i < DISPLAYS; i = i + 1) begin
		dispData[i] <= dat_i[i*NIBBLE +: NIBBLE];
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

// Synchronous components behaviour.
// Here it's simply the display cycle register.
// The module comes with a normally-low asynchronous reset.
always @ (posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        dispCycle <= 0;
    end
    else begin
        dispCycle++;
    end
end

endmodule