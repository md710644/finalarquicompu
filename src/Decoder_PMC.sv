
 module Decoder_PMC

(
	// Input Ports
	
	input iRxFlag,
	input [95 : 0] iMsg,
	input reset,
	
	// Output Ports
	
	output reg [23 : 0] oAddr,
	output reg [31 : 0] oData,
	output reg oError,
	output reg oReq_EXT,
	output reg oWrite,
	output reg oRead
				
);


always @ ( iRxFlag or negedge reset) begin


		if (reset == 0 || iRxFlag == 0) begin
		
			oError = 0 ;
			oReq_EXT = 0;
			oAddr = 0;
			oData = 0;
			oWrite = 0;
			oRead = 0;	
			end	
		
		else begin
			/*

	start byte 0x0F 1B
	input [15 : 0] iInstruction, 2B
	input [23 : 0] iAddr, 3B
	input [31 : 0] iData, 4B
	
	Header equals to from peripheral

read: 0x0001
write 0x0002
	
	
		Start 1B | Header 2B | Data payload 7B | Error 1B| END 1B
	
			*/	
		
			
			oError = |iMsg[15 : 8] ;
			oReq_EXT = 1'b1;
			oAddr = iMsg[39 : 16];
			oData = iMsg[71 : 40];
			oWrite = (iMsg[87 : 72] == 16'h0002) ? 1'b1 : 1'b0;
			oRead = (iMsg[87 : 72] == 16'h0001) ? 1'b1 : 1'b0;
		end

end//end always


endmodule
