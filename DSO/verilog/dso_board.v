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

// Config Wiring
wire [31:0] adc_cfg, dds_a_cfg, dds_b_cfg;

// ADC Memory Buffer Wiring
wire [11:0] adc_buf_addr;
wire [15:0] adc_buf_data;

// DDS Wiring
wire [8:0] dds_a_addr, dds_a_r_addr, dds_b_addr, dds_b_r_addr;
wire [7:0] dds_a_data, dds_a_r_data, dds_b_data, dds_b_r_data;
wire [7:0] dds_a_dac_data, dds_b_dac_data;
wire dds_a_w, dds_b_w;

// ADC and DAC buffering
reg [15:0] adc_buf;
reg [7:0] dds_a_buf, dds_b_buf;

////////////////////////////////////////////////////////////////////////////
// Assignments

// MCU Handshake
assign ready_mcu = 1'b0;

// Analog Device Clocks
assign adc_a_c = pll_clk;
assign adc_b_c = pll_clk;
assign dac_a_c = pll_clk;
assign dac_b_c = pll_clk;

// DDS Wiring
assign dac_a_d = dds_a_buf;
assign dac_b_d = dds_b_buf;

// ADC
assign adc_buf_data = adc_buf;

// PMOD, LED, and Buttons
assign pmod_a = adc_cfg[7:0];
assign pmod_b = adc_buf[7:0];
assign led = 3'b001;

////////////////////////////////////////////////////////////
// Module Instantiations

// PLL
PLL_100MHz pll_inst(.inclk0(clk), .c0(pll_clk));

// SPI Interface
spi_module #(.DDS_AW(9)) spi_inst(
	.clk(pll_clk),
	
	// SPI Interface
	.sck_spi(sck_spi),
	.mosi_spi(mosi_spi),
	.ncs_spi(ncs_spi),
	.miso_spi(miso_spi),
	
	// Configuration Outouts
	//.q_c(pmod_b),
	.adc_cfg_out(adc_cfg),
	.dds_a_cfg_out(dds_a_cfg),
	.dds_b_cfg_out(dds_b_cfg),

	// ADC Buffer Connections
	.mem_data(adc_buf_data),
	.mem_addr(adc_buf_addr),
	
	// DDS Wave Table Connections
   .dds_a_data(dds_a_data),
	.dds_b_data(dds_b_data),
	.dds_a_addr(dds_a_addr),
   .dds_b_addr(dds_b_addr),
   .dds_a_w(dds_a_w),
	.dds_b_w(dds_b_w)
);

// DDS_A wave-table memory
ram_dds ram_dds_a (
	.clock(pll_clk),
	.data(dds_a_data),
	.wraddress(dds_a_addr),
	.wren(dds_a_w),
	.rdaddress(dds_a_r_addr),
	.q(dds_a_r_data)
);

// DDS_B wave-table memory
ram_dds ram_dds_b (
	.clock(pll_clk),
	.data(dds_b_data),
	.wraddress(dds_b_addr),
	.wren(dds_b_w),
	.rdaddress(dds_b_r_addr),
	.q(dds_b_r_data)
);

// DDS_A phase accumulator and controller
dds #(.DDS_AW(9)) dds_a (
	.clk(pll_clk),
	.cfg(dds_a_cfg),
	.tbl_data(dds_a_r_data),
	.tbl_addr(dds_a_r_addr),
	.q(dds_a_dac_data)
);

// DDS_B phase accumulator and controller
dds #(.DDS_AW(9)) dds_b (
	.clk(pll_clk),
	.cfg(dds_b_cfg),
	.tbl_data(dds_b_r_data),
	.tbl_addr(dds_b_r_addr),
	.q(dds_b_dac_data)
);

///////////////////////////////////////
// Analog I/O Buffering

// DDS Output Buffer

always @(negedge pll_clk) {dds_a_buf, dds_b_buf} <= {dds_a_dac_data, dds_b_dac_data};

// ADC Input Buffer
always @(posedge pll_clk) adc_buf <= {adc_a_d, adc_b_d};

endmodule
