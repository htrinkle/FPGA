
module spi_mem_controller(
	input wire clk,
	
	// from spi_bitstream
	input wire sel,
	input wire si,         // not used
	input wire reset_flag,
	input wire valid_flag,
	output wire so,
	// to memory module
	input wire [15:0] data,
	output reg [11:0] addr
);

// count-down counter as most significant bit is shifted out first
wire bit_ctr_null = ~|bit_ctr;

// bit counter
reg [3:0] bit_ctr;
always @(posedge clk) begin
	if (reset_flag) begin
		bit_ctr <= 4'b1111;
	end else if (sel & valid_flag) begin
		bit_ctr <=  bit_ctr - 1'b1;
	end else begin
		bit_ctr <= bit_ctr;
	end
end
// addr counter
always @(posedge clk) begin
	if (reset_flag) begin
		addr <= 12'd0;
	end else if (sel & bit_ctr_null & valid_flag) begin
		addr <= addr + 1'b1;
	end else begin
		addr <= addr;
	end
end

// output to spi_bitstream
assign so = data[bit_ctr];	
	
endmodule