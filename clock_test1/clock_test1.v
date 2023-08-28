module clock_test1
(
  input clk,
  input btn1,
  input btn2,
  output [5:0] led,
);

reg [5:0] ledCounter = 0;
reg [32:0] counter = 0;
reg [7:0] mem [0:1023];


always @(posedge clk) begin
  counter <= counter + 1;
  if (counter >= 13_500_000) begin
    counter <= 0;
    ledCounter <= ledCounter + 1;
  end
end

assign led = ~ ledCounter;

endmodule