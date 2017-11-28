//`include "definesPkg.sv"


module MainMemory_tb;

import definesPkg::*;

   logic clk;
	logic reset;
	Taddress addr;
	logic [31:0] wdata; 
	logic we;
	logic [31:0] rdata;
	Tmesi_state mesi_state_out;
	Tmesi_state mesi_state_in;
	logic [15:0] Page_reference_out;

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
  $display ("Starting memory reads");
	 for (integer i =0; i< 512 ; i = i+1) begin
			@(posedge clk)
			addr.Index <= i;
			//synthesis translate_off 
			addr.Page_reference <= $urandom;
			//synthesis translate_on			
	 end
 endtask

 task write_all_memory;
 $display ("Starting memory writes");
 we= 1'b1;
	 for (integer i =0; i< 512 ; i = i+1) begin
			@(posedge clk) 
			addr.Index <= i;
			//synthesis translate_off 
			addr.Page_reference <= $urandom;
			wdata <= $urandom();//Random
			//synthesis translate_on
			mesi_state_in <= INV;
		end
 we = 1'b0;
 endtask

initial begin
$monitor ("Read data for Page:%h Addr:%h is %h at time=%4t", addr.Page_reference, addr.Index, rdata,  $time);
read_all_memory();
write_all_memory();
$finish;
end


 //monitor event
  always_ff @(posedge clk) begin
	if (reset)
	begin
		$display ("-I-: Reset is Asserted at %t", $time);
	end
 end

endmodule
