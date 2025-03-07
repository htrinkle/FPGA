module SPI_MODULE(
	input wire clk,
	input wire sck,
	input wire mosi,
	input wire ncs,
	output wire miso
);

wire mosi_o;
wire rst;
wire rd;
wire wr;

SPI_SYNC SPI_SYNC_inst(
	.clk(clk),
	.sck(sck),
	.ncs(ncs),
	.mosi(mosi),
	.mosi_out(mosi_o),
	.spi_reset(rst), 
	.spi_read(rd),
	.spi_write(wr),
);


endmodule