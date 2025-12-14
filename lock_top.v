// FPGA可综合顶层文件，适配DE2-115开发板
module Lock_Top(
    input CLK,           // CLOCK_50, PIN_Y2
    input RESET,         // KEY[0],   PIN_M23
    input ENTER,         // KEY[1],   PIN_M21, 高电平有效
    input PRESS,         // KEY[2],   PIN_N21, 高电平有效
    input MODE,          // SW[0],    PIN_AB28, 高电平有效
    input [3:0] CODE,    // SW[4:1],  PIN_AB27, PIN_AD27, PIN_AC27, PIN_AC28, 高电平有效
    output OPEN,         // LEDR[0],  PIN_G19, 高电平有效
    output ERROR,        // LEDR[1],  PIN_F19, 高电平有效
    output [6:0] HEX0    // 七段数码管 HEX0, a~g, 低电平点亮
);
    // 输入按键信号全部取反, 适配低电平有效
    wire enter_n  = ~ENTER;   // 低电平有效
    wire press_n  = ~PRESS;   // 低电平有效

    Lock_Password UUT(
        .OPEN(OPEN),
        .ERROR(ERROR),
        .CODE(CODE),
        .PRESS(press_n),
        .ENTER(enter_n),
        .CLK(CLK),
        .RESET(RESET),
        .MODE(MODE)
    );

    // BCD转七段数码管显示，低电平点亮（共阳）
    reg [6:0] hex0_seg;
    always @(*) begin
        case (CODE)
            4'd0: hex0_seg = 7'b100_0000;
            4'd1: hex0_seg = 7'b111_1001;
            4'd2: hex0_seg = 7'b010_0100;
            4'd3: hex0_seg = 7'b011_0000;
            4'd4: hex0_seg = 7'b001_1001;
            4'd5: hex0_seg = 7'b001_0010;
            4'd6: hex0_seg = 7'b000_0010;
            4'd7: hex0_seg = 7'b111_1000;
            4'd8: hex0_seg = 7'b000_0000;
            4'd9: hex0_seg = 7'b001_0000;
            default: hex0_seg = 7'b111_1111;
        endcase
    end
    assign HEX0 = hex0_seg;
endmodule
