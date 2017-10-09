
module DataPathTx
#(
	parameter WORD_LENGTH = 8
)

(
	// Input Ports
	input clk,
	input reset,
	input Sync_Reset,
	input [ WORD_LENGTH - 1 : 0] iDataTX,
	input iTransmit,
	input iLoad,
	 

	// Output Ports
	output oTxDone,
	output oSerialOut

);



//wires to connect modules

wire [ WORD_LENGTH - 1 : 0] wDataFlop;
wire [ WORD_LENGTH + 1 : 0] wDataWithParity;
wire wMuxOut;
wire wSerialOut;
wire wCounterFlag;



//Output Flop

Register_With_Sync_Reset
#(
	.WORD_LENGTH(WORD_LENGTH)
)
Inputflop
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(1'b1),
	.Sync_Reset(Sync_Reset),
	.Data_Input(iDataTX),

	// Output Ports
	.Data_Output(wDataFlop)
);

//Even parity Generator

EvenParityGenerator
#(
	.WORD_LENGTH(WORD_LENGTH)
)
EvenParityGen_1
(
	// Input Ports
	.iData(wDataFlop),
	
	// Output Ports
	.oDataWithEvenParity(wDataWithParity)

);



// Shift register to serialize output

 Shift_RegisterForGeneratePout 
#(
	.Word_Length(WORD_LENGTH + 2'd2)
)

SR_Tx
(
	// input ports
	.clk(clk), 
	.reset(reset), 
	.Serial_Input(1'b1),
	.Load(iLoad),
	.Shift(iTransmit),
	.Parallel_Input(wDataWithParity),
	.Sync_Reset(Sync_Reset),
	
	// output ports
	.Serial_Output(wSerialOut),
	.Parallel_Output()
);

// count wordLENGTH + 2

CounterWithFlagAndParameter
#(
	// Parameter Declarations
	.MAXIMUM_VALUE(WORD_LENGTH + 2)
	
)
CounterInput

(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(iTransmit),
	.Sync_Reset(Sync_Reset),
	// Output Ports
	.flag(wCounterFlag),
	.counter()
);


//Mux to hold output high until transmit is required
Mux2to1
#(
	.WORD_LENGTH(1)
)
outputmux_out
(
	//inputs
	.Selector(iTransmit), //|| iLoad),
	.MUX_Data0(1'b1),
	.MUX_Data1(wSerialOut),
	//outputs
	.MUX_Output(wMuxOut)

);


// assign outputs

assign oSerialOut = wMuxOut;
assign oTxDone = wCounterFlag;

endmodule
