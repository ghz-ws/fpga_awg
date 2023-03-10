`timescale 1ns / 1ps

module top(
    input ext_rst,
    input mclk,
    output [15:0]dac1,dac2,
    output clk1,clk2,
    output [8:1]pmod,
    output [2:0]led
    );
    
    logic locked,clk,rst;
    assign led=3'b111;
    assign rst=!locked;
    
    //dac if
    logic signed [15:0]dout1,dout2,dout3,dout4;
    logic [15:0]out_l1,out_l2,out_l3,out_l4;    //output latch
    assign  dac1=(clk)?out_l1:out_l3;
    assign  dac2=(clk)?out_l2:out_l4;
    always_ff@(posedge clk) begin
        if(rst)begin
            out_l1<=0;
            out_l2<=0;
            out_l3<=0;
            out_l4<=0;
        end else begin
            out_l1<=$unsigned(dout1+(1<<15));   //signed->unsigned
            out_l2<=$unsigned(dout3+(1<<15));
            out_l3<=$unsigned(dout2+(1<<15));
            out_l4<=$unsigned(dout4+(1<<15));
        end
    end
    
    clk_wiz_0 mmcm(
        .clk_out1(clk),
        .clk_out2(clk1),
        .clk_out3(clk2),
        .reset(ext_rst),
        .locked(locked),
        .clk_in1(mclk)
        );

    sub_top_bbg nco(
        .clk(clk),
        .rst(rst),
        .dout1(dout1),
        .dout2(dout2),
        .dout3(dout3),
        .dout4(dout4),
        .pmod(pmod)
        );
endmodule
