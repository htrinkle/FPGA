module analog_acquisition_tool (
// MCU SPI Interface
	input wire mosi,
	input wire sck,
	input wire ncs,
	output wire miso,
	
// MCU Handshake
	output wire ready,	
	input wire trigger,

// Onboard Devices
	 input wire clk,
	 input wire button,
	 input wire [7:0] adc_a_d,
	 input wire [7:0] adc_b_d,	 
	 output wire [2:0] led,
	 output wire [7:0] dac_a_d,
	 output wire [7:0] dac_b_d,
	 output wire dac_a_c,
	 output wire dac_b_c,
	 output wire adc_a_c,
	 output wire adc_b_c,
		 
// Board IO Headers
	output wire [7:0] pmod_a,
	output wire [7:0] pmod_b
);

localparam LedCounterWidth= $clog2(24_000_000 / 2);

reg [7:0] buf1, buf0;

wire [7:0] ramp;
wire [LedCounterWidth-1:0] led_q;
wire [31:0] q_0;
wire [15:0] adc_data;
wire [11:0] mem_addr;
wire [15:0] mem_data;
wire pll_clk;

// IO Assignments
assign dac_a_c = pll_clk; 
assign dac_b_c = pll_clk; 
assign adc_a_c = pll_clk; 
assign adc_b_c = pll_clk; 
assign dac_a_d = buf1;
assign dac_b_d = buf1;
assign led = led_q[LedCounterWidth-1 : LedCounterWidth-3];
assign pmod_a = q_0[7:0];
assign ready = 1'd0;

assign mem_data = adc_data;

// PLL
PLL_100MHz pll_inst(.inclk0(clk), .c0(pll_clk));
// assign pll_clk = clk;  // bypass pl
// assign pll_clk_dac = ~clk;  // bypass pl

// DAC Ramp Counter 
counter_sr #(.Bits(8)) ramp_ctr(.clk(pll_clk), .sync_reset(~button), .q(ramp));

// LED Counter
counter_sr #(.Bits(LedCounterWidth)) led_ctr(.clk(clk), .sync_reset(~button), .q(led_q));

// ADC Buffer
register #(.N(16)) adc_buf(
	.clk(clk),
	.write_enable(1'b1),
	.data_in({adc_a_d, adc_b_d}),
	.q(adc_data)
);

// SPI Interface
spi_module spi_inst(
	.clk(clk),
	.sck(sck),
	.mosi(mosi),
	.ncs(ncs),
	.miso(miso),
	.data_in_1({16'hfade, adc_data}),
	.mem_data(mem_data),
	.mem_addr(mem_addr),
	.q_c(pmod_b),
	.q_0(q_0),
	//.q_1(q_1)
);

always @(negedge pll_clk)
begin
    {buf1, buf0} = {~buf0, ramp};
end

endmodule
