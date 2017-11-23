
//`include "definesPkg.sv"
import definesPkg::*;

// Simple Dual-Port RAM with different read/write addresses and single read/write clock
// and with a control for writing single bytes into the memory word; byte enable

//Cambiar el diseno para que que solo tenga un inout port de write/read line

module MainMemory( 
   input clk, 
	input reset,
	input Taddress addr,
	input [63:0] wdata, 
	input we,
	input Tmesi_state mesi_state_in,
	output [63:0] rdata,
	output Tmesi_state mesi_state_out
	//input [65:0] write_line, 
	//output [65:0] read_line
);


initial begin
	$display ("Initializing the Main memory");
   $readmemh("main_memory_page0.txt",ram_pg0);
	$readmemh("main_memory_page1.txt",ram_pg1);
end
	// use a multi-dimensional packed array to model individual bytes within the word
	//logic [BYTES-1:0][BYTE_WIDTH-1:0] ram[0:31-1];
   //logic [255:0]ram [63:0];// Debo poner los 96 bits para tener toda la informacion??? o solo con el data es suficiente. Asi, si me infiere la RAM
	logic [65:0]ram_pg0 [255:0]; //Page 0
	logic [65:0]ram_pg1 [255:0]; //page 1
	//logic [1:0][63:0]ram [255:0]; //
	logic [65:0] read_line;
	logic [65:0] write_line;
	always_ff@(posedge clk)
	begin
	//Writes
		if(we) begin
				if (addr.Page_reference == 0)begin
					ram_pg0[addr.Address_code] <= write_line;
					//ram0[addr.Address_Code][65:64] <= mesi_state_in;
				end
				else if (addr.Page_reference == 1) begin
					ram_pg1[addr.Address_code] <= write_line;
					//ram1[addr.Address_Code][65:64] <= mesi_state_in;
				end
				else begin
			      $display("Page %h not found in main memory write", addr.Page_reference);				
				end
			//ram[addr.Page_reference][addr.Address_code] <= wdata.Data;
		end// end we
		//rdata.Data <= ram[addr.Page_reference][addr.Address_code];
		//read
		if (addr.Page_reference == 0)begin
		   read_line <= ram_pg0[addr.Address_code];
			//rdata.Data <= ram_pg0[addr.Address_code];
			//mesi_state_out <= ram_pg0[addr.Address_Code][68:64];
		end 
		else if (addr.Page_reference == 1) begin
			 read_line <= ram_pg1[addr.Address_code];
			//rdata.Data <= ram_pg1[addr.Address_code];
			//mesi_state_out <= ram_pg1[addr.Address_Code][68:64];
		end
		else begin
			$display("Page %h not found in main memory read", addr.Page_reference);
		end
	end
	
	assign write_line = we ? {mesi_state_in, wdata[63:0]} : 'bz;
	assign rdata = read_line[63:0];
	assign mesi_state_out = Tmesi_state'(read_line[65:64]);
	
endmodule : MainMemory
// no se puede inicializar la memoria con de dos paginas con un solo archivo, no lo lee bien. Mejor hacer dos ram. y cada pagina con un archivo. Es mas facil que leer el archivo con for loops. 