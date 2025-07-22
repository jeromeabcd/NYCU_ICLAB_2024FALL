//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   (C) Copyright Laboratory System Integration and Silicon Implementation
//   All Right Reserved
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   ICLAB 2024 Fall
//   Lab01 Exercise		: Snack Shopping Calculator
//   Author     		  : Yu-Hsiang Wang
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//
//   File Name   : SSC.v
//   Module Name : SSC
//   Release version : V1.0 (Release Date: 2024-09)
//
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module SSC(
    // Input signals
    card_num,
    input_money,
    snack_num,
    price, 
    // Output signals
    out_valid,
    out_change
);

//================================================================
//   INPUT AND OUTPUT DECLARATION                         
//================================================================
input [63:0] card_num;
input [8:0] input_money;
input [31:0] snack_num;
input [31:0] price;
output reg out_valid;
output reg [8:0] out_change;    

//================================================================
//    Wire & Registers 
//================================================================

wire [3:0] card_num1,card_num2,card_num3,card_num4,card_num5,card_num6;
wire [3:0] card_num7,card_num8,card_num9,card_num10,card_num11,card_num12;
wire [3:0] card_num13,card_num14,card_num15,card_num16;

reg [3:0] card_num1_mul,card_num3_mul,card_num5_mul,card_num7_mul,card_num9_mul,card_num11_mul,card_num13_mul,card_num15_mul;

reg [4:0] card_num_mul13,card_num_mul57,card_num_mul911,card_num_mul1315;
reg [4:0] card_num24,card_num68,card_num1012,card_num1416;

wire [6:0] card_num_total;

wire [10:0] input_money_in;
reg [10:0] input_money_all;
///////////////////////////////////////
wire [9:0] input_money_8,input_money_7,input_money_6;
wire [9:0] input_money_4,input_money_5,input_money_3;
//////////////////////////////////////

//wire [10:0] input_money_8,input_money_7,input_money_6;
//wire [9:0] input_money_4,input_money_5,input_money_3;

wire [8:0] input_money_2;
wire [7:0] input_money_1;



wire [3:0] snack1,snack2,snack3,snack4,snack5,snack6,snack7,snack8;
wire [3:0] price1,price2,price3,price4,price5,price6,price7,price8;


//sorting
reg [7:0] lv1_1,lv1_2,lv1_3,lv1_4,lv1_5,lv1_6,lv1_7,lv1_8;
//wire [7:0] lv1_1,lv1_2,lv1_3,lv1_4,lv1_5,lv1_6,lv1_7,lv1_8;
reg [7:0] lv2_1,lv2_2,lv2_3,lv2_4,lv2_5,lv2_6,lv2_7,lv2_8;
//wire [7:0] lv2_1,lv2_2,lv2_3,lv2_4,lv2_5,lv2_6,lv2_7,lv2_8;
wire [7:0] lv3_1,lv3_2,lv3_3,lv3_4,lv3_5,lv3_6,lv3_7,lv3_8;
wire [7:0] lv4_1,lv4_2,lv4_3,lv4_4,lv4_5,lv4_6;
wire [7:0] lv5_1,lv5_2,lv5_3,lv5_4,lv5_5,lv5_6,lv5_7,lv5_8;
wire [7:0] lv6_1,lv6_2,lv6_3,lv6_4,lv6_5,lv6_6;


//wire [8:0] totalprice2,totalprice3,totalprice4,totalprice5,totalprice6,totalprice7,totalprice8;

reg  [7:0] totalprice1,totalprice2,totalprice3,totalprice4,totalprice5,totalprice6,totalprice7,totalprice8;

//================================================================
//    DESIGN
//================================================================

assign {card_num1, card_num2, card_num3, card_num4, card_num5, card_num6, card_num7, card_num8, card_num9, card_num10, card_num11, card_num12, card_num13, card_num14, card_num15, card_num16} = card_num ;

always@(*)begin
    case(card_num1)
        4'd0: card_num1_mul = 0;//0
        4'd1: card_num1_mul = 2;//2
        4'd2: card_num1_mul = 4;//4
        4'd3: card_num1_mul = 6;//6
        4'd4: card_num1_mul = 8;//8
        4'd5: card_num1_mul = 1;//10
        4'd6: card_num1_mul = 3;//12
        4'd7: card_num1_mul = 5;//14
        4'd8: card_num1_mul = 7;//16
        4'd9: card_num1_mul = 9;//18
        default:card_num1_mul = 0;
    endcase
end

always@(*)begin
    case(card_num3)
        4'd0: card_num3_mul = 0;//0
        4'd1: card_num3_mul = 2;//2
        4'd2: card_num3_mul = 4;//4
        4'd3: card_num3_mul = 6;//6
        4'd4: card_num3_mul = 8;//8
        4'd5: card_num3_mul = 1;//10
        4'd6: card_num3_mul = 3;//12
        4'd7: card_num3_mul = 5;//14
        4'd8: card_num3_mul = 7;//16
        4'd9: card_num3_mul = 9;//18
        default:card_num3_mul = 0;
    endcase
end

always@(*)begin
    case(card_num5)
        4'd0: card_num5_mul = 0;//0
        4'd1: card_num5_mul = 2;//2
        4'd2: card_num5_mul = 4;//4
        4'd3: card_num5_mul = 6;//6
        4'd4: card_num5_mul = 8;//8
        4'd5: card_num5_mul = 1;//10
        4'd6: card_num5_mul = 3;//12
        4'd7: card_num5_mul = 5;//14
        4'd8: card_num5_mul = 7;//16
        4'd9: card_num5_mul = 9;//18
        default:card_num5_mul = 0;
    endcase
end

always@(*)begin
    case(card_num7)
        4'd0: card_num7_mul = 0;//0
        4'd1: card_num7_mul = 2;//2
        4'd2: card_num7_mul = 4;//4
        4'd3: card_num7_mul = 6;//6
        4'd4: card_num7_mul = 8;//8
        4'd5: card_num7_mul = 1;//10
        4'd6: card_num7_mul = 3;//12
        4'd7: card_num7_mul = 5;//14
        4'd8: card_num7_mul = 7;//16
        4'd9: card_num7_mul = 9;//18
        default:card_num7_mul = 0;
    endcase
end

always@(*)begin
    case(card_num9)
        4'd0: card_num9_mul = 0;//0
        4'd1: card_num9_mul = 2;//2
        4'd2: card_num9_mul = 4;//4
        4'd3: card_num9_mul = 6;//6
        4'd4: card_num9_mul = 8;//8
        4'd5: card_num9_mul = 1;//10
        4'd6: card_num9_mul = 3;//12
        4'd7: card_num9_mul = 5;//14
        4'd8: card_num9_mul = 7;//16
        4'd9: card_num9_mul = 9;//18
        default:card_num9_mul = 0;
    endcase
end

always@(*)begin
    case(card_num11)
        4'd0: card_num11_mul = 0;//0
        4'd1: card_num11_mul = 2;//2
        4'd2: card_num11_mul = 4;//4
        4'd3: card_num11_mul = 6;//6
        4'd4: card_num11_mul = 8;//8
        4'd5: card_num11_mul = 1;//10
        4'd6: card_num11_mul = 3;//12
        4'd7: card_num11_mul = 5;//14
        4'd8: card_num11_mul = 7;//16
        4'd9: card_num11_mul = 9;//18
        default:card_num11_mul = 0;
    endcase
end

always@(*)begin
    case(card_num13)
        4'd0: card_num13_mul = 0;//0
        4'd1: card_num13_mul = 2;//2
        4'd2: card_num13_mul = 4;//4
        4'd3: card_num13_mul = 6;//6
        4'd4: card_num13_mul = 8;//8
        4'd5: card_num13_mul = 1;//10
        4'd6: card_num13_mul = 3;//12
        4'd7: card_num13_mul = 5;//14
        4'd8: card_num13_mul = 7;//16
        4'd9: card_num13_mul = 9;//18
        default:card_num13_mul = 0;
    endcase
end

always@(*)begin
    case(card_num15)
        4'd0: card_num15_mul = 0;//0
        4'd1: card_num15_mul = 2;//2
        4'd2: card_num15_mul = 4;//4
        4'd3: card_num15_mul = 6;//6
        4'd4: card_num15_mul = 8;//8
        4'd5: card_num15_mul = 1;//10
        4'd6: card_num15_mul = 3;//12
        4'd7: card_num15_mul = 5;//14
        4'd8: card_num15_mul = 7;//16
        4'd9: card_num15_mul = 9;//18
        default:card_num15_mul = 0;
    endcase
end

//assign card_num_total = card_num1_mul + card_num3_mul + card_num5_mul + card_num7_mul + card_num9_mul + card_num11_mul + card_num13_mul + card_num15_mul + card_num2 + card_num4 + card_num6 + card_num8 + card_num10 + card_num12 + card_num14 + card_num16;

wire [6:0] card_num_total_1;
wire [6:0] card_num_total_2;
wire [6:0] card_num_total_3;
wire [6:0] card_num_total_4;




assign card_num_total_1 = card_num1_mul + card_num3_mul + card_num5_mul + card_num7_mul ;
assign card_num_total_2 = card_num9_mul + card_num11_mul + card_num13_mul + card_num15_mul ;
assign card_num_total_3 = card_num2 + card_num4 + card_num6 + card_num8  ;
assign card_num_total_4 = card_num10 + card_num12 + card_num14 + card_num16 ;
assign card_num_total   = card_num_total_1 + card_num_total_2 + card_num_total_3 + card_num_total_4 ;



//assign card_num_total = card_num_mul13 + card_num_mul57 +  card_num_mul911 + card_num_mul1315 + card_num24 + card_num68 + card_num1012 + card_num1416;



