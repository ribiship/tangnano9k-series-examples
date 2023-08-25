module clock_test1
#(
  parameter STARTUP_WAIT = 32'd10000000
)
(
  input clk,
  output [5:0] led,

  //max 7219  
  output io_din,
  output io_cs,
  output io_clk
);

localparam WAIT_TIME = 1350000;

localparam STATE_INIT_POWER = 8'd0;
localparam STATE_LOAD_INIT_CMD = 8'd1;
localparam STATE_SEND = 8'd2;
localparam STATE_CHECK_FINISHED_INIT = 8'd3;
localparam STATE_LOAD_DATA = 8'd4;

reg [2:0] state = 0;
reg [7:0] dataToSend = 0;
reg [3:0] bitNumber = 0;  

reg mclk = 1;
reg mdin = 0;
reg mcs = 0;

reg [5:0] ledCounter = 0;
reg [32:0] counter = 0;

localparam SETUP_INSTRUCTIONS = 12;
  reg [(SETUP_INSTRUCTIONS*8)-1:0] startupCommands = {
    8'h0c,  // shutdown display
    8'h00,
  
    8'h09,  // no decode mode
    8'h00,
    
    8'h0b,  // scan all columns
    8'h07,
    
    8'h0a,  // medium intensity
    8'h04,
    
    8'h0c,  // wake up display
    8'h01,
  
    8'h0f,  // display test
    8'h01
  };

  reg [7:0] commandIndex = SETUP_INSTRUCTIONS * 8; // ??

  assign io_sclk = mclk;
  assign io_sdin = mdin;
  assign io_cs = mcs;

always @(posedge clk) begin
    case (state)
      STATE_INIT_POWER: begin
        counter <= counter + 1;
        if (counter == STARTUP_WAIT) begin
          state <= STATE_LOAD_INIT_CMD;
          counter <= 32'b0;
        end
      end

      STATE_LOAD_INIT_CMD: begin
        cs <= 0;
        dataToSend <= startupCommands[(commandIndex - 1)-:8'd8];
        state <= STATE_SEND;
        bitNumber <= 3'd7;
        cs <= 0;
        commandIndex <= commandIndex - 8'd8;
      end

      STATE_SEND: begin
        if (counter == 32'd0) begin
          sclk <= 0;
          sdin <= dataToSend[bitNumber];
          counter <= 32'd1;
        end
        else begin
          counter <= 32'd0;
          sclk <= 1;
          if (bitNumber == 0)
            state <= STATE_CHECK_FINISHED_INIT;
          else
            bitNumber <= bitNumber - 1;
        end
      end

      STATE_CHECK_FINISHED_INIT: begin
          cs <= 1;
          if (commandIndex == 0)
            state <= STATE_LOAD_DATA; 
          else
            state <= STATE_LOAD_INIT_CMD; 
      end
      STATE_LOAD_DATA: begin
        pixelCounter <= pixelCounter + 1;
        cs <= 0;
        dc <= 1;
        bitNumber <= 3'd7;
        state <= STATE_SEND;
        dataToSend <= screenBuffer[pixelCounter];
      end
    endcase
end

assign din = ledCounter[2];
assign cs = ledCounter[1];
assign clk2 = ledCounter[0];

assign led = ~ ledCounter;

endmodule