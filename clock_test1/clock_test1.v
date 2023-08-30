module clock_test1
(
  input clk,
  input btn1,
  input btn2,
  output [5:0] led,
);

// states 
localparam STATE_INITIALZE = 4'd0;
localparam STATE_COUNTING = 4'd1;

reg [3:0] state = STATE_INITIALZE;

reg [5:0] ledCounter = 0;
reg [5:0] mem [0:4];
reg [2:0] index = 0;

reg [31:0] slowCounter = 0;
reg slowClk = 1'b0;


always @(posedge clk) begin
  slowCounter <= slowCounter + 1;
  
  if (slowCounter == 13500000) begin
    slowCounter <= 0;
    slowClk <= ~ slowClk;
  end  
end

always @(posedge slowClk) begin

  case (state)
    STATE_INITIALZE: begin
      mem[0] <= 6'h00;
      mem[1] <= 6'h01;
      mem[2] <= 6'h02;
      mem[3] <= 6'h03;
      mem[4] <= 6'hff;

      state <= STATE_COUNTING;
    end

    STATE_COUNTING: begin
      ledCounter <= mem[index];
      index <= (index == 4) ? 0 : index + 1;  
    end
  endcase
end

assign led = ~ ledCounter;

endmodule