module MemoryController_tb;

	logic clk;
	logic reset;
	logic req_CPU;
	logic req_EXT;
	logic [65:0] read_line;
	// Output Ports
	logic [65:0] write_line;
	logic we;
	logic gnt_CPU; 
	logic gnt_EXT;
	logic [1:0] current_state;
	logic [1:0] next_state;
	
always
		#10 clk = ~clk;


 task CPU_request;
  $display ("Starting CPU Request");
  req_CPU = 1'b1;
  #10;
 endtask
 
  task CPU_release;
  $display ("Starting CPU Request");
  req_CPU = 1'b0;
 endtask
 
 task EXT_request;
  $display ("Starting CPU Request");
  req_EXT = 1'b1;
  #10;
 endtask
 //Main
 initial begin
 $monitor ("Current state is %h at time=%4t", current_state,  $time);
 	clk = 1'b0;
	reset = 1'b1;
	#10 reset = 1'b0;
   CPU_request();
	EXT_request();
	//State should remain in CPU because CPU haven't been released.
	CPU_release();
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
