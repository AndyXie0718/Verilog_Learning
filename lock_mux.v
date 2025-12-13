// 16-bit 4-to-1 data selector (mux)
module DataSelector16 (
    input  [15:0] d0,
    input  [15:0] d1,
    input  [15:0] d2,
    input  [15:0] d3,
    input  [1:0]  sel,
    output [15:0] y
);
    assign y = (sel == 2'b00) ? d0 :
               (sel == 2'b01) ? d1 :
               (sel == 2'b10) ? d2 :
                                 d3;
endmodule

// Password lock using the data selector
module PasswordLock (
    input  [15:0] key_in,
    input  [15:0] pass0,
    input  [15:0] pass1,
    input  [15:0] pass2,
    input  [15:0] pass3,
    input  [1:0]  sel,
    output        unlock,
    output [15:0] selected
);
    wire [15:0] chosen;

    DataSelector16 u_sel (
        .d0(pass0),
        .d1(pass1),
        .d2(pass2),
        .d3(pass3),
        .sel(sel),
        .y(chosen)
    );

    assign unlock   = (key_in == chosen);
    assign selected = chosen;
endmodule