/*always @(*) begin
    case (card_num1_mul)
        4'd0: case(card_num3_mul)
                4'd0: card_num_mul13 = 0;
                4'd1: card_num_mul13 = 1;
                4'd2: card_num_mul13 = 2;
                4'd3: card_num_mul13 = 3;
                4'd4: card_num_mul13 = 4;
                4'd5: card_num_mul13 = 5;
                4'd6: card_num_mul13 = 6;
                4'd7: card_num_mul13 = 7;
                4'd8: card_num_mul13 = 8;
                4'd9: card_num_mul13 = 9;
                default: card_num_mul13 = 0;
              endcase
        4'd1: case(card_num3_mul)
                4'd0: card_num_mul13 = 1;
                4'd1: card_num_mul13 = 2;
                4'd2: card_num_mul13 = 3;
                4'd3: card_num_mul13 = 4;
                4'd4: card_num_mul13 = 5;
                4'd5: card_num_mul13 = 6;
                4'd6: card_num_mul13 = 7;
                4'd7: card_num_mul13 = 8;
                4'd8: card_num_mul13 = 9;
                4'd9: card_num_mul13 = 10;
                default: card_num_mul13 = 0;
              endcase
        4'd2: case(card_num3_mul)
                4'd0: card_num_mul13 = 2;
                4'd1: card_num_mul13 = 3;
                4'd2: card_num_mul13 = 4;
                4'd3: card_num_mul13 = 5;
                4'd4: card_num_mul13 = 6;
                4'd5: card_num_mul13 = 7;
                4'd6: card_num_mul13 = 8;
                4'd7: card_num_mul13 = 9;
                4'd8: card_num_mul13 = 10;
                4'd9: card_num_mul13 = 11;
                default: card_num_mul13 = 0;
              endcase
        4'd3: case(card_num3_mul)
                4'd0: card_num_mul13 = 3;
                4'd1: card_num_mul13 = 4;
                4'd2: card_num_mul13 = 5;
                4'd3: card_num_mul13 = 6;
                4'd4: card_num_mul13 = 7;
                4'd5: card_num_mul13 = 8;
                4'd6: card_num_mul13 = 9;
                4'd7: card_num_mul13 = 10;
                4'd8: card_num_mul13 = 11;
                4'd9: card_num_mul13 = 12;
                default: card_num_mul13 = 0;
              endcase
        4'd4: case(card_num3_mul)
                4'd0: card_num_mul13 = 4;
                4'd1: card_num_mul13 = 5;
                4'd2: card_num_mul13 = 6;
                4'd3: card_num_mul13 = 7;
                4'd4: card_num_mul13 = 8;
                4'd5: card_num_mul13 = 9;
                4'd6: card_num_mul13 = 10;
                4'd7: card_num_mul13 = 11;
                4'd8: card_num_mul13 = 12;
                4'd9: card_num_mul13 = 13;
                default: card_num_mul13 = 0;
              endcase
        4'd5: case(card_num3_mul)
                4'd0: card_num_mul13 = 5;
                4'd1: card_num_mul13 = 6;
                4'd2: card_num_mul13 = 7;
                4'd3: card_num_mul13 = 8;
                4'd4: card_num_mul13 = 9;
                4'd5: card_num_mul13 = 10;
                4'd6: card_num_mul13 = 11;
                4'd7: card_num_mul13 = 12;
                4'd8: card_num_mul13 = 13;
                4'd9: card_num_mul13 = 14;
                default: card_num_mul13 = 0;
              endcase
        4'd6: case(card_num3_mul)
                4'd0: card_num_mul13 = 6;
                4'd1: card_num_mul13 = 7;
                4'd2: card_num_mul13 = 8;
                4'd3: card_num_mul13 = 9;
                4'd4: card_num_mul13 = 10;
                4'd5: card_num_mul13 = 11;
                4'd6: card_num_mul13 = 12;
                4'd7: card_num_mul13 = 13;
                4'd8: card_num_mul13 = 14;
                4'd9: card_num_mul13 = 15;
                default: card_num_mul13 = 0;
              endcase
        4'd7: case(card_num3_mul)
                4'd0: card_num_mul13 = 7;
                4'd1: card_num_mul13 = 8;
                4'd2: card_num_mul13 = 9;
                4'd3: card_num_mul13 = 10;
                4'd4: card_num_mul13 = 11;
                4'd5: card_num_mul13 = 12;
                4'd6: card_num_mul13 = 13;
                4'd7: card_num_mul13 = 14;
                4'd8: card_num_mul13 = 15;
                4'd9: card_num_mul13 = 16;
                default: card_num_mul13 = 0;
              endcase
        4'd8: case(card_num3_mul)
                4'd0: card_num_mul13 = 8;
                4'd1: card_num_mul13 = 9;
                4'd2: card_num_mul13 = 10;
                4'd3: card_num_mul13 = 11;
                4'd4: card_num_mul13 = 12;
                4'd5: card_num_mul13 = 13;
                4'd6: card_num_mul13 = 14;
                4'd7: card_num_mul13 = 15;
                4'd8: card_num_mul13 = 16;
                4'd9: card_num_mul13 = 17;
                default: card_num_mul13 = 0;
              endcase
        4'd9: case(card_num3_mul)
                4'd0: card_num_mul13 = 9;
                4'd1: card_num_mul13 = 10;
                4'd2: card_num_mul13 = 11;
                4'd3: card_num_mul13 = 12;
                4'd4: card_num_mul13 = 13;
                4'd5: card_num_mul13 = 14;
                4'd6: card_num_mul13 = 15;
                4'd7: card_num_mul13 = 16;
                4'd8: card_num_mul13 = 17;
                4'd9: card_num_mul13 = 18;
                default: card_num_mul13 = 0;
              endcase
        default: card_num_mul13 = 0;
    endcase
end

always @(*) begin
    case (card_num5_mul)
        4'd0: case(card_num7_mul)
                4'd0: card_num_mul57 = 0;
                4'd1: card_num_mul57 = 1;
                4'd2: card_num_mul57 = 2;
                4'd3: card_num_mul57 = 3;
                4'd4: card_num_mul57 = 4;
                4'd5: card_num_mul57 = 5;
                4'd6: card_num_mul57 = 6;
                4'd7: card_num_mul57 = 7;
                4'd8: card_num_mul57 = 8;
                4'd9: card_num_mul57 = 9;
                default: card_num_mul57 = 0;
              endcase
        4'd1: case(card_num7_mul)
                4'd0: card_num_mul57 = 1;
                4'd1: card_num_mul57 = 2;
                4'd2: card_num_mul57 = 3;
                4'd3: card_num_mul57 = 4;
                4'd4: card_num_mul57 = 5;
                4'd5: card_num_mul57 = 6;
                4'd6: card_num_mul57 = 7;
                4'd7: card_num_mul57 = 8;
                4'd8: card_num_mul57 = 9;
                4'd9: card_num_mul57 = 10;
                default: card_num_mul57 = 0;
              endcase
        4'd2: case(card_num7_mul)
                4'd0: card_num_mul57 = 2;
                4'd1: card_num_mul57 = 3;
                4'd2: card_num_mul57 = 4;
                4'd3: card_num_mul57 = 5;
                4'd4: card_num_mul57 = 6;
                4'd5: card_num_mul57 = 7;
                4'd6: card_num_mul57 = 8;
                4'd7: card_num_mul57 = 9;
                4'd8: card_num_mul57 = 10;
                4'd9: card_num_mul57 = 11;
                default: card_num_mul57 = 0;
              endcase
        4'd3: case(card_num7_mul)
                4'd0: card_num_mul57 = 3;
                4'd1: card_num_mul57 = 4;
                4'd2: card_num_mul57 = 5;
                4'd3: card_num_mul57 = 6;
                4'd4: card_num_mul57 = 7;
                4'd5: card_num_mul57 = 8;
                4'd6: card_num_mul57 = 9;
                4'd7: card_num_mul57 = 10;
                4'd8: card_num_mul57 = 11;
                4'd9: card_num_mul57 = 12;
                default: card_num_mul57 = 0;
              endcase
        4'd4: case(card_num7_mul)
                4'd0: card_num_mul57 = 4;
                4'd1: card_num_mul57 = 5;
                4'd2: card_num_mul57 = 6;
                4'd3: card_num_mul57 = 7;
                4'd4: card_num_mul57 = 8;
                4'd5: card_num_mul57 = 9;
                4'd6: card_num_mul57 = 10;
                4'd7: card_num_mul57 = 11;
                4'd8: card_num_mul57 = 12;
                4'd9: card_num_mul57 = 13;
                default: card_num_mul57 = 0;
              endcase
        4'd5: case(card_num7_mul)
                4'd0: card_num_mul57 = 5;
                4'd1: card_num_mul57 = 6;
                4'd2: card_num_mul57 = 7;
                4'd3: card_num_mul57 = 8;
                4'd4: card_num_mul57 = 9;
                4'd5: card_num_mul57 = 10;
                4'd6: card_num_mul57 = 11;
                4'd7: card_num_mul57 = 12;
                4'd8: card_num_mul57 = 13;
                4'd9: card_num_mul57 = 14;
                default: card_num_mul57 = 0;
              endcase
        4'd6: case(card_num7_mul)
                4'd0: card_num_mul57 = 6;
                4'd1: card_num_mul57 = 7;
                4'd2: card_num_mul57 = 8;
                4'd3: card_num_mul57 = 9;
                4'd4: card_num_mul57 = 10;
                4'd5: card_num_mul57 = 11;
                4'd6: card_num_mul57 = 12;
                4'd7: card_num_mul57 = 13;
                4'd8: card_num_mul57 = 14;
                4'd9: card_num_mul57 = 15;
                default: card_num_mul57 = 0;
              endcase
        4'd7: case(card_num7_mul)
                4'd0: card_num_mul57 = 7;
                4'd1: card_num_mul57 = 8;
                4'd2: card_num_mul57 = 9;
                4'd3: card_num_mul57 = 10;
                4'd4: card_num_mul57 = 11;
                4'd5: card_num_mul57 = 12;
                4'd6: card_num_mul57 = 13;
                4'd7: card_num_mul57 = 14;
                4'd8: card_num_mul57 = 15;
                4'd9: card_num_mul57 = 16;
                default: card_num_mul57 = 0;
              endcase
        4'd8: case(card_num7_mul)
                4'd0: card_num_mul57 = 8;
                4'd1: card_num_mul57 = 9;
                4'd2: card_num_mul57 = 10;
                4'd3: card_num_mul57 = 11;
                4'd4: card_num_mul57 = 12;
                4'd5: card_num_mul57 = 13;
                4'd6: card_num_mul57 = 14;
                4'd7: card_num_mul57 = 15;
                4'd8: card_num_mul57 = 16;
                4'd9: card_num_mul57 = 17;
                default: card_num_mul57 = 0;
              endcase
        4'd9: case(card_num7_mul)
                4'd0: card_num_mul57 = 9;
                4'd1: card_num_mul57 = 10;
                4'd2: card_num_mul57 = 11;
                4'd3: card_num_mul57 = 12;
                4'd4: card_num_mul57 = 13;
                4'd5: card_num_mul57 = 14;
                4'd6: card_num_mul57 = 15;
                4'd7: card_num_mul57 = 16;
                4'd8: card_num_mul57 = 17;
                4'd9: card_num_mul57 = 18;
                default: card_num_mul57 = 0;
              endcase
        default: card_num_mul57 = 0;
    endcase
end

always @(*) begin
    case (card_num9_mul)
        4'd0: case(card_num11_mul)
                4'd0: card_num_mul911 = 0;
                4'd1: card_num_mul911 = 1;
                4'd2: card_num_mul911 = 2;
                4'd3: card_num_mul911 = 3;
                4'd4: card_num_mul911 = 4;
                4'd5: card_num_mul911 = 5;
                4'd6: card_num_mul911 = 6;
                4'd7: card_num_mul911 = 7;
                4'd8: card_num_mul911 = 8;
                4'd9: card_num_mul911 = 9;
                default: card_num_mul911 = 0;
              endcase
        4'd1: case(card_num11_mul)
                4'd0: card_num_mul911 = 1;
                4'd1: card_num_mul911 = 2;
                4'd2: card_num_mul911 = 3;
                4'd3: card_num_mul911 = 4;
                4'd4: card_num_mul911 = 5;
                4'd5: card_num_mul911 = 6;
                4'd6: card_num_mul911 = 7;
                4'd7: card_num_mul911 = 8;
                4'd8: card_num_mul911 = 9;
                4'd9: card_num_mul911 = 10;
                default: card_num_mul911 = 0;
              endcase
        4'd2: case(card_num11_mul)
                4'd0: card_num_mul911 = 2;
                4'd1: card_num_mul911 = 3;
                4'd2: card_num_mul911 = 4;
                4'd3: card_num_mul911 = 5;
                4'd4: card_num_mul911 = 6;
                4'd5: card_num_mul911 = 7;
                4'd6: card_num_mul911 = 8;
                4'd7: card_num_mul911 = 9;
                4'd8: card_num_mul911 = 10;
                4'd9: card_num_mul911 = 11;
                default: card_num_mul911 = 0;
              endcase
        4'd3: case(card_num11_mul)
                4'd0: card_num_mul911 = 3;
                4'd1: card_num_mul911 = 4;
                4'd2: card_num_mul911 = 5;
                4'd3: card_num_mul911 = 6;
                4'd4: card_num_mul911 = 7;
                4'd5: card_num_mul911 = 8;
                4'd6: card_num_mul911 = 9;
                4'd7: card_num_mul911 = 10;
                4'd8: card_num_mul911 = 11;
                4'd9: card_num_mul911 = 12;
                default: card_num_mul911 = 0;
              endcase
        4'd4: case(card_num11_mul)
                4'd0: card_num_mul911 = 4;
                4'd1: card_num_mul911 = 5;
                4'd2: card_num_mul911 = 6;
                4'd3: card_num_mul911 = 7;
                4'd4: card_num_mul911 = 8;
                4'd5: card_num_mul911 = 9;
                4'd6: card_num_mul911 = 10;
                4'd7: card_num_mul911 = 11;
                4'd8: card_num_mul911 = 12;
                4'd9: card_num_mul911 = 13;
                default: card_num_mul911 = 0;
              endcase
        4'd5: case(card_num11_mul)
                4'd0: card_num_mul911 = 5;
                4'd1: card_num_mul911 = 6;
                4'd2: card_num_mul911 = 7;
                4'd3: card_num_mul911 = 8;
                4'd4: card_num_mul911 = 9;
                4'd5: card_num_mul911 = 10;
                4'd6: card_num_mul911 = 11;
                4'd7: card_num_mul911 = 12;
                4'd8: card_num_mul911 = 13;
                4'd9: card_num_mul911 = 14;
                default: card_num_mul911 = 0;
              endcase
        4'd6: case(card_num11_mul)
                4'd0: card_num_mul911 = 6;
                4'd1: card_num_mul911 = 7;
                4'd2: card_num_mul911 = 8;
                4'd3: card_num_mul911 = 9;
                4'd4: card_num_mul911 = 10;
                4'd5: card_num_mul911 = 11;
                4'd6: card_num_mul911 = 12;
                4'd7: card_num_mul911 = 13;
                4'd8: card_num_mul911 = 14;
                4'd9: card_num_mul911 = 15;
                default: card_num_mul911 = 0;
              endcase
        4'd7: case(card_num11_mul)
                4'd0: card_num_mul911 = 7;
                4'd1: card_num_mul911 = 8;
                4'd2: card_num_mul911 = 9;
                4'd3: card_num_mul911 = 10;
                4'd4: card_num_mul911 = 11;
                4'd5: card_num_mul911 = 12;
                4'd6: card_num_mul911 = 13;
                4'd7: card_num_mul911 = 14;
                4'd8: card_num_mul911 = 15;
                4'd9: card_num_mul911 = 16;
                default: card_num_mul911 = 0;
              endcase
        4'd8: case(card_num11_mul)
                4'd0: card_num_mul911 = 8;
                4'd1: card_num_mul911 = 9;
                4'd2: card_num_mul911 = 10;
                4'd3: card_num_mul911 = 11;
                4'd4: card_num_mul911 = 12;
                4'd5: card_num_mul911 = 13;
                4'd6: card_num_mul911 = 14;
                4'd7: card_num_mul911 = 15;
                4'd8: card_num_mul911 = 16;
                4'd9: card_num_mul911 = 17;
                default: card_num_mul911 = 0;
              endcase
        4'd9: case(card_num11_mul)
                4'd0: card_num_mul911 = 9;
                4'd1: card_num_mul911 = 10;
                4'd2: card_num_mul911 = 11;
                4'd3: card_num_mul911 = 12;
                4'd4: card_num_mul911 = 13;
                4'd5: card_num_mul911 = 14;
                4'd6: card_num_mul911 = 15;
                4'd7: card_num_mul911 = 16;
                4'd8: card_num_mul911 = 17;
                4'd9: card_num_mul911 = 18;
                default: card_num_mul911 = 0;
              endcase
        default: card_num_mul911 = 0;
    endcase
end

always @(*) begin
    case (card_num13_mul)
        4'd0: case(card_num15_mul)
                4'd0: card_num_mul1315 = 0;
                4'd1: card_num_mul1315 = 1;
                4'd2: card_num_mul1315 = 2;
                4'd3: card_num_mul1315 = 3;
                4'd4: card_num_mul1315 = 4;
                4'd5: card_num_mul1315 = 5;
                4'd6: card_num_mul1315 = 6;
                4'd7: card_num_mul1315 = 7;
                4'd8: card_num_mul1315 = 8;
                4'd9: card_num_mul1315 = 9;
                default: card_num_mul1315 = 0;
              endcase
        4'd1: case(card_num15_mul)
                4'd0: card_num_mul1315 = 1;
                4'd1: card_num_mul1315 = 2;
                4'd2: card_num_mul1315 = 3;
                4'd3: card_num_mul1315 = 4;
                4'd4: card_num_mul1315 = 5;
                4'd5: card_num_mul1315 = 6;
                4'd6: card_num_mul1315 = 7;
                4'd7: card_num_mul1315 = 8;
                4'd8: card_num_mul1315 = 9;
                4'd9: card_num_mul1315 = 10;
                default: card_num_mul1315 = 0;
              endcase
        4'd2: case(card_num15_mul)
                4'd0: card_num_mul1315 = 2;
                4'd1: card_num_mul1315 = 3;
                4'd2: card_num_mul1315 = 4;
                4'd3: card_num_mul1315 = 5;
                4'd4: card_num_mul1315 = 6;
                4'd5: card_num_mul1315 = 7;
                4'd6: card_num_mul1315 = 8;
                4'd7: card_num_mul1315 = 9;
                4'd8: card_num_mul1315 = 10;
                4'd9: card_num_mul1315 = 11;
                default: card_num_mul1315 = 0;
              endcase
        4'd3: case(card_num15_mul)
                4'd0: card_num_mul1315 = 3;
                4'd1: card_num_mul1315 = 4;
                4'd2: card_num_mul1315 = 5;
                4'd3: card_num_mul1315 = 6;
                4'd4: card_num_mul1315 = 7;
                4'd5: card_num_mul1315 = 8;
                4'd6: card_num_mul1315 = 9;
                4'd7: card_num_mul1315 = 10;
                4'd8: card_num_mul1315 = 11;
                4'd9: card_num_mul1315 = 12;
                default: card_num_mul1315 = 0;
              endcase
        4'd4: case(card_num15_mul)
                4'd0: card_num_mul1315 = 4;
                4'd1: card_num_mul1315 = 5;
                4'd2: card_num_mul1315 = 6;
                4'd3: card_num_mul1315 = 7;
                4'd4: card_num_mul1315 = 8;
                4'd5: card_num_mul1315 = 9;
                4'd6: card_num_mul1315 = 10;
                4'd7: card_num_mul1315 = 11;
                4'd8: card_num_mul1315 = 12;
                4'd9: card_num_mul1315 = 13;
                default: card_num_mul1315 = 0;
              endcase
        4'd5: case(card_num15_mul)
                4'd0: card_num_mul1315 = 5;
                4'd1: card_num_mul1315 = 6;
                4'd2: card_num_mul1315 = 7;
                4'd3: card_num_mul1315 = 8;
                4'd4: card_num_mul1315 = 9;
                4'd5: card_num_mul1315 = 10;
                4'd6: card_num_mul1315 = 11;
                4'd7: card_num_mul1315 = 12;
                4'd8: card_num_mul1315 = 13;
                4'd9: card_num_mul1315 = 14;
                default: card_num_mul1315 = 0;
              endcase
        4'd6: case(card_num15_mul)
                4'd0: card_num_mul1315 = 6;
                4'd1: card_num_mul1315 = 7;
                4'd2: card_num_mul1315 = 8;
                4'd3: card_num_mul1315 = 9;
                4'd4: card_num_mul1315 = 10;
                4'd5: card_num_mul1315 = 11;
                4'd6: card_num_mul1315 = 12;
                4'd7: card_num_mul1315 = 13;
                4'd8: card_num_mul1315 = 14;
                4'd9: card_num_mul1315 = 15;
                default: card_num_mul1315 = 0;
              endcase
        4'd7: case(card_num15_mul)
                4'd0: card_num_mul1315 = 7;
                4'd1: card_num_mul1315 = 8;
                4'd2: card_num_mul1315 = 9;
                4'd3: card_num_mul1315 = 10;
                4'd4: card_num_mul1315 = 11;
                4'd5: card_num_mul1315 = 12;
                4'd6: card_num_mul1315 = 13;
                4'd7: card_num_mul1315 = 14;
                4'd8: card_num_mul1315 = 15;
                4'd9: card_num_mul1315 = 16;
                default: card_num_mul1315 = 0;
              endcase
        4'd8: case(card_num15_mul)
                4'd0: card_num_mul1315 = 8;
                4'd1: card_num_mul1315 = 9;
                4'd2: card_num_mul1315 = 10;
                4'd3: card_num_mul1315 = 11;
                4'd4: card_num_mul1315 = 12;
                4'd5: card_num_mul1315 = 13;
                4'd6: card_num_mul1315 = 14;
                4'd7: card_num_mul1315 = 15;
                4'd8: card_num_mul1315 = 16;
                4'd9: card_num_mul1315 = 17;
                default: card_num_mul1315 = 0;
              endcase
        4'd9: case(card_num15_mul)
                4'd0: card_num_mul1315 = 9;
                4'd1: card_num_mul1315 = 10;
                4'd2: card_num_mul1315 = 11;
                4'd3: card_num_mul1315 = 12;
                4'd4: card_num_mul1315 = 13;
                4'd5: card_num_mul1315 = 14;
                4'd6: card_num_mul1315 = 15;
                4'd7: card_num_mul1315 = 16;
                4'd8: card_num_mul1315 = 17;
                4'd9: card_num_mul1315 = 18;
                default: card_num_mul1315 = 0;
              endcase
        default: card_num_mul1315 = 0;
    endcase
end

always @(*) begin
    case (card_num2)
        4'd0: case(card_num4)
                4'd0: card_num24 = 0;
                4'd1: card_num24 = 1;
                4'd2: card_num24 = 2;
                4'd3: card_num24 = 3;
                4'd4: card_num24 = 4;
                4'd5: card_num24 = 5;
                4'd6: card_num24 = 6;
                4'd7: card_num24 = 7;
                4'd8: card_num24 = 8;
                4'd9: card_num24 = 9;
                default: card_num24 = 0;
              endcase
        4'd1: case(card_num4)
                4'd0: card_num24 = 1;
                4'd1: card_num24 = 2;
                4'd2: card_num24 = 3;
                4'd3: card_num24 = 4;
                4'd4: card_num24 = 5;
                4'd5: card_num24 = 6;
                4'd6: card_num24 = 7;
                4'd7: card_num24 = 8;
                4'd8: card_num24 = 9;
                4'd9: card_num24 = 10;
                default: card_num24 = 0;
              endcase
        4'd2: case(card_num4)
                4'd0: card_num24 = 2;
                4'd1: card_num24 = 3;
                4'd2: card_num24 = 4;
                4'd3: card_num24 = 5;
                4'd4: card_num24 = 6;
                4'd5: card_num24 = 7;
                4'd6: card_num24 = 8;
                4'd7: card_num24 = 9;
                4'd8: card_num24 = 10;
                4'd9: card_num24 = 11;
                default: card_num24 = 0;
              endcase
        4'd3: case(card_num4)
                4'd0: card_num24 = 3;
                4'd1: card_num24 = 4;
                4'd2: card_num24 = 5;
                4'd3: card_num24 = 6;
                4'd4: card_num24 = 7;
                4'd5: card_num24 = 8;
                4'd6: card_num24 = 9;
                4'd7: card_num24 = 10;
                4'd8: card_num24 = 11;
                4'd9: card_num24 = 12;
                default: card_num24 = 0;
              endcase
        4'd4: case(card_num4)
                4'd0: card_num24 = 4;
                4'd1: card_num24 = 5;
                4'd2: card_num24 = 6;
                4'd3: card_num24 = 7;
                4'd4: card_num24 = 8;
                4'd5: card_num24 = 9;
                4'd6: card_num24 = 10;
                4'd7: card_num24 = 11;
                4'd8: card_num24 = 12;
                4'd9: card_num24 = 13;
                default: card_num24 = 0;
              endcase
        4'd5: case(card_num4)
                4'd0: card_num24 = 5;
                4'd1: card_num24 = 6;
                4'd2: card_num24 = 7;
                4'd3: card_num24 = 8;
                4'd4: card_num24 = 9;
                4'd5: card_num24 = 10;
                4'd6: card_num24 = 11;
                4'd7: card_num24 = 12;
                4'd8: card_num24 = 13;
                4'd9: card_num24 = 14;
                default: card_num24 = 0;
              endcase
        4'd6: case(card_num4)
                4'd0: card_num24 = 6;
                4'd1: card_num24 = 7;
                4'd2: card_num24 = 8;
                4'd3: card_num24 = 9;
                4'd4: card_num24 = 10;
                4'd5: card_num24 = 11;
                4'd6: card_num24 = 12;
                4'd7: card_num24 = 13;
                4'd8: card_num24 = 14;
                4'd9: card_num24 = 15;
                default: card_num24 = 0;
              endcase
        4'd7: case(card_num4)
                4'd0: card_num24 = 7;
                4'd1: card_num24 = 8;
                4'd2: card_num24 = 9;
                4'd3: card_num24 = 10;
                4'd4: card_num24 = 11;
                4'd5: card_num24 = 12;
                4'd6: card_num24 = 13;
                4'd7: card_num24 = 14;
                4'd8: card_num24 = 15;
                4'd9: card_num24 = 16;
                default: card_num24 = 0;
              endcase
        4'd8: case(card_num4)
                4'd0: card_num24 = 8;
                4'd1: card_num24 = 9;
                4'd2: card_num24 = 10;
                4'd3: card_num24 = 11;
                4'd4: card_num24 = 12;
                4'd5: card_num24 = 13;
                4'd6: card_num24 = 14;
                4'd7: card_num24 = 15;
                4'd8: card_num24 = 16;
                4'd9: card_num24 = 17;
                default: card_num24 = 0;
              endcase
        4'd9: case(card_num4)
                4'd0: card_num24 = 9;
                4'd1: card_num24 = 10;
                4'd2: card_num24 = 11;
                4'd3: card_num24 = 12;
                4'd4: card_num24 = 13;
                4'd5: card_num24 = 14;
                4'd6: card_num24 = 15;
                4'd7: card_num24 = 16;
                4'd8: card_num24 = 17;
                4'd9: card_num24 = 18;
                default: card_num24 = 0;
              endcase
        default: card_num24 = 0;
    endcase
end

always @(*) begin
    case (card_num6)
        4'd0: case(card_num8)
                4'd0: card_num68 = 0;
                4'd1: card_num68 = 1;
                4'd2: card_num68 = 2;
                4'd3: card_num68 = 3;
                4'd4: card_num68 = 4;
                4'd5: card_num68 = 5;
                4'd6: card_num68 = 6;
                4'd7: card_num68 = 7;
                4'd8: card_num68 = 8;
                4'd9: card_num68 = 9;
                default: card_num68 = 0;
              endcase
        4'd1: case(card_num8)
                4'd0: card_num68 = 1;
                4'd1: card_num68 = 2;
                4'd2: card_num68 = 3;
                4'd3: card_num68 = 4;
                4'd4: card_num68 = 5;
                4'd5: card_num68 = 6;
                4'd6: card_num68 = 7;
                4'd7: card_num68 = 8;
                4'd8: card_num68 = 9;
                4'd9: card_num68 = 10;
                default: card_num68 = 0;
              endcase
        4'd2: case(card_num8)
                4'd0: card_num68 = 2;
                4'd1: card_num68 = 3;
                4'd2: card_num68 = 4;
                4'd3: card_num68 = 5;
                4'd4: card_num68 = 6;
                4'd5: card_num68 = 7;
                4'd6: card_num68 = 8;
                4'd7: card_num68 = 9;
                4'd8: card_num68 = 10;
                4'd9: card_num68 = 11;
                default: card_num68 = 0;
              endcase
        4'd3: case(card_num8)
                4'd0: card_num68 = 3;
                4'd1: card_num68 = 4;
                4'd2: card_num68 = 5;
                4'd3: card_num68 = 6;
                4'd4: card_num68 = 7;
                4'd5: card_num68 = 8;
                4'd6: card_num68 = 9;
                4'd7: card_num68 = 10;
                4'd8: card_num68 = 11;
                4'd9: card_num68 = 12;
                default: card_num68 = 0;
              endcase
        4'd4: case(card_num8)
                4'd0: card_num68 = 4;
                4'd1: card_num68 = 5;
                4'd2: card_num68 = 6;
                4'd3: card_num68 = 7;
                4'd4: card_num68 = 8;
                4'd5: card_num68 = 9;
                4'd6: card_num68 = 10;
                4'd7: card_num68 = 11;
                4'd8: card_num68 = 12;
                4'd9: card_num68 = 13;
                default: card_num68 = 0;
              endcase
        4'd5: case(card_num8)
                4'd0: card_num68 = 5;
                4'd1: card_num68 = 6;
                4'd2: card_num68 = 7;
                4'd3: card_num68 = 8;
                4'd4: card_num68 = 9;
                4'd5: card_num68 = 10;
                4'd6: card_num68 = 11;
                4'd7: card_num68 = 12;
                4'd8: card_num68 = 13;
                4'd9: card_num68 = 14;
                default: card_num68 = 0;
              endcase
        4'd6: case(card_num8)
                4'd0: card_num68 = 6;
                4'd1: card_num68 = 7;
                4'd2: card_num68 = 8;
                4'd3: card_num68 = 9;
                4'd4: card_num68 = 10;
                4'd5: card_num68 = 11;
                4'd6: card_num68 = 12;
                4'd7: card_num68 = 13;
                4'd8: card_num68 = 14;
                4'd9: card_num68 = 15;
                default: card_num68 = 0;
              endcase
        4'd7: case(card_num8)
                4'd0: card_num68 = 7;
                4'd1: card_num68 = 8;
                4'd2: card_num68 = 9;
                4'd3: card_num68 = 10;
                4'd4: card_num68 = 11;
                4'd5: card_num68 = 12;
                4'd6: card_num68 = 13;
                4'd7: card_num68 = 14;
                4'd8: card_num68 = 15;
                4'd9: card_num68 = 16;
                default: card_num68 = 0;
              endcase
        4'd8: case(card_num8)
                4'd0: card_num68 = 8;
                4'd1: card_num68 = 9;
                4'd2: card_num68 = 10;
                4'd3: card_num68 = 11;
                4'd4: card_num68 = 12;
                4'd5: card_num68 = 13;
                4'd6: card_num68 = 14;
                4'd7: card_num68 = 15;
                4'd8: card_num68 = 16;
                4'd9: card_num68 = 17;
                default: card_num68 = 0;
              endcase
        4'd9: case(card_num8)
                4'd0: card_num68 = 9;
                4'd1: card_num68 = 10;
                4'd2: card_num68 = 11;
                4'd3: card_num68 = 12;
                4'd4: card_num68 = 13;
                4'd5: card_num68 = 14;
                4'd6: card_num68 = 15;
                4'd7: card_num68 = 16;
                4'd8: card_num68 = 17;
                4'd9: card_num68 = 18;
                default: card_num68 = 0;
              endcase
        default: card_num68 = 0;
    endcase
end

always @(*) begin
    case (card_num10)
        4'd0: case(card_num12)
                4'd0: card_num1012 = 0;
                4'd1: card_num1012 = 1;
                4'd2: card_num1012 = 2;
                4'd3: card_num1012 = 3;
                4'd4: card_num1012 = 4;
                4'd5: card_num1012 = 5;
                4'd6: card_num1012 = 6;
                4'd7: card_num1012 = 7;
                4'd8: card_num1012 = 8;
                4'd9: card_num1012 = 9;
                default: card_num1012 = 0;
              endcase
        4'd1: case(card_num12)
                4'd0: card_num1012 = 1;
                4'd1: card_num1012 = 2;
                4'd2: card_num1012 = 3;
                4'd3: card_num1012 = 4;
                4'd4: card_num1012 = 5;
                4'd5: card_num1012 = 6;
                4'd6: card_num1012 = 7;
                4'd7: card_num1012 = 8;
                4'd8: card_num1012 = 9;
                4'd9: card_num1012 = 10;
                default: card_num1012 = 0;
              endcase
        4'd2: case(card_num12)
                4'd0: card_num1012 = 2;
                4'd1: card_num1012 = 3;
                4'd2: card_num1012 = 4;
                4'd3: card_num1012 = 5;
                4'd4: card_num1012 = 6;
                4'd5: card_num1012 = 7;
                4'd6: card_num1012 = 8;
                4'd7: card_num1012 = 9;
                4'd8: card_num1012 = 10;
                4'd9: card_num1012 = 11;
                default: card_num1012 = 0;
              endcase
        4'd3: case(card_num12)
                4'd0: card_num1012 = 3;
                4'd1: card_num1012 = 4;
                4'd2: card_num1012 = 5;
                4'd3: card_num1012 = 6;
                4'd4: card_num1012 = 7;
                4'd5: card_num1012 = 8;
                4'd6: card_num1012 = 9;
                4'd7: card_num1012 = 10;
                4'd8: card_num1012 = 11;
                4'd9: card_num1012 = 12;
                default: card_num1012 = 0;
              endcase
        4'd4: case(card_num12)
                4'd0: card_num1012 = 4;
                4'd1: card_num1012 = 5;
                4'd2: card_num1012 = 6;
                4'd3: card_num1012 = 7;
                4'd4: card_num1012 = 8;
                4'd5: card_num1012 = 9;
                4'd6: card_num1012 = 10;
                4'd7: card_num1012 = 11;
                4'd8: card_num1012 = 12;
                4'd9: card_num1012 = 13;
                default: card_num1012 = 0;
              endcase
        4'd5: case(card_num12)
                4'd0: card_num1012 = 5;
                4'd1: card_num1012 = 6;
                4'd2: card_num1012 = 7;
                4'd3: card_num1012 = 8;
                4'd4: card_num1012 = 9;
                4'd5: card_num1012 = 10;
                4'd6: card_num1012 = 11;
                4'd7: card_num1012 = 12;
                4'd8: card_num1012 = 13;
                4'd9: card_num1012 = 14;
                default: card_num1012 = 0;
              endcase
        4'd6: case(card_num12)
                4'd0: card_num1012 = 6;
                4'd1: card_num1012 = 7;
                4'd2: card_num1012 = 8;
                4'd3: card_num1012 = 9;
                4'd4: card_num1012 = 10;
                4'd5: card_num1012 = 11;
                4'd6: card_num1012 = 12;
                4'd7: card_num1012 = 13;
                4'd8: card_num1012 = 14;
                4'd9: card_num1012 = 15;
                default: card_num1012 = 0;
              endcase
        4'd7: case(card_num12)
                4'd0: card_num1012 = 7;
                4'd1: card_num1012 = 8;
                4'd2: card_num1012 = 9;
                4'd3: card_num1012 = 10;
                4'd4: card_num1012 = 11;
                4'd5: card_num1012 = 12;
                4'd6: card_num1012 = 13;
                4'd7: card_num1012 = 14;
                4'd8: card_num1012 = 15;
                4'd9: card_num1012 = 16;
                default: card_num1012 = 0;
              endcase
        4'd8: case(card_num12)
                4'd0: card_num1012 = 8;
                4'd1: card_num1012 = 9;
                4'd2: card_num1012 = 10;
                4'd3: card_num1012 = 11;
                4'd4: card_num1012 = 12;
                4'd5: card_num1012 = 13;
                4'd6: card_num1012 = 14;
                4'd7: card_num1012 = 15;
                4'd8: card_num1012 = 16;
                4'd9: card_num1012 = 17;
                default: card_num1012 = 0;
              endcase
        4'd9: case(card_num12)
                4'd0: card_num1012 = 9;
                4'd1: card_num1012 = 10;
                4'd2: card_num1012 = 11;
                4'd3: card_num1012 = 12;
                4'd4: card_num1012 = 13;
                4'd5: card_num1012 = 14;
                4'd6: card_num1012 = 15;
                4'd7: card_num1012 = 16;
                4'd8: card_num1012 = 17;
                4'd9: card_num1012 = 18;
                default: card_num1012 = 0;
              endcase
        default: card_num1012 = 0;
    endcase
end

always @(*) begin
    case (card_num14)
        4'd0: case(card_num16)
                4'd0: card_num1416 = 0;
                4'd1: card_num1416 = 1;
                4'd2: card_num1416 = 2;
                4'd3: card_num1416 = 3;
                4'd4: card_num1416 = 4;
                4'd5: card_num1416 = 5;
                4'd6: card_num1416 = 6;
                4'd7: card_num1416 = 7;
                4'd8: card_num1416 = 8;
                4'd9: card_num1416 = 9;
                default: card_num1416 = 0;
              endcase
        4'd1: case(card_num16)
                4'd0: card_num1416 = 1;
                4'd1: card_num1416 = 2;
                4'd2: card_num1416 = 3;
                4'd3: card_num1416 = 4;
                4'd4: card_num1416 = 5;
                4'd5: card_num1416 = 6;
                4'd6: card_num1416 = 7;
                4'd7: card_num1416 = 8;
                4'd8: card_num1416 = 9;
                4'd9: card_num1416 = 10;
                default: card_num1416 = 0;
              endcase
        4'd2: case(card_num16)
                4'd0: card_num1416 = 2;
                4'd1: card_num1416 = 3;
                4'd2: card_num1416 = 4;
                4'd3: card_num1416 = 5;
                4'd4: card_num1416 = 6;
                4'd5: card_num1416 = 7;
                4'd6: card_num1416 = 8;
                4'd7: card_num1416 = 9;
                4'd8: card_num1416 = 10;
                4'd9: card_num1416 = 11;
                default: card_num1416 = 0;
              endcase
        4'd3: case(card_num16)
                4'd0: card_num1416 = 3;
                4'd1: card_num1416 = 4;
                4'd2: card_num1416 = 5;
                4'd3: card_num1416 = 6;
                4'd4: card_num1416 = 7;
                4'd5: card_num1416 = 8;
                4'd6: card_num1416 = 9;
                4'd7: card_num1416 = 10;
                4'd8: card_num1416 = 11;
                4'd9: card_num1416 = 12;
                default: card_num1416 = 0;
              endcase
        4'd4: case(card_num16)
                4'd0: card_num1416 = 4;
                4'd1: card_num1416 = 5;
                4'd2: card_num1416 = 6;
                4'd3: card_num1416 = 7;
                4'd4: card_num1416 = 8;
                4'd5: card_num1416 = 9;
                4'd6: card_num1416 = 10;
                4'd7: card_num1416 = 11;
                4'd8: card_num1416 = 12;
                4'd9: card_num1416 = 13;
                default: card_num1416 = 0;
              endcase
        4'd5: case(card_num16)
                4'd0: card_num1416 = 5;
                4'd1: card_num1416 = 6;
                4'd2: card_num1416 = 7;
                4'd3: card_num1416 = 8;
                4'd4: card_num1416 = 9;
                4'd5: card_num1416 = 10;
                4'd6: card_num1416 = 11;
                4'd7: card_num1416 = 12;
                4'd8: card_num1416 = 13;
                4'd9: card_num1416 = 14;
                default: card_num1416 = 0;
              endcase
        4'd6: case(card_num16)
                4'd0: card_num1416 = 6;
                4'd1: card_num1416 = 7;
                4'd2: card_num1416 = 8;
                4'd3: card_num1416 = 9;
                4'd4: card_num1416 = 10;
                4'd5: card_num1416 = 11;
                4'd6: card_num1416 = 12;
                4'd7: card_num1416 = 13;
                4'd8: card_num1416 = 14;
                4'd9: card_num1416 = 15;
                default: card_num1416 = 0;
              endcase
        4'd7: case(card_num16)
                4'd0: card_num1416 = 7;
                4'd1: card_num1416 = 8;
                4'd2: card_num1416 = 9;
                4'd3: card_num1416 = 10;
                4'd4: card_num1416 = 11;
                4'd5: card_num1416 = 12;
                4'd6: card_num1416 = 13;
                4'd7: card_num1416 = 14;
                4'd8: card_num1416 = 15;
                4'd9: card_num1416 = 16;
                default: card_num1416 = 0;
              endcase
        4'd8: case(card_num16)
                4'd0: card_num1416 = 8;
                4'd1: card_num1416 = 9;
                4'd2: card_num1416 = 10;
                4'd3: card_num1416 = 11;
                4'd4: card_num1416 = 12;
                4'd5: card_num1416 = 13;
                4'd6: card_num1416 = 14;
                4'd7: card_num1416 = 15;
                4'd8: card_num1416 = 16;
                4'd9: card_num1416 = 17;
                default: card_num1416 = 0;
              endcase
        4'd9: case(card_num16)
                4'd0: card_num1416 = 9;
                4'd1: card_num1416 = 10;
                4'd2: card_num1416 = 11;
                4'd3: card_num1416 = 12;
                4'd4: card_num1416 = 13;
                4'd5: card_num1416 = 14;
                4'd6: card_num1416 = 15;
                4'd7: card_num1416 = 16;
                4'd8: card_num1416 = 17;
                4'd9: card_num1416 = 18;
                default: card_num1416 = 0;
              endcase
        default: card_num1416 = 0;
    endcase
end*/
    

