
module DataPathRx
#(
	parameter WORD_LENGTH = 8 //number of bits excluding parity and start bit	)
)
(
	// Input Ports
	input clk,
	input reset,
	input Sync_Reset,
	input iSerialIn,
	input iReceive,
	input iWait,

	// Output Ports
	output oRxDone,
	output oParityError,
	output [WORD_LENGTH - 1 : 0] oParallelOut,
	output oStartRx,
	output oCount4
);

//wires to connect modules
wire wSerialInflop;
wire [WORD_LENGTH + 1 : 0]  wShiftReg;
wire wCounterFlag10;
wire wCounterFlag4;
wire wCounterFlag2;
wire [WORD_LENGTH - 1 : 0] wOutputFlop;
wire wParityError;

//Input Flop
Register_With_Sync_Reset
#(
	.WORD_LENGTH(1)
)
SerialInputFlop
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(1'b1),
	.Sync_Reset(1'b1),
	.Data_Input(iSerialIn),
	// Output Ports
	.Data_Output(wSerialInflop)
);

// Shift register to serialize output
 Shift_RegisterForGeneratePout 
#(
	.Word_Length(10)
)
SR_Rx
(
	// input ports
	.clk(clk), 
	.reset(reset), 
	.Serial_Input(wSerialInflop),
	.Load(~Sync_Reset),
	.Shift(iReceive),
	.Parallel_Input({(WORD_LENGTH+2){1'b0}}),
	.Sync_Reset(Sync_Reset),
	// output ports
	.Serial_Output(),
	.Parallel_Output(wShiftReg)
);


CounterWithFlagAndParameter
#(
	// Parameter Declarations
	.MAXIMUM_VALUE(4)	
)
Count_2
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(~iSerialIn | ~Sync_Reset),
	.Sync_Reset(Sync_Reset),
	// Output Ports
	.flag(wCounterFlag2),
	.counter()
);

CounterWithFlagAndParameter
#(
	// Parameter Declarations
	.MAXIMUM_VALUE(3)	
)
Count_4
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(iWait | ~Sync_Reset),
	.Sync_Reset(Sync_Reset),
	// Output Ports
	.flag(wCounterFlag4),
	.counter()
);




// count wordLENGTH + 2

CounterWithFlagAndParameter
#(
	// Parameter Declarations
	.MAXIMUM_VALUE(11)	
)
Count_10
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(iReceive | ~Sync_Reset),
	.Sync_Reset(Sync_Reset),
	// Output Ports
	.flag(wCounterFlag10),
	.counter()
);
// parity error

EvenParityCheck
#(
	.WORD_LENGTH(WORD_LENGTH + 2)
)
EvenParityCheck_1
(
	// Input Ports
	.iData(wShiftReg),
	.iEnable(wCounterFlag10),
	// Output Ports
	.oParityError(wParityError)
);

//Output Flop
Register_With_Sync_Reset
#(
	.WORD_LENGTH(WORD_LENGTH)
)
outputflop
(
	// Input Ports
	.clk(clk),
	.reset(reset),
	.enable(1'b1),
	.Sync_Reset(Sync_Reset),
	.Data_Input(wShiftReg[WORD_LENGTH : 1]),
	// Output Ports
	.Data_Output(wOutputFlop)
);


// assign outputs

assign oParallelOut = wOutputFlop;
assign oRxDone = wCounterFlag10;
assign oParityError = wParityError;
assign oStartRx = wCounterFlag2;
assign oCount4 = wCounterFlag4;


endmodule
