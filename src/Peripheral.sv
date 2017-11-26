
 module Peripheral

(
	// Input Ports
	
	//from test bench
	input clk,
	input iStart,
	
	input [15 : 0] iInstruction,
	input [23 : 0] iAddr,
	input [31 : 0] iData,
	
	input iError,
	
	//from decoder
	input reset,
	input iTxDone,
	input iRxFlag,
	input iRetry,
	input iWait,
	input iReady,
	input [31 : 0] iMSGData,
	
	// Output Ports
	
	output reg oTransmit,
	output reg oReady,
	output reg [95 : 0] oOutputMsg,//Start 1B | Header 2B | Data payload 7B | Error 1B| END 1B = 12B = 96 bits
	output reg  [31 : 0] oData
	
	
);




/*
Instruction decode

Header equals to:

from peripheral

read: 0x0001
write 0x0002
address 0x0003
data	0x0004

from mem controller

wait: 0xFFF1
ready 0xFFF2
retransmit 0xFFF3

*/


	// parameter declaration
	localparam SIZE = 3'd3;
	localparam IDLE = 3'b000;
	localparam START = 3'b001;	
	localparam MSG	= 3'b010;
	localparam CONFIRM = 3'b011;
	localparam RETRY = 3'b100;
	localparam RECEIVE = 3'b101;
	




reg [SIZE - 1 : 0] state; 
 



/**************************************************************************************/
always@(posedge clk or negedge reset )
 begin

	if(reset == 1'b0)
			state <= IDLE;
	else 
	   case(state)
		
			IDLE:
			begin
				if(iStart == 1'b1)
					state <= START;
				else
					state <= IDLE;
			end					
			START:

				state <= MSG;	

			MSG:
			begin
				if(iTxDone == 1'b1)
					state <= CONFIRM;
				else
					state <= MSG;
			end
			
			CONFIRM:

				if((iRxFlag == 1'b1 && (iRetry == 1'b1 || iWait == 1'b1)))
					state <= RETRY;
				else if ((iRxFlag == 1'b1 && iReady == 1'b1))
					state <= RECEIVE;
						
				else
					state <= CONFIRM;
					
					
			RETRY:

					state <= START;
					
			RECEIVE:

				state <= IDLE;

					
			default:
					state <= IDLE;

			endcase
			
			
			
			
			
			
			
			
end//end always
/*------------------------------------------------------------------------------------------*/

always @ (state) begin

oOutputMsg = 0;
oData = 0;
oTransmit = 0;
oReady = 0;

	 case(state)
		
		IDLE: 
			begin
			oOutputMsg = 0;
			oData = 0;
			oTransmit = 0;
			oReady = 0;
			end
		
		START: 
			begin
			/*

	start byte 0x0F 1B
	input [15 : 0] iInstruction, 2B
	input [23 : 0] iAddr, 3B
	input [31 : 0] iData, 4B
	
	end byte 0xF0	1B
	
		Start 1B | Header 2B | Data payoad 7B | Error 1B| END 1B
	
			*/
			oOutputMsg = {8'h0F, iInstruction, iData, iAddr, 7'b0, iError, 8'hF0};//create output msg
			oData = 0;
			oTransmit = 1;
			oReady = 0;
			end
		
		MSG: 
			begin
			oOutputMsg = {8'h0F, iInstruction, iData, iAddr, 7'b0, iError, 8'hF0};//create output msg
			oTransmit = 0;
			oData = 0;
			oReady = 0;
			end	
			
		CONFIRM: 
			begin
			oTransmit = 0;
			oData = 0;
			oReady = 0;
			end
			
		RETRY: 
			begin
			oTransmit = 0;
			oData = 0;
			oReady = 0;
			end
			
		RECEIVE: 
			begin
			oData = iMSGData;
			oTransmit = 0;
			oReady = 1'b1;
			end
			

		default: 		
			begin
			oOutputMsg = 0;
			oData = 0;
			oTransmit = 0;
			oReady = 0;
			end

	endcase//end case for state
end//end always


endmodule
