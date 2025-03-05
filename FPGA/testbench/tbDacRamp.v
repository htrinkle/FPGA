
`include "../verilog/TEST_ADC_RAMP.v"

module tbDacRamp();

reg button_press;
reg clk = 0;

wire [2:0] led_display;
wire [7:0] dac_a_d;
wire dac_a_c;

TEST_ADC_RAMP dut(clk,button_press,led_display,dac_a_d,dac_a_c);

initial begin
    $display("Starting");
    button_press = 1'b0;
    # 100
    button_press = 1'b1;
    # 100
    button_press = 1'b0;
    # 10000
    $finish;
    $display("Finished");
end

// Setup Dump File
initial begin
    $dumpfile("tbDacRamp.vcd");
    $dumpvars(2, tbDacRamp);
end

// Clock
initial forever begin
  #5 clk <= ~clk;
end

endmodule