`include "../verilog/trigger.v"

module tb_trigger();

wire trig;
reg clk = 1'b0;
reg [7:0] adc_raw, adc;
reg rising_edge;

trigger dut(.clk(clk), .signal(adc), .level(8'd0), .rising_edge(rising_edge), .edge_flag(trig));

initial begin 
    $dumpfile("tb_trig.vcd");
    $dumpvars(2, dut);

    #1 $display("init");
    adc = 0;
    rising_edge = 1'b1;
    #1 $display("init done");
    #10


    #600

    #10 $finish;
  end

  always @(posedge clk) adc <= adc_raw;

  // clock
  initial forever begin
    #5 clk <= ~clk;
  end

  // adc
  initial forever begin
    #10 adc_raw = -43;
    #10 adc_raw = -23;
    #10 adc_raw = -13;
    #10 adc_raw = -3;
    #10 adc_raw = 3;
    #10 adc_raw = -3;
    #10 adc_raw = -2;
    #10 adc_raw = 2;
    #10 adc_raw = -2;
    #10 adc_raw = -3;
    #10 adc_raw = -1;
    #10 adc_raw = 2;
    #10 adc_raw = 3;
    #10 adc_raw = -3;
    #10 adc_raw = -2;
  end


endmodule