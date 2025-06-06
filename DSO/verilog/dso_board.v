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

	parameter BUF_DEPTH = 11;
	parameter DDS_DEPTH = 9;
	
	//////////////////////////////////////////////////////////////////////////
	// wires and register
	
	wire pll_clk;
	
	// SPI Wiring
	wire spi_busy;
	
	// Config Wiring
	wire [31:0] adc_cfg, dds_a_cfg, dds_b_cfg;
	
	// ADC Memory Buffer Wiring
	wire [BUF_DEPTH-1:0] adc_buf_w_addr, trig_addr;
	wire [BUF_DEPTH-1:0] adc_buf_r_addr;
	wire [15:0] adc_buf_data;
	wire adc_buf_wen;
	wire trigger_flag;
	wire trigger_wait, trigger_seen, adc_buf_full;
	reg  adc_data_available = 0;
	wire bank_sel;
	wire [1:0] adc_trig_state;
	wire trig_ch_a, trig_ch_b, trigger_signal;
	
	// DDS Wiring
	wire [DDS_DEPTH-1:0] dds_a_addr, dds_a_r_addr, dds_b_addr, dds_b_r_addr;
	wire [7:0] dds_a_data, dds_a_r_data, dds_b_data, dds_b_r_data;
	wire [7:0] dds_a_dac_data, dds_b_dac_data;
	wire dds_a_w, dds_b_w;
	
	// ADC and DAC buffering
	reg [15:0] adc_buf, adc_buf_n;
	reg [7:0] dds_a_buf, dds_b_buf;
	
	//////////////////////////////////////////////////////////////////////////
	// Assignments
	
	// MCU Handshake
	assign led = ~{trigger_wait, trigger_seen, adc_buf_full};
	//assign led = ~{adc_data_available, adc_trig_state};
	assign ready_mcu = adc_data_available;
		
	// Analog Device Clocks
	assign adc_a_c = pll_clk;
	assign adc_b_c = pll_clk;
	assign dac_a_c = pll_clk;
	assign dac_b_c = pll_clk;
	
	// DDS Wiring
	assign dac_a_d = dds_a_buf;
	assign dac_b_d = dds_b_buf;
	
	// PMOD, LED, and Buttons
	assign pmod_a = adc_cfg[23:16];
	assign pmod_b = adc_cfg[31:24];
	
	//////////////////////////////////////////////////////////////////////////
	// adc_data_available state machine

	always @(posedge pll_clk) begin
		if (adc_buf_full & ~spi_busy) begin
			adc_data_available <= 1'b1;
		end else if (spi_busy) begin // TODO: should get a "clear" signal from 
			adc_data_available <= 1'b0; 
		end else begin
			adc_data_available <= adc_data_available;
		end
	end
	
	//////////////////////////////////////////////////////////////////////////
	// Module Instantiations
	
	// PLL
	PLL_100MHz pll_inst(.inclk0(clk), .c0(pll_clk));
	
	// SPI Interface
	spi_module #(.DDS_AW(DDS_DEPTH)) spi_inst(
	  .clk(pll_clk),
		
	  // SPI Interface
	  .sck_spi(sck_spi),
	  .mosi_spi(mosi_spi),
	  .ncs_spi(ncs_spi),
	  .miso_spi(miso_spi),
		
	  // Configuration Outouts
	  .adc_cfg_out(adc_cfg),
	  .dds_a_cfg_out(dds_a_cfg),
	  .dds_b_cfg_out(dds_b_cfg),
	
	  // ADC Buffer Connections
	 .mem_data(adc_buf_data),
	 .mem_addr(adc_buf_r_addr),
	 .trig_addr({bank_sel, trig_addr}),
		
	  // DDS Wave Table Connections
	  .dds_a_data(dds_a_data),
	  .dds_b_data(dds_b_data),
	  .dds_a_addr(dds_a_addr),
	  .dds_b_addr(dds_b_addr),
	  .dds_a_w(dds_a_w),
	  .dds_b_w(dds_b_w),
		
	  // SPI Status
	  .spi_busy(spi_busy)
	);
	
	//////////////////////////////////////////////////////////////////////////
	// DDS A & B
	
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
	dds #(.DDS_AW(DDS_DEPTH)) dds_a (
		.clk(pll_clk),
		.cfg(dds_a_cfg),
		.tbl_data(dds_a_r_data),
		.tbl_addr(dds_a_r_addr),
		.q(dds_a_dac_data)
	);
	
	// DDS_B phase accumulator and controller
	dds #(.DDS_AW(DDS_DEPTH)) dds_b (
		.clk(pll_clk),
		.cfg(dds_b_cfg),
		.tbl_data(dds_b_r_data),
		.tbl_addr(dds_b_r_addr),
		.q(dds_b_dac_data)
	);
	
	//////////////////////////////////////////////////////////////////////////
	// ADC Buffer and Trigget Logic
	
	// ADC Buffer
	ram_adc ram_adc (
		.clock(pll_clk),
		.data(adc_buf),
		.wraddress({~bank_sel, adc_buf_w_addr}),
		.wren(adc_buf_wen),
		.rdaddress({bank_sel, adc_buf_r_addr}),
		.q(adc_buf_data)
	);
	
	trigger trig_ch_a_inst(
		.clk(pll_clk),
		.signal(adc_buf[7:0]),
		.level(8'd0),
		.rising_edge(~adc_cfg[26]),
		.edge_flag(trig_ch_a)
	);
	
	trigger trig_ch_b_inst(
		.clk(pll_clk),
		.signal(adc_buf[15:8]),
		.level(8'd0),
		.rising_edge(~adc_cfg[26]),
		.edge_flag(trig_ch_b)
	);
	
	assign trigger_signal = ~button | trig_ch_a & ~adc_cfg[27] | trig_ch_b & adc_cfg[27];
	
	adc_driver_test #(.DEPTH(BUF_DEPTH), .DEL_W(24)) adc_driver_inst(
		.clk(pll_clk),
		
		// configuration and control inputs
		.sample_divider(adc_cfg[23:0]),	// Configuration - sample rate
		.mode(adc_cfg[25:24]),
		.trigger_req(trigger_signal),  // Trigger condition is met
		.ready(~spi_busy), // Should only swap mem banks if SPI is not active
		.valid(adc_buf_full),
	
		// Memory Buffer Interface - NOTE data path is direct from ADC to Memory
		.mem_addr(adc_buf_w_addr),		// drives buffer memory and latches buffer offset on done_flag
		.mem_en(adc_buf_wen),			// memory write strobe
		.trig_addr(trig_addr),
		.bank_sel(bank_sel),
		
		// Progress Signals
		.trigger_state(adc_trig_state),
		.waiting_for_trigger(trigger_wait),
		.triggered(trigger_seen)
	);
	
	//////////////////////////////////////////////////////////////////////////
	// Analog I/O Buffering
	
	// DDS Output Buffer
	always @(negedge pll_clk) {dds_a_buf, dds_b_buf} <= {dds_a_dac_data, dds_b_dac_data};
	
	// ADC Input Buffer
	always @(posedge pll_clk) adc_buf <= adc_buf_n;
	always @(negedge pll_clk) adc_buf_n <= {adc_a_d, adc_b_d};

endmodule
