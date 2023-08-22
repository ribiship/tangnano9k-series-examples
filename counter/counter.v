module counter
(
    input clk,
    output [5:0] led
);

localparam WAIT_TIME = 13500000;
// 6 leds on board
reg [5:0] ledCounter = 0;
// 24 bit counter 0 .. 16777215 big enough to count to WAIT_TIME
reg [23:0] clockCounter = 0;

always @(posedge clk) begin
    clockCounter <= clockCounter + 1;
    if (clockCounter == WAIT_TIME) begin
        clockCounter <= 0;
        ledCounter <= ledCounter + 1;
    end
end
// leds turn on when 0 and off when 1 so invert
assign led = ~ledCounter;
endmodule