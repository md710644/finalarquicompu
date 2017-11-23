import definesPkg::*;

module CPU (

	// Input Ports
   input clk, 
	input reset,
	input gnt_CPU,
   input read_mm_completed,	
	input [63:0] data_from_memory,
	input Tmesi_state rd_mesi_state,
	// Output Ports
	output Taddress addr_wanted_from_memory,
	output [63:0] wdata_to_memory,//for memory writes
	output we_to_mm,
	output reg req_CPU
	);
	

	logic we; //to Cache
	Taddress addr;
   Taddress address_to_read;
	logic read_start;
	logic [63:0] wdata; //to cache
	Tmesi_state mesi_state_in;
	logic [63:0] rdata; //from cache
	Tmesi_state cache_mesi_state; 
	Taddress cache_addr;
	//cache instantiation
	Cache Cache0 (.*);


//function to read an address.
  task automatic read_addr;
    input Taddress search_addr;
	 Taddress writable_addr;
	 int found = 0;
	 int free_addr = 0;
	 int cache_line_found;
	 logic [63:0] data_found;
	   $display ("Starting cache read");
		$display ("Searching for Address %h", search_addr.Address_code);
	 //1-Check if address exist in cache memory and is not invalidated
	 for (integer i =0; i< 65 ; i = i+1) begin
		//for (integer j = 0; j < 255; j = j + 1) begin

			addr.Page_reference = 0;
			addr.Address_code = i;

				//synthesis translate_off 
				@(posedge clk);
				//synthesis translate_on
			if (i > 0) begin
				$display("Comparing search_Addr:%h against cache_address: %h i=%d Mesi:%s",search_addr.Address_code, cache_addr.Address_code, i-1, cache_mesi_state);
				if (cache_mesi_state == INV && free_addr == 0) begin
					writable_addr.Page_reference = addr.Page_reference;
					writable_addr.Address_code = i-1;
					$display("First free INV address in cache to write if needed %h i=%d", writable_addr.Address_code,i-1);
					free_addr = 1'b1;
				end
				if (cache_mesi_state != INV) begin
					if (search_addr.Address_code == cache_addr.Address_code) begin
					   cache_line_found = i-1;
						data_found = rdata;
						found = found + 1;
						$display ("Found Adress:%h on cache line: %h with mesi state %s and Data: %h", search_addr.Address_code, cache_line_found, cache_mesi_state, rdata);

					end
				end
			end	
	   //end

	 end
	 $display ("Reached end of cache memory");
	 	 //case0) the address doesn't exist in cache or is invalidated
	 if (found > 1) begin
	    $display("Error Address:%h found in cache more that once", search_addr.Address_code);
    end
	 else if (found == 0) begin
	    $display("Address: %h not found in the cache", search_addr.Address_code);
		 	 //Do a read request to memory controller
		 $display ("Requesting CPU access to memory");
	    req_CPU = 1'b1;
		 wait (gnt_CPU == 1'b1);
		 $display("Grant received");
		 addr_wanted_from_memory=address_to_read;
		 $display("read_addr.Page_referece=%h, read_addr.Address_code=%h", addr_wanted_from_memory.Page_reference, addr_wanted_from_memory.Address_code );
		 wait(read_mm_completed);
		 req_CPU= 1'b0;
		 $display("Data read from memory is: %h with Mesi State=%d", data_from_memory, rd_mesi_state);
		 //when completed, write the cache with this address as exclusive to any invalid address
		 //synthesis translate_off 
		 //@(posedge clk)
		 //synthesis translate_on
		 if (free_addr == 1'b1) begin
			addr = writable_addr;
		 end else begin
			// if there is no a free invalid address, write to address 0. 
			addr = 1'b0;
		 end
		 mesi_state_in = EXC;
       we = 1'b1;
		 wdata = data_from_memory;
		 //synthesis translate_off 
		 @(posedge clk);
		 //synthesis translate_on
		 we = 1'b0;
		 //synthesis translate_off 
		 repeat (2) @(posedge clk);
		 //synthesis translate_on
		 //Checking if the address was written correctly
		 //we = 1'b0;
		 $display ("Data written in cache for Page: %h Address: %h is %h with MESI: %d", addr.Page_reference, addr.Address_code, rdata, cache_mesi_state );		 
    end
	 else if (found == 1) begin
	 //case1) The address exist in cache
	 //Consume the address
	    //$display ("The Address exist in cache line:%0d",cache_line_found);
		 //addr.Page_reference = 1'b0;
       //addr.Address_code = cache_line_found;
		 //mesi_state_in = EXC;
		 //we = 1'b1;
		 //wdata = data_found;
		 ////synthesis translate_off 
		 //@(posedge clk);
		 ////synthesis translate_on
		 //we = 1'b0;
		 //synthesis translate_off 
		 repeat (5) @(posedge clk);
		 //synthesis translate_on
		 $display ("Using Cache Address- Address:%h Data: %h",cache_line_found, data_found);
		 ////synthesis translate_off 
		 //repeat (2) @(posedge clk);
		 ////synthesis translate_on		 
	 end
	 
  endtask
 
always@(posedge clk)
if (read_start)
	read_addr(address_to_read);

		
endmodule : CPU
