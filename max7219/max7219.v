module max7219
#(
  parameter STARTUP_WAIT = 20  // slowClock ticks
)
(
  input clk,
  input btn1,
  input btn2,
  output [5:0] led,

  //max 7219  
  output reg rdin,
  output reg rcs,
  output reg rclk
);

// currrent state 6 bits so we can copy it to leds
localparam STATE_NONE = 6'd0;
// initial state
localparam STATE_INITIALIZE = 6'd1;
// send initialization commands to max7219
localparam STATE_LOAD_INIT_CMD = 6'd2;
// setup send a word
localparam STATE_BEGIN_SEND_WORD = 6'd3;
// send data
localparam STATE_SEND_WORD = 6'd4;
// finish send a word
localparam STATE_END_SEND_WORD = 6'd5;
// state to check if we are done sending all initialization commands
localparam STATE_CHECK_FINISHED_INIT = 6'd6;

localparam STATE_BEGIN_DISPLAY = 6'd7;
localparam STATE_DISPLAY = 6'd8;
localparam STATE_END_DISPLAY = 6'd9;

// the segments to display
reg [7:0] digits [1:8];
reg [3:0] digit;

reg [7:0] font [0:15];

// current state
reg [5:0] state = STATE_INITIALIZE;
// the state to goto when a word has been sent
reg [5:0] stateAfterSend = STATE_NONE;
// 16 bit register to hold current data to send
reg [15:0] dataToSend;
// current index of bit in dataToSend register to be sent
// note that the max7219 needs the most significant bit first
reg [3:0] bitNumber;  



// register to hold led states
reg [5:0] leds = 6'b000000;
// register to hold clock counter 
reg [31:0] counter = 32'b0;

// number of startup commands
localparam STARTUP_COMMANDS = 5;

// the commands to send on startup
// the max7219 needs 16 bits at a time: an 8 bit opcode + 8 bit data, most significant bit first

// initialization of anything other than a 1 bit array is not allowed
reg [15:0] startupCommands [0:STARTUP_COMMANDS - 1];

// index of startup command to send
// as there are only STARTUP_COMMANDS commands to send we need just 3 bits to hold an index tothe current one
reg [3:0] startupIndex = 4'd0; 

// create a slower clock 
localparam SLOW_COUNT = 13500;
reg [31:0] slowClockCounter = 32'd0;
reg slowClk = 1'b0;

always @(posedge clk) begin
  slowClockCounter <= slowClockCounter + 1;
  if (slowClockCounter == SLOW_COUNT) begin
    slowClockCounter <= 32'd0;
    slowClk <= ~ slowClk;
  end
end

// main state machine
always @(posedge slowClk) begin
    if (btn1  == 1'b0) begin
      state <= STATE_INITIALIZE;
    end
    
    case (state)

      STATE_NONE: begin
        leds[5] <= ~ leds[5];

      end
        
      STATE_INITIALIZE: begin
        // max7219 signal registers
        rclk = 1'b1;
        rdin = 1'b0;
        rcs = 1'b0;
        // turn off display 
        startupCommands[0] <= 16'h0c00;
        // do not decode
        startupCommands[1] <= 16'h0900;
        // show all displays
        startupCommands[2] <= 16'h0b07;
        // set intensity
        startupCommands[3] <= 16'h0a00;
        // turn on display
        startupCommands[4] <= 16'h0c01;
        
        font[0] <= 8'h7e;
        font[1] <= 8'h30;
        font[2] <= 8'h6d;
        font[3] <= 8'h79;
        font[4] <= 8'h33;
        font[5] <= 8'h5b;
        font[6] <= 8'h5f;
        font[7] <= 8'h70;
        font[8] <= 8'h7f;
        font[9] <= 8'h7b;
        font[10] <= 8'h77;
        font[11] <= 8'h1f;
        font[12] <= 8'h4e;
        font[13] <= 8'h3d;
        font[14] <= 8'h4f;
        font[15] <= 8'h47;
        
        // prepare display --------
        digits[1] <= 8'h7e;
        digits[2] <= 8'h30;
        digits[3] <= 8'h6d;
        digits[4] <= 8'h79;
        digits[5] <= 8'h33;
        digits[6] <= 8'h5b;
        digits[7] <= 8'h5f;
        digits[8] <= 8'h70;
                    
        // this waiting is needed or else it will not work
        counter <= counter + 1;
        if (counter == STARTUP_WAIT) begin
          startupIndex <= 4'd0;
          counter <= 32'b0;
          state <= STATE_LOAD_INIT_CMD;
        end
      end

      STATE_LOAD_INIT_CMD: begin
        dataToSend <= startupCommands[startupIndex];
        startupIndex <= startupIndex + 1;
        state <= STATE_BEGIN_SEND_WORD;
        stateAfterSend <= STATE_CHECK_FINISHED_INIT;
      end

      STATE_BEGIN_SEND_WORD: begin
        rcs <= 0;
        // most significant bit first
        bitNumber <= 4'd15;
        counter <= 32'b0;
        state <= STATE_SEND_WORD;
      end

      STATE_SEND_WORD: begin
        if (counter == 32'd0) begin
          counter <= 32'd1;
          rclk <= 0;
          rdin <= dataToSend[bitNumber];
        end
        else begin
          counter <= 32'd0;
          rclk <= 1;
          if (bitNumber == 0)
            state <= STATE_END_SEND_WORD;
          else
            bitNumber <= bitNumber - 1;
        end
      end

      STATE_END_SEND_WORD: begin
        rcs <= 1;
        state <= stateAfterSend;
      end

      STATE_CHECK_FINISHED_INIT: begin
        if (startupIndex == STARTUP_COMMANDS)
          state <= STATE_BEGIN_DISPLAY; 
        else 
          state <= STATE_LOAD_INIT_CMD; 
      end

      STATE_BEGIN_DISPLAY: begin
        digit <= 8;
        state <= STATE_DISPLAY;
        stateAfterSend <= STATE_END_DISPLAY;
      end
      
      STATE_DISPLAY: begin
        dataToSend <= { 4'b000, digit, digits[digit] };
        digit <= digit - 1;
        state <= STATE_BEGIN_SEND_WORD;
      end
      
      STATE_END_DISPLAY: begin
        if (digit == 0) 
          state <= STATE_NONE;
        else
          state <= STATE_DISPLAY;
      end
        
    endcase

    if (state != STATE_NONE) begin
        // show state
        leds[5:0] <= state;
    end    
end

// // connect the max7219 to the registers
// assign io_clk = rclk;
// assign io_din = rdin;
// assign io_cs = rcs;

// connect the leds
assign led = ~ leds;

endmodule