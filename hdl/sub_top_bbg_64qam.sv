module sub_top_bbg_64qam(
    input clk,rst,
    output signed [15:0]dout1,dout2,dout3,dout4,
    output [8:1]pmod
    );
    
	logic pat_sync,syb_clk,data_clk,data_out;
    logic signed [15:0]i,q,i_rc_out,q_rc_out,i_rc_out_rc,q_rc_out_rc;
    logic cke,den,rc_cke_i,rc_cke_q;
    assign pmod[8:5]=0;
    
    parameter tap_len_rc=41;
    parameter [tap_len_rc-1:0][15:0]tap_rc='{0,57,97,93,23,-113,-296,-470,-550,-430,0,835,2131,3883,6019,8393,10806,13025,14816,15980,16384,15980,14816,13025,10806,8393,6019,3883,2131,835,0,-430,-550,-470,-296,-113,23,93,97,57,0};  //alpha=0.95
    parameter tap_len_intp1=31;
    parameter [tap_len_intp1-1:0][15:0]tap_intp1='{-42,-94,-177,-291,-406,-457,-352,0,670,1677,2968,4421,5859,7082,7902,8192,7902,7082,5859,4421,2968,1677,670,0,-352,-457,-406,-291,-177,-94,-42};
    
    data_gen data_gen(
        .clk(clk),
        .rst(rst),
        .freq(1),//5M/(freq+1) [Mbps]
        .pn(3),//prbs bit length. 0(PN3),1(PN4),2(PN7),3(PN9),4(PN10),5(PN15)
        .syb(3),//bits per symbol. 0(BPSK),1(QPSK),2(16QAM),3(64QAM)
        .i(i),
        .q(q),
        .cke(cke),
        .den(den),
        .pat_sync(pmod[1]),
        .syb_clk(pmod[2]),
        .data_out(pmod[3]),
        .data_clk(pmod[4])
        );
   
    fir_rc #(.tap_len(tap_len_rc)) i_rc(    //rc filter
        .clk(clk),
        .rst(rst),
        .cke(cke),
        .den(den),
        .din(i),
        .dout(i_rc_out),
        .tap(tap_rc)
        );
    fir_rc #(.tap_len(tap_len_rc)) q_rc(
        .clk(clk),
        .rst(rst),
        .cke(cke),
        .den(den),
        .din(q),
        .dout(q_rc_out),
        .tap(tap_rc)
        );
        
    poly_intp #(.tap_len(tap_len_intp1),.rate(4),.m_rate(4)) i_intp1( //interpolator1
        .clk(clk),
        .rst(rst),
        .cke(cke),
        .din(i_rc_out),
        .dout(i_rc_out_rc),
        .cke_out(rc_cke_i),
        .tap(tap_intp1)
        );
    poly_intp #(.tap_len(tap_len_intp1),.rate(4),.m_rate(4)) q_intp1(
        .clk(clk),
        .rst(rst),
        .cke(cke),
        .din(q_rc_out),
        .dout(q_rc_out_rc),
        .cke_out(rc_cke_q),
        .tap(tap_intp1)
        );
    poly_intp #(.tap_len(tap_len_intp1),.rate(4),.m_rate(1)) i_intp2( //interpolator2
        .clk(clk),
        .rst(rst),
        .cke(rc_cke_i),
        .din(i_rc_out_rc),
        .dout(dout1),
        .cke_out(),
        .tap(tap_intp1)
        );
    poly_intp #(.tap_len(tap_len_intp1),.rate(4),.m_rate(1)) q_intp2(
        .clk(clk),
        .rst(rst),
        .cke(rc_cke_q),
        .din(q_rc_out_rc),
        .dout(dout2),
        .cke_out(),
        .tap(tap_intp1)
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
