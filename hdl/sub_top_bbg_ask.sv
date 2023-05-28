module sub_top_bbg_ask(
    input clk,rst,
    output signed [15:0]dout1,dout2,dout3,dout4,
    output [8:1]pmod
    );
    
	logic pat_sync,syb_clk,data_clk,data_out;
    logic signed [15:0]i,q,i_rc_out,q_rc_out;
    logic cke,den;
    assign pmod[8:5]=0;
    
    parameter tap_len_rc=41;
    parameter [tap_len_rc-1:0][15:0]tap_rc='{0,-320,-723,-1170,-1607,-1966,-2169,-2135,-1794,-1091,0,1474,3289,5365,7592,9833,11942,13770,15184,16078,16384,16078,15184,13770,11942,9833,7592,5365,3289,1474,0,-1091,-1794,-2135,-2169,-1966,-1607,-1170,-723,-320,0};  //alpha=0.5
    //parameter [tap_len_rc-1:0][15:0]tap_rc='{0,60,112,130,89,-20,-185,-357,-456,-376,0,775,2016,3729,5848,8232,10676,12938,14772,15968,16384,15968,14772,12938,10676,8232,5848,3729,2016,775,0,-376,-456,-357,-185,-20,89,130,112,60,0};  //alpha=0.99
    parameter tap_len_intp1=31;
    parameter [tap_len_intp1-1:0][15:0]tap_intp1='{102,129,190,291,436,624,851,1110,1390,1677,1955,2210,2427,2592,2695,2730,2695,2592,2427,2210,1955,1677,1390,1110,851,624,436,291,190,129,102};
    
    data_gen data_gen(
        .clk(clk),
        .rst(rst),
        .freq(49),//5M/(freq+1) [Mbps]
        .pn(3),//prbs bit length. 0(PN3),1(PN4),2(PN7),3(PN9),4(PN10),5(PN15)
        .syb(0),//bits per symbol. 0(BPSK),1(QPSK),2(16QAM),3(64QAM)
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
        
    poly_intp #(.tap_len(tap_len_intp1),.rate(12),.m_rate(1)) i_intp1( //interpolator
        .clk(clk),
        .rst(rst),
        .cke(cke),
        .din(i_rc_out),
        .dout(dout1),
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
    
    logic signed [31:0]temp1;
    logic signed [15:0]temp2;
    assign temp2=(dout1)+10000;
    assign temp1=i_lo*temp2;    //i_lo*i_bbg
    assign dout2=(pmod[3])?32767:-32768;
    assign dout3=temp1>>>15;    //modulated signal
    assign dout4=i_lo;      //LO
endmodule
