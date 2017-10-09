
module ControlTx
(
	// Input Ports
	input clk,
	input reset,
	input iTransmit,
	input iTxDone,
	
	// Output Ports
	output oLoad,
	output oTxReset,
	output oTransmit
	
);

localparam  IDLE = 2'd0;
localparam  LOAD = 2'd1;
localparam  TRANSMIT = 2'd2;
localparam  TXRESET = 2'd3;



reg [1:0] state; 

reg rLoad;
reg rTransmit;
reg rTxDone;
reg rTxReset;


/**************************************************************************************/
always@(posedge clk or negedge reset )
 begin

	if(reset == 1'b0)
			state <= IDLE;
	else 
	   case(state)
		
			IDLE:
			begin
				if(iTransmit == 1'b1)
					state <= LOAD;
				else
					state <= IDLE;
			end					
			LOAD:

				state <= TRANSMIT;	

			TRANSMIT:
			begin
				if(iTxDone == 1'b1)
					state <= TXRESET;
				else
					state <= TRANSMIT;
			end
			TXRESET:

				state <= IDLE;	
												
			default:
					state <= IDLE;

			endcase
end//end always
/*------------------------------------------------------------------------------------------*/

always @ (state) begin

	rLoad=1'b0;
	rTransmit=1'b0;
	rTxReset = 1'b1;
   
	 case(state)
		IDLE: 
			begin
			rLoad=1'b0;
			rTransmit=1'b0;
			rTxReset = 1'b1;
			end
		
		LOAD: 
			begin
			rLoad=1'b1;
			rTransmit=1'b0;
			rTxReset = 1'b1;
			end

		TRANSMIT: 
			begin
			rLoad=1'b0;
			rTransmit=1'b1;
			rTxReset = 1'b1;
			end
		TXRESET: 
		begin
			rLoad=1'b0;
			rTransmit=1'b0;
			rTxReset = 1'b0;
		end
		
		
		default: 		
			begin
			rLoad=1'b0;
			rTransmit=1'b0;
			rTxReset = 1'b1;
			end

	endcase//end case for state
end//end always

// Asingnación de salidas

	
	assign oLoad = rLoad;
	assign oTransmit = rTransmit;
	assign oTxReset = rTxReset;

endmodule
