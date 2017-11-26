
module Peripheral_tb;

	//regs for inputs
	reg clk_tb = 0;
	reg reset_tb = 0;
	//from test bench

	reg iStart_tb = 0;
	
	reg [15 : 0] iInstruction_tb = 0;
	reg [23 : 0] iAddr_tb = 0;
	reg [31 : 0] iData_tb = 0;
	
	reg iError_tb = 0;

	reg iRxFlag_PMC_tb = 0;
		
		//from UART MC to P

	reg iTxDone_tb = 0;
	reg iRxFlag_MCP_tb = 0;
		
		//from decoder MC to P


	wire wRetry_tb;
	wire wWait_tb;
	wire wReady_tb;
	wire [31 : 0] wMSGData_tb;

// Message from MC
//Start 1B | Header 2B | Data payload 7B | Error 1B| END 1B = 12B = 96 bits
	reg [95 : 0] rMCMsg = 0; 

//outputs from Peripheral

	wire oTransmit_tb;
	wire oReady_tb;
	wire [95: 0] oOutputMsg_tb;//Start 1B | Header 2B | Data payoad 7B | Error 1B| END 1B = 12B = 96 bits
	wire  [31 : 0] oData_tb;


// outputs from Decoder P to MC

	wire [23 : 0] oAddr_PMC_tb;
	wire [31 : 0] oData_PMC_tb;
	wire oError_PMC_tb;
	wire oReq_EXT_PMC_tb;
	wire oWrite_PMC_tb;
	wire oRead_PMC_tb;

	//instantiate modules

Peripheral DUV1

(
	// Input Ports
	
	//from test bench
	.clk(clk_tb),
	.reset(reset_tb),
	.iStart(iStart_tb),
	
	.iInstruction(iInstruction_tb),
	.iAddr(iAddr_tb),
	.iData(iData_tb),
	
	.iError(iError_tb),
	
	//from UART
	.iTxDone(iTxDone_tb),
	.iRxFlag(iRxFlag_MCP_tb),
	
	//from decoder MCP
	.iRetry(wRetry_tb),
	.iWait(wWait_tb),
	.iReady(wReady_tb),
	.iMSGData(wMSGData_tb),
	
	// Output Ports
	
	.oTransmit(oTransmit_tb),
	.oReady(oReady_tb),
	.oOutputMsg(oOutputMsg_tb),//Start 1B | Header 2B | Data payoad 7B | Error 1B| END 1B = 12B = 96 bits
	.oData(oData_tb)
	
);

  Decoder_PMC DUV2

(
	// Input Ports
	
	.iRxFlag(iRxFlag_PMC_tb),
	.iMsg(oOutputMsg_tb),//Start 1B | Header 2B | Data payload 7B | Error 1B| END 1B = 12B = 96 bits
	.reset(reset_tb),
	
	// Output Ports
	
	.oAddr(oAddr_PMC_tb),
	.oData(oData_PMC_tb),
	.oError(oError_PMC_tb),
	.oReq_EXT(oReq_EXT_PMC_tb),
	.oWrite(oWrite_PMC_tb),
	.oRead(oRead_PMC_tb)
				
);

 Decoder_MCP DUV3

(
	// Input Ports
	
	.iRxFlag(iRxFlag_MCP_tb),
	.iMsg(rMCMsg),
	.reset(reset_tb),
	
	// Output Ports
	
	.oData(wMSGData_tb),
	.oRetry(wRetry_tb),
	.oWait(wWait_tb),
	.oReady(wReady_tb)
				
);


/*********************************************************/
initial // Clock generator
 begin
   forever #2 clk_tb = !clk_tb;
 end
/*********************************************************/
initial begin // De-assert reset
  #2 reset_tb = 1'b0;
  #4 reset_tb = 1'b1;
  		
end
/*********************************************************
Send Good Message from Peripheral
	reg [15 : 0] iInstruction_tb;
	reg [23 : 0] iAddr_tb;
	reg [31 : 0] iData_tb;
				iError_tb
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

Start 1B | Header 2B | Data payload 7B | Error 1B| END 1B

*********************************************************/
initial begin // Send Write instruction with no error
	
	#5 
	iError_tb = 0;
	iInstruction_tb = 16'h0002;
	iAddr_tb = 24'h00000F;
	iData_tb = 32'hF0F0F0F0;
	iStart_tb = 1'b0;
	
 // Start Transmision
	
	
	#4  iStart_tb = 1'b1;
	#4  iStart_tb = 1'b0;
		
// End of Transmision from UART
	
	

	#4   iTxDone_tb = 1'b1;
		iRxFlag_PMC_tb = 1'b1;

	#4 iRxFlag_PMC_tb = 1'b0;
 		iTxDone_tb = 1'b0;


 /* peripheral inputs from MCP Decoder 
wait: 0xFFF1
ready 0xFFF2
retransmit 0xFFF3
*/
	#6	
	iRxFlag_MCP_tb = 1'b1;
	rMCMsg = {8'h0F, 16'hFFF2, iData_tb, iAddr_tb, 8'b0, 8'hF0};
	#6 iRxFlag_MCP_tb = 1'b0;

//Start 1B | Header 2B | Data payload 7B | Error 1B| END 1B

/*********************************************************/

 // Send read instruction with Retry
	
	#10
	iError_tb = 1;
	iInstruction_tb = 16'h0001;
	iAddr_tb = 24'hFFFFFF;
	iData_tb = 32'h00000000;
	iStart_tb = 1'b0;
#5


 // Start Transmision
	
	
	#6  iStart_tb = 1'b1;
	#6  iStart_tb = 1'b0;
		
	
 // End of Transmision delete after connecting UART
	
	
	#6
	    iTxDone_tb = 1'b1;
    	iError_tb = 0;
//start signal from uart to PMC decoder
	 	iRxFlag_PMC_tb = 1'b1;
	#6 iTxDone_tb = 1'b0;
		iRxFlag_PMC_tb = 1'b0;

 // peripheral inputs from MCP Decoder 
	

 /* peripheral inputs from MCP Decoder 
wait: 0xFFF1
ready 0xFFF2
retransmit 0xFFF3
*/
	#6	
	iRxFlag_MCP_tb = 1'b1;
	rMCMsg = {8'h0F, 16'hFFF3, 32'h0000_0000, iAddr_tb, 8'hFF, 8'hF0};
	#6 iRxFlag_MCP_tb = 1'b0;
//Start 1B | Header 2B | Data payload 7B | Error 1B| END 1B




			#12
	    iTxDone_tb = 1'b1;
//start signal from uart to PMC decoder
	 iRxFlag_PMC_tb = 1'b1;
	#6 iTxDone_tb = 1'b0;
		iRxFlag_PMC_tb = 1'b0;


	#6 
/* peripheral inputs from MCP Decoder 
wait: 0xFFF1
ready 0xFFF2
retransmit 0xFFF3
*/
	#6	
	iRxFlag_MCP_tb = 1'b1;
	rMCMsg = {8'h0F, 16'hFFF2, 32'hABCDEFAB, iAddr_tb, 8'b0, 8'hF0};
	#6 iRxFlag_MCP_tb = 1'b0;
//Start 1B | Header 2B | Data payload 7B | Error 1B| END 1B

end


endmodule

