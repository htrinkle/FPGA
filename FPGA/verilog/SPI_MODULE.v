module spi_module(
	input wire clk,
	input wire sck,
	input wire mosi,
	input wire ncs,
	output wire miso,
	output wire [7:0] q_c,
	output wire [31:0] q_0,
	output wire [31:0] q_1
);

wire mosi_o;
wire rst;
wire rd;
wire wr;
wire [7:0] control_word;
wire control_read;
wire miso_c, miso_0, miso_1;
wire sel_c, sel_0, sel_1;

assign sel_c = rd & ~control_read;
assign sel_0 = rd & control_read & ~control_word[0];
assign sel_1 = rd & control_read &  control_word[0];
assign miso = (~control_read) ? miso_c : control_word[0] ? miso_1 : miso_0;
assign q_c = control_word;

spi_sync spi_sync_inst(
	.clk(clk),
	.sck(sck),
	.ncs(ncs),
	.mosi(mosi),
	.mosi_out(mosi_o),
	.spi_reset(rst), 
	.spi_read(rd),
	.spi_write(wr)
);

shift_register #(.N(8)) sr_ctrl (
    // Control
	.clk(clk),
	.sel(sel_c),
	.si(mosi_o),
	.so(miso_c),
	.reset_flag(rst),
	// Data
	.full(control_read),	
	.data_in({control_word[7:4], 4'ha}),
	.q(control_word)
);

shift_register #(.N(32)) sr_32_0 (
    // Control
	.clk(clk),
	.sel(sel_0),
	.si(mosi_o),
	.so(miso_0),
	.reset_flag(rst),
	// Data
	//.full(tmp),	
	.data_in(32'h01234567),
	.q(q_0)
);

shift_register #(.N(32)) sr_32_1 (
    // Control
	.clk(clk),
	.sel(sel_1),
	.si(mosi_o),
	.so(miso_1),
	.reset_flag(rst),
	// Data
	//.full(tmp),	
	.data_in(32'h11223344),
	.q(q_1)
);

endmodule