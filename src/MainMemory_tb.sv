//`include "definesPkg.sv"

module MainMemory_tb;

import definesPkg::*;

   logic clk;
	logic reset;
	Taddress addr;
	Tdata_sb wdata; 
	logic we;
	Tdata_sb rdata;
	Tmesi_state mesi_state_out;
	Tmesi_state mesi_state_in;

MainMemory MainMemory0 (.*);
// initialization
//Reset pulse

initial
begin
	clk = 1'b0;
	reset = 1'b1;
	#10 reset = 1'b0;
end

always
		#10 clk = ~clk;
		
 task read_all_memory;
	 for (integer i =0; i< 2 ; i = 1+1) begin
		for (integer j = 0; j < 255; j = j + 1) begin
			@(posedge clk) addr.Page_reference <= i; addr.Address_code <= j;
		end
	 end
 endtask


initial begin
$monitor ("The read data is %h at time=%t", rdata.Data, $time);
read_all_memory();
$finish;
end
/*initial
begin
 $recordfile("main_memory_tb.txt");
 $recordvars();
end*/

 //monitor event
  always_ff @(posedge clk) begin
	if (reset)
	begin
		$display ("-I-: Reset is Asserted at %t", $time);
	end
 end

endmodule

