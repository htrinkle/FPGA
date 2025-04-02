`include "../verilog/shift_register.v"
`include "../verilog/register.v"
`include "../verilog/counter_sre.v"
`include "../verilog/adc_driver.v"

module tb_adc_driver();

  parameter BUF_DEPTH = 4;

  reg [15:0] adc_buf = 16'h0106;  
  reg trig_req = 1'b0;
  reg ready = 1'b0;
  reg clk = 1'b0;

  wire valid;
  wire [BUF_DEPTH:0] mem_addr, trig_addr;
  wire mem_en;
  wire trig_occured;
  wire trig_wait;

  adc_driver #(.DEPTH(BUF_DEPTH), .DEL_W(24)) adc_driver_inst(
	  .clk(clk),
    .sample_divider(24'd1),
    .mode(2'd0),
	  .trigger_req(trig_req),
    .ready(ready),
    .valid(valid),
	  .mem_addr(mem_addr),		// drives buffer memory and latches buffer offset on done_flag
	  .mem_en(mem_en),					// memory write strobe
	  .trig_addr(trig_addr),		// trigger address to be used by SPI_Module

	  // Status
	  .waiting_for_trigger(trig_wait),
	  .triggered(trig_occured)
  );

  initial begin 
    $dumpfile("tb_adc_driver.vcd");
    $dumpvars(4, tb_adc_driver);

    #10 $display("init");

    #10 $display("init done");
    #10


    #2000

    #200 $finish;
  end

  // clock
  initial forever begin
    #5 clk <= ~clk;
  end

  // adc
  initial forever begin
    #40 adc_buf <= adc_buf + 1;  // RAMP
  end

  // trigger
  initial forever begin
    #155 trig_req <= 1;
    #52  trig_req <= 0;
  end

  // spi ready
  initial forever begin
    #204 ready <= 1;
    #157  ready <= 0;
  end

  // mem
  always @(posedge clk) begin
    if (mem_en) $display("Buf %04x <- %04x", mem_addr, adc_buf);
  end

endmodule
