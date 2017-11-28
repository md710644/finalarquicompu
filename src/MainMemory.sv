
//`include "definesPkg.sv"
import definesPkg::*;

// Simple Dual-Port RAM with different read/write addresses and single read/write clock
// and with a control for writing single bytes into the memory word; byte enable

//Cambiar el diseno para que que solo tenga un inout port de write/read line

module MainMemory( 
   input clk, 
	input reset,
	input Taddress addr,
	input [31:0] wdata, 
	input we,
	input Tmesi_state mesi_state_in,
	output [31:0] rdata,
	output Tmesi_state mesi_state_out,
	output [15:0] Page_reference_out
	//input [49:0] write_line, 
	//output [49:0] read_line
);


initial begin
	$display ("Initializing the Main memory");
   $readmemb("main_memory_page0.txt",ram_pg0);
	$readmemb("main_memory_page1.txt",ram_pg1);
end
	// use a multi-dimensional packed array to model individual bytes within the word
	//logic [BYTES-1:0][BYTE_WIDTH-1:0] ram[0:31-1];
   //logic [255:0]ram [63:0];// Debo poner los 96 bits para tener toda la informacion??? o solo con el data es suficiente. Asi, si me infiere la RAM
	logic [49:0]ram_pg0 [255:0]; //Page 0
	logic [49:0]ram_pg1 [255:0]; //page 1
	//logic [1:0][63:0]ram [255:0]; //
	logic [49:0] read_line;
	logic [49:0] write_line;
	always_ff@(posedge clk)
	begin
	//Writes
		if(we) begin
				if (addr.Index < 256 ) begin
					ram_pg0[addr.Index] <= write_line;
				end
				else if (addr.Index > 255 && addr.Index < 513) begin
					ram_pg1[addr.Index - 255] <= write_line;
				end
				else begin
			      $display("Index %h not found in main memory write", addr.Index);				
				end
		end// end we
		//read
		if (addr.Index < 256 ) begin
		   read_line <= ram_pg0[addr.Index];
		end 
		else if (addr.Index > 255 && addr.Index < 513) begin
			 read_line <= ram_pg1[addr.Index - 255];
		end
		else begin
			$display("Index %h not found in main memory read", addr.Index);
		end
	end
	
	assign write_line = we ? {mesi_state_in, addr.Page_reference, wdata[31:0]} : 'bz;
	assign rdata = read_line[31:0];
	assign mesi_state_out = Tmesi_state'(read_line[49:48]);
	assign Page_reference_out = read_line [47:32];
	
endmodule : MainMemory
