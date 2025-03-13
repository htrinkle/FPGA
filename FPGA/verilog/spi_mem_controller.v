
module spi_mem_controller(
	input wire clk,
	
   // Control
	input wire sel, //implies shift on posedge clk
	input wire si,
	input wire reset_flag,
	output wire so,
	// Data (to memory module)
	input wire [15:0] data,
	output reg [11:0] addr
);

reg [3:0] bit_ctr;

wire inc_adr = ~|bit_ctr;

// output to spi_bitstream
assign so = data[bit_ctr];	

// bit counter
// count-down counter as most significant bit is shifted out first
always @(posedge clk) begin
	if (reset_flag) begin
		bit_ctr <= 4'b1111;
	end else if (sel) begin
		bit_ctr <=  bit_ctr - 1'b1;
	end else begin
		bit_ctr <= bit_ctr;
	end
end

// addr counter
always @(posedge clk) begin
	if (reset_flag) begin
		addr <= 12'd0;
	end else if (sel & inc_adr) begin
		addr <= addr + 1'b1;
	end else begin
		addr <= addr;
	end
end
	
endmodule