module button2(
    input clk,
    input btn1,
    input btn2,
    output [5:0] led
);

localparam WAIT_TIME = 27000000;
reg [5:0] ledCounter = 0;
reg [25:0] clockCounter = 0;

always @(posedge clk) begin
    clockCounter <= clockCounter + 1;
    if (clockCounter == WAIT_TIME) begin
        clockCounter <= 0;
        ledCounter <= ~ ledCounter;
    end
    if (btn1 == 1'b0) begin
      ledCounter <= 5'b000001;
       clockCounter <= 0;
    end 
    if (btn2 == 1'b0) begin
      ledCounter <= ledCounter + 1;
       clockCounter <= 0;
    end 
end

assign led = ~ledCounter;
endmodule