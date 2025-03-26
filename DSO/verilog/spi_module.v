module spi_module(
	input wire clk,

	// SPI Interface
	input wire ncs_spi,
	input wire sck_spi,
	input wire mosi_spi,
	output wire miso_spi,
	
	// Configuration Outouts
	output wire [7:0] q_c,
	output wire [31:0] adc_cfg_out,
	output wire [31:0] dds_a_cfg_out,
	output wire [31:0] dds_b_cfg_out,

	// ADC Buffer Connections
	input wire [15:0] mem_data,
	output wire [11:0] mem_addr

	// DDS Wave Table RAM
	//output wire [7:0] dds_data,
	//output wire [8:0] dds_addr,
	//output wire dds_a_tbl_w,
	//output wire dds_b_tbl_w
);

// DeviceID ored with version is writtent to SPI while reading control word.
// May be used to detect DSO verilog version. 
localparam DsoDeviceId = 8'h90; 
localparam DsoDeviceVersion = 8'h01;

localparam AdcCfgAddr = 3'd0;
localparam AdcBufAddr = 3'd1;
localparam DDSaCfgAddr = 3'd2;
localparam DDSbCfgAddr = 3'd3;
localparam DDSaTblAddr = 3'd4;
localparam DDSbTblAddr = 3'd5;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Wiring internal to module

// SPI wiring to Internal SPI Peripherals
wire mosi_o;
wire rst;
wire spi_sck_rising;
wire spi_sck_falling;
wire sel_c, sel_adc_cfg, sel_adc_buf, sel_dds_a_cfg, sel_dds_b_cfg, sel_dds_a_tbl, sel_dds_b_tbl, sel_status;
wire miso_c, miso_adc_cfg, miso_adc_buf, miso_dds_a_cfg, miso_dds_b_cfg, miso_dds_a_tbl, miso_dds_b_tbl, miso_status;

// Shift Register Related Wiring

// Command Byte - first byte from MCU to FPGA in any SPI session
wire [7:0] sr_control_out;
wire sr_control_done;
// Signals break-out wwiring
wire [2:0] addr; 
wire write_enable;

// Configuration shift registers
// Convention: _int denotes internal connection between a shift register and an output buffer register

// ADC Config
wire [31:0] adc_cfg_int;
wire sr_32_adc_cfg_done_strobe, sr_32_adc_done;

// DDS Config
wire [31:0] dds_a_cfg_int, dds_b_cfg_int;
wire sr_32_dds_a_cfg_done_strobe, sr_32_dds_b_cfg_done_strobe;

// DDS Wave Table Wiring
wire [7:0] dds_a_write_addr;
wire [7:0] dds_a_write_data;
wire dds_a_write_strobe;

// ADC Data - note 16 bit status word is read out before ADC data buffer
wire sr_16_status_done;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Assignments Section

// Break out control signals
assign addr = sr_control_out[2:0];
assign write_enable = sr_control_out[7];

// Address Decoder - Generate SPI Peripheral Select Lines
assign sel_c = ~sr_control_done;
assign sel_adc_cfg = sr_control_done & (addr == AdcCfgAddr);
assign sel_status = sr_control_done & (addr == AdcBufAddr); // First read 16 bit status
assign sel_adc_buf = sr_16_status_done & (addr == AdcBufAddr);		// then ADC buffer
assign sel_dds_a_cfg = sr_control_done & (addr == DDSaCfgAddr);
assign sel_dds_b_cfg = sr_control_done & (addr == DDSbCfgAddr);
assign sel_dds_a_tbl = sr_control_done & (addr == DDSaTblAddr);
assign sel_dds_b_tbl = sr_control_done & (addr == DDSbTblAddr);


// Muliplex miso signal to based on selected peripheral
assign miso_spi = 	sel_c 			& miso_c | 
					sel_adc_cfg 	& miso_adc_cfg | 
					sel_adc_buf 	& miso_adc_buf | 
					sel_dds_a_cfg	& miso_dds_a_cfg |
					sel_dds_b_cfg	& miso_dds_b_cfg |
					sel_dds_a_tbl	& miso_dds_a_tbl |
					sel_dds_b_tbl	& miso_dds_b_tbl |
					sel_status		& miso_status;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////
// SPI Internal Modules Instatniation

