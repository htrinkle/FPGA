
module spi_mem_writer #(
	parameter AW = 8
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
	output wire write_enable,
	output wire [7:0] data,
	output wire [AW-1:0] addr
);

assign write_enable = sr_word_done;

// Control Byte Shift
shift_register #(.N(8)) sr_ctrl (
	.clk(clk),

    // Control
	.sel(sel),
	.si(si),
	.falling(spi_sck_falling),
	.rising(spi_sck_rising),
	.reset_flag(rst),
	.so(so),
	.done_strobe(sr_word_done),

	// Data
	.data_in(8'h00),
	.data_out(data)
);

counter_sr #(Bits(AW)) addr_counter(
	.clk(clk),
	.en(sr_word_done),
	.sync_reset(rst),
	.q(addr)
);
	
endmodule