
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
	output wire [11:0] addr,
	//
	input update_flag,
	input wire [11:0] write_addr
);

// count-down counter as most significant bit is shifted out first
wire bit_ctr_null = ~|bit_ctr;

// read addr counter
reg [10:0] addr_ctr;

// last addr 
reg [11:0] last_write_addr;

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
		addr_ctr <= last_write_addr[10:0];// + 1'b1;
	end else if (sel & bit_ctr_null & valid_flag) begin
		addr_ctr <= addr_ctr + 1'b1;
	end else begin
		addr_ctr <= addr_ctr;
	end
end

// last_wr_addr 
always @(posedge clk)
	last_write_addr <= (update_flag) ? write_addr : last_write_addr;

// output to spi_bitstream
assign so = data[bit_ctr];	

assign addr = {last_write_addr[11], addr_ctr};
	
endmodule