always @(*) begin
    //if (card_num_total%10 == 0) begin
    if(card_num_total == 10 || card_num_total == 20 || card_num_total == 30 || card_num_total == 40 || card_num_total == 50 || card_num_total == 60 || card_num_total == 70 || card_num_total == 80 || card_num_total == 90 || card_num_total == 100 || card_num_total == 110 || card_num_total == 120)begin
        out_valid = 1;
    end
    else begin
        out_valid = 0;
    end
end

/*
always@(*)begin
    case(card_num_total)
        7'd10: out_valid = 1;
        7'd20: out_valid = 1;
        7'd30: out_valid = 1;
        7'd40: out_valid = 1;
        7'd50: out_valid = 1;
        7'd60: out_valid = 1;
        7'd70: out_valid = 1;
        7'd80: out_valid = 1;
        7'd90: out_valid = 1;
        7'd100: out_valid = 1;
        7'd110: out_valid = 1;
        7'd120: out_valid = 1;
        default:out_valid = 0;
    endcase
end
*/

assign {snack1, snack2, snack3, snack4, snack5, snack6, snack7, snack8} = snack_num ;
assign {price1, price2, price3, price4, price5, price6, price7, price8} = price ;

/*assign totalprice1 = snack_num[31:28]*price[31:28];
assign totalprice2 = snack_num[27:24]*price[27:24];
assign totalprice3 = snack_num[23:20]*price[23:20];
assign totalprice4 = snack_num[19:16]*price[19:16];
assign totalprice5 = snack_num[15:12]*price[15:12];
assign totalprice6 = snack_num[11:8] *price[11:8] ;
assign totalprice7 = snack_num[7:4]  *price[7:4]  ;
assign totalprice8 = snack_num[3:0]  *price[3:0]  ;*/

/*assign totalprice1 = snack1 * price1;
assign totalprice2 = snack2 * price2;
assign totalprice3 = snack3 * price3;
assign totalprice4 = snack4 * price4;
assign totalprice5 = snack5 * price5;
assign totalprice6 = snack6 * price6;
assign totalprice7 = snack7 * price7;
assign totalprice8 = snack8 * price8;*/

