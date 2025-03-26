`include "../verilog/spi_module.v"
`include "../verilog/spi_sync.v"
`include "../verilog/shift_register.v"
`include "../verilog/register.v"
`include "../verilog/spi_mem_reader.v"
`include "../verilog/spi_mem_writer.v"
`include "../verilog/counter_sre.v"

module tb_spi_module();

  // SPI wiring
  wire miso;
  reg clk = 0;
  reg mosi = 0;
  reg sck = 0;
  reg nCS = 1;

  // SPI Master Internal Data
  integer i, j;
  reg [31:0] data = 0;
  reg [31:0] rx_data = 0;
  reg [7:0] cmd = 0;
  reg [7:0] rx_cmd = 0;

  // Outputs from spi_module
  wire [7:0] q_c;
  wire [31:0] q_adc, q_dds_a, q_dds_b;

  wire [15:0] mem_sim;
  wire [11:0] mem_addr;
  assign mem_sim = {4'hE, mem_addr};

  // SPI Module Instantiation
  spi_module dut (
    .clk(clk),

    .sck_spi(sck),
    .mosi_spi(mosi),
    .ncs_spi(nCS),
    .miso_spi(miso),

    .q_c(q_c),
    .adc_cfg_out(q_adc),
    .dds_a_cfg_out(q_dds_a),
    .dds_b_cfg_out(q_dds_b),

    // ADC Buffer Connections
    .mem_data(mem_sim),
    .mem_addr(mem_addr)
  );

  // Tasks to communicate with module via SPI

  //task spi_cfg_write(input [7:0] cmd, input [31:0] data);
  task spi_cfg_write(input [7:0] c, input [31:0] d); begin
    cmd = c;
    data = d;
    $display("Send %2x %8X", cmd, data);
    #1 nCS = 0;
    for (i=0; i<8; i++) begin
      mosi = cmd[7-i];
      #137 sck = 1;
      #10 rx_cmd = {rx_cmd[7:0], miso};
      #137 sck = 0;
    end
    for (i=0; i<32; i++) begin
      mosi = data[31-i];
      #137 sck = 1;
      #10 rx_data = {rx_data[30:0], miso};
      #137 sck = 0;
    end
    nCS = 1;
    #53 $display("Received %2x %08x", rx_cmd, rx_data);
  end endtask

  task spi_mem_rd(input [7:0] c); begin
    cmd = c;
    $display("Mem Read %2x", cmd);
    #1 nCS = 0;
    for (i=0; i<8; i++) begin
      mosi = cmd[7-i];
      #137 sck = 1;
      #10 rx_cmd = {rx_cmd[7:0], miso};
      #137 sck = 0;
    end
    $display("Received ID %2x", rx_cmd);
    for (j=0; j<11; j++) begin
      for (i=0; i<16; i++) begin
        mosi = 1'b0;
        #137 sck = 1;
        #10 rx_data = {rx_data[14:0], miso};
        #137 sck = 0;
      end
      if (j==0) $display("Received Stat %4x", rx_data[15:0]);
      else $display("MEM[%2x] = %04x", j-1, rx_data[15:0]);
    end
    nCS = 1;
    #53 $display("Mem read done");
  end endtask

  // Simulation flow

  initial begin 
    $dumpfile("tb_spi_module.vcd");
    $dumpvars(4, tb_spi_module);

    #10 $display("init");
    #1 clk = 0;
    #1 mosi = 0;
    #1 nCS = 1;
    #1 sck = 0;
    #10 $display("init done");
    #10
    
    // SPI REG0, no Write
    spi_cfg_write('h80, 'h01234567);
    spi_cfg_write('h82, 'h00112233);
    spi_cfg_write('h83, 'hBABEFDCA);
    spi_cfg_write('h00, 'h01234567);
    spi_cfg_write('h02, 'h00112233);
    spi_cfg_write('h03, 'hBABEFDCA);
    spi_cfg_write('h04, 'hA0A1A2A3);

    // MEM Access
    spi_mem_rd(8'h01); // AdcBuf @ 01, read 10 words

    #200 $finish;
  end

  // clock
  initial forever begin
    #5 clk <= ~clk;
  end

endmodule
