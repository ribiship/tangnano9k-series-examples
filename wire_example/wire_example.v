module wire_example (
    input   button1,
    output  [5:0]led
);

begin
    // connect button1 to led[0]
    // note this is not clocked so its like connecting wires hence the assign statements
    assign led[0] = button1;
    
    // connect the rest of the leds to button1 as well
    // this needs a 'genvar' variable as the for loop is a 'generate' loop
    genvar i;
    for (i = 1; i < 6; i++) begin   
      assign led[i] = button1;
    end
end    

endmodule