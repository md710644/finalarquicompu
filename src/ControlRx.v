
module ControlRx
(
	// Input Ports
	input clk,
	input reset,
	input iRxDone,
	input iStartRx,
	input iCount4,
	input iRxClear,
	
	// Output Ports
	output oRxReset,
	output oReceive,
	output oWait,
	output oRxFlag
	
);

localparam  IDLE = 0;
localparam  RECEIVE = 1;
localparam  WAIT = 2;
localparam  RXCOMPLETE = 3;
localparam  RXRESET = 4;



reg [2:0] state; 

reg rReceive;
reg rRxDone;
reg rRxReset;
reg rRxWait;
reg rRxFlag;


/**************************************************************************************/
always@(posedge clk or negedge reset )
 begin

	if(reset == 1'b0)
			state <= IDLE;
	else 
	   case(state)
		
			IDLE:
			begin
				if(iStartRx == 1'b1)
					state <= RECEIVE;
				else
					state <= IDLE;
			end
						
			RECEIVE:
			begin
					state <= WAIT;
			end
			
			WAIT:
			begin
				if(iRxDone == 1'b1)
					state <= RXCOMPLETE;
				else if (iCount4  == 1'b1)
					state <= RECEIVE;
				else 
					state <= WAIT;
			end

			RXCOMPLETE:
			begin
				if(iRxClear == 1'b1)
					state <= RXRESET;
				else
					state <= RXCOMPLETE;
			end
			
			RXRESET:

				state <= IDLE;	
												
			default:
					state <= IDLE;

			endcase
end//end always
/*------------------------------------------------------------------------------------------*/

always @ (state) begin

rReceive = 1'b0;
rRxReset = 1'b1;
   
	 case(state)
		IDLE: 
			begin
		rReceive = 1'b0;
		rRxReset = 1'b1;
		rRxWait = 1'b0;
		rRxFlag = 1'b0;
			end
		
		RECEIVE: 
			begin
		rReceive = 1'b1;
		rRxReset = 1'b1;
		rRxWait = 1'b0;
		rRxFlag = 1'b0;
			end
		WAIT: 
			begin
		rReceive = 1'b0;
		rRxReset = 1'b1;
		rRxWait = 1'b1;
		rRxFlag = 1'b0;

			end
		RXCOMPLETE: 
			begin
		rReceive = 1'b0;
		rRxReset = 1'b1;
		rRxWait = 1'b0;
		rRxFlag = 1'b1;

			end
		
		RXRESET: 
		begin
		rReceive = 1'b0;
		rRxReset = 1'b0;
		rRxWait = 1'b0;
		rRxFlag = 1'b0;

		end
		
		
		default: 		
		begin
		rReceive = 1'b0;
		rRxReset = 1'b1;
		rRxWait = 1'b0;
		rRxFlag = 1'b0;

		end

	endcase//end case for state
end//end always

// Asingnación de salidas

	
	assign oReceive = rReceive;
	assign oRxReset = rRxReset;
	assign oWait = rRxWait;
	assign oRxFlag = rRxFlag;

endmodule
