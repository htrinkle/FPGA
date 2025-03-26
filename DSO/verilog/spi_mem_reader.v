
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
	output wire [AW-1:0] addr
);

wire sr_word_done;
reg delay_sr_word_done;

// delay reset to sr by one clock such that addr is updated before new memory is latched (on reset of sr)
always @(posedge clk) delay_sr_word_done <= sr_word_done;

// Control Byte Shift
shift_register #(.N(16)) sr_read_mem (
	.clk(clk),

    // Control
	.sel(sel),
	.si(si),
	.falling(falling),
	.rising(rising),
	.reset_flag(reset_flag | delay_sr_word_done),
	.so(so),
	.done_strobe(sr_word_done),

	// Data
	.data_in(data)
	//.data_out(data)
);

// Addr Counter
counter_sre #(.Bits(AW)) addr_counter(
	.clk(clk),
	.en(sr_word_done),
	.sync_reset(reset_flag),
	.q(addr)
);







// reg [3:0] bit_ctr;

// wire inc_adr = ~|bit_ctr;

// // output to spi_bitstream
// assign so = data[bit_ctr];	

// // bit counter
// // count-down counter as most significant bit is shifted out first
// always @(posedge clk) begin
// 	if (reset_flag) begin
// 		bit_ctr <= 4'b1111;
// 	end else if (sel & falling) begin
// 		bit_ctr <=  bit_ctr - 1'b1;
// 	end else begin
// 		bit_ctr <= bit_ctr;
// 	end
// end

// // addr counter
// always @(posedge clk) begin
// 	if (reset_flag) begin
// 		addr <= 0;
// 	end else if (sel & inc_adr & falling) begin
// 		addr <= addr + 1'b1;
// 	end else begin
// 		addr <= addr;
// 	end
// end
	
endmodule