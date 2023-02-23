`timescale 1ns / 1ps
module tb_top();
    bit mclk,ext_rst;
    logic [15:0]dac1,dac2;
    logic clk1,clk2;
    logic [8:1]pmod;
    logic [2:0]led;
    
    always #42ns mclk<=!mclk;
    
    initial begin
        @(posedge dut.locked);
        #100us
        $finish;
    end
    
    top dut(.*);
endmodule
