
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
	output wire write_enable_out,
	output wire [7:0] data,
	output wire [AW-1:0] addr
);

wire sr_word_done;

assign write_enable_out = sr_word_done;

// Control Byte Shift
shift_register #(.N(8)) sr_write_mem (
	.clk(clk),

    // Control
	.sel(sel),
	.si(si),
	.falling(falling),
	.rising(rising),
	.reset_flag(reset_flag | sr_word_done),
	.so(so),
	.done_strobe(sr_word_done),

	// Data
	.data_in(8'h00),
	.data_out(data)
);

// Addr Counter
counter_sre #(.Bits(AW)) addr_counter(
	.clk(clk),
	.en(sr_word_done),
	.sync_reset(reset_flag),
	.q(addr)
);
	
endmodule