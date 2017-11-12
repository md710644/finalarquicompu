
 module MemoryController
(
	// Input Ports
	input clk,
	input reset,
	input req_CPU,
	input req_EXT,
	input [65:0] read_line,
	// Output Ports
	output [65:0] write_line,
	output we, 
	output reg gnt_CPU, 
	output reg gnt_EXT
);
/*
   input clk, 
	input reset,
	input Taddress addr,
	input Tdata_sb wdata, 
	input we,
	input Tmesi_state mesi_state_in,
	output Tdata_sb rdata,
	output Tmesi_state mesi_state_out
*/
   
	//Calculate mesi_state_in
	// parameter declaration
	parameter SIZE = 2;
	parameter IDLE = 3'b001;
	parameter GNT_CPU = 3'b010;	
	parameter GNT_EXT	= 3'b100;
	
	// variable declaration
	logic [SIZE-1:0] current_state;
	logic [SIZE-1:0] next_state;
	// combinatorial assignment of next_state
	always_comb begin
		next_state = 3'b000;
		case (current_state)
			IDLE: 
				if (req_CPU) begin
					next_state = GNT_CPU;
				end else if (req_EXT) begin
					next_state = GNT_EXT;
				end else begin
					next_state = IDLE;
				end
			GNT_CPU: 
				if (req_CPU) begin
					next_state = GNT_CPU;
				end else if (req_EXT) begin
					next_state = GNT_EXT;
				end else begin
					next_state = IDLE;
				end
			GNT_EXT:
				if (req_EXT) begin
					next_state = GNT_EXT;
				end else if (req_CPU) begin
					next_state = GNT_CPU;
				end else begin
					next_state = IDLE;	
				end
		default: next_state = IDLE;	
					
		endcase
	end
	
	// sequential assignment of current_state
	always @(posedge clk) begin : FSM_SEQ
		if (reset) begin
			current_state <= IDLE;
		end
		else begin
			current_state <= next_state;
		end
	end

	
//Output logic
	always @(posedge clk) begin
		if (reset) begin
			gnt_CPU <= 'b0;
			gnt_EXT <= 'b0;
		end
		else begin
			case (current_state)
				IDLE: begin
							gnt_CPU <= 'b0;
							gnt_EXT <= 'b0;
						end
				GNT_CPU: begin
							gnt_CPU <= 'b1;
							gnt_EXT <= 'b0;
						end
				GNT_EXT: begin
							gnt_CPU <= 'b0;
							gnt_EXT <= 'b1;				
						end
				default: begin
							gnt_CPU <= 'b0;
							gnt_EXT <= 'b0;
						end
			endcase
		end
	end
	
	
	//assign write_line = we ? {mesi_state_in, wdata.Data} : 'bz;
	//assign rdata.Data = read_line[63:0];
	//assign mesi_state_out = Tmesi_state'(read_line[65:64]);
	
endmodule
