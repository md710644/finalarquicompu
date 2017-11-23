module MemoryController_tb;


MemoryController MemoryController0 (.*);

	logic clk;
	logic reset;
	logic req_CPU;
	logic req_EXT;
	logic [65:0] read_line;
	// Output Ports
	logic [65:0] write_line;
	logic we;
	logic we_to_mm; //from CPU
	logic gnt_CPU; 
	logic gnt_EXT;
	logic release_EXT;
	logic [1:0] current_state;
	logic [1:0] next_state;
	Taddress address_wanted_from_memory;
	Tmesi_state rd_mesi_state;
   logic read_mm_completed;

always
		#10 clk = ~clk;

assign current_state = MemoryController0.current_state;
assign next_state = MemoryController0.next_state;

 task CPU_request;
  $display ("Starting CPU Request");
  req_CPU = 1'b1;
  #10;
 endtask
 
  task CPU_release;
  $display ("Releasing CPU Request");
  req_CPU = 1'b0;
 endtask
 
 task EXT_request;
  $display ("Starting EXT Request");
  req_EXT = 1'b1;
  #10;
 endtask
 
  task EXT_release;
  $display ("Releasing EXT Request");
  req_EXT = 1'b0;
  #10;
 endtask
 //Main
 initial begin
 $monitor ("Current state is %h at time=%4t", current_state,  $time);
 	clk = 1'b0;
	reset = 1'b1;
	#30 reset = 1'b0;
   CPU_request();
	EXT_request();
	//State should remain in CPU because CPU haven't been released.
	CPU_release();
	EXT_release();
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
