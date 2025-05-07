module adc_driver_test #(
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
	output wire [DEPTH-1:0] mem_addr,		// drives buffer memory and latches buffer offset on done_flag
	output wire mem_en,					// memory write strobe
	output wire [DEPTH-1:0] trig_addr,		// trigger address to be used by SPI_Module
	output reg bank_sel = 1'b0, 

	// Status
	output wire [1:0] trigger_state,
	output wire waiting_for_trigger,
	output wire triggered
);

	localparam STATE_WAIT_PREBUF = 2'd0;
	localparam STATE_WAIT_TRIG = 2'd1;
	localparam STATE_WAIT_FILL = 2'd2;
	localparam STATE_WAIT_READ = 2'd3;

	localparam MODE_NORM = 0;
	localparam MODE_AUTO = 1;
	localparam MODE_IMMEDIATE = 2;

	reg [DEL_W-1:0] sample_divider_q = 0;
	reg [DEPTH-1:0] addr, next_addr;
	reg [1:0] state = STATE_WAIT_PREBUF;
	reg [1:0] next_state;
	reg trigger_req_buf = 0;
	wire buf_update_flag;
	wire trigger_flag;
	wire sample_strobe;

	// IO Assignments

	assign sample_strobe = ~|sample_divider_q;
	assign valid = (state == STATE_WAIT_READ);
	assign mem_addr = addr;
	assign mem_en = sample_strobe & (state != STATE_WAIT_READ);
	assign trig_addr = 0;
	assign trigger_state = state;
	assign waiting_for_trigger = (state == STATE_WAIT_TRIG);
	assign triggered = (state == STATE_WAIT_FILL) | (state == STATE_WAIT_READ) ;

	// State Machine

	assign buf_update_flag = ready & valid;

	assign trigger_flag = trigger_req_buf | mode == MODE_IMMEDIATE;

	always @(posedge clk) begin
		if (sample_strobe) 	sample_divider_q <= sample_divider;
		else 				sample_divider_q <= sample_divider_q - 1'b1;
	end

	always @* begin
		case (state)
			STATE_WAIT_PREBUF: next_state = STATE_WAIT_TRIG ;
			STATE_WAIT_TRIG:   next_state = (trigger_flag) ? STATE_WAIT_FILL : STATE_WAIT_TRIG ;
			STATE_WAIT_FILL:   next_state = (&addr) ? STATE_WAIT_READ : STATE_WAIT_FILL;
			STATE_WAIT_READ:   next_state = (buf_update_flag) ? STATE_WAIT_PREBUF : STATE_WAIT_READ;
		endcase
	end

	always @* begin
		case (state)
			STATE_WAIT_PREBUF: next_addr = 0;
			STATE_WAIT_TRIG:   next_addr = 0;
			STATE_WAIT_FILL:   next_addr = (sample_strobe) ? addr+1'b1 : addr;
			STATE_WAIT_READ:   next_addr = 0;
		endcase
	end

	always @(posedge clk) trigger_req_buf <= trigger_req;

	always @(posedge clk) state <= next_state;

	always @(posedge clk) addr <= next_addr;

	always @(posedge clk) bank_sel <= (buf_update_flag) ? ~bank_sel : bank_sel;


endmodule
