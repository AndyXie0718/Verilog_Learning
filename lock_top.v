// FPGA可综合顶层文件，适配DE2-115开发板
module Lock_Top(
    input CLK,           // CLOCK_50, PIN_Y2
    input RESET,         // KEY[0],   PIN_M23
    input ENTER,         // KEY[1],   PIN_M21, 高电平有效
    input PRESS,         // KEY[2],   PIN_N21, 高电平有效
    input MODE,          // SW[0],    PIN_AB28, 高电平有效
    input [3:0] CODE,    // SW[4:1],  PIN_AB27, PIN_AC26, PIN_AD26, PIN_AB26, 高电平有效
    output OPEN,         // LEDR[0],  PIN_G19, 高电平有效
    output ERROR         // LEDR[1],  PIN_F19, 高电平有效
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
endmodule
