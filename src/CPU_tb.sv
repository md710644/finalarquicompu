module CPU_tb;

import definesPkg::*;

	logic clk;
	logic reset;
	logic req_CPU;
	logic [31:0] data_from_memory;
	Taddress addr_from_memory;
   Taddress addr_from_program;
	Tmesi_state rd_mesi_state;
   logic read_mm_completed;
	// Output Ports
	logic [31:0] wdata_to_memory;
	logic we_to_mm;
	//internal logic
	logic [31:0] wdata; //to cache
	logic we; //to cache
	logic  gnt_CPU;
	//logic read_ack;


	
	CPU CPU0 (.*);


	
	
		//Taddress address_to_search;

	always
		#10 clk = ~clk;
		
		
		initial
	begin
		clk = 1'b0;
		reset = 1'b1;
		#10 reset = 1'b0;
    $display("Reading address");
	 CPU0.address_to_read.Page_reference = 'hFFFF;
	 CPU0.address_to_read.Index = 'b1;
	 CPU0.full_search = 1'b0;
    CPU0.read_start = 1'b1;
	 @(posedge clk) CPU0.read_start = 1'b0;
	 //verification case 1) - Read and not found in cache
	 
	 wait (CPU0.req_CPU == 1'b1);
	 #10;
	 gnt_CPU = 1'b1;
	 @(posedge clk);
    $display("When grant is high, the address requested to memory is: Page=%h Address:%h",addr_from_program.Page_reference, addr_from_program.Index);
	 data_from_memory= 32'hDEADBEEF; //possible read data from memory
	 addr_from_memory.address_to_read;
	 rd_mesi_state = EXC;
	 @(posedge clk);
	 read_mm_completed = 1'b1; //Given to CPU when READ data is correct;
	 @(posedge clk);
	 gnt_CPU =1'b0;
	 read_mm_completed = 1'b0;
	 repeat (10) @(posedge clk);
	  //only for not found
	 $finish();
   end
	
endmodule
