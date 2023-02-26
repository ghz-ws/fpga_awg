module sub_top_nco(
    input clk,rst,
    output signed [15:0]dout1,dout2,dout3,dout4,
    output [8:1]pmod
    );
    
    assign pmod[8:5]=0;
    
    multi_nco nco1(
        .clk(clk),
        .rst(rst),
        .accum_rst(0),
        .freq(268435456/50*1/10),
        .pha(268435456/360*0),
        .wavesel(0),    //0(sin),1(rect),2(saw),3(noise)
        .waveout(dout1),
        .trig(pmod[1])
        );
        
    multi_nco nco2(
        .clk(clk),
        .rst(rst),
        .accum_rst(0),
        .freq(268435456/50*1/10),
        .pha(268435456/360*0),
        .wavesel(1),    //0(sin),1(rect),2(saw),3(noise)
        .waveout(dout2),
        .trig(pmod[2])
        );
    
    multi_nco nco3(
        .clk(clk),
        .rst(rst),
        .accum_rst(0),
        .freq(268435456/50*1/10),
        .pha(268435456/360*0),
        .wavesel(2),    //0(sin),1(rect),2(saw),3(noise)
        .waveout(dout3),
        .trig(pmod[3])
        );
        
    multi_nco nco4(
        .clk(clk),
        .rst(rst),
        .accum_rst(0),
        .freq(268435456/50*1/10),
        .pha(268435456/360*0),
        .wavesel(3),    //0(sin),1(rect),2(saw),3(noise)
        .waveout(dout4),
        .trig(pmod[4])
        );
endmodule
