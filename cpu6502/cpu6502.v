module cpu6502
(
  input clk,
  input btn1,
  input btn2,
  output clk1MHz, 
  output [5:0] led
);

// main clock frequency = 27 MHz
localparam CLOCK_FREQUENCY = 32'd27_000_000; 
// number of positive clock edges for a 1 sec delay 
localparam COUNT_1S = (CLOCK_FREQUENCY / 2);
localparam COUNT_500MS = (COUNT_1S / 2);
localparam COUNT_100MS = (COUNT_1S / 10);
localparam COUNT_10MS = (COUNT_1S / 100);
localparam COUNT_1MS = (COUNT_1S / 1000);

localparam COUNT_1US = 12;

// pre initialize state
localparam STATE_NONE =  4'd0;
// initialization state
localparam STATE_INITIALIZE = 4'd1;
// final state
localparam STATE_DONE = 4'd2;
// current state register
reg [3:0] state = STATE_NONE;
reg slowClock = 1'b0;
// register to hold state of leds
reg [5:0] leds = 6'b000000;

localparam SLOW_COUNT = DELAY_1S;
reg [31:0] slowClockCounter = 0;

// create a slowClock
always @(posedge clk) begin 
  slowClockCounter <= slowClockCounter + 1;
  if (slowClockCounter == COUNT_1US) begin
    slowClockCounter <= 0;
    slowClock <= ~ slowClock;
    leds[5] <= slowClock;
  end
end

// state machine
always @(posedge slowClock) begin
  
  case (state) 
    STATE_NONE: begin
      state <= STATE_INITIALIZE;
    end

    STATE_NONE: begin
      state <= STATE_DONE;
    end

    STATE_DONE: begin
      // if button 1 pressed  
      state <= (btn1 == 1'b0) ? STATE_INITIALIZE : STATE_DONE;
    end

  endcase
end

assign clk1MHz = slowClock;

// invert leds as they light up when 0
assign led = ~ leds;

endmodule