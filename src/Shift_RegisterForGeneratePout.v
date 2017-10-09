
module Shift_RegisterForGeneratePout 
#(
	parameter Word_Length = 8
)
(
	// input ports
	input clk, 
	input reset, 
	input Serial_Input,
	input Load,
	input Shift,
	input Sync_Reset,
	input [Word_Length-1:0] Parallel_Input,
	
	// output ports
	output Serial_Output,
	output [Word_Length-1:0] Parallel_Output
);

genvar i;
wire [Word_Length-2:0] SerialOutputsConections;

Register_With_Load
InitialRegister
(
	.clk(clk),
	.reset(reset),
	.Load(Load),
	.Shift(Shift),
	.SerialIn(Serial_Input),
	.ParallelIn(Parallel_Input[0]),
	.Sync_Reset(Sync_Reset),
	.SerialOut(SerialOutputsConections[0])
	
);

generate
	for(i=1;i < Word_Length-1; i=i+1)begin:Registers

		Register_With_Load
		InitialRegister
		(
			.clk(clk),
			.reset(reset),
			.Load(Load),
			.Shift(Shift),
			.SerialIn(SerialOutputsConections[i-1]),
			.ParallelIn(Parallel_Input[i]),
			.Sync_Reset(Sync_Reset),

			
			.SerialOut(SerialOutputsConections[i])
		);
	end
endgenerate

Register_With_Load
FinalRegister
(
	.clk(clk),
	.reset(reset),
	.Load(Load),
	.Shift(Shift),
	.SerialIn(SerialOutputsConections[Word_Length-2]),
	.ParallelIn(Parallel_Input[Word_Length-1]),
	.Sync_Reset(Sync_Reset),
	
	.SerialOut(Serial_Output)
);

assign Parallel_Output = {Serial_Output,SerialOutputsConections} ;

endmodule