always @(*) begin
    if (snack_num[31:28] == 4'd1 ) begin
        case(price[31:28])
            4'd1: totalprice1 = 1;
            4'd2: totalprice1 = 2;
            4'd3: totalprice1 = 3;
            4'd4: totalprice1 = 4;
            4'd5: totalprice1 = 5;
            4'd6: totalprice1 = 6;
            4'd7: totalprice1 = 7;
            4'd8: totalprice1 = 8;
            4'd9: totalprice1 = 9;
            4'd10: totalprice1 = 10;
            4'd11: totalprice1 = 11;
            4'd12: totalprice1 = 12;
            4'd13: totalprice1 = 13;
            4'd14: totalprice1 = 14;
            4'd15: totalprice1 = 15;
            default: totalprice1 = 0;
        endcase
    end
    else if (snack_num[31:28] == 4'd2 )  begin  
        case(price[31:28])
            4'd1: totalprice1 = 2;
            4'd2: totalprice1 = 4;
            4'd3: totalprice1 = 6;
            4'd4: totalprice1 = 8;
            4'd5: totalprice1 = 10;
            4'd6: totalprice1 = 12;
            4'd7: totalprice1 = 14;
            4'd8: totalprice1 = 16;
            4'd9: totalprice1 = 18;
            4'd10: totalprice1 = 20;
            4'd11: totalprice1 = 22;
            4'd12: totalprice1 = 24;
            4'd13: totalprice1 = 26;
            4'd14: totalprice1 = 28;
            4'd15: totalprice1 = 30;
            default: totalprice1 = 0;
        endcase
    end
    else if (snack_num[31:28] == 4'd3 )  begin    
        case(price[31:28])
            4'd1: totalprice1 = 3;
            4'd2: totalprice1 = 6;
            4'd3: totalprice1 = 9;
            4'd4: totalprice1 = 12;
            4'd5: totalprice1 = 15;
            4'd6: totalprice1 = 18;
            4'd7: totalprice1 = 21;
            4'd8: totalprice1 = 24;
            4'd9: totalprice1 = 27;
            4'd10: totalprice1 = 30;
            4'd11: totalprice1 = 33;
            4'd12: totalprice1 = 36;
            4'd13: totalprice1 = 39;
            4'd14: totalprice1 = 42;
            4'd15: totalprice1 = 45;
            default: totalprice1 = 0;
        endcase
    end
    else if (snack_num[31:28] == 4'd4 )  begin
        case(price[31:28])
            4'd1: totalprice1 = 4;
            4'd2: totalprice1 = 8;
            4'd3: totalprice1 = 12;
            4'd4: totalprice1 = 16;
            4'd5: totalprice1 = 20;
            4'd6: totalprice1 = 24;
            4'd7: totalprice1 = 28;
            4'd8: totalprice1 = 32;
            4'd9: totalprice1 = 36;
            4'd10: totalprice1 = 40;
            4'd11: totalprice1 = 44;
            4'd12: totalprice1 = 48;
            4'd13: totalprice1 = 52;
            4'd14: totalprice1 = 56;
            4'd15: totalprice1 = 60;
            default: totalprice1 = 0;
        endcase
    end
    else if (snack_num[31:28] == 4'd5 )  begin
        case(price[31:28])
            4'd1: totalprice1 = 5;
            4'd2: totalprice1 = 10;
            4'd3: totalprice1 = 15;
            4'd4: totalprice1 = 20;
            4'd5: totalprice1 = 25;
            4'd6: totalprice1 = 30;
            4'd7: totalprice1 = 35;
            4'd8: totalprice1 = 40;
            4'd9: totalprice1 = 45;
            4'd10: totalprice1 = 50;
            4'd11: totalprice1 = 55;
            4'd12: totalprice1 = 60;
            4'd13: totalprice1 = 65;
            4'd14: totalprice1 = 70;
            4'd15: totalprice1 = 75;
            default: totalprice1 = 0;
        endcase
    end
    else if (snack_num[31:28] == 4'd6 )  begin
        case(price[31:28])
            4'd1: totalprice1 = 6;
            4'd2: totalprice1 = 12;
            4'd3: totalprice1 = 18;
            4'd4: totalprice1 = 24;
            4'd5: totalprice1 = 30;
            4'd6: totalprice1 = 36;
            4'd7: totalprice1 = 42;
            4'd8: totalprice1 = 48;
            4'd9: totalprice1 = 54;
            4'd10: totalprice1 = 60;
            4'd11: totalprice1 = 66;
            4'd12: totalprice1 = 72;
            4'd13: totalprice1 = 78;
            4'd14: totalprice1 = 84;
            4'd15: totalprice1 = 90;
            default: totalprice1 = 0;
        endcase
    end
    else if (snack_num[31:28] == 4'd7 )  begin
        case(price[31:28])
            4'd1: totalprice1 = 7;
            4'd2: totalprice1 = 14;
            4'd3: totalprice1 = 21;
            4'd4: totalprice1 = 28;
            4'd5: totalprice1 = 35;
            4'd6: totalprice1 = 42;
            4'd7: totalprice1 = 49;
            4'd8: totalprice1 = 56;
            4'd9: totalprice1 = 63;
            4'd10: totalprice1 = 70;
            4'd11: totalprice1 = 77;
            4'd12: totalprice1 = 84;
            4'd13: totalprice1 = 91;
            4'd14: totalprice1 = 98;
            4'd15: totalprice1 = 105;
            default: totalprice1 = 0;
        endcase
    end
    else if (snack_num[31:28] == 4'd8 )  begin    
        case(price[31:28])
            4'd1: totalprice1 = 8;
            4'd2: totalprice1 = 16;
            4'd3: totalprice1 = 24;
            4'd4: totalprice1 = 32;
            4'd5: totalprice1 = 40;
            4'd6: totalprice1 = 48;
            4'd7: totalprice1 = 56;
            4'd8: totalprice1 = 64;
            4'd9: totalprice1 = 72;
            4'd10: totalprice1 = 80;
            4'd11: totalprice1 = 88;
            4'd12: totalprice1 = 96;
            4'd13: totalprice1 = 104;
            4'd14: totalprice1 = 112;
            4'd15: totalprice1 = 120;
            default: totalprice1 = 0;
        endcase
    end
    else if (snack_num[31:28] == 4'd9 )  begin  
        case(price[31:28])
            4'd1: totalprice1 = 9;
            4'd2: totalprice1 = 18;
            4'd3: totalprice1 = 27;
            4'd4: totalprice1 = 36;
            4'd5: totalprice1 = 45;
            4'd6: totalprice1 = 54;
            4'd7: totalprice1 = 63;
            4'd8: totalprice1 = 72;
            4'd9: totalprice1 = 81;
            4'd10: totalprice1 = 90;
            4'd11: totalprice1 = 99;
            4'd12: totalprice1 = 108;
            4'd13: totalprice1 = 117;
            4'd14: totalprice1 = 126;
            4'd15: totalprice1 = 135;
            default: totalprice1 = 0;
        endcase
    end
    else if (snack_num[31:28] == 4'd10 )  begin  
        case(price[31:28])
            4'd1: totalprice1 = 10;
            4'd2: totalprice1 = 20;
            4'd3: totalprice1 = 30;
            4'd4: totalprice1 = 40;
            4'd5: totalprice1 = 50;
            4'd6: totalprice1 = 60;
            4'd7: totalprice1 = 70;
            4'd8: totalprice1 = 80;
            4'd9: totalprice1 = 90;
            4'd10: totalprice1 = 100;
            4'd11: totalprice1 = 110;
            4'd12: totalprice1 = 120;
            4'd13: totalprice1 = 130;
            4'd14: totalprice1 = 140;
            4'd15: totalprice1 = 150;
            default: totalprice1 = 0;
        endcase
    end
    else if (snack_num[31:28] == 4'd11 )  begin      
        case(price[31:28])
            4'd1: totalprice1 = 11;
            4'd2: totalprice1 = 22;
            4'd3: totalprice1 = 33;
            4'd4: totalprice1 = 44;
            4'd5: totalprice1 = 55;
            4'd6: totalprice1 = 66;
            4'd7: totalprice1 = 77;
            4'd8: totalprice1 = 88;
            4'd9: totalprice1 = 99;
            4'd10: totalprice1 = 110;
            4'd11: totalprice1 = 121;
            4'd12: totalprice1 = 132;
            4'd13: totalprice1 = 143;
            4'd14: totalprice1 = 154;
            4'd15: totalprice1 = 165;
            default: totalprice1 = 0;
        endcase
    end
    else if (snack_num[31:28] == 4'd12 )  begin  
        case(price[31:28])
            4'd1: totalprice1 = 12;
            4'd2: totalprice1 = 24;
            4'd3: totalprice1 = 36;
            4'd4: totalprice1 = 48;
            4'd5: totalprice1 = 60;
            4'd6: totalprice1 = 72;
            4'd7: totalprice1 = 84;
            4'd8: totalprice1 = 96;
            4'd9: totalprice1 = 108;
            4'd10: totalprice1 = 120;
            4'd11: totalprice1 = 132;
            4'd12: totalprice1 = 144;
            4'd13: totalprice1 = 156;
            4'd14: totalprice1 = 168;
            4'd15: totalprice1 = 180;
            default: totalprice1 = 0;
        endcase
    end
    else if (snack_num[31:28] == 4'd13 )  begin  
        case(price[31:28])
            4'd1: totalprice1 = 13;
            4'd2: totalprice1 = 26;
            4'd3: totalprice1 = 39;
            4'd4: totalprice1 = 52;
            4'd5: totalprice1 = 65;
            4'd6: totalprice1 = 78;
            4'd7: totalprice1 = 91;
            4'd8: totalprice1 = 104;
            4'd9: totalprice1 = 117;
            4'd10: totalprice1 = 130;
            4'd11: totalprice1 = 143;
            4'd12: totalprice1 = 156;
            4'd13: totalprice1 = 169;
            4'd14: totalprice1 = 182;
            4'd15: totalprice1 = 195;
            default: totalprice1 = 0;
        endcase
    end
    else if (snack_num[31:28] == 4'd14 )  begin      
        case(price[31:28])
            4'd1: totalprice1 = 14;
            4'd2: totalprice1 = 28;
            4'd3: totalprice1 = 42;
            4'd4: totalprice1 = 56;
            4'd5: totalprice1 = 70;
            4'd6: totalprice1 = 84;
            4'd7: totalprice1 = 98;
            4'd8: totalprice1 = 112;
            4'd9: totalprice1 = 126;
            4'd10: totalprice1 = 140;
            4'd11: totalprice1 = 154;
            4'd12: totalprice1 = 168;
            4'd13: totalprice1 = 182;
            4'd14: totalprice1 = 196;
            4'd15: totalprice1 = 210;
            default: totalprice1 = 0;
        endcase
    end
    else if (snack_num[31:28] == 4'd15 )  begin      
        case(price[31:28])
            4'd1: totalprice1 = 15;
            4'd2: totalprice1 = 30;
            4'd3: totalprice1 = 45;
            4'd4: totalprice1 = 60;
            4'd5: totalprice1 = 75;
            4'd6: totalprice1 = 90;
            4'd7: totalprice1 = 105;
            4'd8: totalprice1 = 120;
            4'd9: totalprice1 = 135;
            4'd10: totalprice1 = 150;
            4'd11: totalprice1 = 165;
            4'd12: totalprice1 = 180;
            4'd13: totalprice1 = 195;
            4'd14: totalprice1 = 210;
            4'd15: totalprice1 = 225;
            default: totalprice1 = 0;
        endcase    
    end
    else totalprice1 = 0;
end
/*
always @(*) begin
    case (snack_num[31:28])
        4'd1: case(price[31:28])
            4'd1: totalprice1 = 1;
            4'd2: totalprice1 = 2;
            4'd3: totalprice1 = 3;
            4'd4: totalprice1 = 4;
            4'd5: totalprice1 = 5;
            4'd6: totalprice1 = 6;
            4'd7: totalprice1 = 7;
            4'd8: totalprice1 = 8;
            4'd9: totalprice1 = 9;
            4'd10: totalprice1 = 10;
            4'd11: totalprice1 = 11;
            4'd12: totalprice1 = 12;
            4'd13: totalprice1 = 13;
            4'd14: totalprice1 = 14;
            4'd15: totalprice1 = 15;
            default: totalprice1 = 0;
        endcase
        
        4'd2: case(price[31:28])
            4'd1: totalprice1 = 2;
            4'd2: totalprice1 = 4;
            4'd3: totalprice1 = 6;
            4'd4: totalprice1 = 8;
            4'd5: totalprice1 = 10;
            4'd6: totalprice1 = 12;
            4'd7: totalprice1 = 14;
            4'd8: totalprice1 = 16;
            4'd9: totalprice1 = 18;
            4'd10: totalprice1 = 20;
            4'd11: totalprice1 = 22;
            4'd12: totalprice1 = 24;
            4'd13: totalprice1 = 26;
            4'd14: totalprice1 = 28;
            4'd15: totalprice1 = 30;
            default: totalprice1 = 0;
        endcase
        
        4'd3: case(price[31:28])
            4'd1: totalprice1 = 3;
            4'd2: totalprice1 = 6;
            4'd3: totalprice1 = 9;
            4'd4: totalprice1 = 12;
            4'd5: totalprice1 = 15;
            4'd6: totalprice1 = 18;
            4'd7: totalprice1 = 21;
            4'd8: totalprice1 = 24;
            4'd9: totalprice1 = 27;
            4'd10: totalprice1 = 30;
            4'd11: totalprice1 = 33;
            4'd12: totalprice1 = 36;
            4'd13: totalprice1 = 39;
            4'd14: totalprice1 = 42;
            4'd15: totalprice1 = 45;
            default: totalprice1 = 0;
        endcase
        
        4'd4: case(price[31:28])
            4'd1: totalprice1 = 4;
            4'd2: totalprice1 = 8;
            4'd3: totalprice1 = 12;
            4'd4: totalprice1 = 16;
            4'd5: totalprice1 = 20;
            4'd6: totalprice1 = 24;
            4'd7: totalprice1 = 28;
            4'd8: totalprice1 = 32;
            4'd9: totalprice1 = 36;
            4'd10: totalprice1 = 40;
            4'd11: totalprice1 = 44;
            4'd12: totalprice1 = 48;
            4'd13: totalprice1 = 52;
            4'd14: totalprice1 = 56;
            4'd15: totalprice1 = 60;
            default: totalprice1 = 0;
        endcase
        
        4'd5: case(price[31:28])
            4'd1: totalprice1 = 5;
            4'd2: totalprice1 = 10;
            4'd3: totalprice1 = 15;
            4'd4: totalprice1 = 20;
            4'd5: totalprice1 = 25;
            4'd6: totalprice1 = 30;
            4'd7: totalprice1 = 35;
            4'd8: totalprice1 = 40;
            4'd9: totalprice1 = 45;
            4'd10: totalprice1 = 50;
            4'd11: totalprice1 = 55;
            4'd12: totalprice1 = 60;
            4'd13: totalprice1 = 65;
            4'd14: totalprice1 = 70;
            4'd15: totalprice1 = 75;
            default: totalprice1 = 0;
        endcase
        
        4'd6: case(price[31:28])
            4'd1: totalprice1 = 6;
            4'd2: totalprice1 = 12;
            4'd3: totalprice1 = 18;
            4'd4: totalprice1 = 24;
            4'd5: totalprice1 = 30;
            4'd6: totalprice1 = 36;
            4'd7: totalprice1 = 42;
            4'd8: totalprice1 = 48;
            4'd9: totalprice1 = 54;
            4'd10: totalprice1 = 60;
            4'd11: totalprice1 = 66;
            4'd12: totalprice1 = 72;
            4'd13: totalprice1 = 78;
            4'd14: totalprice1 = 84;
            4'd15: totalprice1 = 90;
            default: totalprice1 = 0;
        endcase
        
        4'd7: case(price[31:28])
            4'd1: totalprice1 = 7;
            4'd2: totalprice1 = 14;
            4'd3: totalprice1 = 21;
            4'd4: totalprice1 = 28;
            4'd5: totalprice1 = 35;
            4'd6: totalprice1 = 42;
            4'd7: totalprice1 = 49;
            4'd8: totalprice1 = 56;
            4'd9: totalprice1 = 63;
            4'd10: totalprice1 = 70;
            4'd11: totalprice1 = 77;
            4'd12: totalprice1 = 84;
            4'd13: totalprice1 = 91;
            4'd14: totalprice1 = 98;
            4'd15: totalprice1 = 105;
            default: totalprice1 = 0;
        endcase
        
        4'd8: case(price[31:28])
            4'd1: totalprice1 = 8;
            4'd2: totalprice1 = 16;
            4'd3: totalprice1 = 24;
            4'd4: totalprice1 = 32;
            4'd5: totalprice1 = 40;
            4'd6: totalprice1 = 48;
            4'd7: totalprice1 = 56;
            4'd8: totalprice1 = 64;
            4'd9: totalprice1 = 72;
            4'd10: totalprice1 = 80;
            4'd11: totalprice1 = 88;
            4'd12: totalprice1 = 96;
            4'd13: totalprice1 = 104;
            4'd14: totalprice1 = 112;
            4'd15: totalprice1 = 120;
            default: totalprice1 = 0;
        endcase
        
        4'd9: case(price[31:28])
            4'd1: totalprice1 = 9;
            4'd2: totalprice1 = 18;
            4'd3: totalprice1 = 27;
            4'd4: totalprice1 = 36;
            4'd5: totalprice1 = 45;
            4'd6: totalprice1 = 54;
            4'd7: totalprice1 = 63;
            4'd8: totalprice1 = 72;
            4'd9: totalprice1 = 81;
            4'd10: totalprice1 = 90;
            4'd11: totalprice1 = 99;
            4'd12: totalprice1 = 108;
            4'd13: totalprice1 = 117;
            4'd14: totalprice1 = 126;
            4'd15: totalprice1 = 135;
            default: totalprice1 = 0;
        endcase
        
        4'd10: case(price[31:28])
            4'd1: totalprice1 = 10;
            4'd2: totalprice1 = 20;
            4'd3: totalprice1 = 30;
            4'd4: totalprice1 = 40;
            4'd5: totalprice1 = 50;
            4'd6: totalprice1 = 60;
            4'd7: totalprice1 = 70;
            4'd8: totalprice1 = 80;
            4'd9: totalprice1 = 90;
            4'd10: totalprice1 = 100;
            4'd11: totalprice1 = 110;
            4'd12: totalprice1 = 120;
            4'd13: totalprice1 = 130;
            4'd14: totalprice1 = 140;
            4'd15: totalprice1 = 150;
            default: totalprice1 = 0;
        endcase
        
        4'd11: case(price[31:28])
            4'd1: totalprice1 = 11;
            4'd2: totalprice1 = 22;
            4'd3: totalprice1 = 33;
            4'd4: totalprice1 = 44;
            4'd5: totalprice1 = 55;
            4'd6: totalprice1 = 66;
            4'd7: totalprice1 = 77;
            4'd8: totalprice1 = 88;
            4'd9: totalprice1 = 99;
            4'd10: totalprice1 = 110;
            4'd11: totalprice1 = 121;
            4'd12: totalprice1 = 132;
            4'd13: totalprice1 = 143;
            4'd14: totalprice1 = 154;
            4'd15: totalprice1 = 165;
            default: totalprice1 = 0;
        endcase
        
        4'd12: case(price[31:28])
            4'd1: totalprice1 = 12;
            4'd2: totalprice1 = 24;
            4'd3: totalprice1 = 36;
            4'd4: totalprice1 = 48;
            4'd5: totalprice1 = 60;
            4'd6: totalprice1 = 72;
            4'd7: totalprice1 = 84;
            4'd8: totalprice1 = 96;
            4'd9: totalprice1 = 108;
            4'd10: totalprice1 = 120;
            4'd11: totalprice1 = 132;
            4'd12: totalprice1 = 144;
            4'd13: totalprice1 = 156;
            4'd14: totalprice1 = 168;
            4'd15: totalprice1 = 180;
            default: totalprice1 = 0;
        endcase
        
        4'd13: case(price[31:28])
            4'd1: totalprice1 = 13;
            4'd2: totalprice1 = 26;
            4'd3: totalprice1 = 39;
            4'd4: totalprice1 = 52;
            4'd5: totalprice1 = 65;
            4'd6: totalprice1 = 78;
            4'd7: totalprice1 = 91;
            4'd8: totalprice1 = 104;
            4'd9: totalprice1 = 117;
            4'd10: totalprice1 = 130;
            4'd11: totalprice1 = 143;
            4'd12: totalprice1 = 156;
            4'd13: totalprice1 = 169;
            4'd14: totalprice1 = 182;
            4'd15: totalprice1 = 195;
            default: totalprice1 = 0;
        endcase
        
        4'd14: case(price[31:28])
            4'd1: totalprice1 = 14;
            4'd2: totalprice1 = 28;
            4'd3: totalprice1 = 42;
            4'd4: totalprice1 = 56;
            4'd5: totalprice1 = 70;
            4'd6: totalprice1 = 84;
            4'd7: totalprice1 = 98;
            4'd8: totalprice1 = 112;
            4'd9: totalprice1 = 126;
            4'd10: totalprice1 = 140;
            4'd11: totalprice1 = 154;
            4'd12: totalprice1 = 168;
            4'd13: totalprice1 = 182;
            4'd14: totalprice1 = 196;
            4'd15: totalprice1 = 210;
            default: totalprice1 = 0;
        endcase
        
        4'd15: case(price[31:28])
            4'd1: totalprice1 = 15;
            4'd2: totalprice1 = 30;
            4'd3: totalprice1 = 45;
            4'd4: totalprice1 = 60;
            4'd5: totalprice1 = 75;
            4'd6: totalprice1 = 90;
            4'd7: totalprice1 = 105;
            4'd8: totalprice1 = 120;
            4'd9: totalprice1 = 135;
            4'd10: totalprice1 = 150;
            4'd11: totalprice1 = 165;
            4'd12: totalprice1 = 180;
            4'd13: totalprice1 = 195;
            4'd14: totalprice1 = 210;
            4'd15: totalprice1 = 225;
            default: totalprice1 = 0;
        endcase
        
        default: totalprice1 = 0;
    endcase
end
*/
always @(*) begin
    case (snack2)
        4'd1: case(price2)
            4'd1: totalprice2 = 1;
            4'd2: totalprice2 = 2;
            4'd3: totalprice2 = 3;
            4'd4: totalprice2 = 4;
            4'd5: totalprice2 = 5;
            4'd6: totalprice2 = 6;
            4'd7: totalprice2 = 7;
            4'd8: totalprice2 = 8;
            4'd9: totalprice2 = 9;
            4'd10: totalprice2 = 10;
            4'd11: totalprice2 = 11;
            4'd12: totalprice2 = 12;
            4'd13: totalprice2 = 13;
            4'd14: totalprice2 = 14;
            4'd15: totalprice2 = 15;
            default: totalprice2 = 0;
        endcase
        
        4'd2: case(price2)
            4'd1: totalprice2 = 2;
            4'd2: totalprice2 = 4;
            4'd3: totalprice2 = 6;
            4'd4: totalprice2 = 8;
            4'd5: totalprice2 = 10;
            4'd6: totalprice2 = 12;
            4'd7: totalprice2 = 14;
            4'd8: totalprice2 = 16;
            4'd9: totalprice2 = 18;
            4'd10: totalprice2 = 20;
            4'd11: totalprice2 = 22;
            4'd12: totalprice2 = 24;
            4'd13: totalprice2 = 26;
            4'd14: totalprice2 = 28;
            4'd15: totalprice2 = 30;
            default: totalprice2 = 0;
        endcase
        
        4'd3: case(price2)
            4'd1: totalprice2 = 3;
            4'd2: totalprice2 = 6;
            4'd3: totalprice2 = 9;
            4'd4: totalprice2 = 12;
            4'd5: totalprice2 = 15;
            4'd6: totalprice2 = 18;
            4'd7: totalprice2 = 21;
            4'd8: totalprice2 = 24;
            4'd9: totalprice2 = 27;
            4'd10: totalprice2 = 30;
            4'd11: totalprice2 = 33;
            4'd12: totalprice2 = 36;
            4'd13: totalprice2 = 39;
            4'd14: totalprice2 = 42;
            4'd15: totalprice2 = 45;
            default: totalprice2 = 0;
        endcase
        
        4'd4: case(price2)
            4'd1: totalprice2 = 4;
            4'd2: totalprice2 = 8;
            4'd3: totalprice2 = 12;
            4'd4: totalprice2 = 16;
            4'd5: totalprice2 = 20;
            4'd6: totalprice2 = 24;
            4'd7: totalprice2 = 28;
            4'd8: totalprice2 = 32;
            4'd9: totalprice2 = 36;
            4'd10: totalprice2 = 40;
            4'd11: totalprice2 = 44;
            4'd12: totalprice2 = 48;
            4'd13: totalprice2 = 52;
            4'd14: totalprice2 = 56;
            4'd15: totalprice2 = 60;
            default: totalprice2 = 0;
        endcase
        
        4'd5: case(price2)
            4'd1: totalprice2 = 5;
            4'd2: totalprice2 = 10;
            4'd3: totalprice2 = 15;
            4'd4: totalprice2 = 20;
            4'd5: totalprice2 = 25;
            4'd6: totalprice2 = 30;
            4'd7: totalprice2 = 35;
            4'd8: totalprice2 = 40;
            4'd9: totalprice2 = 45;
            4'd10: totalprice2 = 50;
            4'd11: totalprice2 = 55;
            4'd12: totalprice2 = 60;
            4'd13: totalprice2 = 65;
            4'd14: totalprice2 = 70;
            4'd15: totalprice2 = 75;
            default: totalprice2 = 0;
        endcase
        
        4'd6: case(price2)
            4'd1: totalprice2 = 6;
            4'd2: totalprice2 = 12;
            4'd3: totalprice2 = 18;
            4'd4: totalprice2 = 24;
            4'd5: totalprice2 = 30;
            4'd6: totalprice2 = 36;
            4'd7: totalprice2 = 42;
            4'd8: totalprice2 = 48;
            4'd9: totalprice2 = 54;
            4'd10: totalprice2 = 60;
            4'd11: totalprice2 = 66;
            4'd12: totalprice2 = 72;
            4'd13: totalprice2 = 78;
            4'd14: totalprice2 = 84;
            4'd15: totalprice2 = 90;
            default: totalprice2 = 0;
        endcase
        
        4'd7: case(price2)
            4'd1: totalprice2 = 7;
            4'd2: totalprice2 = 14;
            4'd3: totalprice2 = 21;
            4'd4: totalprice2 = 28;
            4'd5: totalprice2 = 35;
            4'd6: totalprice2 = 42;
            4'd7: totalprice2 = 49;
            4'd8: totalprice2 = 56;
            4'd9: totalprice2 = 63;
            4'd10: totalprice2 = 70;
            4'd11: totalprice2 = 77;
            4'd12: totalprice2 = 84;
            4'd13: totalprice2 = 91;
            4'd14: totalprice2 = 98;
            4'd15: totalprice2 = 105;
            default: totalprice2 = 0;
        endcase
        
        4'd8: case(price2)
            4'd1: totalprice2 = 8;
            4'd2: totalprice2 = 16;
            4'd3: totalprice2 = 24;
            4'd4: totalprice2 = 32;
            4'd5: totalprice2 = 40;
            4'd6: totalprice2 = 48;
            4'd7: totalprice2 = 56;
            4'd8: totalprice2 = 64;
            4'd9: totalprice2 = 72;
            4'd10: totalprice2 = 80;
            4'd11: totalprice2 = 88;
            4'd12: totalprice2 = 96;
            4'd13: totalprice2 = 104;
            4'd14: totalprice2 = 112;
            4'd15: totalprice2 = 120;
            default: totalprice2 = 0;
        endcase
        
        4'd9: case(price2)
            4'd1: totalprice2 = 9;
            4'd2: totalprice2 = 18;
            4'd3: totalprice2 = 27;
            4'd4: totalprice2 = 36;
            4'd5: totalprice2 = 45;
            4'd6: totalprice2 = 54;
            4'd7: totalprice2 = 63;
            4'd8: totalprice2 = 72;
            4'd9: totalprice2 = 81;
            4'd10: totalprice2 = 90;
            4'd11: totalprice2 = 99;
            4'd12: totalprice2 = 108;
            4'd13: totalprice2 = 117;
            4'd14: totalprice2 = 126;
            4'd15: totalprice2 = 135;
            default: totalprice2 = 0;
        endcase
        
        4'd10: case(price2)
            4'd1: totalprice2 = 10;
            4'd2: totalprice2 = 20;
            4'd3: totalprice2 = 30;
            4'd4: totalprice2 = 40;
            4'd5: totalprice2 = 50;
            4'd6: totalprice2 = 60;
            4'd7: totalprice2 = 70;
            4'd8: totalprice2 = 80;
            4'd9: totalprice2 = 90;
            4'd10: totalprice2 = 100;
            4'd11: totalprice2 = 110;
            4'd12: totalprice2 = 120;
            4'd13: totalprice2 = 130;
            4'd14: totalprice2 = 140;
            4'd15: totalprice2 = 150;
            default: totalprice2 = 0;
        endcase
        
        4'd11: case(price2)
            4'd1: totalprice2 = 11;
            4'd2: totalprice2 = 22;
            4'd3: totalprice2 = 33;
            4'd4: totalprice2 = 44;
            4'd5: totalprice2 = 55;
            4'd6: totalprice2 = 66;
            4'd7: totalprice2 = 77;
            4'd8: totalprice2 = 88;
            4'd9: totalprice2 = 99;
            4'd10: totalprice2 = 110;
            4'd11: totalprice2 = 121;
            4'd12: totalprice2 = 132;
            4'd13: totalprice2 = 143;
            4'd14: totalprice2 = 154;
            4'd15: totalprice2 = 165;
            default: totalprice2 = 0;
        endcase
        
        4'd12: case(price2)
            4'd1: totalprice2 = 12;
            4'd2: totalprice2 = 24;
            4'd3: totalprice2 = 36;
            4'd4: totalprice2 = 48;
            4'd5: totalprice2 = 60;
            4'd6: totalprice2 = 72;
            4'd7: totalprice2 = 84;
            4'd8: totalprice2 = 96;
            4'd9: totalprice2 = 108;
            4'd10: totalprice2 = 120;
            4'd11: totalprice2 = 132;
            4'd12: totalprice2 = 144;
            4'd13: totalprice2 = 156;
            4'd14: totalprice2 = 168;
            4'd15: totalprice2 = 180;
            default: totalprice2 = 0;
        endcase
        
        4'd13: case(price2)
            4'd1: totalprice2 = 13;
            4'd2: totalprice2 = 26;
            4'd3: totalprice2 = 39;
            4'd4: totalprice2 = 52;
            4'd5: totalprice2 = 65;
            4'd6: totalprice2 = 78;
            4'd7: totalprice2 = 91;
            4'd8: totalprice2 = 104;
            4'd9: totalprice2 = 117;
            4'd10: totalprice2 = 130;
            4'd11: totalprice2 = 143;
            4'd12: totalprice2 = 156;
            4'd13: totalprice2 = 169;
            4'd14: totalprice2 = 182;
            4'd15: totalprice2 = 195;
            default: totalprice2 = 0;
        endcase
        
        4'd14: case(price2)
            4'd1: totalprice2 = 14;
            4'd2: totalprice2 = 28;
            4'd3: totalprice2 = 42;
            4'd4: totalprice2 = 56;
            4'd5: totalprice2 = 70;
            4'd6: totalprice2 = 84;
            4'd7: totalprice2 = 98;
            4'd8: totalprice2 = 112;
            4'd9: totalprice2 = 126;
            4'd10: totalprice2 = 140;
            4'd11: totalprice2 = 154;
            4'd12: totalprice2 = 168;
            4'd13: totalprice2 = 182;
            4'd14: totalprice2 = 196;
            4'd15: totalprice2 = 210;
            default: totalprice2 = 0;
        endcase
        
        4'd15: case(price2)
            4'd1: totalprice2 = 15;
            4'd2: totalprice2 = 30;
            4'd3: totalprice2 = 45;
            4'd4: totalprice2 = 60;
            4'd5: totalprice2 = 75;
            4'd6: totalprice2 = 90;
            4'd7: totalprice2 = 105;
            4'd8: totalprice2 = 120;
            4'd9: totalprice2 = 135;
            4'd10: totalprice2 = 150;
            4'd11: totalprice2 = 165;
            4'd12: totalprice2 = 180;
            4'd13: totalprice2 = 195;
            4'd14: totalprice2 = 210;
            4'd15: totalprice2 = 225;
            default: totalprice2 = 0;
        endcase
        
        default: totalprice2 = 0;
    endcase
end

always @(*) begin
    case (snack3)
        4'd1: case(price3)
            4'd1: totalprice3 = 1;
            4'd2: totalprice3 = 2;
            4'd3: totalprice3 = 3;
            4'd4: totalprice3 = 4;
            4'd5: totalprice3 = 5;
            4'd6: totalprice3 = 6;
            4'd7: totalprice3 = 7;
            4'd8: totalprice3 = 8;
            4'd9: totalprice3 = 9;
            4'd10: totalprice3 = 10;
            4'd11: totalprice3 = 11;
            4'd12: totalprice3 = 12;
            4'd13: totalprice3 = 13;
            4'd14: totalprice3 = 14;
            4'd15: totalprice3 = 15;
            default: totalprice3 = 0;
        endcase
        
        4'd2: case(price3)
            4'd1: totalprice3 = 2;
            4'd2: totalprice3 = 4;
            4'd3: totalprice3 = 6;
            4'd4: totalprice3 = 8;
            4'd5: totalprice3 = 10;
            4'd6: totalprice3 = 12;
            4'd7: totalprice3 = 14;
            4'd8: totalprice3 = 16;
            4'd9: totalprice3 = 18;
            4'd10: totalprice3 = 20;
            4'd11: totalprice3 = 22;
            4'd12: totalprice3 = 24;
            4'd13: totalprice3 = 26;
            4'd14: totalprice3 = 28;
            4'd15: totalprice3 = 30;
            default: totalprice3 = 0;
        endcase
        
        4'd3: case(price3)
            4'd1: totalprice3 = 3;
            4'd2: totalprice3 = 6;
            4'd3: totalprice3 = 9;
            4'd4: totalprice3 = 12;
            4'd5: totalprice3 = 15;
            4'd6: totalprice3 = 18;
            4'd7: totalprice3 = 21;
            4'd8: totalprice3 = 24;
            4'd9: totalprice3 = 27;
            4'd10: totalprice3 = 30;
            4'd11: totalprice3 = 33;
            4'd12: totalprice3 = 36;
            4'd13: totalprice3 = 39;
            4'd14: totalprice3 = 42;
            4'd15: totalprice3 = 45;
            default: totalprice3 = 0;
        endcase
        
        4'd4: case(price3)
            4'd1: totalprice3 = 4;
            4'd2: totalprice3 = 8;
            4'd3: totalprice3 = 12;
            4'd4: totalprice3 = 16;
            4'd5: totalprice3 = 20;
            4'd6: totalprice3 = 24;
            4'd7: totalprice3 = 28;
            4'd8: totalprice3 = 32;
            4'd9: totalprice3 = 36;
            4'd10: totalprice3 = 40;
            4'd11: totalprice3 = 44;
            4'd12: totalprice3 = 48;
            4'd13: totalprice3 = 52;
            4'd14: totalprice3 = 56;
            4'd15: totalprice3 = 60;
            default: totalprice3 = 0;
        endcase
        
        4'd5: case(price3)
            4'd1: totalprice3 = 5;
            4'd2: totalprice3 = 10;
            4'd3: totalprice3 = 15;
            4'd4: totalprice3 = 20;
            4'd5: totalprice3 = 25;
            4'd6: totalprice3 = 30;
            4'd7: totalprice3 = 35;
            4'd8: totalprice3 = 40;
            4'd9: totalprice3 = 45;
            4'd10: totalprice3 = 50;
            4'd11: totalprice3 = 55;
            4'd12: totalprice3 = 60;
            4'd13: totalprice3 = 65;
            4'd14: totalprice3 = 70;
            4'd15: totalprice3 = 75;
            default: totalprice3 = 0;
        endcase
        
        4'd6: case(price3)
            4'd1: totalprice3 = 6;
            4'd2: totalprice3 = 12;
            4'd3: totalprice3 = 18;
            4'd4: totalprice3 = 24;
            4'd5: totalprice3 = 30;
            4'd6: totalprice3 = 36;
            4'd7: totalprice3 = 42;
            4'd8: totalprice3 = 48;
            4'd9: totalprice3 = 54;
            4'd10: totalprice3 = 60;
            4'd11: totalprice3 = 66;
            4'd12: totalprice3 = 72;
            4'd13: totalprice3 = 78;
            4'd14: totalprice3 = 84;
            4'd15: totalprice3 = 90;
            default: totalprice3 = 0;
        endcase
        
        4'd7: case(price3)
            4'd1: totalprice3 = 7;
            4'd2: totalprice3 = 14;
            4'd3: totalprice3 = 21;
            4'd4: totalprice3 = 28;
            4'd5: totalprice3 = 35;
            4'd6: totalprice3 = 42;
            4'd7: totalprice3 = 49;
            4'd8: totalprice3 = 56;
            4'd9: totalprice3 = 63;
            4'd10: totalprice3 = 70;
            4'd11: totalprice3 = 77;
            4'd12: totalprice3 = 84;
            4'd13: totalprice3 = 91;
            4'd14: totalprice3 = 98;
            4'd15: totalprice3 = 105;
            default: totalprice3 = 0;
        endcase
        
        4'd8: case(price3)
            4'd1: totalprice3 = 8;
            4'd2: totalprice3 = 16;
            4'd3: totalprice3 = 24;
            4'd4: totalprice3 = 32;
            4'd5: totalprice3 = 40;
            4'd6: totalprice3 = 48;
            4'd7: totalprice3 = 56;
            4'd8: totalprice3 = 64;
            4'd9: totalprice3 = 72;
            4'd10: totalprice3 = 80;
            4'd11: totalprice3 = 88;
            4'd12: totalprice3 = 96;
            4'd13: totalprice3 = 104;
            4'd14: totalprice3 = 112;
            4'd15: totalprice3 = 120;
            default: totalprice3 = 0;
        endcase
        
        4'd9: case(price3)
            4'd1: totalprice3 = 9;
            4'd2: totalprice3 = 18;
            4'd3: totalprice3 = 27;
            4'd4: totalprice3 = 36;
            4'd5: totalprice3 = 45;
            4'd6: totalprice3 = 54;
            4'd7: totalprice3 = 63;
            4'd8: totalprice3 = 72;
            4'd9: totalprice3 = 81;
            4'd10: totalprice3 = 90;
            4'd11: totalprice3 = 99;
            4'd12: totalprice3 = 108;
            4'd13: totalprice3 = 117;
            4'd14: totalprice3 = 126;
            4'd15: totalprice3 = 135;
            default: totalprice3 = 0;
        endcase
        
        4'd10: case(price3)
            4'd1: totalprice3 = 10;
            4'd2: totalprice3 = 20;
            4'd3: totalprice3 = 30;
            4'd4: totalprice3 = 40;
            4'd5: totalprice3 = 50;
            4'd6: totalprice3 = 60;
            4'd7: totalprice3 = 70;
            4'd8: totalprice3 = 80;
            4'd9: totalprice3 = 90;
            4'd10: totalprice3 = 100;
            4'd11: totalprice3 = 110;
            4'd12: totalprice3 = 120;
            4'd13: totalprice3 = 130;
            4'd14: totalprice3 = 140;
            4'd15: totalprice3 = 150;
            default: totalprice3 = 0;
        endcase
        
        4'd11: case(price3)
            4'd1: totalprice3 = 11;
            4'd2: totalprice3 = 22;
            4'd3: totalprice3 = 33;
            4'd4: totalprice3 = 44;
            4'd5: totalprice3 = 55;
            4'd6: totalprice3 = 66;
            4'd7: totalprice3 = 77;
            4'd8: totalprice3 = 88;
            4'd9: totalprice3 = 99;
            4'd10: totalprice3 = 110;
            4'd11: totalprice3 = 121;
            4'd12: totalprice3 = 132;
            4'd13: totalprice3 = 143;
            4'd14: totalprice3 = 154;
            4'd15: totalprice3 = 165;
            default: totalprice3 = 0;
        endcase
        
        4'd12: case(price3)
            4'd1: totalprice3 = 12;
            4'd2: totalprice3 = 24;
            4'd3: totalprice3 = 36;
            4'd4: totalprice3 = 48;
            4'd5: totalprice3 = 60;
            4'd6: totalprice3 = 72;
            4'd7: totalprice3 = 84;
            4'd8: totalprice3 = 96;
            4'd9: totalprice3 = 108;
            4'd10: totalprice3 = 120;
            4'd11: totalprice3 = 132;
            4'd12: totalprice3 = 144;
            4'd13: totalprice3 = 156;
            4'd14: totalprice3 = 168;
            4'd15: totalprice3 = 180;
            default: totalprice3 = 0;
        endcase
        
        4'd13: case(price3)
            4'd1: totalprice3 = 13;
            4'd2: totalprice3 = 26;
            4'd3: totalprice3 = 39;
            4'd4: totalprice3 = 52;
            4'd5: totalprice3 = 65;
            4'd6: totalprice3 = 78;
            4'd7: totalprice3 = 91;
            4'd8: totalprice3 = 104;
            4'd9: totalprice3 = 117;
            4'd10: totalprice3 = 130;
            4'd11: totalprice3 = 143;
            4'd12: totalprice3 = 156;
            4'd13: totalprice3 = 169;
            4'd14: totalprice3 = 182;
            4'd15: totalprice3 = 195;
            default: totalprice3 = 0;
        endcase
        
        4'd14: case(price3)
            4'd1: totalprice3 = 14;
            4'd2: totalprice3 = 28;
            4'd3: totalprice3 = 42;
            4'd4: totalprice3 = 56;
            4'd5: totalprice3 = 70;
            4'd6: totalprice3 = 84;
            4'd7: totalprice3 = 98;
            4'd8: totalprice3 = 112;
            4'd9: totalprice3 = 126;
            4'd10: totalprice3 = 140;
            4'd11: totalprice3 = 154;
            4'd12: totalprice3 = 168;
            4'd13: totalprice3 = 182;
            4'd14: totalprice3 = 196;
            4'd15: totalprice3 = 210;
            default: totalprice3 = 0;
        endcase
        
        4'd15: case(price3)
            4'd1: totalprice3 = 15;
            4'd2: totalprice3 = 30;
            4'd3: totalprice3 = 45;
            4'd4: totalprice3 = 60;
            4'd5: totalprice3 = 75;
            4'd6: totalprice3 = 90;
            4'd7: totalprice3 = 105;
            4'd8: totalprice3 = 120;
            4'd9: totalprice3 = 135;
            4'd10: totalprice3 = 150;
            4'd11: totalprice3 = 165;
            4'd12: totalprice3 = 180;
            4'd13: totalprice3 = 195;
            4'd14: totalprice3 = 210;
            4'd15: totalprice3 = 225;
            default: totalprice3 = 0;
        endcase
        
        default: totalprice3 = 0;
    endcase
end

always @(*) begin
    case (snack4)
        4'd1: case(price4)
            4'd1: totalprice4 = 1;
            4'd2: totalprice4 = 2;
            4'd3: totalprice4 = 3;
            4'd4: totalprice4 = 4;
            4'd5: totalprice4 = 5;
            4'd6: totalprice4 = 6;
            4'd7: totalprice4 = 7;
            4'd8: totalprice4 = 8;
            4'd9: totalprice4 = 9;
            4'd10: totalprice4 = 10;
            4'd11: totalprice4 = 11;
            4'd12: totalprice4 = 12;
            4'd13: totalprice4 = 13;
            4'd14: totalprice4 = 14;
            4'd15: totalprice4 = 15;
            default: totalprice4 = 0;
        endcase
        
        4'd2: case(price4)
            4'd1: totalprice4 = 2;
            4'd2: totalprice4 = 4;
            4'd3: totalprice4 = 6;
            4'd4: totalprice4 = 8;
            4'd5: totalprice4 = 10;
            4'd6: totalprice4 = 12;
            4'd7: totalprice4 = 14;
            4'd8: totalprice4 = 16;
            4'd9: totalprice4 = 18;
            4'd10: totalprice4 = 20;
            4'd11: totalprice4 = 22;
            4'd12: totalprice4 = 24;
            4'd13: totalprice4 = 26;
            4'd14: totalprice4 = 28;
            4'd15: totalprice4 = 30;
            default: totalprice4 = 0;
        endcase
        
        4'd3: case(price4)
            4'd1: totalprice4 = 3;
            4'd2: totalprice4 = 6;
            4'd3: totalprice4 = 9;
            4'd4: totalprice4 = 12;
            4'd5: totalprice4 = 15;
            4'd6: totalprice4 = 18;
            4'd7: totalprice4 = 21;
            4'd8: totalprice4 = 24;
            4'd9: totalprice4 = 27;
            4'd10: totalprice4 = 30;
            4'd11: totalprice4 = 33;
            4'd12: totalprice4 = 36;
            4'd13: totalprice4 = 39;
            4'd14: totalprice4 = 42;
            4'd15: totalprice4 = 45;
            default: totalprice4 = 0;
        endcase
        
        4'd4: case(price4)
            4'd1: totalprice4 = 4;
            4'd2: totalprice4 = 8;
            4'd3: totalprice4 = 12;
            4'd4: totalprice4 = 16;
            4'd5: totalprice4 = 20;
            4'd6: totalprice4 = 24;
            4'd7: totalprice4 = 28;
            4'd8: totalprice4 = 32;
            4'd9: totalprice4 = 36;
            4'd10: totalprice4 = 40;
            4'd11: totalprice4 = 44;
            4'd12: totalprice4 = 48;
            4'd13: totalprice4 = 52;
            4'd14: totalprice4 = 56;
            4'd15: totalprice4 = 60;
            default: totalprice4 = 0;
        endcase
        
        4'd5: case(price4)
            4'd1: totalprice4 = 5;
            4'd2: totalprice4 = 10;
            4'd3: totalprice4 = 15;
            4'd4: totalprice4 = 20;
            4'd5: totalprice4 = 25;
            4'd6: totalprice4 = 30;
            4'd7: totalprice4 = 35;
            4'd8: totalprice4 = 40;
            4'd9: totalprice4 = 45;
            4'd10: totalprice4 = 50;
            4'd11: totalprice4 = 55;
            4'd12: totalprice4 = 60;
            4'd13: totalprice4 = 65;
            4'd14: totalprice4 = 70;
            4'd15: totalprice4 = 75;
            default: totalprice4 = 0;
        endcase
        
        4'd6: case(price4)
            4'd1: totalprice4 = 6;
            4'd2: totalprice4 = 12;
            4'd3: totalprice4 = 18;
            4'd4: totalprice4 = 24;
            4'd5: totalprice4 = 30;
            4'd6: totalprice4 = 36;
            4'd7: totalprice4 = 42;
            4'd8: totalprice4 = 48;
            4'd9: totalprice4 = 54;
            4'd10: totalprice4 = 60;
            4'd11: totalprice4 = 66;
            4'd12: totalprice4 = 72;
            4'd13: totalprice4 = 78;
            4'd14: totalprice4 = 84;
            4'd15: totalprice4 = 90;
            default: totalprice4 = 0;
        endcase
        
        4'd7: case(price4)
            4'd1: totalprice4 = 7;
            4'd2: totalprice4 = 14;
            4'd3: totalprice4 = 21;
            4'd4: totalprice4 = 28;
            4'd5: totalprice4 = 35;
            4'd6: totalprice4 = 42;
            4'd7: totalprice4 = 49;
            4'd8: totalprice4 = 56;
            4'd9: totalprice4 = 63;
            4'd10: totalprice4 = 70;
            4'd11: totalprice4 = 77;
            4'd12: totalprice4 = 84;
            4'd13: totalprice4 = 91;
            4'd14: totalprice4 = 98;
            4'd15: totalprice4 = 105;
            default: totalprice4 = 0;
        endcase
        
        4'd8: case(price4)
            4'd1: totalprice4 = 8;
            4'd2: totalprice4 = 16;
            4'd3: totalprice4 = 24;
            4'd4: totalprice4 = 32;
            4'd5: totalprice4 = 40;
            4'd6: totalprice4 = 48;
            4'd7: totalprice4 = 56;
            4'd8: totalprice4 = 64;
            4'd9: totalprice4 = 72;
            4'd10: totalprice4 = 80;
            4'd11: totalprice4 = 88;
            4'd12: totalprice4 = 96;
            4'd13: totalprice4 = 104;
            4'd14: totalprice4 = 112;
            4'd15: totalprice4 = 120;
            default: totalprice4 = 0;
        endcase
        
        4'd9: case(price4)
            4'd1: totalprice4 = 9;
            4'd2: totalprice4 = 18;
            4'd3: totalprice4 = 27;
            4'd4: totalprice4 = 36;
            4'd5: totalprice4 = 45;
            4'd6: totalprice4 = 54;
            4'd7: totalprice4 = 63;
            4'd8: totalprice4 = 72;
            4'd9: totalprice4 = 81;
            4'd10: totalprice4 = 90;
            4'd11: totalprice4 = 99;
            4'd12: totalprice4 = 108;
            4'd13: totalprice4 = 117;
            4'd14: totalprice4 = 126;
            4'd15: totalprice4 = 135;
            default: totalprice4 = 0;
        endcase
        
        4'd10: case(price4)
            4'd1: totalprice4 = 10;
            4'd2: totalprice4 = 20;
            4'd3: totalprice4 = 30;
            4'd4: totalprice4 = 40;
            4'd5: totalprice4 = 50;
            4'd6: totalprice4 = 60;
            4'd7: totalprice4 = 70;
            4'd8: totalprice4 = 80;
            4'd9: totalprice4 = 90;
            4'd10: totalprice4 = 100;
            4'd11: totalprice4 = 110;
            4'd12: totalprice4 = 120;
            4'd13: totalprice4 = 130;
            4'd14: totalprice4 = 140;
            4'd15: totalprice4 = 150;
            default: totalprice4 = 0;
        endcase
        
        4'd11: case(price4)
            4'd1: totalprice4 = 11;
            4'd2: totalprice4 = 22;
            4'd3: totalprice4 = 33;
            4'd4: totalprice4 = 44;
            4'd5: totalprice4 = 55;
            4'd6: totalprice4 = 66;
            4'd7: totalprice4 = 77;
            4'd8: totalprice4 = 88;
            4'd9: totalprice4 = 99;
            4'd10: totalprice4 = 110;
            4'd11: totalprice4 = 121;
            4'd12: totalprice4 = 132;
            4'd13: totalprice4 = 143;
            4'd14: totalprice4 = 154;
            4'd15: totalprice4 = 165;
            default: totalprice4 = 0;
        endcase
        
        4'd12: case(price4)
            4'd1: totalprice4 = 12;
            4'd2: totalprice4 = 24;
            4'd3: totalprice4 = 36;
            4'd4: totalprice4 = 48;
            4'd5: totalprice4 = 60;
            4'd6: totalprice4 = 72;
            4'd7: totalprice4 = 84;
            4'd8: totalprice4 = 96;
            4'd9: totalprice4 = 108;
            4'd10: totalprice4 = 120;
            4'd11: totalprice4 = 132;
            4'd12: totalprice4 = 144;
            4'd13: totalprice4 = 156;
            4'd14: totalprice4 = 168;
            4'd15: totalprice4 = 180;
            default: totalprice4 = 0;
        endcase
        
        4'd13: case(price4)
            4'd1: totalprice4 = 13;
            4'd2: totalprice4 = 26;
            4'd3: totalprice4 = 39;
            4'd4: totalprice4 = 52;
            4'd5: totalprice4 = 65;
            4'd6: totalprice4 = 78;
            4'd7: totalprice4 = 91;
            4'd8: totalprice4 = 104;
            4'd9: totalprice4 = 117;
            4'd10: totalprice4 = 130;
            4'd11: totalprice4 = 143;
            4'd12: totalprice4 = 156;
            4'd13: totalprice4 = 169;
            4'd14: totalprice4 = 182;
            4'd15: totalprice4 = 195;
            default: totalprice4 = 0;
        endcase
        
        4'd14: case(price4)
            4'd1: totalprice4 = 14;
            4'd2: totalprice4 = 28;
            4'd3: totalprice4 = 42;
            4'd4: totalprice4 = 56;
            4'd5: totalprice4 = 70;
            4'd6: totalprice4 = 84;
            4'd7: totalprice4 = 98;
            4'd8: totalprice4 = 112;
            4'd9: totalprice4 = 126;
            4'd10: totalprice4 = 140;
            4'd11: totalprice4 = 154;
            4'd12: totalprice4 = 168;
            4'd13: totalprice4 = 182;
            4'd14: totalprice4 = 196;
            4'd15: totalprice4 = 210;
            default: totalprice4 = 0;
        endcase
        
        4'd15: case(price4)
            4'd1: totalprice4 = 15;
            4'd2: totalprice4 = 30;
            4'd3: totalprice4 = 45;
            4'd4: totalprice4 = 60;
            4'd5: totalprice4 = 75;
            4'd6: totalprice4 = 90;
            4'd7: totalprice4 = 105;
            4'd8: totalprice4 = 120;
            4'd9: totalprice4 = 135;
            4'd10: totalprice4 = 150;
            4'd11: totalprice4 = 165;
            4'd12: totalprice4 = 180;
            4'd13: totalprice4 = 195;
            4'd14: totalprice4 = 210;
            4'd15: totalprice4 = 225;
            default: totalprice4 = 0;
        endcase
        
        default: totalprice4 = 0;
    endcase
end

always @(*) begin
    case (snack5)
        4'd1: case(price5)
            4'd1: totalprice5 = 1;
            4'd2: totalprice5 = 2;
            4'd3: totalprice5 = 3;
            4'd4: totalprice5 = 4;
            4'd5: totalprice5 = 5;
            4'd6: totalprice5 = 6;
            4'd7: totalprice5 = 7;
            4'd8: totalprice5 = 8;
            4'd9: totalprice5 = 9;
            4'd10: totalprice5 = 10;
            4'd11: totalprice5 = 11;
            4'd12: totalprice5 = 12;
            4'd13: totalprice5 = 13;
            4'd14: totalprice5 = 14;
            4'd15: totalprice5 = 15;
            default: totalprice5 = 0;
        endcase
        
        4'd2: case(price5)
            4'd1: totalprice5 = 2;
            4'd2: totalprice5 = 4;
            4'd3: totalprice5 = 6;
            4'd4: totalprice5 = 8;
            4'd5: totalprice5 = 10;
            4'd6: totalprice5 = 12;
            4'd7: totalprice5 = 14;
            4'd8: totalprice5 = 16;
            4'd9: totalprice5 = 18;
            4'd10: totalprice5 = 20;
            4'd11: totalprice5 = 22;
            4'd12: totalprice5 = 24;
            4'd13: totalprice5 = 26;
            4'd14: totalprice5 = 28;
            4'd15: totalprice5 = 30;
            default: totalprice5 = 0;
        endcase
        
        4'd3: case(price5)
            4'd1: totalprice5 = 3;
            4'd2: totalprice5 = 6;
            4'd3: totalprice5 = 9;
            4'd4: totalprice5 = 12;
            4'd5: totalprice5 = 15;
            4'd6: totalprice5 = 18;
            4'd7: totalprice5 = 21;
            4'd8: totalprice5 = 24;
            4'd9: totalprice5 = 27;
            4'd10: totalprice5 = 30;
            4'd11: totalprice5 = 33;
            4'd12: totalprice5 = 36;
            4'd13: totalprice5 = 39;
            4'd14: totalprice5 = 42;
            4'd15: totalprice5 = 45;
            default: totalprice5 = 0;
        endcase
        
        4'd4: case(price5)
            4'd1: totalprice5 = 4;
            4'd2: totalprice5 = 8;
            4'd3: totalprice5 = 12;
            4'd4: totalprice5 = 16;
            4'd5: totalprice5 = 20;
            4'd6: totalprice5 = 24;
            4'd7: totalprice5 = 28;
            4'd8: totalprice5 = 32;
            4'd9: totalprice5 = 36;
            4'd10: totalprice5 = 40;
            4'd11: totalprice5 = 44;
            4'd12: totalprice5 = 48;
            4'd13: totalprice5 = 52;
            4'd14: totalprice5 = 56;
            4'd15: totalprice5 = 60;
            default: totalprice5 = 0;
        endcase
        
        4'd5: case(price5)
            4'd1: totalprice5 = 5;
            4'd2: totalprice5 = 10;
            4'd3: totalprice5 = 15;
            4'd4: totalprice5 = 20;
            4'd5: totalprice5 = 25;
            4'd6: totalprice5 = 30;
            4'd7: totalprice5 = 35;
            4'd8: totalprice5 = 40;
            4'd9: totalprice5 = 45;
            4'd10: totalprice5 = 50;
            4'd11: totalprice5 = 55;
            4'd12: totalprice5 = 60;
            4'd13: totalprice5 = 65;
            4'd14: totalprice5 = 70;
            4'd15: totalprice5 = 75;
            default: totalprice5 = 0;
        endcase
        
        4'd6: case(price5)
            4'd1: totalprice5 = 6;
            4'd2: totalprice5 = 12;
            4'd3: totalprice5 = 18;
            4'd4: totalprice5 = 24;
            4'd5: totalprice5 = 30;
            4'd6: totalprice5 = 36;
            4'd7: totalprice5 = 42;
            4'd8: totalprice5 = 48;
            4'd9: totalprice5 = 54;
            4'd10: totalprice5 = 60;
            4'd11: totalprice5 = 66;
            4'd12: totalprice5 = 72;
            4'd13: totalprice5 = 78;
            4'd14: totalprice5 = 84;
            4'd15: totalprice5 = 90;
            default: totalprice5 = 0;
        endcase
        
        4'd7: case(price5)
            4'd1: totalprice5 = 7;
            4'd2: totalprice5 = 14;
            4'd3: totalprice5 = 21;
            4'd4: totalprice5 = 28;
            4'd5: totalprice5 = 35;
            4'd6: totalprice5 = 42;
            4'd7: totalprice5 = 49;
            4'd8: totalprice5 = 56;
            4'd9: totalprice5 = 63;
            4'd10: totalprice5 = 70;
            4'd11: totalprice5 = 77;
            4'd12: totalprice5 = 84;
            4'd13: totalprice5 = 91;
            4'd14: totalprice5 = 98;
            4'd15: totalprice5 = 105;
            default: totalprice5 = 0;
        endcase
        
        4'd8: case(price5)
            4'd1: totalprice5 = 8;
            4'd2: totalprice5 = 16;
            4'd3: totalprice5 = 24;
            4'd4: totalprice5 = 32;
            4'd5: totalprice5 = 40;
            4'd6: totalprice5 = 48;
            4'd7: totalprice5 = 56;
            4'd8: totalprice5 = 64;
            4'd9: totalprice5 = 72;
            4'd10: totalprice5 = 80;
            4'd11: totalprice5 = 88;
            4'd12: totalprice5 = 96;
            4'd13: totalprice5 = 104;
            4'd14: totalprice5 = 112;
            4'd15: totalprice5 = 120;
            default: totalprice5 = 0;
        endcase
        
        4'd9: case(price5)
            4'd1: totalprice5 = 9;
            4'd2: totalprice5 = 18;
            4'd3: totalprice5 = 27;
            4'd4: totalprice5 = 36;
            4'd5: totalprice5 = 45;
            4'd6: totalprice5 = 54;
            4'd7: totalprice5 = 63;
            4'd8: totalprice5 = 72;
            4'd9: totalprice5 = 81;
            4'd10: totalprice5 = 90;
            4'd11: totalprice5 = 99;
            4'd12: totalprice5 = 108;
            4'd13: totalprice5 = 117;
            4'd14: totalprice5 = 126;
            4'd15: totalprice5 = 135;
            default: totalprice5 = 0;
        endcase
        
        4'd10: case(price5)
            4'd1: totalprice5 = 10;
            4'd2: totalprice5 = 20;
            4'd3: totalprice5 = 30;
            4'd4: totalprice5 = 40;
            4'd5: totalprice5 = 50;
            4'd6: totalprice5 = 60;
            4'd7: totalprice5 = 70;
            4'd8: totalprice5 = 80;
            4'd9: totalprice5 = 90;
            4'd10: totalprice5 = 100;
            4'd11: totalprice5 = 110;
            4'd12: totalprice5 = 120;
            4'd13: totalprice5 = 130;
            4'd14: totalprice5 = 140;
            4'd15: totalprice5 = 150;
            default: totalprice5 = 0;
        endcase
        
        4'd11: case(price5)
            4'd1: totalprice5 = 11;
            4'd2: totalprice5 = 22;
            4'd3: totalprice5 = 33;
            4'd4: totalprice5 = 44;
            4'd5: totalprice5 = 55;
            4'd6: totalprice5 = 66;
            4'd7: totalprice5 = 77;
            4'd8: totalprice5 = 88;
            4'd9: totalprice5 = 99;
            4'd10: totalprice5 = 110;
            4'd11: totalprice5 = 121;
            4'd12: totalprice5 = 132;
            4'd13: totalprice5 = 143;
            4'd14: totalprice5 = 154;
            4'd15: totalprice5 = 165;
            default: totalprice5 = 0;
        endcase
        
        4'd12: case(price5)
            4'd1: totalprice5 = 12;
            4'd2: totalprice5 = 24;
            4'd3: totalprice5 = 36;
            4'd4: totalprice5 = 48;
            4'd5: totalprice5 = 60;
            4'd6: totalprice5 = 72;
            4'd7: totalprice5 = 84;
            4'd8: totalprice5 = 96;
            4'd9: totalprice5 = 108;
            4'd10: totalprice5 = 120;
            4'd11: totalprice5 = 132;
            4'd12: totalprice5 = 144;
            4'd13: totalprice5 = 156;
            4'd14: totalprice5 = 168;
            4'd15: totalprice5 = 180;
            default: totalprice5 = 0;
        endcase
        
        4'd13: case(price5)
            4'd1: totalprice5 = 13;
            4'd2: totalprice5 = 26;
            4'd3: totalprice5 = 39;
            4'd4: totalprice5 = 52;
            4'd5: totalprice5 = 65;
            4'd6: totalprice5 = 78;
            4'd7: totalprice5 = 91;
            4'd8: totalprice5 = 104;
            4'd9: totalprice5 = 117;
            4'd10: totalprice5 = 130;
            4'd11: totalprice5 = 143;
            4'd12: totalprice5 = 156;
            4'd13: totalprice5 = 169;
            4'd14: totalprice5 = 182;
            4'd15: totalprice5 = 195;
            default: totalprice5 = 0;
        endcase
        
        4'd14: case(price5)
            4'd1: totalprice5 = 14;
            4'd2: totalprice5 = 28;
            4'd3: totalprice5 = 42;
            4'd4: totalprice5 = 56;
            4'd5: totalprice5 = 70;
            4'd6: totalprice5 = 84;
            4'd7: totalprice5 = 98;
            4'd8: totalprice5 = 112;
            4'd9: totalprice5 = 126;
            4'd10: totalprice5 = 140;
            4'd11: totalprice5 = 154;
            4'd12: totalprice5 = 168;
            4'd13: totalprice5 = 182;
            4'd14: totalprice5 = 196;
            4'd15: totalprice5 = 210;
            default: totalprice5 = 0;
        endcase
        
        4'd15: case(price5)
            4'd1: totalprice5 = 15;
            4'd2: totalprice5 = 30;
            4'd3: totalprice5 = 45;
            4'd4: totalprice5 = 60;
            4'd5: totalprice5 = 75;
            4'd6: totalprice5 = 90;
            4'd7: totalprice5 = 105;
            4'd8: totalprice5 = 120;
            4'd9: totalprice5 = 135;
            4'd10: totalprice5 = 150;
            4'd11: totalprice5 = 165;
            4'd12: totalprice5 = 180;
            4'd13: totalprice5 = 195;
            4'd14: totalprice5 = 210;
            4'd15: totalprice5 = 225;
            default: totalprice5 = 0;
        endcase
        
        default: totalprice5 = 0;
    endcase
end

always @(*) begin
    case (snack6)
        4'd1: case(price6)
            4'd1: totalprice6 = 1;
            4'd2: totalprice6 = 2;
            4'd3: totalprice6 = 3;
            4'd4: totalprice6 = 4;
            4'd5: totalprice6 = 5;
            4'd6: totalprice6 = 6;
            4'd7: totalprice6 = 7;
            4'd8: totalprice6 = 8;
            4'd9: totalprice6 = 9;
            4'd10: totalprice6 = 10;
            4'd11: totalprice6 = 11;
            4'd12: totalprice6 = 12;
            4'd13: totalprice6 = 13;
            4'd14: totalprice6 = 14;
            4'd15: totalprice6 = 15;
            default: totalprice6 = 0;
        endcase
        
        4'd2: case(price6)
            4'd1: totalprice6 = 2;
            4'd2: totalprice6 = 4;
            4'd3: totalprice6 = 6;
            4'd4: totalprice6 = 8;
            4'd5: totalprice6 = 10;
            4'd6: totalprice6 = 12;
            4'd7: totalprice6 = 14;
            4'd8: totalprice6 = 16;
            4'd9: totalprice6 = 18;
            4'd10: totalprice6 = 20;
            4'd11: totalprice6 = 22;
            4'd12: totalprice6 = 24;
            4'd13: totalprice6 = 26;
            4'd14: totalprice6 = 28;
            4'd15: totalprice6 = 30;
            default: totalprice6 = 0;
        endcase
        
        4'd3: case(price6)
            4'd1: totalprice6 = 3;
            4'd2: totalprice6 = 6;
            4'd3: totalprice6 = 9;
            4'd4: totalprice6 = 12;
            4'd5: totalprice6 = 15;
            4'd6: totalprice6 = 18;
            4'd7: totalprice6 = 21;
            4'd8: totalprice6 = 24;
            4'd9: totalprice6 = 27;
            4'd10: totalprice6 = 30;
            4'd11: totalprice6 = 33;
            4'd12: totalprice6 = 36;
            4'd13: totalprice6 = 39;
            4'd14: totalprice6 = 42;
            4'd15: totalprice6 = 45;
            default: totalprice6 = 0;
        endcase
        
        4'd4: case(price6)
            4'd1: totalprice6 = 4;
            4'd2: totalprice6 = 8;
            4'd3: totalprice6 = 12;
            4'd4: totalprice6 = 16;
            4'd5: totalprice6 = 20;
            4'd6: totalprice6 = 24;
            4'd7: totalprice6 = 28;
            4'd8: totalprice6 = 32;
            4'd9: totalprice6 = 36;
            4'd10: totalprice6 = 40;
            4'd11: totalprice6 = 44;
            4'd12: totalprice6 = 48;
            4'd13: totalprice6 = 52;
            4'd14: totalprice6 = 56;
            4'd15: totalprice6 = 60;
            default: totalprice6 = 0;
        endcase
        
        4'd5: case(price6)
            4'd1: totalprice6 = 5;
            4'd2: totalprice6 = 10;
            4'd3: totalprice6 = 15;
            4'd4: totalprice6 = 20;
            4'd5: totalprice6 = 25;
            4'd6: totalprice6 = 30;
            4'd7: totalprice6 = 35;
            4'd8: totalprice6 = 40;
            4'd9: totalprice6 = 45;
            4'd10: totalprice6 = 50;
            4'd11: totalprice6 = 55;
            4'd12: totalprice6 = 60;
            4'd13: totalprice6 = 65;
            4'd14: totalprice6 = 70;
            4'd15: totalprice6 = 75;
            default: totalprice6 = 0;
        endcase
        
        4'd6: case(price6)
            4'd1: totalprice6 = 6;
            4'd2: totalprice6 = 12;
            4'd3: totalprice6 = 18;
            4'd4: totalprice6 = 24;
            4'd5: totalprice6 = 30;
            4'd6: totalprice6 = 36;
            4'd7: totalprice6 = 42;
            4'd8: totalprice6 = 48;
            4'd9: totalprice6 = 54;
            4'd10: totalprice6 = 60;
            4'd11: totalprice6 = 66;
            4'd12: totalprice6 = 72;
            4'd13: totalprice6 = 78;
            4'd14: totalprice6 = 84;
            4'd15: totalprice6 = 90;
            default: totalprice6 = 0;
        endcase
        
        4'd7: case(price6)
            4'd1: totalprice6 = 7;
            4'd2: totalprice6 = 14;
            4'd3: totalprice6 = 21;
            4'd4: totalprice6 = 28;
            4'd5: totalprice6 = 35;
            4'd6: totalprice6 = 42;
            4'd7: totalprice6 = 49;
            4'd8: totalprice6 = 56;
            4'd9: totalprice6 = 63;
            4'd10: totalprice6 = 70;
            4'd11: totalprice6 = 77;
            4'd12: totalprice6 = 84;
            4'd13: totalprice6 = 91;
            4'd14: totalprice6 = 98;
            4'd15: totalprice6 = 105;
            default: totalprice6 = 0;
        endcase
        
        4'd8: case(price6)
            4'd1: totalprice6 = 8;
            4'd2: totalprice6 = 16;
            4'd3: totalprice6 = 24;
            4'd4: totalprice6 = 32;
            4'd5: totalprice6 = 40;
            4'd6: totalprice6 = 48;
            4'd7: totalprice6 = 56;
            4'd8: totalprice6 = 64;
            4'd9: totalprice6 = 72;
            4'd10: totalprice6 = 80;
            4'd11: totalprice6 = 88;
            4'd12: totalprice6 = 96;
            4'd13: totalprice6 = 104;
            4'd14: totalprice6 = 112;
            4'd15: totalprice6 = 120;
            default: totalprice6 = 0;
        endcase
        
        4'd9: case(price6)
            4'd1: totalprice6 = 9;
            4'd2: totalprice6 = 18;
            4'd3: totalprice6 = 27;
            4'd4: totalprice6 = 36;
            4'd5: totalprice6 = 45;
            4'd6: totalprice6 = 54;
            4'd7: totalprice6 = 63;
            4'd8: totalprice6 = 72;
            4'd9: totalprice6 = 81;
            4'd10: totalprice6 = 90;
            4'd11: totalprice6 = 99;
            4'd12: totalprice6 = 108;
            4'd13: totalprice6 = 117;
            4'd14: totalprice6 = 126;
            4'd15: totalprice6 = 135;
            default: totalprice6 = 0;
        endcase
        
        4'd10: case(price6)
            4'd1: totalprice6 = 10;
            4'd2: totalprice6 = 20;
            4'd3: totalprice6 = 30;
            4'd4: totalprice6 = 40;
            4'd5: totalprice6 = 50;
            4'd6: totalprice6 = 60;
            4'd7: totalprice6 = 70;
            4'd8: totalprice6 = 80;
            4'd9: totalprice6 = 90;
            4'd10: totalprice6 = 100;
            4'd11: totalprice6 = 110;
            4'd12: totalprice6 = 120;
            4'd13: totalprice6 = 130;
            4'd14: totalprice6 = 140;
            4'd15: totalprice6 = 150;
            default: totalprice6 = 0;
        endcase
        
        4'd11: case(price6)
            4'd1: totalprice6 = 11;
            4'd2: totalprice6 = 22;
            4'd3: totalprice6 = 33;
            4'd4: totalprice6 = 44;
            4'd5: totalprice6 = 55;
            4'd6: totalprice6 = 66;
            4'd7: totalprice6 = 77;
            4'd8: totalprice6 = 88;
            4'd9: totalprice6 = 99;
            4'd10: totalprice6 = 110;
            4'd11: totalprice6 = 121;
            4'd12: totalprice6 = 132;
            4'd13: totalprice6 = 143;
            4'd14: totalprice6 = 154;
            4'd15: totalprice6 = 165;
            default: totalprice6 = 0;
        endcase
        
        4'd12: case(price6)
            4'd1: totalprice6 = 12;
            4'd2: totalprice6 = 24;
            4'd3: totalprice6 = 36;
            4'd4: totalprice6 = 48;
            4'd5: totalprice6 = 60;
            4'd6: totalprice6 = 72;
            4'd7: totalprice6 = 84;
            4'd8: totalprice6 = 96;
            4'd9: totalprice6 = 108;
            4'd10: totalprice6 = 120;
            4'd11: totalprice6 = 132;
            4'd12: totalprice6 = 144;
            4'd13: totalprice6 = 156;
            4'd14: totalprice6 = 168;
            4'd15: totalprice6 = 180;
            default: totalprice6 = 0;
        endcase
        
        4'd13: case(price6)
            4'd1: totalprice6 = 13;
            4'd2: totalprice6 = 26;
            4'd3: totalprice6 = 39;
            4'd4: totalprice6 = 52;
            4'd5: totalprice6 = 65;
            4'd6: totalprice6 = 78;
            4'd7: totalprice6 = 91;
            4'd8: totalprice6 = 104;
            4'd9: totalprice6 = 117;
            4'd10: totalprice6 = 130;
            4'd11: totalprice6 = 143;
            4'd12: totalprice6 = 156;
            4'd13: totalprice6 = 169;
            4'd14: totalprice6 = 182;
            4'd15: totalprice6 = 195;
            default: totalprice6 = 0;
        endcase
        
        4'd14: case(price6)
            4'd1: totalprice6 = 14;
            4'd2: totalprice6 = 28;
            4'd3: totalprice6 = 42;
            4'd4: totalprice6 = 56;
            4'd5: totalprice6 = 70;
            4'd6: totalprice6 = 84;
            4'd7: totalprice6 = 98;
            4'd8: totalprice6 = 112;
            4'd9: totalprice6 = 126;
            4'd10: totalprice6 = 140;
            4'd11: totalprice6 = 154;
            4'd12: totalprice6 = 168;
            4'd13: totalprice6 = 182;
            4'd14: totalprice6 = 196;
            4'd15: totalprice6 = 210;
            default: totalprice6 = 0;
        endcase
        
        4'd15: case(price6)
            4'd1: totalprice6 = 15;
            4'd2: totalprice6 = 30;
            4'd3: totalprice6 = 45;
            4'd4: totalprice6 = 60;
            4'd5: totalprice6 = 75;
            4'd6: totalprice6 = 90;
            4'd7: totalprice6 = 105;
            4'd8: totalprice6 = 120;
            4'd9: totalprice6 = 135;
            4'd10: totalprice6 = 150;
            4'd11: totalprice6 = 165;
            4'd12: totalprice6 = 180;
            4'd13: totalprice6 = 195;
            4'd14: totalprice6 = 210;
            4'd15: totalprice6 = 225;
            default: totalprice6 = 0;
        endcase
        
        default: totalprice6 = 0;
    endcase
end

always @(*) begin
    case (snack7)
        4'd1: case(price7)
            4'd1: totalprice7 = 1;
            4'd2: totalprice7 = 2;
            4'd3: totalprice7 = 3;
            4'd4: totalprice7 = 4;
            4'd5: totalprice7 = 5;
            4'd6: totalprice7 = 6;
            4'd7: totalprice7 = 7;
            4'd8: totalprice7 = 8;
            4'd9: totalprice7 = 9;
            4'd10: totalprice7 = 10;
            4'd11: totalprice7 = 11;
            4'd12: totalprice7 = 12;
            4'd13: totalprice7 = 13;
            4'd14: totalprice7 = 14;
            4'd15: totalprice7 = 15;
            default: totalprice7 = 0;
        endcase
        
        4'd2: case(price7)
            4'd1: totalprice7 = 2;
            4'd2: totalprice7 = 4;
            4'd3: totalprice7 = 6;
            4'd4: totalprice7 = 8;
            4'd5: totalprice7 = 10;
            4'd6: totalprice7 = 12;
            4'd7: totalprice7 = 14;
            4'd8: totalprice7 = 16;
            4'd9: totalprice7 = 18;
            4'd10: totalprice7 = 20;
            4'd11: totalprice7 = 22;
            4'd12: totalprice7 = 24;
            4'd13: totalprice7 = 26;
            4'd14: totalprice7 = 28;
            4'd15: totalprice7 = 30;
            default: totalprice7 = 0;
        endcase
        
        4'd3: case(price7)
            4'd1: totalprice7 = 3;
            4'd2: totalprice7 = 6;
            4'd3: totalprice7 = 9;
            4'd4: totalprice7 = 12;
            4'd5: totalprice7 = 15;
            4'd6: totalprice7 = 18;
            4'd7: totalprice7 = 21;
            4'd8: totalprice7 = 24;
            4'd9: totalprice7 = 27;
            4'd10: totalprice7 = 30;
            4'd11: totalprice7 = 33;
            4'd12: totalprice7 = 36;
            4'd13: totalprice7 = 39;
            4'd14: totalprice7 = 42;
            4'd15: totalprice7 = 45;
            default: totalprice7 = 0;
        endcase
        
        4'd4: case(price7)
            4'd1: totalprice7 = 4;
            4'd2: totalprice7 = 8;
            4'd3: totalprice7 = 12;
            4'd4: totalprice7 = 16;
            4'd5: totalprice7 = 20;
            4'd6: totalprice7 = 24;
            4'd7: totalprice7 = 28;
            4'd8: totalprice7 = 32;
            4'd9: totalprice7 = 36;
            4'd10: totalprice7 = 40;
            4'd11: totalprice7 = 44;
            4'd12: totalprice7 = 48;
            4'd13: totalprice7 = 52;
            4'd14: totalprice7 = 56;
            4'd15: totalprice7 = 60;
            default: totalprice7 = 0;
        endcase
        
        4'd5: case(price7)
            4'd1: totalprice7 = 5;
            4'd2: totalprice7 = 10;
            4'd3: totalprice7 = 15;
            4'd4: totalprice7 = 20;
            4'd5: totalprice7 = 25;
            4'd6: totalprice7 = 30;
            4'd7: totalprice7 = 35;
            4'd8: totalprice7 = 40;
            4'd9: totalprice7 = 45;
            4'd10: totalprice7 = 50;
            4'd11: totalprice7 = 55;
            4'd12: totalprice7 = 60;
            4'd13: totalprice7 = 65;
            4'd14: totalprice7 = 70;
            4'd15: totalprice7 = 75;
            default: totalprice7 = 0;
        endcase
        
        4'd6: case(price7)
            4'd1: totalprice7 = 6;
            4'd2: totalprice7 = 12;
            4'd3: totalprice7 = 18;
            4'd4: totalprice7 = 24;
            4'd5: totalprice7 = 30;
            4'd6: totalprice7 = 36;
            4'd7: totalprice7 = 42;
            4'd8: totalprice7 = 48;
            4'd9: totalprice7 = 54;
            4'd10: totalprice7 = 60;
            4'd11: totalprice7 = 66;
            4'd12: totalprice7 = 72;
            4'd13: totalprice7 = 78;
            4'd14: totalprice7 = 84;
            4'd15: totalprice7 = 90;
            default: totalprice7 = 0;
        endcase
        
        4'd7: case(price7)
            4'd1: totalprice7 = 7;
            4'd2: totalprice7 = 14;
            4'd3: totalprice7 = 21;
            4'd4: totalprice7 = 28;
            4'd5: totalprice7 = 35;
            4'd6: totalprice7 = 42;
            4'd7: totalprice7 = 49;
            4'd8: totalprice7 = 56;
            4'd9: totalprice7 = 63;
            4'd10: totalprice7 = 70;
            4'd11: totalprice7 = 77;
            4'd12: totalprice7 = 84;
            4'd13: totalprice7 = 91;
            4'd14: totalprice7 = 98;
            4'd15: totalprice7 = 105;
            default: totalprice7 = 0;
        endcase
        
        4'd8: case(price7)
            4'd1: totalprice7 = 8;
            4'd2: totalprice7 = 16;
            4'd3: totalprice7 = 24;
            4'd4: totalprice7 = 32;
            4'd5: totalprice7 = 40;
            4'd6: totalprice7 = 48;
            4'd7: totalprice7 = 56;
            4'd8: totalprice7 = 64;
            4'd9: totalprice7 = 72;
            4'd10: totalprice7 = 80;
            4'd11: totalprice7 = 88;
            4'd12: totalprice7 = 96;
            4'd13: totalprice7 = 104;
            4'd14: totalprice7 = 112;
            4'd15: totalprice7 = 120;
            default: totalprice7 = 0;
        endcase
        
        4'd9: case(price7)
            4'd1: totalprice7 = 9;
            4'd2: totalprice7 = 18;
            4'd3: totalprice7 = 27;
            4'd4: totalprice7 = 36;
            4'd5: totalprice7 = 45;
            4'd6: totalprice7 = 54;
            4'd7: totalprice7 = 63;
            4'd8: totalprice7 = 72;
            4'd9: totalprice7 = 81;
            4'd10: totalprice7 = 90;
            4'd11: totalprice7 = 99;
            4'd12: totalprice7 = 108;
            4'd13: totalprice7 = 117;
            4'd14: totalprice7 = 126;
            4'd15: totalprice7 = 135;
            default: totalprice7 = 0;
        endcase
        
        4'd10: case(price7)
            4'd1: totalprice7 = 10;
            4'd2: totalprice7 = 20;
            4'd3: totalprice7 = 30;
            4'd4: totalprice7 = 40;
            4'd5: totalprice7 = 50;
            4'd6: totalprice7 = 60;
            4'd7: totalprice7 = 70;
            4'd8: totalprice7 = 80;
            4'd9: totalprice7 = 90;
            4'd10: totalprice7 = 100;
            4'd11: totalprice7 = 110;
            4'd12: totalprice7 = 120;
            4'd13: totalprice7 = 130;
            4'd14: totalprice7 = 140;
            4'd15: totalprice7 = 150;
            default: totalprice7 = 0;
        endcase
        
        4'd11: case(price7)
            4'd1: totalprice7 = 11;
            4'd2: totalprice7 = 22;
            4'd3: totalprice7 = 33;
            4'd4: totalprice7 = 44;
            4'd5: totalprice7 = 55;
            4'd6: totalprice7 = 66;
            4'd7: totalprice7 = 77;
            4'd8: totalprice7 = 88;
            4'd9: totalprice7 = 99;
            4'd10: totalprice7 = 110;
            4'd11: totalprice7 = 121;
            4'd12: totalprice7 = 132;
            4'd13: totalprice7 = 143;
            4'd14: totalprice7 = 154;
            4'd15: totalprice7 = 165;
            default: totalprice7 = 0;
        endcase
        
        4'd12: case(price7)
            4'd1: totalprice7 = 12;
            4'd2: totalprice7 = 24;
            4'd3: totalprice7 = 36;
            4'd4: totalprice7 = 48;
            4'd5: totalprice7 = 60;
            4'd6: totalprice7 = 72;
            4'd7: totalprice7 = 84;
            4'd8: totalprice7 = 96;
            4'd9: totalprice7 = 108;
            4'd10: totalprice7 = 120;
            4'd11: totalprice7 = 132;
            4'd12: totalprice7 = 144;
            4'd13: totalprice7 = 156;
            4'd14: totalprice7 = 168;
            4'd15: totalprice7 = 180;
            default: totalprice7 = 0;
        endcase
        
        4'd13: case(price7)
            4'd1: totalprice7 = 13;
            4'd2: totalprice7 = 26;
            4'd3: totalprice7 = 39;
            4'd4: totalprice7 = 52;
            4'd5: totalprice7 = 65;
            4'd6: totalprice7 = 78;
            4'd7: totalprice7 = 91;
            4'd8: totalprice7 = 104;
            4'd9: totalprice7 = 117;
            4'd10: totalprice7 = 130;
            4'd11: totalprice7 = 143;
            4'd12: totalprice7 = 156;
            4'd13: totalprice7 = 169;
            4'd14: totalprice7 = 182;
            4'd15: totalprice7 = 195;
            default: totalprice7 = 0;
        endcase
        
        4'd14: case(price7)
            4'd1: totalprice7 = 14;
            4'd2: totalprice7 = 28;
            4'd3: totalprice7 = 42;
            4'd4: totalprice7 = 56;
            4'd5: totalprice7 = 70;
            4'd6: totalprice7 = 84;
            4'd7: totalprice7 = 98;
            4'd8: totalprice7 = 112;
            4'd9: totalprice7 = 126;
            4'd10: totalprice7 = 140;
            4'd11: totalprice7 = 154;
            4'd12: totalprice7 = 168;
            4'd13: totalprice7 = 182;
            4'd14: totalprice7 = 196;
            4'd15: totalprice7 = 210;
            default: totalprice7 = 0;
        endcase
        
        4'd15: case(price7)
            4'd1: totalprice7 = 15;
            4'd2: totalprice7 = 30;
            4'd3: totalprice7 = 45;
            4'd4: totalprice7 = 60;
            4'd5: totalprice7 = 75;
            4'd6: totalprice7 = 90;
            4'd7: totalprice7 = 105;
            4'd8: totalprice7 = 120;
            4'd9: totalprice7 = 135;
            4'd10: totalprice7 = 150;
            4'd11: totalprice7 = 165;
            4'd12: totalprice7 = 180;
            4'd13: totalprice7 = 195;
            4'd14: totalprice7 = 210;
            4'd15: totalprice7 = 225;
            default: totalprice7 = 0;
        endcase
        
        default: totalprice7 = 0;
    endcase
end

always @(*) begin
    case (snack8)
        4'd1: case(price8)
            4'd1: totalprice8 = 1;
            4'd2: totalprice8 = 2;
            4'd3: totalprice8 = 3;
            4'd4: totalprice8 = 4;
            4'd5: totalprice8 = 5;
            4'd6: totalprice8 = 6;
            4'd7: totalprice8 = 7;
            4'd8: totalprice8 = 8;
            4'd9: totalprice8 = 9;
            4'd10: totalprice8 = 10;
            4'd11: totalprice8 = 11;
            4'd12: totalprice8 = 12;
            4'd13: totalprice8 = 13;
            4'd14: totalprice8 = 14;
            4'd15: totalprice8 = 15;
            default: totalprice8 = 0;
        endcase
        
        4'd2: case(price8)
            4'd1: totalprice8 = 2;
            4'd2: totalprice8 = 4;
            4'd3: totalprice8 = 6;
            4'd4: totalprice8 = 8;
            4'd5: totalprice8 = 10;
            4'd6: totalprice8 = 12;
            4'd7: totalprice8 = 14;
            4'd8: totalprice8 = 16;
            4'd9: totalprice8 = 18;
            4'd10: totalprice8 = 20;
            4'd11: totalprice8 = 22;
            4'd12: totalprice8 = 24;
            4'd13: totalprice8 = 26;
            4'd14: totalprice8 = 28;
            4'd15: totalprice8 = 30;
            default: totalprice8 = 0;
        endcase
        
        4'd3: case(price8)
            4'd1: totalprice8 = 3;
            4'd2: totalprice8 = 6;
            4'd3: totalprice8 = 9;
            4'd4: totalprice8 = 12;
            4'd5: totalprice8 = 15;
            4'd6: totalprice8 = 18;
            4'd7: totalprice8 = 21;
            4'd8: totalprice8 = 24;
            4'd9: totalprice8 = 27;
            4'd10: totalprice8 = 30;
            4'd11: totalprice8 = 33;
            4'd12: totalprice8 = 36;
            4'd13: totalprice8 = 39;
            4'd14: totalprice8 = 42;
            4'd15: totalprice8 = 45;
            default: totalprice8 = 0;
        endcase
        
        4'd4: case(price8)
            4'd1: totalprice8 = 4;
            4'd2: totalprice8 = 8;
            4'd3: totalprice8 = 12;
            4'd4: totalprice8 = 16;
            4'd5: totalprice8 = 20;
            4'd6: totalprice8 = 24;
            4'd7: totalprice8 = 28;
            4'd8: totalprice8 = 32;
            4'd9: totalprice8 = 36;
            4'd10: totalprice8 = 40;
            4'd11: totalprice8 = 44;
            4'd12: totalprice8 = 48;
            4'd13: totalprice8 = 52;
            4'd14: totalprice8 = 56;
            4'd15: totalprice8 = 60;
            default: totalprice8 = 0;
        endcase
        
        4'd5: case(price8)
            4'd1: totalprice8 = 5;
            4'd2: totalprice8 = 10;
            4'd3: totalprice8 = 15;
            4'd4: totalprice8 = 20;
            4'd5: totalprice8 = 25;
            4'd6: totalprice8 = 30;
            4'd7: totalprice8 = 35;
            4'd8: totalprice8 = 40;
            4'd9: totalprice8 = 45;
            4'd10: totalprice8 = 50;
            4'd11: totalprice8 = 55;
            4'd12: totalprice8 = 60;
            4'd13: totalprice8 = 65;
            4'd14: totalprice8 = 70;
            4'd15: totalprice8 = 75;
            default: totalprice8 = 0;
        endcase
        
        4'd6: case(price8)
            4'd1: totalprice8 = 6;
            4'd2: totalprice8 = 12;
            4'd3: totalprice8 = 18;
            4'd4: totalprice8 = 24;
            4'd5: totalprice8 = 30;
            4'd6: totalprice8 = 36;
            4'd7: totalprice8 = 42;
            4'd8: totalprice8 = 48;
            4'd9: totalprice8 = 54;
            4'd10: totalprice8 = 60;
            4'd11: totalprice8 = 66;
            4'd12: totalprice8 = 72;
            4'd13: totalprice8 = 78;
            4'd14: totalprice8 = 84;
            4'd15: totalprice8 = 90;
            default: totalprice8 = 0;
        endcase
        
        4'd7: case(price8)
            4'd1: totalprice8 = 7;
            4'd2: totalprice8 = 14;
            4'd3: totalprice8 = 21;
            4'd4: totalprice8 = 28;
            4'd5: totalprice8 = 35;
            4'd6: totalprice8 = 42;
            4'd7: totalprice8 = 49;
            4'd8: totalprice8 = 56;
            4'd9: totalprice8 = 63;
            4'd10: totalprice8 = 70;
            4'd11: totalprice8 = 77;
            4'd12: totalprice8 = 84;
            4'd13: totalprice8 = 91;
            4'd14: totalprice8 = 98;
            4'd15: totalprice8 = 105;
            default: totalprice8 = 0;
        endcase
        
        4'd8: case(price8)
            4'd1: totalprice8 = 8;
            4'd2: totalprice8 = 16;
            4'd3: totalprice8 = 24;
            4'd4: totalprice8 = 32;
            4'd5: totalprice8 = 40;
            4'd6: totalprice8 = 48;
            4'd7: totalprice8 = 56;
            4'd8: totalprice8 = 64;
            4'd9: totalprice8 = 72;
            4'd10: totalprice8 = 80;
            4'd11: totalprice8 = 88;
            4'd12: totalprice8 = 96;
            4'd13: totalprice8 = 104;
            4'd14: totalprice8 = 112;
            4'd15: totalprice8 = 120;
            default: totalprice8 = 0;
        endcase
        
        4'd9: case(price8)
            4'd1: totalprice8 = 9;
            4'd2: totalprice8 = 18;
            4'd3: totalprice8 = 27;
            4'd4: totalprice8 = 36;
            4'd5: totalprice8 = 45;
            4'd6: totalprice8 = 54;
            4'd7: totalprice8 = 63;
            4'd8: totalprice8 = 72;
            4'd9: totalprice8 = 81;
            4'd10: totalprice8 = 90;
            4'd11: totalprice8 = 99;
            4'd12: totalprice8 = 108;
            4'd13: totalprice8 = 117;
            4'd14: totalprice8 = 126;
            4'd15: totalprice8 = 135;
            default: totalprice8 = 0;
        endcase
        
        4'd10: case(price8)
            4'd1: totalprice8 = 10;
            4'd2: totalprice8 = 20;
            4'd3: totalprice8 = 30;
            4'd4: totalprice8 = 40;
            4'd5: totalprice8 = 50;
            4'd6: totalprice8 = 60;
            4'd7: totalprice8 = 70;
            4'd8: totalprice8 = 80;
            4'd9: totalprice8 = 90;
            4'd10: totalprice8 = 100;
            4'd11: totalprice8 = 110;
            4'd12: totalprice8 = 120;
            4'd13: totalprice8 = 130;
            4'd14: totalprice8 = 140;
            4'd15: totalprice8 = 150;
            default: totalprice8 = 0;
        endcase
        
        4'd11: case(price8)
            4'd1: totalprice8 = 11;
            4'd2: totalprice8 = 22;
            4'd3: totalprice8 = 33;
            4'd4: totalprice8 = 44;
            4'd5: totalprice8 = 55;
            4'd6: totalprice8 = 66;
            4'd7: totalprice8 = 77;
            4'd8: totalprice8 = 88;
            4'd9: totalprice8 = 99;
            4'd10: totalprice8 = 110;
            4'd11: totalprice8 = 121;
            4'd12: totalprice8 = 132;
            4'd13: totalprice8 = 143;
            4'd14: totalprice8 = 154;
            4'd15: totalprice8 = 165;
            default: totalprice8 = 0;
        endcase
        
        4'd12: case(price8)
            4'd1: totalprice8 = 12;
            4'd2: totalprice8 = 24;
            4'd3: totalprice8 = 36;
            4'd4: totalprice8 = 48;
            4'd5: totalprice8 = 60;
            4'd6: totalprice8 = 72;
            4'd7: totalprice8 = 84;
            4'd8: totalprice8 = 96;
            4'd9: totalprice8 = 108;
            4'd10: totalprice8 = 120;
            4'd11: totalprice8 = 132;
            4'd12: totalprice8 = 144;
            4'd13: totalprice8 = 156;
            4'd14: totalprice8 = 168;
            4'd15: totalprice8 = 180;
            default: totalprice8 = 0;
        endcase
        
        4'd13: case(price8)
            4'd1: totalprice8 = 13;
            4'd2: totalprice8 = 26;
            4'd3: totalprice8 = 39;
            4'd4: totalprice8 = 52;
            4'd5: totalprice8 = 65;
            4'd6: totalprice8 = 78;
            4'd7: totalprice8 = 91;
            4'd8: totalprice8 = 104;
            4'd9: totalprice8 = 117;
            4'd10: totalprice8 = 130;
            4'd11: totalprice8 = 143;
            4'd12: totalprice8 = 156;
            4'd13: totalprice8 = 169;
            4'd14: totalprice8 = 182;
            4'd15: totalprice8 = 195;
            default: totalprice8 = 0;
        endcase
        
        4'd14: case(price8)
            4'd1: totalprice8 = 14;
            4'd2: totalprice8 = 28;
            4'd3: totalprice8 = 42;
            4'd4: totalprice8 = 56;
            4'd5: totalprice8 = 70;
            4'd6: totalprice8 = 84;
            4'd7: totalprice8 = 98;
            4'd8: totalprice8 = 112;
            4'd9: totalprice8 = 126;
            4'd10: totalprice8 = 140;
            4'd11: totalprice8 = 154;
            4'd12: totalprice8 = 168;
            4'd13: totalprice8 = 182;
            4'd14: totalprice8 = 196;
            4'd15: totalprice8 = 210;
            default: totalprice8 = 0;
        endcase
        
        4'd15: case(price8)
            4'd1: totalprice8 = 15;
            4'd2: totalprice8 = 30;
            4'd3: totalprice8 = 45;
            4'd4: totalprice8 = 60;
            4'd5: totalprice8 = 75;
            4'd6: totalprice8 = 90;
            4'd7: totalprice8 = 105;
            4'd8: totalprice8 = 120;
            4'd9: totalprice8 = 135;
            4'd10: totalprice8 = 150;
            4'd11: totalprice8 = 165;
            4'd12: totalprice8 = 180;
            4'd13: totalprice8 = 195;
            4'd14: totalprice8 = 210;
            4'd15: totalprice8 = 225;
            default: totalprice8 = 0;
        endcase
        
        default: totalprice8 = 0;
    endcase
end
//sorting


///////////////////////////////////////////////////////////////////////////////////
/*
//lv1
assign lv1_1 = (totalprice1>totalprice3)?totalprice1:totalprice3;
assign lv1_3 = (totalprice1>totalprice3)?totalprice3:totalprice1;
assign lv1_2 = (totalprice2>totalprice4)?totalprice2:totalprice4;
assign lv1_4 = (totalprice2>totalprice4)?totalprice4:totalprice2;
assign lv1_5 = (totalprice5>totalprice7)?totalprice5:totalprice7;
assign lv1_7 = (totalprice5>totalprice7)?totalprice7:totalprice5;
assign lv1_6 = (totalprice6>totalprice8)?totalprice6:totalprice8;
assign lv1_8 = (totalprice6>totalprice8)?totalprice8:totalprice6;

//lv2
assign lv2_1 = (lv1_1>lv1_5)?lv1_1:lv1_5;
assign lv2_5 = (lv1_1>lv1_5)?lv1_5:lv1_1;
assign lv2_2 = (lv1_2>lv1_6)?lv1_2:lv1_6;
assign lv2_6 = (lv1_2>lv1_6)?lv1_6:lv1_2;
assign lv2_3 = (lv1_3>lv1_7)?lv1_3:lv1_7;
assign lv2_7 = (lv1_3>lv1_7)?lv1_7:lv1_3;
assign lv2_4 = (lv1_4>lv1_8)?lv1_4:lv1_8;
assign lv2_8 = (lv1_4>lv1_8)?lv1_8:lv1_4;

//lv3
assign lv3_1 = (lv2_1>lv2_2)?lv2_1:lv2_2;
assign lv3_2 = (lv2_1>lv2_2)?lv2_2:lv2_1;

assign lv3_3 = (lv2_3>lv2_4)?lv2_3:lv2_4;
assign lv3_4 = (lv2_3>lv2_4)?lv2_4:lv2_3;

assign lv3_5 = (lv2_5>lv2_6)?lv2_5:lv2_6;
assign lv3_6 = (lv2_5>lv2_6)?lv2_6:lv2_5;

assign lv3_7 = (lv2_7>lv2_8)?lv2_7:lv2_8;
assign lv3_8 = (lv2_7>lv2_8)?lv2_8:lv2_7;

//lv4
assign lv4_3 = (lv3_3>lv3_5)?lv3_3:lv3_5;
assign lv4_5 = (lv3_3>lv3_5)?lv3_5:lv3_3;

assign lv4_4 = (lv3_4>lv3_6)?lv3_4:lv3_6;
assign lv4_6 = (lv3_4>lv3_6)?lv3_6:lv3_4;

//lv5
assign lv5_2 = (lv3_2>lv4_5)?lv3_2:lv4_5;
assign lv5_5 = (lv3_2>lv4_5)?lv4_5:lv3_2;

assign lv5_4 = (lv4_4>lv3_7)?lv4_4:lv3_7;
assign lv5_7 = (lv4_4>lv3_7)?lv3_7:lv4_4;


//lv6
assign lv6_1 = (lv5_2>lv4_3)?lv5_2:lv4_3;
assign lv6_2 = (lv5_2>lv4_3)?lv4_3:lv5_2;

assign lv6_3 = (lv5_4>lv5_5)?lv5_4:lv5_5;
assign lv6_4 = (lv5_4>lv5_5)?lv5_5:lv5_4;

assign lv6_5 = (lv4_6>lv5_7)?lv4_6:lv5_7;
assign lv6_6 = (lv4_6>lv5_7)?lv5_7:lv4_6;
*/
//////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////////
//lv1
always @(*) begin
    if (totalprice1>totalprice3) begin
        lv1_1 = totalprice1 ;
        lv1_3 = totalprice3 ;
    end
    else begin
        lv1_1 = totalprice3 ;
        lv1_3 = totalprice1 ;
    end
end

always @(*) begin
    if (totalprice2>totalprice4) begin
        lv1_2 = totalprice2 ;
        lv1_4 = totalprice4 ;
    end
    else begin
        lv1_2 = totalprice4 ;
        lv1_4 = totalprice2 ;
    end
end

always @(*) begin
    if (totalprice5>totalprice7) begin
        lv1_5 = totalprice5 ;
        lv1_7 = totalprice7 ;
    end
    else begin
        lv1_5 = totalprice7 ;
        lv1_7 = totalprice5 ;
    end
end

always @(*) begin
    if (totalprice6>totalprice8) begin
        lv1_6 = totalprice6 ;
        lv1_8 = totalprice8 ;
    end
    else begin
        lv1_6 = totalprice8 ;
        lv1_8 = totalprice6 ;
    end
end

//assign lv1_1 = (totalprice1>totalprice3)?totalprice1:totalprice3;
//assign lv1_3 = (totalprice1>totalprice3)?totalprice3:totalprice1;
//assign lv1_2 = (totalprice2>totalprice4)?totalprice2:totalprice4;
//assign lv1_4 = (totalprice2>totalprice4)?totalprice4:totalprice2;
//assign lv1_5 = (totalprice5>totalprice7)?totalprice5:totalprice7;
//assign lv1_7 = (totalprice5>totalprice7)?totalprice7:totalprice5;
//assign lv1_6 = (totalprice6>totalprice8)?totalprice6:totalprice8;
//assign lv1_8 = (totalprice6>totalprice8)?totalprice8:totalprice6;

//lv2
always @(*) begin
    if (lv1_1>lv1_5) begin
        lv2_1 = lv1_1 ;
        lv2_5 = lv1_5 ;
    end
    else begin
        lv2_1 = lv1_5 ;
        lv2_5 = lv1_1 ;
    end
end

always @(*) begin
    if (lv1_2>lv1_6) begin
        lv2_2 = lv1_2 ;
        lv2_6 = lv1_6 ;
    end
    else begin
        lv2_2 = lv1_6 ;
        lv2_6 = lv1_2 ;
    end
end

always @(*) begin
    if (lv1_3>lv1_7) begin
        lv2_3 = lv1_3 ;
        lv2_7 = lv1_7 ;
    end
    else begin
        lv2_3 = lv1_7 ;
        lv2_7 = lv1_3 ;
    end
end

always @(*) begin
    if (lv1_4>lv1_8) begin
        lv2_4 = lv1_4 ;
        lv2_8 = lv1_8 ;
    end
    else begin
        lv2_4 = lv1_8 ;
        lv2_8 = lv1_4 ;
    end
end




//assign lv2_1 = (lv1_1>lv1_5)?lv1_1:lv1_5;
//assign lv2_5 = (lv1_1>lv1_5)?lv1_5:lv1_1;
//assign lv2_2 = (lv1_2>lv1_6)?lv1_2:lv1_6;
//assign lv2_6 = (lv1_2>lv1_6)?lv1_6:lv1_2;
//assign lv2_3 = (lv1_3>lv1_7)?lv1_3:lv1_7;
//assign lv2_7 = (lv1_3>lv1_7)?lv1_7:lv1_3;
//assign lv2_4 = (lv1_4>lv1_8)?lv1_4:lv1_8;
//assign lv2_8 = (lv1_4>lv1_8)?lv1_8:lv1_4;

//lv3
/*
always @(*) begin
    if (lv2_1>lv2_2) begin
        lv3_1 = lv2_1 ;
        lv3_2 = lv2_2 ;
    end
    else begin
        lv3_1 = lv2_2 ;
        lv3_2 = lv2_1 ;
    end
end

always @(*) begin
    if (lv2_5>lv2_6) begin
        lv3_5 = lv2_5 ;
        lv3_6 = lv2_6 ;
    end
    else begin
        lv3_5 = lv2_6 ;
        lv3_6 = lv2_5 ;
    end
end
*/


assign lv3_1 = (lv2_1>lv2_2)?lv2_1:lv2_2;
assign lv3_2 = (lv2_1>lv2_2)?lv2_2:lv2_1;

assign lv3_3 = (lv2_3>lv2_4)?lv2_3:lv2_4;
assign lv3_4 = (lv2_3>lv2_4)?lv2_4:lv2_3;

assign lv3_5 = (lv2_5>lv2_6)?lv2_5:lv2_6;
assign lv3_6 = (lv2_5>lv2_6)?lv2_6:lv2_5;

assign lv3_7 = (lv2_7>lv2_8)?lv2_7:lv2_8;
assign lv3_8 = (lv2_7>lv2_8)?lv2_8:lv2_7;

//lv4
assign lv4_3 = (lv3_3>lv3_5)?lv3_3:lv3_5;
assign lv4_5 = (lv3_3>lv3_5)?lv3_5:lv3_3;

assign lv4_4 = (lv3_4>lv3_6)?lv3_4:lv3_6;
assign lv4_6 = (lv3_4>lv3_6)?lv3_6:lv3_4;

//lv5
assign lv5_2 = (lv3_2>lv4_5)?lv3_2:lv4_5;
assign lv5_5 = (lv3_2>lv4_5)?lv4_5:lv3_2;

assign lv5_4 = (lv4_4>lv3_7)?lv4_4:lv3_7;
assign lv5_7 = (lv4_4>lv3_7)?lv3_7:lv4_4;


//lv6
assign lv6_1 = (lv5_2>lv4_3)?lv5_2:lv4_3;
assign lv6_2 = (lv5_2>lv4_3)?lv4_3:lv5_2;

assign lv6_3 = (lv5_4>lv5_5)?lv5_4:lv5_5;
assign lv6_4 = (lv5_4>lv5_5)?lv5_5:lv5_4;

assign lv6_5 = (lv4_6>lv5_7)?lv4_6:lv5_7;
assign lv6_6 = (lv4_6>lv5_7)?lv5_7:lv4_6;
/////////////////////////////////////////////////////////////////////////////


assign input_money_in = input_money;
assign input_money_8 = input_money_7+lv3_8;
assign input_money_7 = input_money_6+lv6_6;
assign input_money_6 = input_money_5+lv6_5;
assign input_money_5 = input_money_4+lv6_4;
assign input_money_4 = input_money_3+lv6_3;
assign input_money_3 = input_money_2+lv6_2;
assign input_money_2 = input_money_1+lv6_1;
assign input_money_1 = lv3_1;


/*
always @(*) begin
    if (out_valid == 0) begin
        out_change = input_money_in;
    end
    else if(input_money_in >= input_money_8)begin
        out_change = input_money_in - input_money_8;
    end
    else if(input_money_in >= input_money_7)begin
        out_change = input_money_in - input_money_7;
    end
    else if(input_money_in >= input_money_6)begin
        out_change = input_money_in - input_money_6;
    end
    else if(input_money_in >= input_money_5)begin
        out_change = input_money_in - input_money_5;
    end
    else if(input_money_in >= input_money_4)begin
        out_change = input_money_in - input_money_4;
    end
    else if(input_money_in >= input_money_3)begin
        out_change = input_money_in - input_money_3;
    end
    else if(input_money_in >= input_money_2)begin
        out_change = input_money_in - input_money_2;
    end
    else if(input_money_in >= (lv3_1))begin
        out_change = input_money_in - (lv3_1);
    end
    else begin
        out_change = input_money_in;
    end
end
*/





reg [8:0] input_money_all_1;
reg [8:0] input_money_all_2;
/*
always @(*) begin
    if (out_valid == 0  ) begin
        out_change = input_money_in;
    end
    else if ( input_money_in >= input_money_5) begin 
        out_change = input_money_in - input_money_all_1;
    end
    else if (input_money_in <= input_money_5 ) begin
        out_change = input_money_in - input_money_all_2;
    end
    else begin
        out_change = input_money_in;
    end
end
*/


always @(*) begin
    if ( input_money_in >= input_money_5 && out_valid == 1 ) begin 
        out_change = input_money_in - input_money_all_1;
    end
    else if (input_money_in <= input_money_5 && out_valid == 1 ) begin
        out_change = input_money_in - input_money_all_2;
    end
    else begin
        out_change = input_money_in;
    end
end



always @(*) begin
    if (input_money_in >= input_money_8) begin
        input_money_all_1 = input_money_8;
    end
    else if (input_money_in >= input_money_7) begin
        input_money_all_1 = input_money_7;
    end
    else if (input_money_in >= input_money_6) begin
        input_money_all_1 = input_money_6;
    end
    else if (input_money_in >= input_money_5) begin
        input_money_all_1 = input_money_5;
    end
    else input_money_all_1 = 0;
end



always @(*) begin
    if (input_money_in >= input_money_4) begin
        input_money_all_2 = input_money_4;
    end
    else if (input_money_in >= input_money_3) begin
        input_money_all_2 = input_money_3;
    end
    else if (input_money_in >= input_money_2) begin
        input_money_all_2 = input_money_2;
    end
    else if (input_money_in >= input_money_1) begin
        input_money_all_2 = input_money_1;
    end
    else input_money_all_2 = 0;
end




endmodule