// SPI SCK sync to internal clock
spi_sync spi_sync_inst(
	// MCU Interface
	.clk(clk),
	.sck(sck_spi),
	.ncs(ncs_spi),
	.mosi(mosi_spi),

	// Output to SPI peripherals
	.mosi_out(mosi_o),
	.spi_start(rst), 
	.spi_sck_rising(spi_sck_rising),
	.spi_sck_falling(spi_sck_falling)
);

// Control Byte Shift
shift_register #(.N(8)) sr_ctrl (
	.clk(clk),

    // Control
	.sel(sel_c),
	.si(mosi_o),
	.falling(spi_sck_falling),
	.rising(spi_sck_rising),
	.reset_flag(rst),
	.so(miso_c),
	.done(sr_control_done),

	// Data
	.data_in(DsoDeviceId | DsoDeviceVersion),
	.data_out(sr_control_out)
);

// ADC Config (32 bit shift register)
shift_register #(.N(32)) sr_32_adc (
	.clk(clk),

    // Control
	.sel(sel_adc_cfg),
	.si(mosi_o),
	.so(miso_adc_cfg),
	.falling(spi_sck_falling),
	.rising(spi_sck_rising),
	.reset_flag(rst),
	.done_strobe(sr_32_adc_cfg_done_strobe),

	// Data	
	.data_in(adc_cfg_out),
	.data_out(adc_cfg_int)
);

register #(.N(32)) r_32_adc (
	.clk(clk),	
	.write_enable(write_enable & sr_32_adc_cfg_done_strobe),	
	.data_in(adc_cfg_int),	
	.q(adc_cfg_out)
);

// DDS A Config (32 bit shift register)
shift_register #(.N(32)) sr_32_dds_a (
	.clk(clk),

    // Control
	.sel(sel_dds_a_cfg),
	.si(mosi_o),
	.so(miso_dds_a_cfg),
	.falling(spi_sck_falling),
	.rising(spi_sck_rising),
	.reset_flag(rst),
	.done_strobe(sr_32_dds_a_cfg_done_strobe),

	// Data	
	.data_in(dds_a_cfg_out),
	.data_out(dds_a_cfg_int)
);

register #(.N(32)) r_32_dds_a (
	.clk(clk),	
	.write_enable(write_enable & sr_32_dds_a_cfg_done_strobe),	
	.data_in(dds_a_cfg_int),	
	.q(dds_a_cfg_out)
);

// DDS B Config (32 bit shift register)
shift_register #(.N(32)) sr_32_dds_b (
	.clk(clk),

    // Control
	.sel(sel_dds_b_cfg),
	.si(mosi_o),
	.so(miso_dds_b_cfg),
	.falling(spi_sck_falling),
	.rising(spi_sck_rising),
	.reset_flag(rst),
	.done_strobe(sr_32_dds_b_cfg_done_strobe),

	// Data	
	.data_in(dds_b_cfg_out),
	.data_out(dds_b_cfg_int)
);

register #(.N(32)) r_32_dds_b (
	.clk(clk),	
	.write_enable(write_enable & sr_32_dds_b_cfg_done_strobe),	
	.data_in(dds_b_cfg_int),	
	.q(dds_b_cfg_out)
);

// DDS B Config (32 bit shift register)
shift_register #(.N(16)) sr_16_status (
	.clk(clk),

    // Control
	.sel(sel_status),
	.si(mosi_o),
	.so(miso_status),
	.falling(spi_sck_falling),
	.rising(spi_sck_rising),
	.reset_flag(rst),
	//.done_strobe(),
	.done(sr_16_status_done),

	// Data	
	.data_in(16'h1234)
	//.data_out(dds_b_cfg_out)
);

// Sequential memory read
spi_mem_reader #(.AW(12)) adc_mem_reader (
	.clk(clk),

    // Control
	.sel(sel_adc_buf),
	.si(mosi_o),
	.so(miso_adc_buf),
	.falling(spi_sck_falling),
	.rising(spi_sck_rising),
	.reset_flag(rst),

	// Data	
	.data(mem_data),
	.addr(mem_addr)
);

// dds memory writer
spi_mem_writer #(.AW(8)) dds_a_mem_writer (
	.clk(clk),
	
   // Control
 	.reset_flag(rst),  
   	.sel(sel_dds_a_tbl),
	.si(mosi_o),
	.so(miso_dds_a_tbl),
	.falling(spi_sck_falling),
	.rising(spi_sck_rising),

	// Data (to memory module)
	.write_enable_out(dds_a_write_strobe),
	.data(dds_a_write_data),
	.addr(dds_a_write_addr)
);

endmodule