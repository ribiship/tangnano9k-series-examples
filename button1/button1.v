module button1(
    input clk,
    input btn1,
    input btn2,
    output [5:0] led,
    output reg newclk
);

localparam WAIT_TIME = 13500000;
reg [5:0] ledCounter = 0;
reg [23:0] clockCounter = 0;
reg [5:0] newClockCounter = 1;

always @(posedge clk) begin
    clockCounter <= clockCounter + 1;
    if (clockCounter == WAIT_TIME) begin
        clockCounter <= 0;
        ledCounter <= ~ ledCounter;
    end
    if (btn1 == 1'b0) begin
      ledCounter <= 5'b10101;
       clockCounter <= 0;
    end 
    if (btn2 == 1'b0) begin
      ledCounter <= ledCounter + 1;
       clockCounter <= 0;
    end 
    newClockCounter <= newClockCounter + 1;
    if (newClockCounter == 12) begin
        newClockCounter <= 0 ;
        newclk <= ~newclk;
    end
end

assign led = ledCounter;
endmodule