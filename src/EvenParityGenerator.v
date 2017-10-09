module EvenParityGenerator
#(
	parameter WORD_LENGTH = 8
)

(
	// Input Ports
	input [ WORD_LENGTH - 1 : 0] iData,
	
	// Output Ports
	output  [ WORD_LENGTH + 1 : 0] oDataWithEvenParity

);


reg rParityBit;
reg  [ WORD_LENGTH + 1 : 0] rDataWithEvenParity;


always @(iData) begin
	
	rParityBit = ^iData;
	rDataWithEvenParity = {1'b0, iData, rParityBit};
end


assign oDataWithEvenParity = rDataWithEvenParity;

endmodule
