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

localparam Reg0 = 2'd0;
localparam Reg1 = 2'd1;

wire mosi_o;
wire rst;
wire rd;
wire wr;
wire [7:0] control_word;
wire control_word_latched;
wire miso_c, miso_0, miso_1;
wire sel_c, sel_0, sel_1;
wire [1:0] adr;
wire write_enable;

// Break out control signals
assign {write_enable, adr} = control_word[2:0];

// Shift Register Select Lines
assign sel_c = rd & ~control_word_latched;
assign sel_0 = rd & control_word_latched & (adr == Reg0);
assign sel_1 = rd & control_word_latched & (adr == Reg1);

// MISO Multiplexing
assign miso = (~control_word_latched) ? miso_c : 
				(adr == Reg0) ? miso_0 : 
				(adr == Reg1) ? miso_1 : 1'b0;

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
	.write_enable(1'b1),
	.reset_flag(rst),
	// Data
	.full(control_word_latched),	
	.data_in({control_word[7:4], 4'ha}),
	.q(control_word)
);

shift_register #(.N(32)) sr_32_0 (
    // Control
	.clk(clk),
	.sel(sel_0),
	.si(mosi_o),
	.so(miso_0),
	.write_enable(write_enable),
	.reset_flag(rst),
	// Data
	//.full(tmp),	
	.data_in(q_0),
	.q(q_0)
);

shift_register #(.N(32)) sr_32_1 (
    // Control
	.clk(clk),
	.sel(sel_1),
	.si(mosi_o),
	.so(miso_1),
	.write_enable(write_enable),
	.reset_flag(rst),
	// Data
	//.full(tmp),	
	.data_in(q_1),
	.q(q_1)
);

endmodule