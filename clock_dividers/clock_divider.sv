/*
 *	file: clock_divider.sv
 *	author: Manuel Burnay
 * 	Last Modified: 2020.02.08
 */


/*
 *	Simple mod-counter based block divider.
 *	Has input rate and output rate parameters,
 *	And as long as the input rate is perfectly divisible 
 * 	by half of the output rate, then the module will 
 * 	produce a perfect clock division.
 */
module clock_divider 
#(
	parameter INPUT_RATE = 100000000,
	parameter OUTPUT_RATE = 1000
 )
(
	input wire clk_i,
	output reg clk_o
);

reg[31:0] counter;

localparam DIV = INPUT_RATE/OUTPUT_RATE;
localparam HALF_CYCLE = DIV/2;

initial begin
	counter <= 0;
	clk_o 	<= 0;
end

generate 
	if (DIV == 1) begin
		always @ (*) begin
			clk_o <= clk_i;
		end
	end
	else begin
		always @ (posedge clk_i) begin
			if (counter == HALF_CYCLE-1) begin
				clk_o <= ~clk_o;
				counter <= 0;
			end
			else
				counter++;
		end
	end
endgenerate

endmodule