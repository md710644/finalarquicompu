
import definesPkg::*;

module Cache( 
   input clk, 
	input reset,
	input Taddress addr,
	input [31:0] wdata, 
	input we,
	input Tmesi_state mesi_state_in,
	output [31:0] rdata,
	output Tmesi_state cache_mesi_state, 
	output Taddress cache_addr
	//input [65:0] write_line, 
	//output [65:0] read_line
);


initial begin
	$display ("Initializing the cache");
   $readmemb("cache_page0.txt",cache_pg0);
end
   //256 lines of 58 bits each
	logic [57:0]cache_pg0 [255:0]; //Page 0 - 2b(MESI) 16b(Page) 8b(Addr) 32b(Data) =58b

	logic [57:0] read_line;
	logic [57:0] write_line;
	always_ff@(posedge clk)
	begin
	//Write
		if(we) begin
		      if (addr.Index < 255) begin
				cache_pg0[addr.Index] <= write_line;
				end
				else begin
			      $display("Index for write %h out of bounds in memory cache", addr.Index);				
				end
		end// end we
	//Read
		if (addr.Index < 255)begin
		   read_line <= cache_pg0[addr.Index];
		end 
		else begin
			$display("Index for read %h out of bounds in memory cache", addr.Index);
		end
		//else begin
		//	$display("Page %h not found in cache read", addr.Page_reference);
		//end
	end
	
	assign write_line = we ? {mesi_state_in, addr.Page_reference, addr.Index, wdata} : 'bz;
	assign cache_mesi_state = Tmesi_state'(read_line[57:56]);
	assign cache_addr.Page_reference = read_line[55:40];
	assign cache_addr.Index = read_line[39:32];
	assign rdata = read_line[31:0];

	//Hacer la cache asyncrona? 
	
endmodule : Cache
