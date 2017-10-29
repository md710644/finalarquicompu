
 module Peripheral
#(
	parameter WORD_LENGTH = 8
)

(
	// Input Ports
	input clk,
	input reset,
	input [WORD_LENGTH-1 : 0] iBus,
	// Output Ports
	output [WORD_LENGTH-1 : 0] oBus
);



endmodule