module adc_driver #(
	parameter DEPTH = 11,
	parameter DEL_W = 24
)(
	input wire clk,

	// sample freq = clk freq / (1 + sample_divider)
	input wire [DEL_W-1:0] sample_divider,
	input wire [1:0] mode,

	// Trigger condition is met
	input wire trigger_req,

	// Should only swap mem banks if SPI is not active - i.e. "Ready" line from SPI_Module is high
	input wire ready,	// consumer is ready to receive
	output wire valid,  // adc data is valid

	// Memory Buffer Control - note data path is direct from ADC to Memory
	output wire [DEPTH:0] mem_addr,		// drives buffer memory and latches buffer offset on done_flag
	output wire mem_en,					// memory write strobe
	output wire [DEPTH:0] trig_addr,		// trigger address to be used by SPI_Module

	// Status
	output wire waiting_for_trigger,
	output wire triggered
);

	localparam STATE_WAIT_PREBUF = 2'd0;
	localparam STATE_WAIT_TRIG = 2'd1;
	localparam STATE_WAIT_FILL = 2'd2;
	localparam STATE_WAIT_READ = 2'd3; // We do not want to update read_buffer while nCS is selected (Active Low)

	localparam MODE_NORM = 0;
	localparam MODE_AUTO = 1;
	localparam MODE_IMMEDIATE = 2;

	// State Machine
	reg [1:0] state = STATE_WAIT_PREBUF;
	reg [1:0] next_state;

	// Memory Address Counter
	wire [DEPTH-1:0] mem_addr_ctr_q;
	wire [DEPTH:0] trig_addr_q;  // Note this includes bank_sel as msb
	wire buf_update_flag;  // When set, bank_sel will toggle and read has occured
	reg bank_sel = 1'b0;   // assigned to most significant address bit.

	// Sampling Interval Divider
	wire [DEL_W-1:0] sample_divider_q;
	wire sample_flag;

	// Sample Counter
	wire [DEPTH-1:0] sample_q;
	wire half_buffer_sampled = sample_q[DEPTH-1];

	// Trigger
	wire trigger_flag;
	wire trigger_req_internal; 

	// Signal Assignments
	assign sample_flag = sample_divider_q == sample_divider;
	assign buf_update_flag = ready & valid;
	assign trigger_req_internal = trigger_req;// | 
							//	(mode == MODE_IMMEDIATE) |
							//	((mode == MODE_AUTO & half_buffer_sampled));

	// IO Assignments
	assign mem_addr = {bank_sel, mem_addr_ctr_q};
	assign mem_en = sample_flag;
	assign valid = (state == STATE_WAIT_READ);
	assign waiting_for_trigger = (state == STATE_WAIT_TRIG);
	assign trigger_flag = (next_state == STATE_WAIT_FILL) & waiting_for_trigger;
	assign triggered = (state == STATE_WAIT_FILL);


	// Trigger State Machine
	always @* begin
		case (state)
			STATE_WAIT_PREBUF: next_state = (half_buffer_sampled) ? STATE_WAIT_TRIG : state;
			STATE_WAIT_TRIG: next_state = (trigger_req_internal) ? STATE_WAIT_FILL : state;
			STATE_WAIT_FILL: next_state = (half_buffer_sampled) ? STATE_WAIT_READ : state;
			STATE_WAIT_READ: next_state = (buf_update_flag) ? STATE_WAIT_PREBUF : state;
		endcase
	end

	always @(posedge clk) state <= next_state;

	// Buffer Occupancy State Machine - reset whenever trigger state changes
	counter_sre #(.Bits(DEL_W)) sample_divider_ctr(.clk(clk), .en(1'b1), .sync_reset(sample_flag), .q(sample_divider_q));

	// Sample Counter - resets onchange of state
	counter_sre #(.Bits(DEPTH)) sample_ctr(.clk(clk), .en(sample_flag), .sync_reset(next_state != state), .q(sample_q));

	// Memory Addr Statemachine
	counter_sre #(.Bits(DEPTH)) addr_ctr(.clk(clk), .en(sample_flag), .sync_reset(next_state != state), .q(mem_addr_ctr_q));
	always @(posedge clk) bank_sel <= (buf_update_flag) ? ~bank_sel : bank_sel;

	// Trigger Capture - captures bank and address of trigger event
	register #(.N(DEPTH+1)) trig_add_reg(.clk(clk), .write_enable(trigger_flag), .data_in(mem_addr), .q(trig_addr_q));

	// Trigger Buffer - Persist Trigger {bank, addr} for use by consumer while acquisition continues on alternative bank
	// Consumer should treat:
	//		 trig_addr[DEPTH-1] as bank select signal
	//		 trig_addr[DEPTH-2:0] as the actual address out of [DEPTH-2:0] circular buffer at which trigger happened.
	register #(.N(DEPTH+1)) trig_buf_reg(.clk(clk), .write_enable(buf_update_flag), .data_in(trig_addr_q), .q(trig_addr));

endmodule