//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//    (C) Copyright System Integration and Silicon Implementation Laboratory
//    All Right Reserved
//		Date		: 2024/10
//		Version		: v1.0
//   	File Name   : HAMMING_IP.v
//   	Module Name : HAMMING_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################
module HAMMING_IP #(parameter IP_BIT = 8) (
    // Input signals
    IN_code,
    // Output signals
    OUT_code
);

// ===============================================================
// Input & Output
// ===============================================================
input [IP_BIT+4-1:0]  IN_code;

output reg [IP_BIT-1:0] OUT_code;

// ===============================================================
// Design
// ===============================================================
wire  Hamming_in [0:15] ;
wire  [3:0] Hamming_code [0:15] ;
reg   [3:0] Hamming_add  ;
reg  Hamming_all [0:15] ;
reg  Hamming_gg [0:15] ;
reg  [10:0] Hamming_out ;
integer k;

genvar i , j ;
generate
    for (i = 1  ; i < 16 ; i  = i + 1) begin 
		if (i < IP_BIT+5) begin 
			assign Hamming_in[i] = IN_code[IP_BIT+4-i] ;
		end
		else begin 
			assign Hamming_in[i] = 0 ;
		end
	end
endgenerate

assign Hamming_in[0] = 0 ;

assign Hamming_code[0]  = 0 ;
assign Hamming_code[1]  = (Hamming_in[1]==1)?1:0;
assign Hamming_code[2]  = (Hamming_in[2]==1)?2:0;
assign Hamming_code[3]  = (Hamming_in[3]==1)?3:0;
assign Hamming_code[4]  = (Hamming_in[4]==1)?4:0;
assign Hamming_code[5]  = (Hamming_in[5]==1)?5:0;
assign Hamming_code[6]  = (Hamming_in[6]==1)?6:0;
assign Hamming_code[7]  = (Hamming_in[7]==1)?7:0;
assign Hamming_code[8]  = (Hamming_in[8]==1)?8:0;
assign Hamming_code[9]  = (Hamming_in[9]==1)?9:0;
assign Hamming_code[10] = (Hamming_in[10]==1)?10:0;
assign Hamming_code[11] = (Hamming_in[11]==1)?11:0;
assign Hamming_code[12] = (Hamming_in[12]==1)?12:0;
assign Hamming_code[13] = (Hamming_in[13]==1)?13:0;
assign Hamming_code[14] = (Hamming_in[14]==1)?14:0;
assign Hamming_code[15] = (Hamming_in[15]==1)?15:0;


always @(*) begin
    Hamming_add[0] = Hamming_code[1][0] + Hamming_code[2][0]  + Hamming_code[3][0]  + Hamming_code[4][0]  + Hamming_code[5][0]  + Hamming_code[6][0] + 
                    Hamming_code[7][0] + Hamming_code[8][0]  + Hamming_code[9][0]  + Hamming_code[10][0]  + Hamming_code[11][0]  + Hamming_code[12][0] 
                    + Hamming_code[13][0]  + Hamming_code[14][0]  + Hamming_code[15][0] ;
    Hamming_add[1] = Hamming_code[1][1] + Hamming_code[2][1] + Hamming_code[3][1] + Hamming_code[4][1] + Hamming_code[5][1] + Hamming_code[6][1] 
                 + Hamming_code[7][1] + Hamming_code[8][1] + Hamming_code[9][1] + Hamming_code[10][1] + Hamming_code[11][1] + Hamming_code[12][1] 
                 + Hamming_code[13][1] + Hamming_code[14][1] + Hamming_code[15][1];
    Hamming_add[2] = Hamming_code[1][2] + Hamming_code[2][2] + Hamming_code[3][2] + Hamming_code[4][2] + Hamming_code[5][2] + Hamming_code[6][2] 
                 + Hamming_code[7][2] + Hamming_code[8][2] + Hamming_code[9][2] + Hamming_code[10][2] + Hamming_code[11][2] + Hamming_code[12][2] 
                 + Hamming_code[13][2] + Hamming_code[14][2] + Hamming_code[15][2];
    Hamming_add[3] = Hamming_code[1][3] + Hamming_code[2][3] + Hamming_code[3][3] + Hamming_code[4][3] + Hamming_code[5][3] + Hamming_code[6][3] 
                 + Hamming_code[7][3] + Hamming_code[8][3] + Hamming_code[9][3] + Hamming_code[10][3] + Hamming_code[11][3] + Hamming_code[12][3] 
                 + Hamming_code[13][3] + Hamming_code[14][3] + Hamming_code[15][3];
end

/*always @(*) begin
    if(Hamming_in[Hamming_add]==0)begin 
        Hamming_all[Hamming_add] = 1;
        for (k = 0 ; k < 16 ; k  = k + 1) begin 
            Hamming_all[k] = Hamming_in[k] ;
        end
    end
    else if(Hamming_in[Hamming_add]==1)begin
        Hamming_all[Hamming_add] = 0;
        for (k = 0 ; k < 16 ; k  = k + 1) begin 
            Hamming_all[k] = Hamming_in[k] ;
        end
    end
    else begin
        for (k = 0 ; k < 16 ; k  = k + 1) begin 
            Hamming_all[k] = Hamming_in[k] ;
        end
    end
end*/

always @(*) begin
    if(Hamming_in[Hamming_add]==0)begin 
        for (k = 0 ; k < 16 ; k  = k + 1) begin 
            if (k==Hamming_add)Hamming_all[k] = 1 ;
            else Hamming_all[k] = Hamming_in[k] ;
        end
    end
    else if(Hamming_in[Hamming_add]==1)begin
        for (k = 0 ; k < 16 ; k  = k + 1) begin 
            if (k==Hamming_add)Hamming_all[k] = 0 ;
            else Hamming_all[k] = Hamming_in[k] ;
        end
    end
    else begin
        for (k = 0 ; k < 16 ; k  = k + 1) begin 
            Hamming_all[k] = Hamming_in[k] ;
        end
    end
end


/*always @(*) begin
    for (k = 0 ; k < 16 ; k  = k + 1) begin 
        Hamming_gg[k] = Hamming_in[k] ;
    end
end*/

always @(*) begin
    Hamming_out[0] = Hamming_all[3];
    Hamming_out[1] = Hamming_all[5];
    Hamming_out[2] = Hamming_all[6];
    Hamming_out[3] = Hamming_all[7];
    Hamming_out[4] = Hamming_all[9];
    Hamming_out[5] = Hamming_all[10];
    Hamming_out[6] = Hamming_all[11];
    Hamming_out[7] = Hamming_all[12];
    Hamming_out[8] = Hamming_all[13];
    Hamming_out[9] = Hamming_all[14];
    Hamming_out[10] = Hamming_all[15];
end



/*always @(*) begin
    Hamming_out[10] = Hamming_all[3];
    Hamming_out[9] = Hamming_all[5];
    Hamming_out[8] = Hamming_all[6];
    Hamming_out[7] = Hamming_all[7];
    Hamming_out[6] = Hamming_all[9];
    Hamming_out[5] = Hamming_all[10];
    Hamming_out[4] = Hamming_all[11];
    Hamming_out[3] = Hamming_all[12];
    Hamming_out[2] = Hamming_all[13];
    Hamming_out[1] = Hamming_all[14];
    Hamming_out[0] = Hamming_all[15];
end*/

generate 
	for (i = 0 ; i < IP_BIT ; i  = i + 1) begin 
        always @(*) begin
            OUT_code[i] = Hamming_out[IP_BIT-1-i] ;
        end
    end
endgenerate



endmodule