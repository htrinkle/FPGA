module dso_board (
// MCU SPI Interface
	input wire mosi_spi,
	input wire sck_spi,
	input wire ncs_spi,
	output wire miso_spi,
	
// MCU Handshake
	input wire trigger_mcu,
	output wire ready_mcu,	

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

wire pll_clk;
wire [15:0] adc_buf;
wire [11:0] adc_buf_addr;
wire [15:0] adc_buf_data;

// MCU Handshake
assign ready_mcu = 1'b0;
assign led = 3'b001;

// Internal Wiring
assign adc_buf = {adc_a_d, adc_b_d};
assign pmod_a = 8'h55;

// Analog Device Clocks
assign adc_c_a = pll_clk;
assign adc_c_b = pll_clk;
assign dac_c_a = pll_clk;
assign dac_c_b = pll_clk;

// DDS Wiring
assign dac_a_d = adc_a_d;
assign dac_b_d = adc_b_d;

// PLL
PLL_100MHz pll_inst(.inclk0(clk), .c0(pll_clk));

// SPI Interface
spi_module spi_inst(
	// SPI Interface
	.clk(clk),
	.sck(sck_spi),
	.mosi(mosi_spi),
	.ncs(ncs_spi),
	.miso(miso_spi),
	
	// Internal Connections
	.data_in_1({16'hfade, adc_buf}),
	.mem_data(adc_buf_data),
	.mem_addr(adc_buf_addr),
	.q_c(pmod_b),
	//.q_0(q_0),
	//.q_1(q_1)
);



/////////////////////////////////////////////////////
// Analog IO Buffer Management

// ADC Buffer
//register #(.N(16)) adc_buf(
//	.clk(clk),
//	.write_enable(1'b1),
//	.data_in({adc_a_d, adc_b_d}),
//	.q(adc_data)
//);

// DDS Output Buffer
//always @(negedge pll_clk)
//begin
//    {buf1, buf0} = {~buf0, ramp};
//end

endmodule
