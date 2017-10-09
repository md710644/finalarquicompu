module UART
#(
		parameter WORD_LENGTH = 8
)

(

//	input clk4x,
//	input clk1x,
	// Input Ports
	input wclk1x,
	input wclk4x,
	input reset,
	input iSerialIn,
	input [ WORD_LENGTH - 1 : 0] iDataTX,
	input iTransmit ,
	input iClearRxFlag,
	 

	// Output Ports
	output [ WORD_LENGTH - 1 : 0] oDataRx,
	output oRxFlag,
	output oSerialOut,
	output oParityError,
	output oTxDone
);


//wire to connect modules

//clock wires

// wire wclk1x; /*synthesis keep*/
// wire wclk4x; /*synthesis keep*/

//Tx Wires
wire wTxDone;
wire wTxLoad;
wire wTxTransmit;
wire wiTransmitOneShot;
wire wTxSync_Reset;
wire wTxSerialOut;

//Rx wires
wire wRxDone;
wire wRxReceive;
wire wRxSync_Reset;
wire wParityError;
wire [ WORD_LENGTH - 1 : 0] wDataRx;
wire wStartRx;
wire wCount4;
wire wWait;
wire wRxFlag;
wire wiClearRxFlagOneShot;


//assign wires


// PLLs


// PLL	PLL_inst1 (
// 	.areset ( ~reset ),
// 	.inclk0 ( clk ),
// 	.c0 ( wclk1x ),
// 	.c1 ( wclk4x )
// 	);


//One shot modules to debounce inputs from pushbuttons

 One_Shot OS_transmit
(
	// Input Ports
	.clk(wclk1x),
	.reset(reset),
	.Start(iTransmit),

	// Output Ports
	.Shot(wiTransmitOneShot)
);
 One_Shot OS_ClearRxFlag
(
	// Input Ports
	.clk(wclk4x),
	.reset(reset),
	.Start(~iClearRxFlag),

	// Output Ports
	.Shot(wiClearRxFlagOneShot)
);

// control tx


ControlTx ControlTx_1
(	// Input Ports
	.clk(wclk1x),
	.reset(reset),
	.iTransmit(wiTransmitOneShot),
	.iTxDone(wTxDone),
	// Output Ports
	.oLoad(wTxLoad),
	.oTxReset(wTxSync_Reset),
	.oTransmit(wTxTransmit)
);

//datapath tx


DataPathTx 
#(
	.WORD_LENGTH(WORD_LENGTH)
)
DataPathTx_1
(
	// Input Ports
	.clk(wclk1x),
	.reset(reset),
	.Sync_Reset(wTxSync_Reset),
	.iDataTX(iDataTX),
	.iTransmit(wTxTransmit),
	.iLoad(wTxLoad),
	 
	// Output Ports
	.oTxDone(wTxDone),
	.oSerialOut(wTxSerialOut)
);


//control rx
ControlRx ControlRx_1
(
	// Input Ports
	.clk(wclk4x),
	.reset(reset),
	.iRxDone(wRxDone),
	.iStartRx(wStartRx),
	.iCount4(wCount4),
	.iRxClear(wiClearRxFlagOneShot),
	// Output Ports
	.oRxReset(wRxSync_Reset),
	.oReceive(wRxReceive),
	.oWait(wWait),
	.oRxFlag(wRxFlag)
);


//datapath rx

DataPathRx
#(
	.WORD_LENGTH(WORD_LENGTH) //number of bits excluding parity and start bit	)
)
DataPathRx_1
(
	// Input Ports
	.clk(wclk4x),
	.reset(reset),
	.Sync_Reset(wRxSync_Reset),
	.iSerialIn(iSerialIn),
	.iReceive(wRxReceive),
	.iWait(wWait),
	// Output Ports
	.oRxDone(wRxDone),
	.oParityError(wParityError),
	.oParallelOut(wDataRx),
	.oStartRx(wStartRx),
	.oCount4(wCount4)
);

//Assign outputs
assign oSerialOut = wTxSerialOut;
assign oParityError = wParityError;
assign oDataRx = wDataRx;
assign oRxFlag = wRxFlag;
assign oTxDone = ~wTxSync_Reset;

endmodule
