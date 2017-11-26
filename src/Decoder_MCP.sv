
 module Decoder_MCP

(
	// Input Ports
	
	input iRxFlag,
	input [95 : 0] iMsg,
	input reset,
	
	// Output Ports
	
	output reg [31 : 0] oData,
	output reg oRetry,
	output reg oWait,
	output reg oReady
				
);


always @ ( iRxFlag or negedge reset) begin


		if (reset == 0 || iRxFlag == 0) begin
		
			oData = 0 ;
			oRetry = 0;
			oWait = 0;
			oReady = 0;
			
			end	
		
		else begin
			/*

	start byte 0x0F 1B
	input [15 : 0] iInstruction, 2B
	input [23 : 0] iAddr, 3B
	input [31 : 0] iData, 4B
	

from mem controller

wait: 0xFFF1
ready 0xFFF2
retransmit 0xFFF3
	
	
		Start 1B | Header 2B | Data payload 7B | Error 1B| END 1B
	
			*/	
		
			
			oData = iMsg[71 : 40];
			oWait = (iMsg[87 : 72] == 16'hFFF1) ? 1'b1 : 1'b0;
			oReady = (iMsg[87 : 72] == 16'hFFF2) ? 1'b1 : 1'b0;
			oRetry = (iMsg[87 : 72] == 16'hFFF3) ? 1'b1 : 1'b0;
		end

end//end always


endmodule
