module max7219
#(
  parameter STARTUP_WAIT = 32'd10_000_000
)
(
  input clk,
  output [5:0] led,

  //max 7219  
  output io_din,
  output io_cs,
  output io_clk
);

localparam WAIT_TIME = 1_350_000;

// initial state
localparam STATE_INIT_POWER = 8'd0;
// sent initialization commands to max7219
localparam STATE_LOAD_INIT_CMD = 8'd1;
// send data
localparam STATE_SEND = 8'd2;
// state to check if we are done sending all initialization commands
localparam STATE_CHECK_FINISHED_INIT = 8'd3;
// all done
localparam STATE_DONE = 8'd4;

// as there are only 5 states, only 3 bits are needed 
reg [2:0] state = 2'b0;
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
reg [5:0] leds = 6'b111111;
// register to hold clock counter 
reg [32:0] counter = 0;

// number of startup commands
localparam STARTUP_COMMANDS = 6;

// the commands to send on startup
// the max7219 needs 16 bits at a time: an 8 bit opcode + 8 bit data, most significant bit first

 reg [15:0] startupCommands [0:STARTUP_COMMANDS - 1]; //= {
//     16'h0c00,  // shutdown + 0 = display off, 1 = display on
      
//     16'h0900,  // decode mode for 7 segment displays +  0 = no, 1 = yes
       
//     16'h0b07,  // scanlimit + 0 = 1 column .. 7 = scan all 8 columns
    
//     16'h0a07,  // medium intensity + 0 = min brightness, h0f = max brightness
      
//     16'h0c01,  // shutdown + 0 = display off, 1 = display on
  
//     16'h0f01  // display test + 0 = off, 1 = turn all segments
// };

// index of startup command to send
// as there are only 6 SETUP_COMMANDS we need just 3 bits to hold an index
reg [2:0] starupIndex = 3'b0; 


always @(posedge clk) begin
    case (state)
      STATE_INIT_POWER: begin
        startupCommands[0] <= 16'h0c00;

        counter <= counter + 1;
        if (counter == STARTUP_WAIT) begin
          state <= STATE_LOAD_INIT_CMD;
          counter <= 32'b0;
        end
      end

      STATE_LOAD_INIT_CMD: begin
        rcs <= 0;
        dataToSend <= startupCommands[commandIndex];
        state <= STATE_SEND;
        // most significant bit first
        bitNumber <= 4'd15;
        commandIndex <= commandIndex + 1;
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
          if (commandIndex == STARTUP_COMMANDS)
            state <= STATE_DONE; 
          else
            state <= STATE_LOAD_INIT_CMD; 
      end
      
      STATE_DONE: begin
        // all done    
      end
        
    endcase
    // show state
    leds[3:0] <= state;
end

// connect the max7219 to the registers
assign io_sclk = rclk;
assign io_din = rdin;
assign io_cs = rcs;

// connect the leds
assign led = ~ leds;

endmodule