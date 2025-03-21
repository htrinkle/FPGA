// Module Description
//   manage memory address and memory write enable signals
//   when triggered, read 4096 ADC Samples, 1 sample evey (1 + sample_divider) clks
//
//// ADC Buffer SPI Interface
//spi_mem_controller spi_mem_controller_inst(
//	.clk(clk),
//	
//	// from spi_bitstream
//	.sel(spi_sel_out[2]),
//	.si(spi_mosi_out),         // not used
//	.reset_flag(spi_reset_flag),
//	.valid_flag(spi_valid_flag),
//	.so(memADC_so),
//	// to memory module
//	.data(mem_rd_data),
//	.addr(mem_rd_addr),
// .update_flag(adc_done),
// .write_addr(mem_wr_addr)
//);
//
//// ADC Buffer Memory Megafunction
//ram	ram_inst (
////tbMem ram_inst(
//   .clock(clk),
//	.data(adc_filtered),
//	.rdaddress(mem_rd_addr),
//	.wraddress(mem_wr_addr),
//	.wren(adc_mem_wren),
//	.q(mem_rd_data)
//);
//
////ADC to Memory Interface
//adc_controller adc_controller_inst(
//	.clk(clk),
//	.sample_divider(sample_divider),
//	.mem_addr(mem_wr_addr),
//	.mem_en(adc_mem_wren),
//	.done_flag(adc_done),
//	.triggered(adc_trig),
//	//.trigger_en(pmod_nCS & ~pmod_valid), // replace with following line
// .update_en(pmod_nCS),
//	.trigger_req(~but),
//	.trigger_mode(trigger_mode),
//	.rising_edge(rising_edge),
//	.falling_edge(falling_edge)
//);
	
module adc_controller(
	input wire clk,
	input wire [19:0] sample_divider,
	output wire [11:0] mem_addr,			// drives buffer memory and latches buffer offset on done_flag
	output wire mem_en,						// memory read strobe
	output wire done_flag,					// flags buffer full
	output wire triggered,					// 
	input wire update_en,					// able to update read-buffer (i.e. swap read and write buffer)
	input wire trigger_req,					// force trigger if in STATE_WAIT_TRIG - i.e. manual button
	input wire [2:0] trigger_mode,		// trigger mode
	input wire rising_edge,					
	input wire falling_edge
);

parameter auto_trigger = 3'd0;
parameter trigger_rising = 3'd1;
parameter trigger_falling = 3'd2;
parameter manual_trigger = 3'd2;

parameter STATE_WAIT_PREBUF = 2'd0;
parameter STATE_WAIT_TRIG = 2'd1;
parameter STATE_WAIT_FILL = 2'd2;
parameter STATE_WAIT_READ = 2'd3; // We do not want to update read_buffer while nCS is selected (Active Low)

// sample freq = clk freq / (1 + divider)
assign mem_en = (sample_counter == sample_divider);
assign triggered = (state == STATE_WAIT_FILL);
assign done_flag =  (state == STATE_WAIT_READ) & update_en;

wire trigger_flag;
assign trigger_flag = 
	trigger_req | 
	(trigger_mode == auto_trigger) | 
	( (trigger_mode == trigger_rising) & rising_edge) |
	( (trigger_mode == trigger_falling) & falling_edge); 

// State Machine
reg [1:0] state = STATE_WAIT_PREBUF;
reg [1:0] next_state;

always @* 
	case (state)
		STATE_WAIT_PREBUF: next_state = (&buf_ctr) ? STATE_WAIT_TRIG : state;
		STATE_WAIT_TRIG: next_state = (trigger_flag) ? STATE_WAIT_FILL : state;
		STATE_WAIT_FILL: next_state = (&buf_ctr) ? STATE_WAIT_READ : state;
		STATE_WAIT_READ: next_state = (update_en) ? STATE_WAIT_PREBUF : state;
	endcase

always @(posedge clk)
	state <= next_state;

// State Buf Counter - counts number sample intervals
parameter BUF_CTR_ZERO = 10'd0;
reg [9:0] buf_ctr = BUF_CTR_ZERO;
reg bank_sel = 1'b0;

always @(posedge clk)
	if (state == next_state )
		buf_ctr <= (mem_en) ? buf_ctr + 1'b1 : buf_ctr;
	else
		buf_ctr <= BUF_CTR_ZERO; 
	
// Sample Interval Counter
reg [19:0] sample_counter = 20'd0;

always @(posedge clk)
	sample_counter <= (mem_en | (state == STATE_WAIT_READ)) ? 24'd0 : sample_counter + 1'b1;
	
// Bank Selection
always @(posedge clk)
	bank_sel <= (update_en & (state == STATE_WAIT_READ)) ? ~bank_sel : bank_sel;
	
// Memory Address
reg [10:0] mem_addr_ctr = 11'd0;
assign mem_addr = {bank_sel, mem_addr_ctr};

always @(posedge clk)
	mem_addr_ctr = (mem_en) ? mem_addr_ctr + 1'b1 : mem_addr_ctr;

endmodule