`timescale 1ns/1ps // 时间单位1ns，精度1ps，适配多数仿真器
module tb_Lock_Password;

// 定义与顶层模块一致的测试信号
reg [3:0] CODE;
reg PRESS;
reg ENTER;
reg CLK;
reg RESET;
reg MODE;
wire OPEN;
wire ERROR;

// 实例化顶层模块（核心：端口名必须和顶层完全一致）
Lock_Password UUT(
    .OPEN(OPEN),
    .ERROR(ERROR),
    .CODE(CODE),
    .PRESS(PRESS),
    .ENTER(ENTER),
    .CLK(CLK),
    .RESET(RESET),
    .MODE(MODE)
);

// 生成时钟：50MHz（周期20ns，仿真速度更快）
initial begin
    CLK = 1'b0;
    forever #10 CLK = ~CLK; // 每10ns翻转，周期20ns
end

// 测试流程（简化：复位→设密码1234→输正确密码→输错误密码）
initial begin
    // 1. 初始复位
    RESET = 1'b0;  // 低电平复位
    PRESS = 1'b0;
    ENTER = 1'b0;
    CODE = 4'b0000;
    MODE = 1'b0;   // 先进入设置密码模式
    #100;          // 等待100ns
    
    // 2. 取消复位，开始设密码
    RESET = 1'b1;
    #50;
    
    // 设密码：1（0001）→2（0010）→3（0011）→4（0100）
    // 按数字1
    CODE = 4'b0001;
    PRESS = 1'b1;
    #20;
    PRESS = 1'b0;
    #80;
    
    // 按数字2
    CODE = 4'b0010;
    PRESS = 1'b1;
    #20;
    PRESS = 1'b0;
    #80;
    
    // 按数字3
    CODE = 4'b0011;
    PRESS = 1'b1;
    #20;
    PRESS = 1'b0;
    #80;
    
    // 按数字4
    CODE = 4'b0100;
    PRESS = 1'b1;
    #20;
    PRESS = 1'b0;
    #200;
    
    // 3. 切换到解锁模式，输错误密码1235
    MODE = 1'b1;
    #100;
    
    // 按数字1
    CODE = 4'b0001;
    PRESS = 1'b1;
    #20;
    PRESS = 1'b0;
    #80;
    
    // 按数字2
    CODE = 4'b0010;
    PRESS = 1'b1;
    #20;
    PRESS = 1'b0;
    #80;
    
    // 按数字3
    CODE = 4'b0011;
    PRESS = 1'b1;
    #20;
    PRESS = 1'b0;
    #80;
    
    // 按数字5（错误位）
    CODE = 4'b0101;
    PRESS = 1'b1;
    #20;
    PRESS = 1'b0;
    #100;
    
    // 按确认键，触发错误
    ENTER = 1'b1;
    #20;
    ENTER = 1'b0;
    #300;
    
    // 4. 复位后，输正确密码1234
    RESET = 1'b0;
    #100;
    RESET = 1'b1;
    MODE = 1'b1;
    #100;
    
    // 按数字1
    CODE = 4'b0001;
    PRESS = 1'b1;
    #20;
    PRESS = 1'b0;
    #80;
    
    // 按数字2
    CODE = 4'b0010;
    PRESS = 1'b1;
    #20;
    PRESS = 1'b0;
    #80;
    
    // 按数字3
    CODE = 4'b0011;
    PRESS = 1'b1;
    #20;
    PRESS = 1'b0;
    #80;
    
    // 按数字4
    CODE = 4'b0100;
    PRESS = 1'b1;
    #20;
    PRESS = 1'b0;
    #100;
    
    // 按确认键，触发开锁
    ENTER = 1'b1;
    #20;
    ENTER = 1'b0;
    #500;
    
    // 结束仿真
    $finish;
end

endmodule