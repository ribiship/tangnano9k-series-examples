module wire_example (
    input   button1,
    output  [5:0]led
);

begin
    // connect button1 to led[0]
    // note button is normally high and leds light up when low
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

// Device Utilisation:
//         VCC:               1/    1   100%
//         SLICE:             0/ 8640     0%
//         IOB:               7/  274     2% = 6 LEDs + 1 button1
//         ODDR:              0/  274     0%
//         MUX2_LUT5:         0/ 4320     0%
//         MUX2_LUT6:         0/ 2160     0%
//         MUX2_LUT7:         0/ 1080     0%
//         MUX2_LUT8:         0/ 1056     0%
//         GND:               1/    1   100%
//         RAMW:              0/  270     0%
//         GSR:               1/    1   100%
//         OSC:               0/    1     0%
//         rPLL:              0/    2     0%