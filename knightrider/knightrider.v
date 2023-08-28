    module knightrider (
        input clk,
        input button1,
        input button2,
        output [5:0]led
    );

begin
    
    // states
    localparam STATE_INITIALIZING = 4'd0;
    localparam STATE_SHIFT_LEFT = 4'd1;
    localparam STATE_SHIFT_RIGHT = 4'd2;

        //pulses before moving the led
    localparam MOVEWAIT = 27_200_000;
    localparam MOVEWAIT2 = MOVEWAIT / 16;
    
    // register to hold the current state of the leds
    // 0 = off, 15 = full on
    reg [3:0]leds[5:0];
    // clock counter 32 bits good for 2^32 / 27000000 = 159 seconds of clk pulses
    reg [31:0]counter = 0;
    
    reg [3:0]currentState = STATE_INITIALIZING;

    always @(posedge clk) begin

        case (currentState)
          STATE_INITIALIZING: begin
            leds[5] <= 4'b0000;
            leds[4] <= 4'b0000;
            leds[3] <= 4'b0000;
            leds[2] <= 4'b0000;
            leds[1] <= 4'b0000;
            leds[0] <= 4'b1111;
            currentState <= STATE_SHIFT_LEFT;
        end

        STATE_SHIFT_LEFT: begin
            counter <= counter + 1;
            if (counter == MOVEWAIT2) begin
                // start again
                counter <= 0;
                leds[5] <= leds[4]; 
                leds[4] <= leds[3]; 
                leds[3] <= leds[2]; 
                leds[2] <= leds[1]; 
                leds[1] <= leds[0]; 
                leds[0] <= 4'b0000; 
                if (leds[4] == 4'b1111) currentState <= STATE_SHIFT_RIGHT;
                else currentState <= STATE_SHIFT_LEFT;
            end
        end
        
        STATE_SHIFT_RIGHT: begin
            counter <= counter + 1;
            if (counter == MOVEWAIT2) begin
                counter <= 0;
                leds[0] <= leds[1]; 
                leds[1] <= leds[2]; 
                leds[2] <= leds[3]; 
                leds[3] <= leds[4]; 
                leds[4] <= leds[5]; 
                leds[5] <= 4'b0000; 
                if (leds[1] == 4'b1111) currentState <= STATE_SHIFT_LEFT;
                else currentState <= STATE_SHIFT_RIGHT;
            end
        end

    endcase    
end
    
    // connect led to leds
    // note: leds are turned on when 0
    assign led[0] = ~(leds[0] == 4'b1111);
    assign led[1] = ~(leds[1] == 4'b1111);
    assign led[2] = ~(leds[2] == 4'b1111);
    assign led[3] = ~(leds[3] == 4'b1111);
    assign led[4] = ~(leds[4] == 4'b1111);
    assign led[5] = ~(leds[5] == 4'b1111);

end    
endmodule