module TEST_DUAL_DAC(
    input wire clk,
    input wire button,
    output wire [2:0] led,
    output wire [7:0] dac_a_d,
    output wire [7:0] dac_b_d,
    output wire dac_a_c,
    output wire dac_b_c
);

localparam LED_CTR_WIDTH = $clog2(24_000_000 / 2);

reg [7:0] buf1, buf0;
wire [7:0] ramp;
wire [LED_CTR_WIDTH-1:0] led_q;

// IO Assignments
assign dac_a_c = clk;
assign dac_b_c = clk;
assign dac_a_d = buf1;
assign dac_b_d = buf1;
assign led = led_q[LED_CTR_WIDTH-1 : LED_CTR_WIDTH-3];

// Ramp Counter 
COUNTER_SR #(.BITS(8)) ramp_ctr(.clk(clk), .sReset(~button), .q(ramp));

// LED Counter
COUNTER_SR #(.BITS(LED_CTR_WIDTH)) led_ctr(.clk(clk), .sReset(~button), .q(led_q));

// Neg-edge triggered buffer for DAC data output
always @(negedge clk)
begin
    {buf1, buf0} = {~buf0, ramp};
end

endmodule