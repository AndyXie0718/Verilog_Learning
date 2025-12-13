# 16位数据选择器密码锁 (Verilog)

## 文件说明
- `lock_mux.v`：包含16位4选1数据选择器（DataSelector16）和密码锁（PasswordLock）模块。
- `tb_lock_mux.v`：仿真用testbench，自动测试所有选择和密码情况。

## 仿真步骤（ModelSim/QuestaSim）
1. 打开 ModelSim/QuestaSim 命令行，进入本目录：

```powershell
cd d:/tools/intelFPGA_lite/18.1/modelsim_lock_new
```

2. 编译源文件：
```powershell
vlog lock_mux.v tb_lock_mux.v
```

3. 运行仿真：
```powershell
vsim -c tb_lock_mux -do "run -all; quit"
```

4. 查看输出：
- 仿真结果会在命令行显示各选择和密码的解锁情况。

## 主要信号说明
- `key_in`：输入密码
- `sel`：选择哪组密码（00~11）
- `unlock`：为1表示解锁成功

## 修改密码
可在 testbench (`tb_lock_mux.v`) 的 initial 块中修改 `pass0`~`pass3`。

---
如需可视化波形，可用 ModelSim GUI 运行并添加信号至波形窗口。
