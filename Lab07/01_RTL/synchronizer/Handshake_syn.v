module Handshake_syn #(parameter WIDTH=8) (
    sclk,
    dclk,
    rst_n,
    sready,
    din,
    dbusy,
    sidle,
    dvalid,
    dout,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake
);

input sclk, dclk;
input rst_n;
input sready;
input [WIDTH-1:0] din;
input dbusy;
output reg sidle;
output reg dvalid;
output reg [WIDTH-1:0] dout;

// You can change the input / output of the custom flag ports
output reg flag_handshake_to_clk1;
input flag_clk1_to_handshake;

output flag_handshake_to_clk2;
input flag_clk2_to_handshake;

// Remember:
//   Don't modify the signal name
reg sreq;
wire dreq;
reg dack;
wire sack;

//---------------------------------------------------------------------
//  flipflop
//---------------------------------------------------------------------

NDFF_syn U_NDFF_req(.D(sreq), .Q(dreq), .clk(dclk), .rst_n(rst_n));
NDFF_syn U_NDFF_ack(.D(dack), .Q(sack), .clk(sclk), .rst_n(rst_n));


//---------------------------------------------------------------------
//  idle design
//---------------------------------------------------------------------

always @(posedge sclk or negedge rst_n)begin
    if(!rst_n)begin
        sidle <= 1;
    end
    else if (sready || sreq || sack)begin    
        sidle <= 0;
    end
    else begin                              
        sidle <= 1;
    end
end

//---------------------------------------------------------------------
//  req design
//---------------------------------------------------------------------

always @(posedge sclk or negedge rst_n) begin
    if(!rst_n)begin        
        sreq <= 0;
    end
    else if(sack)begin     
        sreq <= 0;
    end
    else if(sready)begin   
        sreq <= 1;
    end
    else begin             
        sreq <= sreq;
    end
end


always @(posedge dclk or negedge rst_n)begin
    if(!rst_n)begin                     
        dvalid <= 0;
        dack <= 0;
    end
    else begin
        dvalid <= (dreq && !dbusy && dack)?1:0 ;
        dack <= (dreq && !dbusy)?1:0 ;
    end
end

//---------------------------------------------------------------------
//  out design
//---------------------------------------------------------------------

always @(posedge dclk or negedge rst_n) begin
    if(!rst_n)begin                
        dout <= 0;
    end
    else if(dreq && !dbusy)begin
        dout <= din;
    end
    else begin                   
        dout <= dout;
    end
end


endmodule