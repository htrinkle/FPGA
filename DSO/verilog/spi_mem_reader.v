
module spi_mem_reader#(
	parameter AW = 12
)(
	input wire clk,
	
   // Control
	input wire sel, //implies shift on posedge clk
	input wire rising,
	input wire falling,
	input wire si,
	input wire reset_flag,
	output wire so,
	
	// Data (to memory module)
	input wire [15:0] data,
	output reg [AW-1:0] addr
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
	end else if (sel & falling) begin
		bit_ctr <=  bit_ctr - 1'b1;
	end else begin
		bit_ctr <= bit_ctr;
	end
end

// addr counter
always @(posedge clk) begin
	if (reset_flag) begin
		addr <= 0;
	end else if (sel & inc_adr & falling) begin
		addr <= addr + 1'b1;
	end else begin
		addr <= addr;
	end
end
	
endmodule