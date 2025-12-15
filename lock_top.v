// FPGA可综合顶层文件，适配DE2-115开发板
module Lock_Top(
    input CLK,           // CLOCK_50, PIN_Y2
    input RESET,         // KEY[0],   PIN_M23
    input ENTER,         // KEY[1],   PIN_M21, 高电平有效
    input PRESS,         // KEY[2],   PIN_N21, 高电平有效
    input MODE,          // SW[0],    PIN_AB28, 高电平有效
    input [3:0] CODE,    // SW[4:1],  PIN_AB27, PIN_AD27, PIN_AC27, PIN_AC28, 高电平有效
    output OPEN,         // LEDG[0],  PIN_E21, 高电平有效
    output ERROR,        // LEDR[0],  PIN_G19, 高电平有效
    // 七段数码管 HEX0~4, a~g, 低电平点亮
    output [6:0] HEX0,   
    output [6:0] HEX1,
    output [6:0] HEX2,
    output [6:0] HEX3,
    output [6:0] HEX4
);
    // DE2-115 的 KEY 通常为低电平有效：按下=0，松开=1。
    // 这里先取反得到“按下=1”的有效电平，再做同步与沿检测，确保“一次按下只触发一次”。
    wire enter_btn = ~ENTER;  // 按下=1
    wire press_btn = ~PRESS;  // 按下=1

    // 2 级同步器（避免异步按键直接进时序逻辑）
    reg [1:0] enter_ff;
    reg [1:0] press_ff;
    always @(posedge CLK or negedge RESET) begin
        if (!RESET) begin
            enter_ff <= 2'b00;
            press_ff <= 2'b00;
        end else begin
            enter_ff <= {enter_ff[0], enter_btn};
            press_ff <= {press_ff[0], press_btn};
        end
    end
    wire enter_sync = enter_ff[1];
    wire press_sync = press_ff[1];

    // 上升沿检测：生成 1 个 CLK 周期宽度的脉冲
    reg enter_sync_d;
    reg press_sync_d;
    always @(posedge CLK or negedge RESET) begin
        if (!RESET) begin
            enter_sync_d <= 1'b0;
            press_sync_d <= 1'b0;
        end else begin
            enter_sync_d <= enter_sync;
            press_sync_d <= press_sync;
        end
    end
    wire enter_pulse = enter_sync & ~enter_sync_d;
    wire press_pulse = press_sync & ~press_sync_d;

    // <-- 新增：把寄存器值从 Lock_Password 导出来
    wire [15:0] save_pwd;
    wire [15:0] input_pwd;

    Lock_Password UUT(
        .OPEN(OPEN),
        .ERROR(ERROR),
        .SAVE_PWD(save_pwd),      // <-- 新增
        .INPUT_PWD(input_pwd),    // <-- 新增
        .CODE(CODE),
        .PRESS(press_pulse),
        .ENTER(enter_pulse),
        .CLK(CLK),
        .RESET(RESET),
        .MODE(MODE)
    );

    // 4bit(0~9) -> 七段(低电平点亮)。超出0~9显示空白
    function automatic [6:0] bcd_to_7seg(input [3:0] bcd);
        begin
            case (bcd)
                4'd0: bcd_to_7seg = 7'b100_0000;
                4'd1: bcd_to_7seg = 7'b111_1001;
                4'd2: bcd_to_7seg = 7'b010_0100;
                4'd3: bcd_to_7seg = 7'b011_0000;
                4'd4: bcd_to_7seg = 7'b001_1001;
                4'd5: bcd_to_7seg = 7'b001_0010;
                4'd6: bcd_to_7seg = 7'b000_0010;
                4'd7: bcd_to_7seg = 7'b111_1000;
                4'd8: bcd_to_7seg = 7'b000_0000;
                4'd9: bcd_to_7seg = 7'b001_0000;
                default: bcd_to_7seg = 7'b111_1111; // 空白
            endcase
        end
    endfunction

    // HEX4：实时显示拨码CODE
    wire [6:0] seg0 = bcd_to_7seg(4'd0);
    assign HEX4 = bcd_to_7seg(CODE);

    // HEX0-3：根据MODE选择显示保存密码 or 输入密码
    wire [15:0] disp_pwd = (MODE == 1'b0) ? save_pwd : input_pwd;
    // 低位在HEX0，高位在HEX3
    assign HEX0 = (!RESET) ? seg0 : bcd_to_7seg(disp_pwd[3:0]);
    assign HEX1 = (!RESET) ? seg0 : bcd_to_7seg(disp_pwd[7:4]);
    assign HEX2 = (!RESET) ? seg0 : bcd_to_7seg(disp_pwd[11:8]);
    assign HEX3 = (!RESET) ? seg0 : bcd_to_7seg(disp_pwd[15:12]);

endmodule