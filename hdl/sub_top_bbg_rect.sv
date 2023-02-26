module sub_top_bbg_rect(
    input clk,rst,
    output signed [15:0]dout1,dout2,dout3,dout4,
    output [8:1]pmod
    );
    
	logic pat_sync,syb_clk,data_clk,data_out;
    logic signed [15:0]i,q,i_rc_out,q_rc_out;
    logic cke,den;
    assign pmod[8:5]=0;
    
    parameter tap_len_rc=41;
    parameter [tap_len_rc-1:0][15:0]tap_rc='{0,-320,-723,-1170,-1607,-1966,-2169,-2135,-1794,-1091,0,1474,3289,5365,7592,9833,11942,13770,15184,16078,16384,16078,15184,13770,11942,9833,7592,5365,3289,1474,0,-1091,-1794,-2135,-2169,-1966,-1607,-1170,-723,-320,0};
    parameter tap_len_intp1=31;
    parameter [tap_len_intp1-1:0][15:0]tap_intp1='{-111,-127,-155,-171,-136,0,284,753,1417,2255,3212,4205,5131,5887,6381,6553,6381,5887,5131,4205,3212,2255,1417,753,284,0,-136,-171,-155,-127,-111};
    
    data_gen data_gen(
        .clk(clk),
        .rst(rst),
        .freq(1),//5M/(freq+1) [Mbps]
        .pn(3),//prbs bit length. 0(PN3),1(PN4),2(PN7),3(PN9),4(PN10),5(PN15)
        .syb(2),//bits per symbol. 0(BPSK),1(QPSK),2(16QAM),3(64QAM)
        .i(i),
        .q(q),
        .cke(cke),
        .den(den),
        .pat_sync(pmod[1]),
        .syb_clk(pmod[2]),
        .data_out(pmod[3]),
        .data_clk(pmod[4])
        );
    
    rect_filter i_rect(
        .clk(clk),
        .rst(rst),
        .cke(cke),
        .den(den),
        .din(i),
        .dout(dout1)
        );
        
    rect_filter q_rect(
        .clk(clk),
        .rst(rst),
        .cke(cke),
        .den(den),
        .din(q),
        .dout(dout2)
        );
    
    //LO multiplier and modulated signal
    logic [27:0]lo_freq=268435456/50*10; //LO freq
    logic signed [15:0]i_lo,q_lo;
    iq_rom_nco nco(
        .clk(clk),
        .rst(rst),
        .accum_rst(0),
        .freq(lo_freq),
        .sin(q_lo),
        .cos(i_lo),
        .trig(trig1)
        );
    
    logic [31:0]temp1,temp2;
    assign temp1=dout1*i_lo;
    assign temp2=dout2*q_lo;
    assign dout3=(temp1+temp2)>>>15;    //modulated signal
    assign dout4=i_lo;      //LO
endmodule
