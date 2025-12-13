// Testbench for PasswordLock
`timescale 1ns/1ps
module tb_lock_mux;
    reg  [15:0] key_in;
    reg  [15:0] pass0, pass1, pass2, pass3;
    reg  [1:0]  sel;
    wire        unlock;
    wire [15:0] selected;

    PasswordLock uut (
        .key_in(key_in),
        .pass0(pass0),
        .pass1(pass1),
        .pass2(pass2),
        .pass3(pass3),
        .sel(sel),
        .unlock(unlock),
        .selected(selected)
    );

    initial begin
        // Set passwords
        pass0 = 16'h1234;
        pass1 = 16'h5678;
        pass2 = 16'habcd;
        pass3 = 16'hbeef;
        $monitor($time, "key=0x%h unlock=%b", key_in, unlock);
        end

    initial begin
        $display("Testing PasswordLock with 5ns interval...");
        // 时序输入，每隔5ns输入一组数据
        sel = 2'b00; key_in = 16'h1234; #5;
        sel = 2'b00; key_in = 16'h0000; #5;
        sel = 2'b01; key_in = 16'h5678; #5;
        sel = 2'b01; key_in = 16'h1111; #5;
        sel = 2'b10; key_in = 16'habcd; #5;
        sel = 2'b10; key_in = 16'h2222; #5;
        sel = 2'b11; key_in = 16'hbeef; #5;
        sel = 2'b11; key_in = 16'h3333; #5;
        // 保持最后一组数据一段时间
        #10;
        $display("Test complete.");
    end
endmodule
