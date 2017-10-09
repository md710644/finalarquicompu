

module CounterWithFlagAndParameter
#(
	// Parameter Declarations
	parameter MAXIMUM_VALUE = 2,
	parameter NBITS = CeilLog2(MAXIMUM_VALUE)
)

(
	// Input Ports
	input clk,
	input reset,
	input enable,
	input Sync_Reset,
	
	// Output Ports
	output flag,
	output[NBITS - 1 : 0] counter
);

reg MaxValue_Bit;

reg [NBITS-1 : 0] counter_reg;

/*********************************************************************************************/

	always@(negedge clk or negedge reset)
	begin
		if (reset == 1'b0)
			counter_reg <= {NBITS{1'b0}};
		else 
			begin
			if(enable == 1'b1) 
				begin
					if(Sync_Reset == 1'b1) 
					begin
						if(counter_reg == MAXIMUM_VALUE - 1)
							counter_reg <= {NBITS{1'b0}};
						else
							counter_reg <= counter_reg + 1'b1;
					end
					else
						counter_reg <= {NBITS{1'b0}};
				end
							
			end
	end//end always


always@(counter_reg)
	if(counter_reg == MAXIMUM_VALUE - 1'b1)
		MaxValue_Bit = 1'b1;
	else
		MaxValue_Bit = 1'b0;

		
/*********************************************************************************************/
assign flag = MaxValue_Bit;
assign counter = counter_reg;


/*********************************************************************************************/
/*********************************************************************************************/
   
 /*Log Function*/
     function integer CeilLog2;
       input integer data;
       integer i,result;
       begin
          for(i=0; 2**i < data; i=i+1)
             result = i + 1;
          CeilLog2 = result;
       end
    endfunction

/*********************************************************************************************/
endmodule


