module max7219
#(
  parameter STARTUP_WAIT = 20  // slowClock ticks
)
(
  input clk,
  input btn1,
  output [5:0] led,

  //max 7219  
  output io_din,
  output io_cs,
  output io_clk
);

// currrent state 6 bits so we can copy it to leds
localparam STATE_NONE = 6'd0;
// initial state
localparam STATE_INITIALIZE = 6'd1;
// send initialization commands to max7219
localparam STATE_LOAD_INIT_CMD = 6'd2;
// send data
localparam STATE_SEND = 6'd3;
// state to check if we are done sending all initialization commands
localparam STATE_CHECK_FINISHED_INIT = 6'd4;



// as there are only 5 states, only 3 bits are needed 
reg [5:0] state = STATE_INITIALIZE;
// 16 bit register to hold current data to send
reg [15:0] dataToSend;
// current index of bit in dataToSend register to be sent
// note that the max7219 needs the most significant bit first
reg [3:0] bitNumber;  

// max7219 signal registers
reg rclk = 1'b1;
reg rdin = 1'b0;
reg rcs = 1'b0;

// register to hold led states
reg [5:0] leds = 6'b000000;
// register to hold clock counter 
reg [31:0] counter = 0;

// number of startup commands
localparam STARTUP_COMMANDS = 13;

// the commands to send on startup
// the max7219 needs 16 bits at a time: an 8 bit opcode + 8 bit data, most significant bit first

// initialization of anything other than a 1 bit array is not allowed
reg [15:0] startupCommands [0:STARTUP_COMMANDS - 1];

// index of startup command to send
// as there are only STARTUP_COMMANDS commands to send we need just 3 bits to hold an index tothe current one
reg [3:0] startupIndex = 4'd0; 

// create a slower clock 
localparam SLOW_COUNT = 1350;
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
        // turn on first display
        startupCommands[5] <= 16'h017e;
        startupCommands[6] <= 16'h0230;
        startupCommands[7] <= 16'h036d;
        startupCommands[8] <= 16'h0479;
        startupCommands[9] <= 16'h0533;
        startupCommands[10] <= 16'h065b;
        startupCommands[11] <= 16'h075f;
        startupCommands[12] <= 16'h0870;
   
       // counter <= counter + 1;
       // if (counter == STARTUP_WAIT) begin
          state <= STATE_LOAD_INIT_CMD;
          counter <= 32'b0;
       // end
      end

      STATE_LOAD_INIT_CMD: begin
        rcs <= 0;
        dataToSend <= startupCommands[startupIndex];
        state <= STATE_SEND;
        // most significant bit first
        bitNumber <= 4'd15;
        startupIndex <= startupIndex + 1;
      end

      STATE_SEND: begin
        if (counter == 32'd0) begin
          counter <= 32'd1;
          rclk <= 0;
          rdin <= dataToSend[bitNumber];
        end
        else begin
          counter <= 32'd0;
          rclk <= 1;
          if (bitNumber == 0)
            state <= STATE_CHECK_FINISHED_INIT;
          else
            bitNumber <= bitNumber - 1;
        end
      end

      STATE_CHECK_FINISHED_INIT: begin
          rcs <= 1;
          if (startupIndex == STARTUP_COMMANDS)
            state <= STATE_NONE; 
          else 
            state <= STATE_LOAD_INIT_CMD; 
      end
    endcase
    if (state != STATE_NONE) begin
        // show state
        leds[5:0] <= state;
    end    
end

// connect the max7219 to the registers
assign io_clk = rclk;
assign io_din = rdin;
assign io_cs = rcs;

// connect the leds
assign led = ~ leds;

endmodule