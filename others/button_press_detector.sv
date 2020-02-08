/*
 *	file: button_press_detector.sv
 *	author: Manuel Burnay
 * 	Last Modified: 2020.02.08
 */


/*
 *	This module is a very simple state machine that detects a "high" state of a button,
 *	and once it does it'll assert press_o for a single clock cycle,
 * 	and afterwards it'll deassert it and will not assert it again until the button input
 * 	goes low for at least a clock cycle.
 */
module button_press_detector
#(
	parameter BUTTONS = 1	// How many buttons this module will handle
 )
(
	input wire clk_i,
	input wire[BUTTONS-1:0] button_i,

	output reg[BUTTONS-1:0] press_o
);

reg[BUTTONS-1:0] buttonLatch;

always @ (*) begin
	press_o <= ~buttonLatch & button_i;
end

always @ (posedge clk_i) begin
	buttonLatch <= button_i;
end

endmodule : button_press_detector