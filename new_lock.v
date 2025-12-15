// 1. 2位递增计数器（修正时序逻辑，避免锁存器）
module UPCount(
    input CLR, EN, CP,
    output reg [1:0] Q
);
always@(posedge CP or negedge CLR) begin
    if(!CLR) Q <= 2'b00;       // 复位清零
    else if(EN) begin           // 使能时计数
        if(Q == 2'b11) Q <= 2'b11; // 计数到3（4位）停止
        else Q <= Q + 1'b1;
    end
    else Q <= Q;                // 不使能保持原态
end
endmodule

// 2. 4位并行寄存器（直接指定4位，不用参数，减少错误）
module Reg4(
    input [3:0] Pdata,
    input LD, CP,
    input CLR,
    output reg [3:0] Q
);
always@(posedge CP or negedge CLR) begin
    if(!CLR) Q <= 4'b0000;      // 复位清零（CLR=0）
    else if(LD) Q <= Pdata;     // 锁存输入数据
    else Q <= Q;                // 保持原态
end
endmodule

// 3. 16位数值比较器（直接指定16位，简化调用）
module Comparator16(
    input [15:0] A, B,
    output reg EQU
);
always@(*) begin
    if(A == B) EQU = 1'b1;      // 两数相等输出1
    else EQU = 1'b0;
end
endmodule

// 4. 密码锁处理单元（简化模块调用，去掉冗余）
module Lock_datapath(
    output AEQB, BITEQ,
    output [15:0] SAVE_PWD,     // <-- 新增：导出保存密码（QA3..QA0）
    output [15:0] INPUT_PWD,    // <-- 新增：导出输入密码（QB3..QB0）
    input [3:0] CODE,      // 0-9 BCD码输入
    input PRESS,           // 数字键按下（1=按下）
    input CLK, RESET,      // 时钟、复位（1=正常，0=复位）
    input MODE             // 0=设密码，1=解锁
);
wire [3:0] QA0, QA1, QA2, QA3; // 存储密码寄存器输出
wire [3:0] QB0, QB1, QB2, QB3; // 输入密码寄存器输出
wire [15:0] Save_Pwd, Input_Pwd; // 16位完整密码
wire [1:0] CNT;                // 计数结果

// 复位策略：只清“当前模式”相关寄存器，避免解锁时清掉已保存密码
// RESET=0 为复位有效（异步清零端 CLR 为低有效）
// MODE=0(设密码)：清保存寄存器 RA0~RA3
// MODE=1(解锁)：清输入寄存器 RB0~RB3
wire clr_save  = RESET | MODE;   // RESET=0 且 MODE=0 -> 0：清保存寄存器
wire clr_input = RESET | ~MODE;  // RESET=0 且 MODE=1 -> 0：清输入寄存器

// 存储密码：4个4位寄存器级联（设密码模式时锁存）
Reg4 RA0(.Pdata(CODE), .LD(!MODE & PRESS), .CP(CLK), .CLR(clr_save), .Q(QA0));
Reg4 RA1(.Pdata(QA0), .LD(!MODE & PRESS), .CP(CLK), .CLR(clr_save), .Q(QA1));
Reg4 RA2(.Pdata(QA1), .LD(!MODE & PRESS), .CP(CLK), .CLR(clr_save), .Q(QA2));
Reg4 RA3(.Pdata(QA2), .LD(!MODE & PRESS), .CP(CLK), .CLR(clr_save), .Q(QA3));
assign Save_Pwd = {QA3, QA2, QA1, QA0}; // 拼接16位存储密码

// 输入密码：4个4位寄存器级联（解锁模式时锁存）
Reg4 RB0(.Pdata(CODE), .LD(MODE & PRESS), .CP(CLK), .CLR(clr_input), .Q(QB0));
Reg4 RB1(.Pdata(QB0), .LD(MODE & PRESS), .CP(CLK), .CLR(clr_input), .Q(QB1));
Reg4 RB2(.Pdata(QB1), .LD(MODE & PRESS), .CP(CLK), .CLR(clr_input), .Q(QB2));
Reg4 RB3(.Pdata(QB2), .LD(MODE & PRESS), .CP(CLK), .CLR(clr_input), .Q(QB3));
assign Input_Pwd = {QB3, QB2, QB1, QB0}; // 拼接16位输入密码

// <-- 新增：连接到输出端口（纯展示用）
assign SAVE_PWD  = Save_Pwd;
assign INPUT_PWD = Input_Pwd;

// 密码比较：存储密码 vs 输入密码
Comparator16 Comp_Pwd(.A(Save_Pwd), .B(Input_Pwd), .EQU(AEQB));

// 计数：解锁模式下，按下数字键计数（计4次）
UPCount CNT_inst(
    .CLR(RESET), .EN(PRESS & MODE & !BITEQ), .CP(CLK), .Q(CNT)
);

// 计数比较：是否计满4次（2'b11=3，对应4位输入）
Comparator16 Comp_CNT(.A({14'b00000000000000, CNT}), .B(16'b0000000000000011), .EQU(BITEQ));
endmodule



// 5. 密码锁控制单元（简化状态机，避免冗余）
module Lock_control(
    output reg OPEN, ERROR,
    input CLK, RESET,      // 时钟、复位（1=正常，0=复位）
    input PRESS, ENTER,    // 数字键按下、确认键（#）
    input BITEQ, AEQB      // 计满4位、密码相等
);
// 状态编码（简化为3个核心状态）
parameter S_IDLE=2'b00, S_INPUT=2'b01, S_OPEN=2'b10, S_ERROR=2'b11;
reg [1:0] CurrentState, NextState;

// 状态寄存器时序逻辑
always@(posedge CLK or negedge RESET) begin
    if(!RESET) CurrentState <= S_IDLE; // 复位回到空闲态
    else CurrentState <= NextState;    // 切换到次态
end

// 次态逻辑+输出逻辑
always@(*) begin
    OPEN = 1'b0;
    ERROR = 1'b0;
    case(CurrentState)
        S_IDLE: begin // 空闲态：等待数字键按下
            if(PRESS) NextState = S_INPUT;
            else NextState = S_IDLE;
        end
        S_INPUT: begin // 输入态：已输入4位，等确认键
            if(ENTER) begin
                if(AEQB) NextState = S_OPEN;  // 密码对→开锁
                else NextState = S_ERROR;    // 密码错→报错
            end
            else NextState = S_INPUT;
        end
        S_OPEN: begin // 开锁态：输出开锁信号
            OPEN = 1'b1;
            NextState = S_OPEN; // 保持开锁（复位后退出）
        end
        S_ERROR: begin // 报错态：输出错误信号
            ERROR = 1'b1;
            NextState = S_ERROR; // 保持报错（复位后退出）
        end
        default: NextState = S_IDLE;
    endcase
end
endmodule

// 6. 顶层模块（总入口，信号清晰，无冗余）
module Lock_Password(
    output OPEN, ERROR,    // 开锁成功、密码错误输出
    output [15:0] SAVE_PWD,    // <-- 新增：给真正顶层显示用
    output [15:0] INPUT_PWD,   // <-- 新增：给真正顶层显示用
    input [3:0] CODE,      // 0-9按键BCD码（0=4'b0000~9=4'b1001）
    input PRESS,           // 数字键按下（1=按下，0=松开）
    input ENTER,           // 确认键（#键，1=按下）
    input CLK,             // 系统时钟（建议1kHz，不用太快）
    input RESET,           // 复位键（*键，1=正常，0=复位/上锁）
    input MODE             // 模式切换（0=设置密码，1=解锁）
);

// 内部信号连接（不用改）
wire AEQB, BITEQ;

// 实例化两个核心单元
Lock_datapath U_Datapath(
    .AEQB(AEQB), .BITEQ(BITEQ),
    .SAVE_PWD(SAVE_PWD),        // <-- 新增连接
    .INPUT_PWD(INPUT_PWD),      // <-- 新增连接
    .CODE(CODE), .PRESS(PRESS), .CLK(CLK), .RESET(RESET), .MODE(MODE)
);

Lock_control U_Control(
    .OPEN(OPEN), .ERROR(ERROR),
    .CLK(CLK), .RESET(RESET), .PRESS(PRESS), .ENTER(ENTER),
    .BITEQ(BITEQ), .AEQB(AEQB)
);
endmodule