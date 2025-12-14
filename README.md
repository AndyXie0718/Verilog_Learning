#### `verilog`基本语法
[Verilog 教程](https://www.runoob.com/w3cnote/verilog-tutorial.html)
另: 数电课本

##### 数据类型, 运算符(数电第七版P64-73)
- `begin...end`代替C:`{...}`
- 末尾有分号`;`!

##### 数电元件/组合逻辑的描述方法(数电第七版P60)
- a. 数据流描述("`assign`"关键字, 使用与`&`或`|`非`~`组合而成的逻辑表达式直接写出输入输出关系式, 需要手动对逻辑表达式进行化简, 但是整体简洁)
```C++
// 2选1数据选择器
// 文件名：mux2to1_df.v
module mux2to1_df (
    input D0, D1, S,      // 输入端口
    output wire Y         // 输出端口及数据类型
);

    // 电路功能描述
    assign Y = (~S & D0) | (S & D1);

endmodule

// 4选1数据选择器
module choose_4to1(
   input i0, i1, i2, i3, // 数据输入端
   input s1, s0, // 地址输入端
   input e, // 使能端
   output out // 输出端
);
   assign out = ((~s1) & (~s0) & i0 | (~s1) & s0 & i1 | s1 & (~s0) & i2 | s1 & s0 & i3) & e;
endmodule
```

- b. 门级描述(使用预先定义好的基准元件`and`, `or`, `not`描述门电路中各个元件不同端口之间的连接关系, 无需化简, 注意不要漏掉元件连接关系)
```C++
// 2选1数据选择器
// 文件名：mux2to1.v
module mux2to1(D0, D1, S, Y);
    input D0, D1, S;    // 输入端口
    output Y;           // 输出端口
    wire Snot, A, B;    // 内部节点

    // 电路逻辑功能描述
    not U1(Snot, S);         // S 取反
    and U2(A, D0, Snot);     // A = D0 & ~S
    and U3(B, D1, S);        // B = D1 & S
    or  U4(Y, A, B);         // Y = A | B
endmodule
```

- c. LUT查找表描述(使用case语句直接指定输入输出的高低电平组合)
```C++
// 4选1数据选择器
module data_selector_4to1(
   input [1:0] sel, // 选择信号
   input [3:0] in, // 数据输入
   output reg out // 输出
);
   always @(*) begin
       case (sel)
           2'b00: out = in[0];
           2'b01: out = in[1];
           2'b10: out = in[2];
           2'b11: out = in[3];
       endcase
   end
endmodule
```

##### `testbench`(tb)编写方法
- testbench模板(数电第七版P483附录C.1)
```C++
module 测试模块名 ();
    // 输入信号声明
    reg 输入信号名;
    // ...
    // 输出信号声明
    wire 输出信号名;
    // ...

    // 实例化待测试设计模块
    设计模块实例名 (端口连接);

    // 激励信号
    initial begin
        // 此处添加激励
    end

    // 时钟信号（如需要）
    always begin
        // 此处添加时钟信号
    end

    // 输出语句
    initial begin
        // 此处添加输出语句
    end
endmodule
```

- testbench示例(数电第七版P62)
```C++
`timescale 1ns/1ns    // 时间单位为1ns，精确度为1ns

module test_mux2to1_df;
    reg PD0, PD1, PS;     // 声明输入信号
    wire PY;              // 声明输出信号

    // 实例引用设计块
    mux2to1_df t_mux (PD0, PD1, PS, PY); // 按照端口位置进行连接

    initial 
    begin // 初始化波形
        // 激励信号
        PS = 0; PD1 = 0; PD0 = 0;   // 语句1
        #5 PS = 0; PD1 = 0; PD0 = 1; // 语句2
        #5 PS = 0; PD1 = 1; PD0 = 0; // 语句3
        #5 PS = 0; PD1 = 1; PD0 = 1; // 语句4
        #5 PS = 1; PD1 = 0; PD0 = 0; // 语句5
        #5 PS = 1; PD1 = 0; PD0 = 1; // 语句6
        #5 PS = 1; PD1 = 1; PD0 = 0; // 语句7
        #5 PS = 1; PD1 = 1; PD0 = 1; // 语句8
        #5 PS = 0; PD1 = 0; PD0 = 0; // 语句9
        #5 $stop;                    // 语句10
    end

    initial 
    begin // 控制台输出部分
        $monitor($time, ":\tS = %b\tD1 = %b\tD0 = %b\tY = %b", PS, PD1, PD0, PY);
    end
endmodule
```

- 信息打印(出现在`Transcript`)(详见数电第七版P490附录C.4`编译指令, 系统任务和系统函数`)
  - 函数
    - `$display()` 最基本的关键词, 格式化字符串用法参考`C:printf()`, 整体用法相较C宽松(允许变量出现在格式化字符串前)
    - `$monitor()` 用法和`$display()`完全相同(见上面`testbench`), 特殊功能: 只有检测到`()`内包含的变量改变才会输出到`Transcript`
    - `$random(seed)` 生成一个整型随机数
  - 关键字
    - `$time` 显示当前仿真时间
    - `$stop` 停止仿真

#### `modelsim`仿真
[学会使用Hdlbits网页版Verilog代码仿真验证平台](https://www.cnblogs.com/mc2-xiangliangzi/p/10821072.html)
[在线仿真网页](https://hdlbits.01xz.net/wiki/Iverilog)
[Modelsim仿真之精度设置错误](https://blog.csdn.net/CAOXUN_FPGA/article/details/89639764)

##### 创建工程
- a. `File-New-Project`, 自行编辑`Project Name`, `Project Location`, 选择OK
- b. 为项目添加文件: `Project-Add to Project`, 可选 `Existing File`或者`New File`(注意添加文件的时候尽量不要中文注释, 否则会编码错误)
- c. 编译: `Compile-Compile All`, 如果出现报错建议回到`Quartus`编译以查看报错的详细原因

##### 仿真与调试
- a. 开始仿真: `Simulate-Start Simulate`, 注意看清楚仿真文件的路径, modelsim自带很多库文件仿真, 在创建Project的时候如果没有特殊设置自己写的文件应该在顶栏`work`文件夹下面, 如: `test`(属性`attribute`为模块`module`), 注意右下角可以选择波形图的坐标轴刻度, 默认一大格`100ps`, 可调`1/10/100us, 1/10/100ms`等挡位, 注意如果步长过大可能会导致仿真报错: `Error: (vsim-3601) Iteration limit reached at time 0 ns`, 本实验仿真选择`100ns`

- b. 添加可视化信息
  - **查看波形**: `View-Wave`; 
  - 查看打印信息: `View-Transcript`; 
  - 查看变量: `View-Locals`, `View-Objects(全局, 推荐看这个)`, `View-Watch`; 
  - **添加波形**: 在 `Objects`界面右键变量可以选择`View Declaration`, `Add Wave`, 允许使用`Ctrl+A`添加全部波形变量;

- c. 调试
有3种运行方式: 按照提前设置的仿真时间步长运行, 单步运行, 断点运行; **3种运行方式在顶部工具栏中部都有对应的快捷图标**

- 按照提前设置的仿真时间步长运行, 可通过修改`Simulate-Runtime Options-Default Run`或者进入`Wave`界面后顶部工具栏中部修改`Run Length`(默认`100ps`)
  - `Simulate-Run-Continue`(快捷图标`ContinueRun`), 跑1个标准仿真时间步长
  - `Simulate-Run-Run -100`(无快捷图标), 跑100个标准仿真时间步长
  - `Simulate-Run-Run -All`(快捷图标`Run -All`), 全部运行, 注意会弹出是否退出仿真的提示框, 选择`No`返回后才能查看完整波形
- 断点运行: `Simulate-Run-Next`(快捷图标`Run`), 推荐使用该方法, 演示时更清晰, 需要在`testbench`中打好断点
- 单步运行: `Simulate-Run-Step-*`


其他调试相关选项
- `Simulate-Restart`(快捷图标`Restart`)
- `Simulate-End Simulation`
- 波形的放大与缩小(快捷图标)
  - `Zoom in`(快捷键I)
  - `Zoom out`(快捷键O)
  - `Zoom full`(快捷键F)

#### `quartus prime 18.1`配置`DE2-115`开发板硬件下载与引脚分配说明
- [[野火]FPGA Verilog开发实战指南——基于Altera EP4CE10 征途Mini开发板](https://doc.embedfire.com/fpga/altera/ep4ce10_mini/zh/latest/)
  - [点亮你的LED灯-一个完整的设计过程](https://doc.embedfire.com/fpga/altera/ep4ce10_mini/zh/latest/fpga/Led.html#id4)
  - [如何快速批量绑定或删除管脚配置](https://doc.embedfire.com/fpga/altera/ep4ce10_mini/zh/latest/fpga/IO_Lock.html) 
  - [Quartus软件和USB-Blaster驱动安装](https://doc.embedfire.com/fpga/altera/ep4ce10_mini/zh/latest/fpga/Quartus.html)
  - [【FPGA】Quartus II安装Altera USB-Blaster安装驱动程序出现问题（代码39）的解决办法](https://www.cnblogs.com/Skyrim-sssuuu/p/18817257)

大致流程参考: 数电第七版P460
- 在quartus中选择对应器件(`EP4CE115F29C7`, 实际开发板后面带`N`表示无铅, 不影响烧录/管脚配置)
- 分配输入输出信号到相应引脚(参考开发手册, 结合AI, 但是注意自己**仔细对照开发手册检查管脚**)
- 重新编译并下载文件(后缀`.pof`/.sof)
- 使用jtag/as模式下载到fpga中(上电仿真使用`jtag`模式, 该模式注意检查开发板左下角开关`SW19`是否打到`RUN`)


##### 1. 顶层文件说明
工程名称: `lock`, 项目结构:
```text
modelsim_lock_new/
├── quartus_compile/     # Quartus工程及引脚分配
│   ├── output_files/lock.sof        # 实际下载到开发板上的sof文件
│   ├── lock_pins.tcl        # 常用引脚分配脚本
│   ├── lock.qpf             # Quartus工程文件
│   ├── lock.qsf             # Quartus设置文件（含顶层、源文件、引脚分配）
├── lock_top.v               # FPGA顶层文件（含数码管显示）
├── new_lock.v               # 密码锁完整功能实现（数据通路+控制）
├── tb_new_lock.v            # 密码锁完整功能仿真testbench(不含数码管)
├── README.md                # 工程说明文档
├── vsim.wlf                 # ModelSim仿真波形文件
```

- 新增 `lock_top.v` 作为FPGA可综合顶层文件，端口与开发板元件一一对应。
- 端口说明：
  | 功能      | 顶层端口 | 板载元件 | 说明           |
  |-----------|----------|----------|----------------|
  | 时钟      | CLK      | CLOCK_50 | 50MHz主时钟    |
  | 复位      | RESET    | KEY[0]   | 复位按钮       |
  | 确认      | ENTER    | KEY[1]   | 确认按钮       |
  | 输入      | PRESS    | KEY[2]   | 数字键输入     |
  | 模式切换  | MODE     | SW[0]    | 拨码开关       |
  | 密码输入  | CODE[3:0]| SW[4:1]  | 拨码开关       |
  | 开锁指示  | OPEN     | LEDR[0]  | 红色LED        |
  | 错误指示  | ERROR    | LEDR[1]  | 红色LED        |

##### 2. 工程设置
- `lock.qsf` 已设置 `Lock_Top` 为顶层实体，并添加 `lock_top.v`: 
```
set_global_assignment -name TOP_LEVEL_ENTITY Lock_Top
set_global_assignment -name VERILOG_FILE ../lock_top.v
```
- 新增 `quartus_compile/lock_pins.tcl`，包含常用引脚分配脚本，可在 Quartus Tcl Console 执行(执行后需要重新编译, 也可不执行脚本直接修改`.qsf`文件): 
  - 图形化界面`Tools-Tcl scripts`手动添加或命令行执行`tcl`脚本:`source quartus_compile/lock_pins.tcl`
  - 直接修改`lock.qsf`(把`tcl`脚本内容添加进去): `set_location_assignment PIN_Y2 -to CLK ...`
- 主要引脚分配如下: 
```
set_location_assignment PIN_Y2   -to CLK
set_location_assignment PIN_M23  -to RESET
set_location_assignment PIN_M21  -to ENTER
set_location_assignment PIN_N21  -to PRESS
set_location_assignment PIN_AB28 -to MODE

# 检查管脚前(分别对应SW[4], SW[5], SW[6], SW[7])
#set_location_assignment PIN_AB27 -to CODE[3]
#set_location_assignment PIN_AC26 -to CODE[2]
#set_location_assignment PIN_AD26 -to CODE[1]
#set_location_assignment PIN_AB26 -to CODE[0]
# 检查管脚后(分别对应SW[4], SW[3], SW[2], SW[1])
set_location_assignment PIN_AB27 -to CODE[3]
set_location_assignment PIN_AD27 -to CODE[2]
set_location_assignment PIN_AC27 -to CODE[1]
set_location_assignment PIN_AC28 -to CODE[0]

set_location_assignment PIN_G19  -to OPEN
set_location_assignment PIN_F19  -to ERROR
```
**仔细对照开发手册检查管脚**
**仔细对照开发手册检查管脚**
**仔细对照开发手册检查管脚**
##### 3. 下载与测试流程
1. 在 Quartus 中重新编译工程。
2. 执行 `lock_pins.tcl` 脚本自动分配引脚。
3. 下载 `.sof` 文件到开发板，拨码开关/按键/LED 即可直接交互测试密码锁功能。

#### `lock_top.v`下载开发板注意事项
- 模板同仿真testbench类似, 只是无需声明仿真时间`timescale`和仿真激励输入`initial begin ...end`
- 注意: 仿真和原理设计和实际开发板的高低电平有效/正负脉冲触发不一定一样, 此时需要根据手册+多次烧录验证对输入/输出信号(如ENTER, PRESS信号)取反处理:
```v
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
```

#### 新增功能: 使用数码管显示当前输入数字

- 顶层文件 `lock_top.v` 在`module Lock_Top()`中已增加 HEX0 七段数码管端口`output [6:0] HEX0`
```v
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
```
- 数码管为共阳极，低电平点亮，显示范围0~9。
- 只需将 HEX0[6:0] 分配到开发板对应引脚即可。
  - HEX0 七段数码管引脚分配（a~g）
  ```
  set_location_assignment PIN_G18 -to HEX0[0]
  set_location_assignment PIN_F22 -to HEX0[1]
  set_location_assignment PIN_E17 -to HEX0[2]
  set_location_assignment PIN_L26 -to HEX0[3]
  set_location_assignment PIN_L25 -to HEX0[4]
  set_location_assignment PIN_J22 -to HEX0[5]
  set_location_assignment PIN_H22 -to HEX0[6]
  ```

  - 下载后, HEX0会实时显示拨码开关SW[4:1]BCD码对应数字
