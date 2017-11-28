import definesPkg::*;

module CPU (

	// Input Ports
   input clk, 
	input reset,
	input gnt_CPU,
   input read_mm_completed,	
	input [31:0] data_from_memory,
	input Taddress addr_from_memory,
	input Tmesi_state rd_mesi_state,
	// Output Ports
	output Taddress addr_from_program,
	output [31:0] wdata_to_memory,//for memory writes
	output we_to_mm,
	output reg req_CPU
	);
	

	logic we; //to Cache
	Taddress addr;
   Taddress address_to_read;
	logic read_start;
	logic [31:0] wdata; //to cache
	Tmesi_state mesi_state_in;
	logic [31:0] rdata; //from cache
	Tmesi_state cache_mesi_state; 
	Taddress cache_addr;
	logic full_search;
	logic Omiss;
	logic Ohit;
	
	//cache instantiation
	Cache Cache0 (.*);


//function to read an address.
  task automatic read_addr;
    input Taddress search_addr;
	 input full_search;
	 Taddress writable_addr;
	 int hit = 0;
	 int free_addr = 0;
	 int cache_line_found;
	 logic [31:0] data_found;
	   $display ("Starting cache read");
		$display ("Searching for Address %h", search_addr.Index);
	 //1-Check if address exist in cache memory and is not invalidated
	 if (full_search) begin
	 $display ("Doing a full search");
		 for (integer i =0; i< 255 ; i = i+1) begin
				addr.Index = i;
				//synthesis translate_off 
				@(posedge clk);
				//synthesis translate_on
				if (i > 0) begin
					$display("Comparing search_Addr:%h against cache_address: %h i=%d Mesi:%s",search_addr.Index, cache_addr.Index, i-1, cache_mesi_state);
					if (cache_mesi_state == INV && free_addr == 0) begin
						writable_addr.Index = i-1;
						$display("First free INV address in cache to write if needed %h i=%d", writable_addr.Index,i-1);
						free_addr = 1'b1;
					end
					if (cache_mesi_state != INV) begin
						if (search_addr.Page_reference == cache_addr.Page_reference) begin
							if (search_addr.Index == cache_addr.Index) begin
								cache_line_found = i-1;
								data_found = rdata;
								hit = hit + 1;
								Omiss = 1'b0;
								$display ("Found Adress: Page_Reference:%h Index: %h on cache line: %h with mesi state %s and Data: %h", search_addr.Page_reference, search_addr.Index, cache_line_found, cache_mesi_state, rdata);
							end
						end
					end
				end	
		 end
		 $display ("Reached end of cache memory");
		end else begin
			$display ("Doing an index search");
			addr = search_addr;
			//synthesis translate_off 
			@(posedge clk);
			//synthesis translate_on
			if (cache_mesi_state != INV) begin
				if (cache_addr.Index == search_addr.Index) begin
					$display("Cache_addr.index: %h matches search_addr.Index %h", cache_addr.Index, search_addr.Index);
					if (cache_addr.Page_reference == search_addr.Page_reference) begin
						$display("cache_addr.Page_reference: %h matches search_addr.Page_reference: %h", cache_addr.Page_reference, search_addr.Page_reference);
						hit = hit + 1;
					end
				end
			end
			if (hit == 0) begin
				$display ("search_addr.Index:%h, search_addr.Page_reference:%h not found in cache", search_addr.Index, search_addr.Page_reference );			
			end	
		end	
	 	 //case0) the address doesn't exist in cache or is invalidated
	 if (hit > 1) begin
	    $display("Error Address: Index: %h PageReference: found in cache more that once", search_addr.Index, search_addr.Page_reference);
    end
	 else if (hit == 0) begin
		 $display ("MISS!!!");
		 Omiss = 1'b1;
	    $display("Address with Index: %h and Page_reference: %h not found in the cache", search_addr.Index, search_addr.Page_reference);
		 	 //Do a read request to memory controller
		 $display ("Requesting CPU access to memory");
	    req_CPU = 1'b1;
		 wait (gnt_CPU == 1'b1);
		 $display("Grant received");
		 addr_from_program=address_to_read;
		 $display("read_addr.Page_referece=%h, read_addr.Index=%h", addr_from_program.Page_reference, addr_from_program.Index );
		 wait(read_mm_completed);
		 req_CPU= 1'b0;
		 $display("Data read from memory is: %h with Mesi State=%d and Adress: Index: %h Page_reference: %h", data_from_memory, rd_mesi_state, addr_from_memory.Index, addr_from_memory.Page_reference);
		 //when completed, write the cache with this address as exclusive to any invalid address
		 //synthesis translate_off 
		 //@(posedge clk)
		 //synthesis translate_on
		 if (full_search == 1'b1) begin
			 if (free_addr == 1'b1) begin
				addr.Index = writable_addr.Index;
			 end else begin
				// if there is no a free invalid address, write to address 0. 
				addr.Index = 1'b0;
			 end
		 end else begin 
				addr.Index = addr_from_program.Index;
		 end
		 addr.Page_reference = addr_from_memory.Page_reference;
		 mesi_state_in = SHD;
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
		 $display ("Data written in cache for Addres: Page:%h Index:%h is %h with MESI: %d", addr.Page_reference, addr.Index, rdata, cache_mesi_state );		 
    end
	 else if (hit == 1) begin
	 //case1) The address exist in cache
	 //Consume the address
	 		 $display ("HIT!");
			Ohit = 1'b1;
		 //synthesis translate_off 
		 repeat (5) @(posedge clk);
		 //synthesis translate_on
		 $display ("Using Cache Address- Address:%h Data: %h",cache_line_found, data_found);
		 
	 end
	 
  endtask
 
always@(posedge clk)
if (read_start)
	read_addr(address_to_read, full_search);

		
endmodule : CPU
