module multi_nco(
    input clk,rst,accum_rst,
	input [27:0]freq,
	input [27:0]pha,
	input [1:0]wavesel,
	output logic signed [15:0]waveout,
	output trig
	);
    
    //noise gen
	logic [14:0]lfsr;
	always_ff@(posedge clk)begin
	   if(rst)begin
	       lfsr<=0;
	   end else begin
	       lfsr<={lfsr[14:0],!(lfsr[14]^lfsr[13])};
	   end
	end
    
    //phase accumulator
	logic [27:0]accum,ref_accum;
	assign trig=!accum[27];
	assign ref_accum=accum+pha;
	always_ff@(posedge clk)begin
		if(rst||accum_rst)begin
			accum<=0;
		end else begin
			accum<=accum+freq;
		end
	end
	
	//sin table
	logic signed [15:0]table_out,sin_out;
	assign sin_out=(ref_accum[27]==1)?0-table_out:table_out;   //0-179 / 180-359
	always_comb begin
	   case(ref_accum[26:22])
	        0:table_out=0;
	        1:table_out=3210;
            2:table_out=6389;
            3:table_out=9507;
            4:table_out=12533;
            5:table_out=15439;
            6:table_out=18196;
            7:table_out=20778;
            8:table_out=23160;
            9:table_out=25319;
            10:table_out=27235;
            11:table_out=28889;
            12:table_out=30265;
            13:table_out=31349;
            14:table_out=32132;
            15:table_out=32606;
            16:table_out=32766;
            17:table_out=32611;
            18:table_out=32143;
            19:table_out=31365;
            20:table_out=30285;
            21:table_out=28914;
            22:table_out=27264;
            23:table_out=25353;
            24:table_out=23197;
            25:table_out=20818;
            26:table_out=18239;
            27:table_out=15485;
            28:table_out=12581;
            29:table_out=9557;
            30:table_out=6440;
            31:table_out=3262;
            default:table_out=0;
	   endcase
	end
	
	//wave selector
	always_comb begin
	   case(wavesel)
	       0:waveout=sin_out;      //sin
	       1:waveout=(sin_out[15]==0)?32766:-32766;    //rectangle
	       2:waveout=$signed(ref_accum[27:12]);     //up sawtooth
	       3:waveout=$signed({lfsr,1'b0}-(1<<15));//noise
	       default:waveout=sin_out;
	   endcase
	end
endmodule
