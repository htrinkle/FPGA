
module spi_readable_memory(
	input wire clk,
	input wire sel,
	input wire si,
	input wire reset_flag,
	input wire valid_flag,
	output wire so,
	input wire [15:0] q,
	input wire write_enable_flag,
	input wire write_reset_flag
);

parameter read_ctr_msb = 4 + 6 - 1;

reg [15:0] mem[0:63];




reg [5:0] write_ctr;
reg [read_ctr_msb:0] read_bit_ctr;
wire [15:0] word0, word1, word2;
wire [15:0] current_word;

assign word0 = mem[6'd0];
assign word1 = mem[6'd1];
assign word2 = mem[6'd2];

assign current_word = mem[read_bit_ctr[read_ctr_msb:4]];

assign so = current_word[4'b1111-read_bit_ctr[3:0]] ;

// Parallel Write

// write counter
always @(posedge clk) begin
	if (write_reset_flag) 
		write_ctr <= 0;
	else if (write_enable_flag)
		write_ctr <= write_ctr + 1;
	else
		write_ctr <= write_ctr;
end

// memory write
always @(posedge clk)
	if (write_enable_flag)
		mem[write_ctr] <= q;

// SPI Read

always @(posedge clk)
	read_bit_ctr <= (reset_flag) ? 0 : (valid_flag & sel) ? read_bit_ctr + 1 : read_bit_ctr;

initial begin
	mem[6'd0] = 16'hAA55;
	mem[6'd1] = 16'h0001;
end
	
endmodule