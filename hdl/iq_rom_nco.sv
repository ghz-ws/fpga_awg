`timescale 1ns / 1ps

module iq_rom_nco(
    input clk,rst,accum_rst,
	input [27:0]freq,
	output logic signed [15:0]sin,cos,
	output trig
    );
    
    parameter pha=268435456/4;
    
    //phase accumulator
	logic [27:0]accum;
	assign trig=!accum[27];
	always_ff@(posedge clk)begin
		if(rst||accum_rst)begin
			accum<=0;
		end else begin
			accum<=accum+freq;
		end
	end
	
	logic [10:0]sin_addr,cos_addr;
	logic [3:0]addr_latch;
	always_ff@(posedge clk)begin
		if(rst)begin
			addr_latch<=0;
		end else begin
			addr_latch<={addr_latch[2],cos_addr[10],addr_latch[0],sin_addr[10]};
		end
	end
	
	//calc sin/cos
	logic [15:0]douta,doutb;
	assign sin_addr=accum[27:17];
	assign cos_addr=(accum+pha)>>17;
	assign sin=(addr_latch[1]==1)?0-douta:douta;   //0-179 / 180-359
	assign cos=(addr_latch[3]==1)?0-doutb:doutb;   //0-179 / 180-359
	
	blk_mem_gen_0 nco_rom(
	   .clka(clk),    // input wire clka
       .addra(sin_addr[9:0]),  // input wire [1 : 0] addra
       .douta(douta),  // output wire [15 : 0] douta
       .clkb(clk),    // input wire clkb
       .addrb(cos_addr[9:0]),  // input wire [1 : 0] addrb
       .doutb(doutb)  // output wire [15 : 0] doutb
    );
endmodule
