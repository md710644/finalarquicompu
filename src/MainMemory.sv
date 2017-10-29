
//`include "definesPkg.sv"
import definesPkg::*;

// Simple Dual-Port RAM with different read/write addresses and single read/write clock
// and with a control for writing single bytes into the memory word; byte enable


module MainMemory( 
   input clk, 
	input reset,
	input Taddress addr,
	input Tdata_sb wdata, 
	input we,
	input Tmesi_state mesi_state_in,
	output Tdata_sb rdata,
	output Tmesi_state mesi_state_out
);


	//localparam int WORDS = 1 << ADDR_WIDTH ;
initial begin
	$display ("Initializing the Main memory");
   $readmemh("main_memory_page0.txt",ram0);
	$readmemh("main_memory_page1.txt",ram1);
end
	// use a multi-dimensional packed array to model individual bytes within the word
	//logic [BYTES-1:0][BYTE_WIDTH-1:0] ram[0:31-1];
   //logic [255:0]ram [63:0];// Debo poner los 96 bits para tener toda la informacion??? o solo con el data es suficiente. Asi, si me infiere la RAM
	logic [65:0]ram0 [255:0]; //Page 0
	logic [63:0]ram1 [255:0]; //page 1
	//logic [1:0][63:0]ram [255:0]; //
	always_ff@(posedge clk)
	begin
		if(we) begin
				if (addr.Page_reference == 0)begin
					ram0[addr.Address_code] <= wdata.Data;
					//ram0[addr.Address_Code][65:64] <= mesi_state_in;
				end
				else if (addr.Page_reference == 1) begin
					ram1[addr.Address_code] <= wdata.Data;
					//ram1[addr.Address_Code][65:64] <= mesi_state_in;
				end
			//ram[addr.Page_reference][addr.Address_code] <= wdata.Data;
		end// end we
		//rdata.Data <= ram[addr.Page_reference][addr.Address_code];
		if (addr.Page_reference == 0)begin
			rdata.Data <= ram0[addr.Address_code];
			//mesi_state_out <= ram0[addr.Address_Code][65:64];
		end 
		else if (addr.Page_reference == 1) begin
			rdata.Data <= ram1[addr.Address_code];
			//mesi_state_out <= ram1[addr.Address_Code][65:64];
		end
	end
endmodule : MainMemory
// no se puede inicializar la memoria con de dos paginas con un solo archivo, no lo lee bien. Mejor hacer dos ram. y cada pagina con un archivo. Es mas facil que leer el archivo con for loops. 