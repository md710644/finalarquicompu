module EvenParityCheck
#(
	parameter WORD_LENGTH = 10
)

(
	// Input Ports
	input [ WORD_LENGTH - 1 : 0] iData,
	input iEnable,

	
	// Output Ports
	output oParityError

);


reg rParityError;
reg rEvenParity;

always @(iData) begin

	rEvenParity = ^iData[WORD_LENGTH-2 : 1];

		if ( rEvenParity == iData[0]) 
			rParityError = 0;
		else 
			rParityError = 1;
	
	end //end always


assign oParityError = rParityError & iEnable;

endmodule
