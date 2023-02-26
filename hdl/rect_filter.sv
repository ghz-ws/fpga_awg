module rect_filter(
    input clk,rst,cke,den,
    input signed [15:0]din,
    output logic signed [15:0]dout
    );
    
    always_ff@(posedge clk)begin
        if(rst)begin
            dout<=0;
        end else begin
            if(cke)begin
                if(den)begin
                    dout<=din;
                end
            end 
        end
    end
endmodule