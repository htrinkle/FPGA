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
//	.trigger_req(~but)
//);
	
module adc_controller_pretrig(
	input wire clk,

	// Configuration - sample rate
	input wire [19:0] sample_divider,

	// Trigger condition is met
	input wire trigger_req,

	// Should only swap mem banks if SPI is not active - i.e. "Ready" line from SPI_Module is high
	input wire update_en,

	// Memory Buffer Control - note data path is direct from ADC to Memory
	output wire [11:0] mem_addr,		// drives buffer memory and latches buffer offset on done_flag
	output wire mem_en,					// memory write strobe

	// Progress Signals
	output wire [2:0] trigger_state,
	output wire done_flag,				// flags buffer full
	output wire trigger_flag			// used to enable latching of trigger address
);

parameter STATE_WAIT_PREBUF = 2'd0;
parameter STATE_WAIT_TRIG = 2'd1;
parameter STATE_WAIT_FILL = 2'd2;
parameter STATE_WAIT_READ = 2'd3; // We do not want to update read_buffer while nCS is selected (Active Low)

parameter BUF_CTR_ZERO = 10'd0;

// sample freq = clk freq / (1 + divider)

// State Machine
reg [1:0] state = STATE_WAIT_PREBUF;
reg [1:0] next_state;

// Sample interval counter
reg [19:0] sample_counter = 20'd0;

// Memory Address Counter
reg [10:0] mem_addr_ctr = 11'd0;
reg bank_sel = 1'b0; // assigned to most significant address bit.

// buffer occupancy counter 
// memory is implemented as circular buffer, so need to count occupancy separately
reg [9:0] buf_ctr = BUF_CTR_ZERO;

// IO Assignments
assign mem_addr = {bank_sel, mem_addr_ctr};
assign mem_en = (sample_counter == sample_divider);
assign done_flag =  (state == STATE_WAIT_READ) & update_en;
assign trigger_flag = (next_state == STATE_WAIT_FILL) & (state == STATE_WAIT_TRIG);
assign trigger_state = {	state == STATE_WAIT_READ, 
									state == STATE_WAIT_FILL, 
									state == STATE_WAIT_TRIG};

// Trigger State Machine
always @* begin
	case (state)
		STATE_WAIT_PREBUF: next_state = (&buf_ctr) ? STATE_WAIT_TRIG : state;
		STATE_WAIT_TRIG: next_state = (trigger_req) ? STATE_WAIT_FILL : state;
		STATE_WAIT_FILL: next_state = (&buf_ctr) ? STATE_WAIT_READ : state;
		STATE_WAIT_READ: next_state = (update_en) ? STATE_WAIT_PREBUF : state;
	endcase
end

always @(posedge clk) state <= next_state;

// Buffer Occupancy State Machine - reset whenever trigger state changes
always @(posedge clk) begin
	if (state == next_state ) begin
		buf_ctr <= (mem_en) ? buf_ctr + 1'b1 : buf_ctr;
	end else begin
		buf_ctr <= BUF_CTR_ZERO; 
	end
end

// Sample Counter
always @(posedge clk) sample_counter <= (mem_en | (state == STATE_WAIT_READ)) ? 24'd0 : sample_counter + 1'b1;
	
// Memory Addr Statemachine
always @(posedge clk) bank_sel <= (update_en & (state == STATE_WAIT_READ)) ? ~bank_sel : bank_sel;
always @(posedge clk) mem_addr_ctr = (mem_en) ? mem_addr_ctr + 1'b1 : mem_addr_ctr;

endmodule