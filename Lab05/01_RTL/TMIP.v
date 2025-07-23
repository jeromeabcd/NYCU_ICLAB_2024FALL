module TMIP(
    // input signals
    clk,
    rst_n,
    in_valid, 
    in_valid2,
    
    image,
    template,
    image_size,
	action,
	
    // output signals
    out_valid,
    out_value
    );

input            clk, rst_n;
input            in_valid, in_valid2;

input      [7:0] image;
input      [7:0] template;
input      [1:0] image_size;
input      [2:0] action;

output reg       out_valid;
output reg       out_value;

//==================================================================
// parameter & integer
//==================================================================
integer i,j;
parameter IDLE = 0;
parameter IN_DATA = 1;
parameter WAIT = 2;
parameter IN_DATA2 = 3;
parameter CAL = 4;
parameter STORE = 5;
parameter OUT = 6;

//==================================================================
// reg & wire
//==================================================================
reg [2:0] current_state,next_state;
reg [1:0] image_size_in;
reg [1:0] image_size_not;
reg [7:0] img_R,img_G,img_B;
reg [7:0] img_RG;
reg [7:0] gray_0,gray_1,gray_2;
reg [7:0] gray_0_seq,gray_1_seq,gray_2_seq;
reg [7:0] addr_g0,addr_g1,addr_g2;

//corr

reg [3:0] sum_a, sum_b, sum_c, sum_d, sum_e, sum_f, sum_g, sum_h, sum_i;
reg [19:0] median;
reg cor_ab, cor_ac, cor_ad, cor_ae, cor_af, cor_ag, cor_ah, cor_ai;
reg cor_ba, cor_bc, cor_bd, cor_be, cor_bf, cor_bg, cor_bh, cor_bi;
reg cor_ca, cor_cb, cor_cd, cor_ce, cor_cf, cor_cg, cor_ch, cor_ci;
reg cor_da, cor_db, cor_dc, cor_de, cor_df, cor_dg, cor_dh, cor_di;
reg cor_ea, cor_eb, cor_ec, cor_ed, cor_ef, cor_eg, cor_eh, cor_ei;
reg cor_fa, cor_fb, cor_fc, cor_fd, cor_fe, cor_fg, cor_fh, cor_fi;
reg cor_ga, cor_gb, cor_gc, cor_gd, cor_ge, cor_gf, cor_gh, cor_gi;
reg cor_ha, cor_hb, cor_hc, cor_hd, cor_he, cor_hf, cor_hg, cor_hi;
reg cor_ia, cor_ib, cor_ic, cor_id, cor_ie, cor_if, cor_ig, cor_ih;


reg [7:0] sram_g0,sram_g0_out;
reg [7:0] sram_g1,sram_g1_out;
reg [7:0] sram_g2,sram_g2_out;
reg [19:0] cal_map[0:17][0:17];

reg [7:0]template_in[0:2][0:2];
reg [2:0]act_in[0:7];


reg [1:0]counter_RGB;
reg [9:0]counter;
reg [8:0]counter_out;
reg [4:0]counter_out_bit;
reg [3:0]counter_set;
reg [4:0]counter_in2;
reg [9:0]counter_inD2;
reg [9:0]counter_inD2_seq;
reg [3:0]counter_act;
reg [9:0]counter_cal;

reg [7:0]conv1,conv2,conv3,conv4,conv5,conv6,conv7,conv8,conv9;
reg [19:0]conv_all;

reg [7:0]comp1,comp2,comp3,comp4;
reg [7:0]comp12,comp34;
reg [7:0]compall;

reg [7:0]word_count ;
reg [7:0]word_count_seq ;


reg sram_CS  ;
reg sram_WEB ;

//==================================================================
// FSM
//==================================================================
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) current_state <= 0;
	else current_state <= next_state;
end

always @(*) begin
	case(current_state)
        IDLE:begin//0
            if(in_valid) next_state = IN_DATA;
            else next_state = IDLE;
        end
        IN_DATA:begin//1
            if(!in_valid) next_state = WAIT;
            else next_state = IN_DATA;
        end
        WAIT:begin//2
            if(in_valid2) next_state = IN_DATA2;
            else next_state = WAIT;
        end
        IN_DATA2:begin//3
            if(counter_inD2 == word_count+2) next_state = CAL;
            else next_state = IN_DATA2;
        end
        CAL:begin//4
            if(act_in[counter_act] == 4 || act_in[counter_act] == 5 || (act_in[counter_act] == 6 && counter_cal==257)  || (act_in[counter_act] == 7 && counter_cal==257) || (act_in[counter_act] == 3 && counter_cal==65)) next_state = STORE;
            else next_state = CAL;
        end
        STORE:begin//5
            if(counter_act == counter_in2) next_state = OUT;
            else next_state = CAL;
        end
        OUT:begin//6
            if(counter_set == 8 && counter_out == 16 && image_size_in==0) next_state = IDLE;
            else if(counter_set == 8 && counter_out == 64 && image_size_in==1) next_state = IDLE;
            else if(counter_set == 8 && counter_out == 256 && image_size_in==2) next_state = IDLE;
            else if(counter_set < 8 && counter_out == 16 && image_size_in==0) next_state = WAIT;
            else if(counter_set < 8 && counter_out == 64 && image_size_in==1) next_state = WAIT;
            else if(counter_set < 8 && counter_out == 256 && image_size_in==2) next_state = WAIT;
            else next_state = OUT;
        end
        default:next_state = IDLE;
	endcase
end


//==================================================================
// counter design
//==================================================================

//==================================================================
// design
//==================================================================


always @(posedge clk or negedge rst_n) begin//counter
    if(!rst_n) counter <= 0;
    else if(in_valid) counter <= counter + 1;
    else if(current_state==IN_DATA || current_state==WAIT) counter <= counter + 1;
    else if(current_state==IDLE) counter <= 0;
end

always @(posedge clk or negedge rst_n) begin//counter_in2
    if(!rst_n) counter_in2 <= 0;
    else if(in_valid2) counter_in2 <= counter_in2 + 1;
    else if(current_state==OUT) counter_in2 <= 0;
    else if(current_state==IDLE) counter_in2 <= 0;
end

always @(posedge clk or negedge rst_n) begin//counter_inD2
    if(!rst_n) counter_inD2 <= 0;
    else if(current_state==WAIT) counter_inD2 <= 0;
    else if(current_state==IN_DATA2) counter_inD2 <= counter_inD2 + 1;
    else if(current_state==IDLE) counter_inD2 <= 0;
end

always @(posedge clk or negedge rst_n) begin//counter_cal
    if(!rst_n) counter_cal <= 0;
    else if(current_state==CAL) counter_cal <= counter_cal + 1;
    else if(current_state==STORE) counter_cal <= 0;
    else if(current_state==IDLE) counter_cal <= 0;
end


always @(posedge clk or negedge rst_n) begin//counter_inD2
    if(!rst_n) counter_inD2_seq <= 0;
    else counter_inD2_seq <= counter_inD2;
end

always @(posedge clk or negedge rst_n) begin//counter_act
    if(!rst_n) counter_act <= 1;
    else if(current_state == CAL && next_state == STORE) counter_act <= counter_act + 1;
    else if(current_state==IN_DATA2) counter_act <= 1;
end

always @(posedge clk or negedge rst_n) begin//counter_set
    if(!rst_n) counter_set <= 0;
    else if(current_state == IN_DATA2 && next_state == CAL) counter_set <= counter_set + 1;
    else if(current_state==IDLE) counter_set <= 0;
end


always @(posedge clk or negedge rst_n) begin//counter_RGB
    if(!rst_n) counter_RGB <= 0;
    else if(counter_RGB==2) counter_RGB <= 0;
    else if((in_valid || next_state == WAIT)&& counter_RGB<=2) counter_RGB <= counter_RGB + 1;
    else if(current_state==IDLE) counter_RGB <= 0;
end

always @(posedge clk or negedge rst_n) begin//counter_out
    if(!rst_n) counter_out <= 0;
    else if(current_state == IN_DATA2) counter_out <= 0;
    else if(counter_out_bit == 19) counter_out <= counter_out + 1;
    else if(current_state == IDLE) counter_out <= 0;
end

always @(posedge clk or negedge rst_n) begin//counter_out
    if(!rst_n) counter_out_bit <= 0;
    else if(current_state == IN_DATA2) counter_out_bit <= 0;
    else if(counter_out_bit == 19) counter_out_bit <= 0;
    else if(current_state == OUT && counter_out_bit<=19) counter_out_bit <= counter_out_bit + 1;
    else if(current_state == IDLE) counter_out_bit <= 0;
end

always @ (posedge clk or negedge rst_n) begin 
	if (!rst_n) word_count <= 0 ;
    else if(current_state == IDLE) word_count <= 0;
	else if (image_size_in==0 && current_state == IN_DATA && counter_RGB == 0 && word_count<15) word_count <= word_count + 1;
    else if (image_size_in==1 && current_state == IN_DATA && counter_RGB == 0 && word_count<63) word_count <= word_count + 1;
    else if (image_size_in==2 && current_state == IN_DATA && counter_RGB == 0 && word_count<255) word_count <= word_count + 1;
end

//==================================================================
// design
//==================================================================
always @(posedge clk or negedge rst_n) begin//image_size
    if(!rst_n) image_size_in <= 0;
    else if(act_in[counter_act] == 3 && image_size_in == 2 && next_state==STORE) image_size_in <= 1;
    else if(act_in[counter_act] == 3 && image_size_in == 1 && next_state==STORE) image_size_in <= 0;
    else if (next_state == WAIT) image_size_in <= image_size_not;
    else if (next_state == IN_DATA && current_state == IDLE) image_size_in <= image_size;
end

always @(posedge clk or negedge rst_n) begin//image_size
    if(!rst_n) image_size_not <= 0;
    else if (next_state == IN_DATA && current_state == IDLE) image_size_not <= image_size;
end

always @(posedge clk or negedge rst_n) begin//temp_in
    if(!rst_n) begin
        for(i = 0; i < 8; i = i + 1) begin
            for(j = 0; j < 8; j = j + 1) begin
                template_in[i][j] <= 0; 
            end   
        end
    end
    else if(in_valid)begin
        case(counter)
            0  : template_in[0][0] <= template;
            1  : template_in[0][1] <= template;
            2  : template_in[0][2] <= template;
            3  : template_in[1][0] <= template;
            4  : template_in[1][1] <= template;
            5  : template_in[1][2] <= template;
            6  : template_in[2][0] <= template;
            7  : template_in[2][1] <= template;
            8  : template_in[2][2] <= template;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin//act_in
    if(!rst_n) begin
        for(i = 0; i < 8; i = i + 1) begin
            act_in[i] <= 0; 
        end
    end
    else if(in_valid2)begin
        case(counter_in2)
            0  : act_in[0] <= action;
            1  : act_in[1] <= action;
            2  : act_in[2] <= action;
            3  : act_in[3] <= action;
            4  : act_in[4] <= action;
            5  : act_in[5] <= action;
            6  : act_in[6] <= action;
            7  : act_in[7] <= action;
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin //img_in
    if (!rst_n)begin
        img_R <= 0;
        img_G <= 0;
        img_B <= 0;
    end
    else if(next_state==IN_DATA)begin
        case(counter_RGB)
            0:begin//0
                img_R <= image;
            end
            1:begin//1
                img_G <= image;
            end
            2:begin//2
                img_B <= image;
            end
            default:begin
                img_R <= img_R;
                img_G <= img_G;
                img_B <= img_B;
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin//map
    if(!rst_n) begin
        for(i = 0; i < 18; i = i + 1) begin
            for(j = 0; j < 18; j = j + 1) begin
                cal_map[i][j] <= 0;
            end
        end
    end
    else if(next_state == IDLE || current_state == WAIT) begin
        for(i = 0; i < 18; i = i + 1) begin
            for(j = 0; j < 18; j = j + 1) begin
                cal_map[i][j] <= 0;
            end
        end
    end
    else if(current_state == IN_DATA2 && act_in[0] == 0 && image_size_in == 0)begin
        case(counter_inD2)
            2  : cal_map[1][1] <= sram_g0_out;
            3  : cal_map[1][2] <= sram_g0_out;
            4  : cal_map[1][3] <= sram_g0_out;
            5  : cal_map[1][4] <= sram_g0_out;
            6  : cal_map[2][1] <= sram_g0_out;
            7  : cal_map[2][2] <= sram_g0_out;
            8  : cal_map[2][3] <= sram_g0_out;
            9  : cal_map[2][4] <= sram_g0_out;
            10 : cal_map[3][1] <= sram_g0_out;
            11 : cal_map[3][2] <= sram_g0_out;
            12 : cal_map[3][3] <= sram_g0_out;
            13 : cal_map[3][4] <= sram_g0_out;
            14 : cal_map[4][1] <= sram_g0_out;
            15 : cal_map[4][2] <= sram_g0_out;
            16 : cal_map[4][3] <= sram_g0_out;
            17 : cal_map[4][4] <= sram_g0_out;
        endcase
    end
    else if(current_state == IN_DATA2 && act_in[0] == 1 && image_size_in == 0)begin
        case(counter_inD2)
            2  : cal_map[1][1] <= sram_g1_out;
            3  : cal_map[1][2] <= sram_g1_out;
            4  : cal_map[1][3] <= sram_g1_out;
            5  : cal_map[1][4] <= sram_g1_out;
            6  : cal_map[2][1] <= sram_g1_out;
            7  : cal_map[2][2] <= sram_g1_out;
            8  : cal_map[2][3] <= sram_g1_out;
            9  : cal_map[2][4] <= sram_g1_out;
            10 : cal_map[3][1] <= sram_g1_out;
            11 : cal_map[3][2] <= sram_g1_out;
            12 : cal_map[3][3] <= sram_g1_out;
            13 : cal_map[3][4] <= sram_g1_out;
            14 : cal_map[4][1] <= sram_g1_out;
            15 : cal_map[4][2] <= sram_g1_out;
            16 : cal_map[4][3] <= sram_g1_out;
            17 : cal_map[4][4] <= sram_g1_out;
        endcase
    end
    else if(current_state == IN_DATA2 && act_in[0] == 2 && image_size_in == 0)begin
        case(counter_inD2)
            2  : cal_map[1][1] <= sram_g2_out;
            3  : cal_map[1][2] <= sram_g2_out;
            4  : cal_map[1][3] <= sram_g2_out;
            5  : cal_map[1][4] <= sram_g2_out;
            6  : cal_map[2][1] <= sram_g2_out;
            7  : cal_map[2][2] <= sram_g2_out;
            8  : cal_map[2][3] <= sram_g2_out;
            9  : cal_map[2][4] <= sram_g2_out;
            10 : cal_map[3][1] <= sram_g2_out;
            11 : cal_map[3][2] <= sram_g2_out;
            12 : cal_map[3][3] <= sram_g2_out;
            13 : cal_map[3][4] <= sram_g2_out;
            14 : cal_map[4][1] <= sram_g2_out;
            15 : cal_map[4][2] <= sram_g2_out;
            16 : cal_map[4][3] <= sram_g2_out;
            17 : cal_map[4][4] <= sram_g2_out;
        endcase
    end
    else if(current_state == IN_DATA2 && act_in[0] == 0 && image_size_in == 1)begin
        case(counter_inD2)
            2  : cal_map[1][1] <= sram_g0_out;
            3  : cal_map[1][2] <= sram_g0_out;
            4  : cal_map[1][3] <= sram_g0_out;
            5  : cal_map[1][4] <= sram_g0_out;
            6  : cal_map[1][5] <= sram_g0_out;
            7  : cal_map[1][6] <= sram_g0_out;
            8  : cal_map[1][7] <= sram_g0_out;
            9  : cal_map[1][8] <= sram_g0_out;
            10 : cal_map[2][1] <= sram_g0_out;
            11 : cal_map[2][2] <= sram_g0_out;
            12 : cal_map[2][3] <= sram_g0_out;
            13 : cal_map[2][4] <= sram_g0_out;
            14 : cal_map[2][5] <= sram_g0_out;
            15 : cal_map[2][6] <= sram_g0_out;
            16 : cal_map[2][7] <= sram_g0_out;
            17 : cal_map[2][8] <= sram_g0_out;
            18 : cal_map[3][1] <= sram_g0_out;
            19 : cal_map[3][2] <= sram_g0_out;
            20 : cal_map[3][3] <= sram_g0_out;
            21 : cal_map[3][4] <= sram_g0_out;
            22 : cal_map[3][5] <= sram_g0_out;
            23 : cal_map[3][6] <= sram_g0_out;
            24 : cal_map[3][7] <= sram_g0_out;
            25 : cal_map[3][8] <= sram_g0_out;
            26 : cal_map[4][1] <= sram_g0_out;
            27 : cal_map[4][2] <= sram_g0_out;
            28 : cal_map[4][3] <= sram_g0_out;
            29 : cal_map[4][4] <= sram_g0_out;
            30 : cal_map[4][5] <= sram_g0_out;
            31 : cal_map[4][6] <= sram_g0_out;
            32 : cal_map[4][7] <= sram_g0_out;
            33 : cal_map[4][8] <= sram_g0_out;
            34 : cal_map[5][1] <= sram_g0_out;
            35 : cal_map[5][2] <= sram_g0_out;
            36 : cal_map[5][3] <= sram_g0_out;
            37 : cal_map[5][4] <= sram_g0_out;
            38 : cal_map[5][5] <= sram_g0_out;
            39 : cal_map[5][6] <= sram_g0_out;
            40 : cal_map[5][7] <= sram_g0_out;
            41 : cal_map[5][8] <= sram_g0_out;
            42 : cal_map[6][1] <= sram_g0_out;
            43 : cal_map[6][2] <= sram_g0_out;
            44 : cal_map[6][3] <= sram_g0_out;
            45 : cal_map[6][4] <= sram_g0_out;
            46 : cal_map[6][5] <= sram_g0_out;
            47 : cal_map[6][6] <= sram_g0_out;
            48 : cal_map[6][7] <= sram_g0_out;
            49 : cal_map[6][8] <= sram_g0_out;
            50 : cal_map[7][1] <= sram_g0_out;
            51 : cal_map[7][2] <= sram_g0_out;
            52 : cal_map[7][3] <= sram_g0_out;
            53 : cal_map[7][4] <= sram_g0_out;
            54 : cal_map[7][5] <= sram_g0_out;
            55 : cal_map[7][6] <= sram_g0_out;
            56 : cal_map[7][7] <= sram_g0_out;
            57 : cal_map[7][8] <= sram_g0_out;
            58 : cal_map[8][1] <= sram_g0_out;
            59 : cal_map[8][2] <= sram_g0_out;
            60 : cal_map[8][3] <= sram_g0_out;
            61 : cal_map[8][4] <= sram_g0_out;
            62 : cal_map[8][5] <= sram_g0_out;
            63 : cal_map[8][6] <= sram_g0_out;
            64 : cal_map[8][7] <= sram_g0_out;
            65 : cal_map[8][8] <= sram_g0_out;
        endcase
    end
    else if(current_state == IN_DATA2 && act_in[0] == 1 && image_size_in == 1)begin
        case(counter_inD2)
            2  : cal_map[1][1] <= sram_g1_out;
            3  : cal_map[1][2] <= sram_g1_out;
            4  : cal_map[1][3] <= sram_g1_out;
            5  : cal_map[1][4] <= sram_g1_out;
            6  : cal_map[1][5] <= sram_g1_out;
            7  : cal_map[1][6] <= sram_g1_out;
            8  : cal_map[1][7] <= sram_g1_out;
            9  : cal_map[1][8] <= sram_g1_out;
            10 : cal_map[2][1] <= sram_g1_out;
            11 : cal_map[2][2] <= sram_g1_out;
            12 : cal_map[2][3] <= sram_g1_out;
            13 : cal_map[2][4] <= sram_g1_out;
            14 : cal_map[2][5] <= sram_g1_out;
            15 : cal_map[2][6] <= sram_g1_out;
            16 : cal_map[2][7] <= sram_g1_out;
            17 : cal_map[2][8] <= sram_g1_out;
            18 : cal_map[3][1] <= sram_g1_out;
            19 : cal_map[3][2] <= sram_g1_out;
            20 : cal_map[3][3] <= sram_g1_out;
            21 : cal_map[3][4] <= sram_g1_out;
            22 : cal_map[3][5] <= sram_g1_out;
            23 : cal_map[3][6] <= sram_g1_out;
            24 : cal_map[3][7] <= sram_g1_out;
            25 : cal_map[3][8] <= sram_g1_out;
            26 : cal_map[4][1] <= sram_g1_out;
            27 : cal_map[4][2] <= sram_g1_out;
            28 : cal_map[4][3] <= sram_g1_out;
            29 : cal_map[4][4] <= sram_g1_out;
            30 : cal_map[4][5] <= sram_g1_out;
            31 : cal_map[4][6] <= sram_g1_out;
            32 : cal_map[4][7] <= sram_g1_out;
            33 : cal_map[4][8] <= sram_g1_out;
            34 : cal_map[5][1] <= sram_g1_out;
            35 : cal_map[5][2] <= sram_g1_out;
            36 : cal_map[5][3] <= sram_g1_out;
            37 : cal_map[5][4] <= sram_g1_out;
            38 : cal_map[5][5] <= sram_g1_out;
            39 : cal_map[5][6] <= sram_g1_out;
            40 : cal_map[5][7] <= sram_g1_out;
            41 : cal_map[5][8] <= sram_g1_out;
            42 : cal_map[6][1] <= sram_g1_out;
            43 : cal_map[6][2] <= sram_g1_out;
            44 : cal_map[6][3] <= sram_g1_out;
            45 : cal_map[6][4] <= sram_g1_out;
            46 : cal_map[6][5] <= sram_g1_out;
            47 : cal_map[6][6] <= sram_g1_out;
            48 : cal_map[6][7] <= sram_g1_out;
            49 : cal_map[6][8] <= sram_g1_out;
            50 : cal_map[7][1] <= sram_g1_out;
            51 : cal_map[7][2] <= sram_g1_out;
            52 : cal_map[7][3] <= sram_g1_out;
            53 : cal_map[7][4] <= sram_g1_out;
            54 : cal_map[7][5] <= sram_g1_out;
            55 : cal_map[7][6] <= sram_g1_out;
            56 : cal_map[7][7] <= sram_g1_out;
            57 : cal_map[7][8] <= sram_g1_out;
            58 : cal_map[8][1] <= sram_g1_out;
            59 : cal_map[8][2] <= sram_g1_out;
            60 : cal_map[8][3] <= sram_g1_out;
            61 : cal_map[8][4] <= sram_g1_out;
            62 : cal_map[8][5] <= sram_g1_out;
            63 : cal_map[8][6] <= sram_g1_out;
            64 : cal_map[8][7] <= sram_g1_out;
            65 : cal_map[8][8] <= sram_g1_out;
        endcase
    end
    else if(current_state == IN_DATA2 && act_in[0] == 2 && image_size_in == 1)begin
        case(counter_inD2)
            2  : cal_map[1][1] <= sram_g2_out;
            3  : cal_map[1][2] <= sram_g2_out;
            4  : cal_map[1][3] <= sram_g2_out;
            5  : cal_map[1][4] <= sram_g2_out;
            6  : cal_map[1][5] <= sram_g2_out;
            7  : cal_map[1][6] <= sram_g2_out;
            8  : cal_map[1][7] <= sram_g2_out;
            9  : cal_map[1][8] <= sram_g2_out;
            10 : cal_map[2][1] <= sram_g2_out;
            11 : cal_map[2][2] <= sram_g2_out;
            12 : cal_map[2][3] <= sram_g2_out;
            13 : cal_map[2][4] <= sram_g2_out;
            14 : cal_map[2][5] <= sram_g2_out;
            15 : cal_map[2][6] <= sram_g2_out;
            16 : cal_map[2][7] <= sram_g2_out;
            17 : cal_map[2][8] <= sram_g2_out;
            18 : cal_map[3][1] <= sram_g2_out;
            19 : cal_map[3][2] <= sram_g2_out;
            20 : cal_map[3][3] <= sram_g2_out;
            21 : cal_map[3][4] <= sram_g2_out;
            22 : cal_map[3][5] <= sram_g2_out;
            23 : cal_map[3][6] <= sram_g2_out;
            24 : cal_map[3][7] <= sram_g2_out;
            25 : cal_map[3][8] <= sram_g2_out;
            26 : cal_map[4][1] <= sram_g2_out;
            27 : cal_map[4][2] <= sram_g2_out;
            28 : cal_map[4][3] <= sram_g2_out;
            29 : cal_map[4][4] <= sram_g2_out;
            30 : cal_map[4][5] <= sram_g2_out;
            31 : cal_map[4][6] <= sram_g2_out;
            32 : cal_map[4][7] <= sram_g2_out;
            33 : cal_map[4][8] <= sram_g2_out;
            34 : cal_map[5][1] <= sram_g2_out;
            35 : cal_map[5][2] <= sram_g2_out;
            36 : cal_map[5][3] <= sram_g2_out;
            37 : cal_map[5][4] <= sram_g2_out;
            38 : cal_map[5][5] <= sram_g2_out;
            39 : cal_map[5][6] <= sram_g2_out;
            40 : cal_map[5][7] <= sram_g2_out;
            41 : cal_map[5][8] <= sram_g2_out;
            42 : cal_map[6][1] <= sram_g2_out;
            43 : cal_map[6][2] <= sram_g2_out;
            44 : cal_map[6][3] <= sram_g2_out;
            45 : cal_map[6][4] <= sram_g2_out;
            46 : cal_map[6][5] <= sram_g2_out;
            47 : cal_map[6][6] <= sram_g2_out;
            48 : cal_map[6][7] <= sram_g2_out;
            49 : cal_map[6][8] <= sram_g2_out;
            50 : cal_map[7][1] <= sram_g2_out;
            51 : cal_map[7][2] <= sram_g2_out;
            52 : cal_map[7][3] <= sram_g2_out;
            53 : cal_map[7][4] <= sram_g2_out;
            54 : cal_map[7][5] <= sram_g2_out;
            55 : cal_map[7][6] <= sram_g2_out;
            56 : cal_map[7][7] <= sram_g2_out;
            57 : cal_map[7][8] <= sram_g2_out;
            58 : cal_map[8][1] <= sram_g2_out;
            59 : cal_map[8][2] <= sram_g2_out;
            60 : cal_map[8][3] <= sram_g2_out;
            61 : cal_map[8][4] <= sram_g2_out;
            62 : cal_map[8][5] <= sram_g2_out;
            63 : cal_map[8][6] <= sram_g2_out;
            64 : cal_map[8][7] <= sram_g2_out;
            65 : cal_map[8][8] <= sram_g2_out;
        endcase
    end
    else if(current_state == IN_DATA2 && act_in[0] == 0 && image_size_in == 2)begin
        case(counter_inD2)
            2  : cal_map[1][1] <= sram_g0_out;
            3  : cal_map[1][2] <= sram_g0_out;
            4  : cal_map[1][3] <= sram_g0_out;
            5  : cal_map[1][4] <= sram_g0_out;
            6  : cal_map[1][5] <= sram_g0_out;
            7  : cal_map[1][6] <= sram_g0_out;
            8  : cal_map[1][7] <= sram_g0_out;
            9  : cal_map[1][8] <= sram_g0_out;
            10 : cal_map[1][9] <= sram_g0_out;
            11 : cal_map[1][10] <= sram_g0_out;
            12 : cal_map[1][11] <= sram_g0_out;
            13 : cal_map[1][12] <= sram_g0_out;
            14 : cal_map[1][13] <= sram_g0_out;
            15 : cal_map[1][14] <= sram_g0_out;
            16 : cal_map[1][15] <= sram_g0_out;
            17 : cal_map[1][16] <= sram_g0_out;
            18 : cal_map[2][1] <= sram_g0_out;
            19 : cal_map[2][2] <= sram_g0_out;
            20 : cal_map[2][3] <= sram_g0_out;
            21 : cal_map[2][4] <= sram_g0_out;
            22 : cal_map[2][5] <= sram_g0_out;
            23 : cal_map[2][6] <= sram_g0_out;
            24 : cal_map[2][7] <= sram_g0_out;
            25 : cal_map[2][8] <= sram_g0_out;
            26 : cal_map[2][9] <= sram_g0_out;
            27 : cal_map[2][10] <= sram_g0_out;
            28 : cal_map[2][11] <= sram_g0_out;
            29 : cal_map[2][12] <= sram_g0_out;
            30 : cal_map[2][13] <= sram_g0_out;
            31 : cal_map[2][14] <= sram_g0_out;
            32 : cal_map[2][15] <= sram_g0_out;
            33 : cal_map[2][16] <= sram_g0_out;
            34 : cal_map[3][1] <= sram_g0_out;
            35 : cal_map[3][2] <= sram_g0_out;
            36 : cal_map[3][3] <= sram_g0_out;
            37 : cal_map[3][4] <= sram_g0_out;
            38 : cal_map[3][5] <= sram_g0_out;
            39 : cal_map[3][6] <= sram_g0_out;
            40 : cal_map[3][7] <= sram_g0_out;
            41 : cal_map[3][8] <= sram_g0_out;
            42 : cal_map[3][9] <= sram_g0_out;
            43 : cal_map[3][10] <= sram_g0_out;
            44 : cal_map[3][11] <= sram_g0_out;
            45 : cal_map[3][12] <= sram_g0_out;
            46 : cal_map[3][13] <= sram_g0_out;
            47 : cal_map[3][14] <= sram_g0_out;
            48 : cal_map[3][15] <= sram_g0_out;
            49 : cal_map[3][16] <= sram_g0_out;
            50 : cal_map[4][1] <= sram_g0_out;
            51 : cal_map[4][2] <= sram_g0_out;
            52 : cal_map[4][3] <= sram_g0_out;
            53 : cal_map[4][4] <= sram_g0_out;
            54 : cal_map[4][5] <= sram_g0_out;
            55 : cal_map[4][6] <= sram_g0_out;
            56 : cal_map[4][7] <= sram_g0_out;
            57 : cal_map[4][8] <= sram_g0_out;
            58 : cal_map[4][9] <= sram_g0_out;
            59 : cal_map[4][10] <= sram_g0_out;
            60 : cal_map[4][11] <= sram_g0_out;
            61 : cal_map[4][12] <= sram_g0_out;
            62 : cal_map[4][13] <= sram_g0_out;
            63 : cal_map[4][14] <= sram_g0_out;
            64 : cal_map[4][15] <= sram_g0_out;
            65 : cal_map[4][16] <= sram_g0_out;
            66 : cal_map[5][1] <= sram_g0_out;
            67 : cal_map[5][2] <= sram_g0_out;
            68 : cal_map[5][3] <= sram_g0_out;
            69 : cal_map[5][4] <= sram_g0_out;
            70 : cal_map[5][5] <= sram_g0_out;
            71 : cal_map[5][6] <= sram_g0_out;
            72 : cal_map[5][7] <= sram_g0_out;
            73 : cal_map[5][8] <= sram_g0_out;
            74 : cal_map[5][9] <= sram_g0_out;
            75 : cal_map[5][10] <= sram_g0_out;
            76 : cal_map[5][11] <= sram_g0_out;
            77 : cal_map[5][12] <= sram_g0_out;
            78 : cal_map[5][13] <= sram_g0_out;
            79 : cal_map[5][14] <= sram_g0_out;
            80 : cal_map[5][15] <= sram_g0_out;
            81 : cal_map[5][16] <= sram_g0_out;
            82 : cal_map[6][1] <= sram_g0_out;
            83 : cal_map[6][2] <= sram_g0_out;
            84 : cal_map[6][3] <= sram_g0_out;
            85 : cal_map[6][4] <= sram_g0_out;
            86 : cal_map[6][5] <= sram_g0_out;
            87 : cal_map[6][6] <= sram_g0_out;
            88 : cal_map[6][7] <= sram_g0_out;
            89 : cal_map[6][8] <= sram_g0_out;
            90 : cal_map[6][9] <= sram_g0_out;
            91 : cal_map[6][10] <= sram_g0_out;
            92 : cal_map[6][11] <= sram_g0_out;
            93 : cal_map[6][12] <= sram_g0_out;
            94 : cal_map[6][13] <= sram_g0_out;
            95 : cal_map[6][14] <= sram_g0_out;
            96 : cal_map[6][15] <= sram_g0_out;
            97 : cal_map[6][16] <= sram_g0_out;
            98 : cal_map[7][1] <= sram_g0_out;
            99 : cal_map[7][2] <= sram_g0_out;
            100 : cal_map[7][3] <= sram_g0_out;
            101 : cal_map[7][4] <= sram_g0_out;
            102 : cal_map[7][5] <= sram_g0_out;
            103 : cal_map[7][6] <= sram_g0_out;
            104 : cal_map[7][7] <= sram_g0_out;
            105 : cal_map[7][8] <= sram_g0_out;
            106 : cal_map[7][9] <= sram_g0_out;
            107 : cal_map[7][10] <= sram_g0_out;
            108 : cal_map[7][11] <= sram_g0_out;
            109 : cal_map[7][12] <= sram_g0_out;
            110 : cal_map[7][13] <= sram_g0_out;
            111 : cal_map[7][14] <= sram_g0_out;
            112 : cal_map[7][15] <= sram_g0_out;
            113 : cal_map[7][16] <= sram_g0_out;
            114 : cal_map[8][1] <= sram_g0_out;
            115 : cal_map[8][2] <= sram_g0_out;
            116 : cal_map[8][3] <= sram_g0_out;
            117 : cal_map[8][4] <= sram_g0_out;
            118 : cal_map[8][5] <= sram_g0_out;
            119 : cal_map[8][6] <= sram_g0_out;
            120 : cal_map[8][7] <= sram_g0_out;
            121 : cal_map[8][8] <= sram_g0_out;
            122 : cal_map[8][9] <= sram_g0_out;
            123 : cal_map[8][10] <= sram_g0_out;
            124 : cal_map[8][11] <= sram_g0_out;
            125 : cal_map[8][12] <= sram_g0_out;
            126 : cal_map[8][13] <= sram_g0_out;
            127 : cal_map[8][14] <= sram_g0_out;
            128 : cal_map[8][15] <= sram_g0_out;
            129 : cal_map[8][16] <= sram_g0_out;
            130 : cal_map[9][1] <= sram_g0_out;
            131 : cal_map[9][2] <= sram_g0_out;
            132 : cal_map[9][3] <= sram_g0_out;
            133 : cal_map[9][4] <= sram_g0_out;
            134 : cal_map[9][5] <= sram_g0_out;
            135 : cal_map[9][6] <= sram_g0_out;
            136 : cal_map[9][7] <= sram_g0_out;
            137 : cal_map[9][8] <= sram_g0_out;
            138 : cal_map[9][9] <= sram_g0_out;
            139 : cal_map[9][10] <= sram_g0_out;
            140 : cal_map[9][11] <= sram_g0_out;
            141 : cal_map[9][12] <= sram_g0_out;
            142 : cal_map[9][13] <= sram_g0_out;
            143 : cal_map[9][14] <= sram_g0_out;
            144 : cal_map[9][15] <= sram_g0_out;
            145 : cal_map[9][16] <= sram_g0_out;
            146 : cal_map[10][1] <= sram_g0_out;
            147 : cal_map[10][2] <= sram_g0_out;
            148 : cal_map[10][3] <= sram_g0_out;
            149 : cal_map[10][4] <= sram_g0_out;
            150 : cal_map[10][5] <= sram_g0_out;
            151 : cal_map[10][6] <= sram_g0_out;
            152 : cal_map[10][7] <= sram_g0_out;
            153 : cal_map[10][8] <= sram_g0_out;
            154 : cal_map[10][9] <= sram_g0_out;
            155 : cal_map[10][10] <= sram_g0_out;
            156 : cal_map[10][11] <= sram_g0_out;
            157 : cal_map[10][12] <= sram_g0_out;
            158 : cal_map[10][13] <= sram_g0_out;
            159 : cal_map[10][14] <= sram_g0_out;
            160 : cal_map[10][15] <= sram_g0_out;
            161 : cal_map[10][16] <= sram_g0_out;
            162 : cal_map[11][1] <= sram_g0_out;
            163 : cal_map[11][2] <= sram_g0_out;
            164 : cal_map[11][3] <= sram_g0_out;
            165 : cal_map[11][4] <= sram_g0_out;
            166 : cal_map[11][5] <= sram_g0_out;
            167 : cal_map[11][6] <= sram_g0_out;
            168 : cal_map[11][7] <= sram_g0_out;
            169 : cal_map[11][8] <= sram_g0_out;
            170 : cal_map[11][9] <= sram_g0_out;
            171 : cal_map[11][10] <= sram_g0_out;
            172 : cal_map[11][11] <= sram_g0_out;
            173 : cal_map[11][12] <= sram_g0_out;
            174 : cal_map[11][13] <= sram_g0_out;
            175 : cal_map[11][14] <= sram_g0_out;
            176 : cal_map[11][15] <= sram_g0_out;
            177 : cal_map[11][16] <= sram_g0_out;
            178 : cal_map[12][1] <= sram_g0_out;
            179 : cal_map[12][2] <= sram_g0_out;
            180 : cal_map[12][3] <= sram_g0_out;
            181 : cal_map[12][4] <= sram_g0_out;
            182 : cal_map[12][5] <= sram_g0_out;
            183 : cal_map[12][6] <= sram_g0_out;
            184 : cal_map[12][7] <= sram_g0_out;
            185 : cal_map[12][8] <= sram_g0_out;
            186 : cal_map[12][9] <= sram_g0_out;
            187 : cal_map[12][10] <= sram_g0_out;
            188 : cal_map[12][11] <= sram_g0_out;
            189 : cal_map[12][12] <= sram_g0_out;
            190 : cal_map[12][13] <= sram_g0_out;
            191 : cal_map[12][14] <= sram_g0_out;
            192 : cal_map[12][15] <= sram_g0_out;
            193 : cal_map[12][16] <= sram_g0_out;
            194 : cal_map[13][1] <= sram_g0_out;
            195 : cal_map[13][2] <= sram_g0_out;
            196 : cal_map[13][3] <= sram_g0_out;
            197 : cal_map[13][4] <= sram_g0_out;
            198 : cal_map[13][5] <= sram_g0_out;
            199 : cal_map[13][6] <= sram_g0_out;
            200 : cal_map[13][7] <= sram_g0_out;
            201 : cal_map[13][8] <= sram_g0_out;
            202 : cal_map[13][9] <= sram_g0_out;
            203 : cal_map[13][10] <= sram_g0_out;
            204 : cal_map[13][11] <= sram_g0_out;
            205 : cal_map[13][12] <= sram_g0_out;
            206 : cal_map[13][13] <= sram_g0_out;
            207 : cal_map[13][14] <= sram_g0_out;
            208 : cal_map[13][15] <= sram_g0_out;
            209 : cal_map[13][16] <= sram_g0_out;
            210 : cal_map[14][1] <= sram_g0_out;
            211 : cal_map[14][2] <= sram_g0_out;
            212 : cal_map[14][3] <= sram_g0_out;
            213 : cal_map[14][4] <= sram_g0_out;
            214 : cal_map[14][5] <= sram_g0_out;
            215 : cal_map[14][6] <= sram_g0_out;
            216 : cal_map[14][7] <= sram_g0_out;
            217 : cal_map[14][8] <= sram_g0_out;
            218 : cal_map[14][9] <= sram_g0_out;
            219 : cal_map[14][10] <= sram_g0_out;
            220 : cal_map[14][11] <= sram_g0_out;
            221 : cal_map[14][12] <= sram_g0_out;
            222 : cal_map[14][13] <= sram_g0_out;
            223 : cal_map[14][14] <= sram_g0_out;
            224 : cal_map[14][15] <= sram_g0_out;
            225 : cal_map[14][16] <= sram_g0_out;
            226 : cal_map[15][1] <= sram_g0_out;
            227 : cal_map[15][2] <= sram_g0_out;
            228 : cal_map[15][3] <= sram_g0_out;
            229 : cal_map[15][4] <= sram_g0_out;
            230 : cal_map[15][5] <= sram_g0_out;
            231 : cal_map[15][6] <= sram_g0_out;
            232 : cal_map[15][7] <= sram_g0_out;
            233 : cal_map[15][8] <= sram_g0_out;
            234 : cal_map[15][9] <= sram_g0_out;
            235 : cal_map[15][10] <= sram_g0_out;
            236 : cal_map[15][11] <= sram_g0_out;
            237 : cal_map[15][12] <= sram_g0_out;
            238 : cal_map[15][13] <= sram_g0_out;
            239 : cal_map[15][14] <= sram_g0_out;
            240 : cal_map[15][15] <= sram_g0_out;
            241 : cal_map[15][16] <= sram_g0_out;
            242 : cal_map[16][1] <= sram_g0_out;
            243 : cal_map[16][2] <= sram_g0_out;
            244 : cal_map[16][3] <= sram_g0_out;
            245 : cal_map[16][4] <= sram_g0_out;
            246 : cal_map[16][5] <= sram_g0_out;
            247 : cal_map[16][6] <= sram_g0_out;
            248 : cal_map[16][7] <= sram_g0_out;
            249 : cal_map[16][8] <= sram_g0_out;
            250 : cal_map[16][9] <= sram_g0_out;
            251 : cal_map[16][10] <= sram_g0_out;
            252 : cal_map[16][11] <= sram_g0_out;
            253 : cal_map[16][12] <= sram_g0_out;
            254 : cal_map[16][13] <= sram_g0_out;
            255 : cal_map[16][14] <= sram_g0_out;
            256 : cal_map[16][15] <= sram_g0_out;
            257 : cal_map[16][16] <= sram_g0_out;
        endcase
    end
    else if(current_state == IN_DATA2 && act_in[0] == 1 && image_size_in == 2)begin
        case(counter_inD2)
            2  : cal_map[1][1] <= sram_g1_out;
            3  : cal_map[1][2] <= sram_g1_out;
            4  : cal_map[1][3] <= sram_g1_out;
            5  : cal_map[1][4] <= sram_g1_out;
            6  : cal_map[1][5] <= sram_g1_out;
            7  : cal_map[1][6] <= sram_g1_out;
            8  : cal_map[1][7] <= sram_g1_out;
            9  : cal_map[1][8] <= sram_g1_out;
            10 : cal_map[1][9] <= sram_g1_out;
            11 : cal_map[1][10] <= sram_g1_out;
            12 : cal_map[1][11] <= sram_g1_out;
            13 : cal_map[1][12] <= sram_g1_out;
            14 : cal_map[1][13] <= sram_g1_out;
            15 : cal_map[1][14] <= sram_g1_out;
            16 : cal_map[1][15] <= sram_g1_out;
            17 : cal_map[1][16] <= sram_g1_out;
            18 : cal_map[2][1] <= sram_g1_out;
            19 : cal_map[2][2] <= sram_g1_out;
            20 : cal_map[2][3] <= sram_g1_out;
            21 : cal_map[2][4] <= sram_g1_out;
            22 : cal_map[2][5] <= sram_g1_out;
            23 : cal_map[2][6] <= sram_g1_out;
            24 : cal_map[2][7] <= sram_g1_out;
            25 : cal_map[2][8] <= sram_g1_out;
            26 : cal_map[2][9] <= sram_g1_out;
            27 : cal_map[2][10] <= sram_g1_out;
            28 : cal_map[2][11] <= sram_g1_out;
            29 : cal_map[2][12] <= sram_g1_out;
            30 : cal_map[2][13] <= sram_g1_out;
            31 : cal_map[2][14] <= sram_g1_out;
            32 : cal_map[2][15] <= sram_g1_out;
            33 : cal_map[2][16] <= sram_g1_out;
            34 : cal_map[3][1] <= sram_g1_out;
            35 : cal_map[3][2] <= sram_g1_out;
            36 : cal_map[3][3] <= sram_g1_out;
            37 : cal_map[3][4] <= sram_g1_out;
            38 : cal_map[3][5] <= sram_g1_out;
            39 : cal_map[3][6] <= sram_g1_out;
            40 : cal_map[3][7] <= sram_g1_out;
            41 : cal_map[3][8] <= sram_g1_out;
            42 : cal_map[3][9] <= sram_g1_out;
            43 : cal_map[3][10] <= sram_g1_out;
            44 : cal_map[3][11] <= sram_g1_out;
            45 : cal_map[3][12] <= sram_g1_out;
            46 : cal_map[3][13] <= sram_g1_out;
            47 : cal_map[3][14] <= sram_g1_out;
            48 : cal_map[3][15] <= sram_g1_out;
            49 : cal_map[3][16] <= sram_g1_out;
            50 : cal_map[4][1] <= sram_g1_out;
            51 : cal_map[4][2] <= sram_g1_out;
            52 : cal_map[4][3] <= sram_g1_out;
            53 : cal_map[4][4] <= sram_g1_out;
            54 : cal_map[4][5] <= sram_g1_out;
            55 : cal_map[4][6] <= sram_g1_out;
            56 : cal_map[4][7] <= sram_g1_out;
            57 : cal_map[4][8] <= sram_g1_out;
            58 : cal_map[4][9] <= sram_g1_out;
            59 : cal_map[4][10] <= sram_g1_out;
            60 : cal_map[4][11] <= sram_g1_out;
            61 : cal_map[4][12] <= sram_g1_out;
            62 : cal_map[4][13] <= sram_g1_out;
            63 : cal_map[4][14] <= sram_g1_out;
            64 : cal_map[4][15] <= sram_g1_out;
            65 : cal_map[4][16] <= sram_g1_out;
            66 : cal_map[5][1] <= sram_g1_out;
            67 : cal_map[5][2] <= sram_g1_out;
            68 : cal_map[5][3] <= sram_g1_out;
            69 : cal_map[5][4] <= sram_g1_out;
            70 : cal_map[5][5] <= sram_g1_out;
            71 : cal_map[5][6] <= sram_g1_out;
            72 : cal_map[5][7] <= sram_g1_out;
            73 : cal_map[5][8] <= sram_g1_out;
            74 : cal_map[5][9] <= sram_g1_out;
            75 : cal_map[5][10] <= sram_g1_out;
            76 : cal_map[5][11] <= sram_g1_out;
            77 : cal_map[5][12] <= sram_g1_out;
            78 : cal_map[5][13] <= sram_g1_out;
            79 : cal_map[5][14] <= sram_g1_out;
            80 : cal_map[5][15] <= sram_g1_out;
            81 : cal_map[5][16] <= sram_g1_out;
            82 : cal_map[6][1] <= sram_g1_out;
            83 : cal_map[6][2] <= sram_g1_out;
            84 : cal_map[6][3] <= sram_g1_out;
            85 : cal_map[6][4] <= sram_g1_out;
            86 : cal_map[6][5] <= sram_g1_out;
            87 : cal_map[6][6] <= sram_g1_out;
            88 : cal_map[6][7] <= sram_g1_out;
            89 : cal_map[6][8] <= sram_g1_out;
            90 : cal_map[6][9] <= sram_g1_out;
            91 : cal_map[6][10] <= sram_g1_out;
            92 : cal_map[6][11] <= sram_g1_out;
            93 : cal_map[6][12] <= sram_g1_out;
            94 : cal_map[6][13] <= sram_g1_out;
            95 : cal_map[6][14] <= sram_g1_out;
            96 : cal_map[6][15] <= sram_g1_out;
            97 : cal_map[6][16] <= sram_g1_out;
            98 : cal_map[7][1] <= sram_g1_out;
            99 : cal_map[7][2] <= sram_g1_out;
            100 : cal_map[7][3] <= sram_g1_out;
            101 : cal_map[7][4] <= sram_g1_out;
            102 : cal_map[7][5] <= sram_g1_out;
            103 : cal_map[7][6] <= sram_g1_out;
            104 : cal_map[7][7] <= sram_g1_out;
            105 : cal_map[7][8] <= sram_g1_out;
            106 : cal_map[7][9] <= sram_g1_out;
            107 : cal_map[7][10] <= sram_g1_out;
            108 : cal_map[7][11] <= sram_g1_out;
            109 : cal_map[7][12] <= sram_g1_out;
            110 : cal_map[7][13] <= sram_g1_out;
            111 : cal_map[7][14] <= sram_g1_out;
            112 : cal_map[7][15] <= sram_g1_out;
            113 : cal_map[7][16] <= sram_g1_out;
            114 : cal_map[8][1] <= sram_g1_out;
            115 : cal_map[8][2] <= sram_g1_out;
            116 : cal_map[8][3] <= sram_g1_out;
            117 : cal_map[8][4] <= sram_g1_out;
            118 : cal_map[8][5] <= sram_g1_out;
            119 : cal_map[8][6] <= sram_g1_out;
            120 : cal_map[8][7] <= sram_g1_out;
            121 : cal_map[8][8] <= sram_g1_out;
            122 : cal_map[8][9] <= sram_g1_out;
            123 : cal_map[8][10] <= sram_g1_out;
            124 : cal_map[8][11] <= sram_g1_out;
            125 : cal_map[8][12] <= sram_g1_out;
            126 : cal_map[8][13] <= sram_g1_out;
            127 : cal_map[8][14] <= sram_g1_out;
            128 : cal_map[8][15] <= sram_g1_out;
            129 : cal_map[8][16] <= sram_g1_out;
            130 : cal_map[9][1] <= sram_g1_out;
            131 : cal_map[9][2] <= sram_g1_out;
            132 : cal_map[9][3] <= sram_g1_out;
            133 : cal_map[9][4] <= sram_g1_out;
            134 : cal_map[9][5] <= sram_g1_out;
            135 : cal_map[9][6] <= sram_g1_out;
            136 : cal_map[9][7] <= sram_g1_out;
            137 : cal_map[9][8] <= sram_g1_out;
            138 : cal_map[9][9] <= sram_g1_out;
            139 : cal_map[9][10] <= sram_g1_out;
            140 : cal_map[9][11] <= sram_g1_out;
            141 : cal_map[9][12] <= sram_g1_out;
            142 : cal_map[9][13] <= sram_g1_out;
            143 : cal_map[9][14] <= sram_g1_out;
            144 : cal_map[9][15] <= sram_g1_out;
            145 : cal_map[9][16] <= sram_g1_out;
            146 : cal_map[10][1] <= sram_g1_out;
            147 : cal_map[10][2] <= sram_g1_out;
            148 : cal_map[10][3] <= sram_g1_out;
            149 : cal_map[10][4] <= sram_g1_out;
            150 : cal_map[10][5] <= sram_g1_out;
            151 : cal_map[10][6] <= sram_g1_out;
            152 : cal_map[10][7] <= sram_g1_out;
            153 : cal_map[10][8] <= sram_g1_out;
            154 : cal_map[10][9] <= sram_g1_out;
            155 : cal_map[10][10] <= sram_g1_out;
            156 : cal_map[10][11] <= sram_g1_out;
            157 : cal_map[10][12] <= sram_g1_out;
            158 : cal_map[10][13] <= sram_g1_out;
            159 : cal_map[10][14] <= sram_g1_out;
            160 : cal_map[10][15] <= sram_g1_out;
            161 : cal_map[10][16] <= sram_g1_out;
            162 : cal_map[11][1] <= sram_g1_out;
            163 : cal_map[11][2] <= sram_g1_out;
            164 : cal_map[11][3] <= sram_g1_out;
            165 : cal_map[11][4] <= sram_g1_out;
            166 : cal_map[11][5] <= sram_g1_out;
            167 : cal_map[11][6] <= sram_g1_out;
            168 : cal_map[11][7] <= sram_g1_out;
            169 : cal_map[11][8] <= sram_g1_out;
            170 : cal_map[11][9] <= sram_g1_out;
            171 : cal_map[11][10] <= sram_g1_out;
            172 : cal_map[11][11] <= sram_g1_out;
            173 : cal_map[11][12] <= sram_g1_out;
            174 : cal_map[11][13] <= sram_g1_out;
            175 : cal_map[11][14] <= sram_g1_out;
            176 : cal_map[11][15] <= sram_g1_out;
            177 : cal_map[11][16] <= sram_g1_out;
            178 : cal_map[12][1] <= sram_g1_out;
            179 : cal_map[12][2] <= sram_g1_out;
            180 : cal_map[12][3] <= sram_g1_out;
            181 : cal_map[12][4] <= sram_g1_out;
            182 : cal_map[12][5] <= sram_g1_out;
            183 : cal_map[12][6] <= sram_g1_out;
            184 : cal_map[12][7] <= sram_g1_out;
            185 : cal_map[12][8] <= sram_g1_out;
            186 : cal_map[12][9] <= sram_g1_out;
            187 : cal_map[12][10] <= sram_g1_out;
            188 : cal_map[12][11] <= sram_g1_out;
            189 : cal_map[12][12] <= sram_g1_out;
            190 : cal_map[12][13] <= sram_g1_out;
            191 : cal_map[12][14] <= sram_g1_out;
            192 : cal_map[12][15] <= sram_g1_out;
            193 : cal_map[12][16] <= sram_g1_out;
            194 : cal_map[13][1] <= sram_g1_out;
            195 : cal_map[13][2] <= sram_g1_out;
            196 : cal_map[13][3] <= sram_g1_out;
            197 : cal_map[13][4] <= sram_g1_out;
            198 : cal_map[13][5] <= sram_g1_out;
            199 : cal_map[13][6] <= sram_g1_out;
            200 : cal_map[13][7] <= sram_g1_out;
            201 : cal_map[13][8] <= sram_g1_out;
            202 : cal_map[13][9] <= sram_g1_out;
            203 : cal_map[13][10] <= sram_g1_out;
            204 : cal_map[13][11] <= sram_g1_out;
            205 : cal_map[13][12] <= sram_g1_out;
            206 : cal_map[13][13] <= sram_g1_out;
            207 : cal_map[13][14] <= sram_g1_out;
            208 : cal_map[13][15] <= sram_g1_out;
            209 : cal_map[13][16] <= sram_g1_out;
            210 : cal_map[14][1] <= sram_g1_out;
            211 : cal_map[14][2] <= sram_g1_out;
            212 : cal_map[14][3] <= sram_g1_out;
            213 : cal_map[14][4] <= sram_g1_out;
            214 : cal_map[14][5] <= sram_g1_out;
            215 : cal_map[14][6] <= sram_g1_out;
            216 : cal_map[14][7] <= sram_g1_out;
            217 : cal_map[14][8] <= sram_g1_out;
            218 : cal_map[14][9] <= sram_g1_out;
            219 : cal_map[14][10] <= sram_g1_out;
            220 : cal_map[14][11] <= sram_g1_out;
            221 : cal_map[14][12] <= sram_g1_out;
            222 : cal_map[14][13] <= sram_g1_out;
            223 : cal_map[14][14] <= sram_g1_out;
            224 : cal_map[14][15] <= sram_g1_out;
            225 : cal_map[14][16] <= sram_g1_out;
            226 : cal_map[15][1] <= sram_g1_out;
            227 : cal_map[15][2] <= sram_g1_out;
            228 : cal_map[15][3] <= sram_g1_out;
            229 : cal_map[15][4] <= sram_g1_out;
            230 : cal_map[15][5] <= sram_g1_out;
            231 : cal_map[15][6] <= sram_g1_out;
            232 : cal_map[15][7] <= sram_g1_out;
            233 : cal_map[15][8] <= sram_g1_out;
            234 : cal_map[15][9] <= sram_g1_out;
            235 : cal_map[15][10] <= sram_g1_out;
            236 : cal_map[15][11] <= sram_g1_out;
            237 : cal_map[15][12] <= sram_g1_out;
            238 : cal_map[15][13] <= sram_g1_out;
            239 : cal_map[15][14] <= sram_g1_out;
            240 : cal_map[15][15] <= sram_g1_out;
            241 : cal_map[15][16] <= sram_g1_out;
            242 : cal_map[16][1] <= sram_g1_out;
            243 : cal_map[16][2] <= sram_g1_out;
            244 : cal_map[16][3] <= sram_g1_out;
            245 : cal_map[16][4] <= sram_g1_out;
            246 : cal_map[16][5] <= sram_g1_out;
            247 : cal_map[16][6] <= sram_g1_out;
            248 : cal_map[16][7] <= sram_g1_out;
            249 : cal_map[16][8] <= sram_g1_out;
            250 : cal_map[16][9] <= sram_g1_out;
            251 : cal_map[16][10] <= sram_g1_out;
            252 : cal_map[16][11] <= sram_g1_out;
            253 : cal_map[16][12] <= sram_g1_out;
            254 : cal_map[16][13] <= sram_g1_out;
            255 : cal_map[16][14] <= sram_g1_out;
            256 : cal_map[16][15] <= sram_g1_out;
            257 : cal_map[16][16] <= sram_g1_out;
        endcase
    end
    
    else if(current_state == IN_DATA2 && act_in[0] == 2 && image_size_in == 2)begin
        case(counter_inD2)
            2  : cal_map[1][1] <= sram_g2_out;
            3  : cal_map[1][2] <= sram_g2_out;
            4  : cal_map[1][3] <= sram_g2_out;
            5  : cal_map[1][4] <= sram_g2_out;
            6  : cal_map[1][5] <= sram_g2_out;
            7  : cal_map[1][6] <= sram_g2_out;
            8  : cal_map[1][7] <= sram_g2_out;
            9  : cal_map[1][8] <= sram_g2_out;
            10 : cal_map[1][9] <= sram_g2_out;
            11 : cal_map[1][10] <= sram_g2_out;
            12 : cal_map[1][11] <= sram_g2_out;
            13 : cal_map[1][12] <= sram_g2_out;
            14 : cal_map[1][13] <= sram_g2_out;
            15 : cal_map[1][14] <= sram_g2_out;
            16 : cal_map[1][15] <= sram_g2_out;
            17 : cal_map[1][16] <= sram_g2_out;
            18 : cal_map[2][1] <= sram_g2_out;
            19 : cal_map[2][2] <= sram_g2_out;
            20 : cal_map[2][3] <= sram_g2_out;
            21 : cal_map[2][4] <= sram_g2_out;
            22 : cal_map[2][5] <= sram_g2_out;
            23 : cal_map[2][6] <= sram_g2_out;
            24 : cal_map[2][7] <= sram_g2_out;
            25 : cal_map[2][8] <= sram_g2_out;
            26 : cal_map[2][9] <= sram_g2_out;
            27 : cal_map[2][10] <= sram_g2_out;
            28 : cal_map[2][11] <= sram_g2_out;
            29 : cal_map[2][12] <= sram_g2_out;
            30 : cal_map[2][13] <= sram_g2_out;
            31 : cal_map[2][14] <= sram_g2_out;
            32 : cal_map[2][15] <= sram_g2_out;
            33 : cal_map[2][16] <= sram_g2_out;
            34 : cal_map[3][1] <= sram_g2_out;
            35 : cal_map[3][2] <= sram_g2_out;
            36 : cal_map[3][3] <= sram_g2_out;
            37 : cal_map[3][4] <= sram_g2_out;
            38 : cal_map[3][5] <= sram_g2_out;
            39 : cal_map[3][6] <= sram_g2_out;
            40 : cal_map[3][7] <= sram_g2_out;
            41 : cal_map[3][8] <= sram_g2_out;
            42 : cal_map[3][9] <= sram_g2_out;
            43 : cal_map[3][10] <= sram_g2_out;
            44 : cal_map[3][11] <= sram_g2_out;
            45 : cal_map[3][12] <= sram_g2_out;
            46 : cal_map[3][13] <= sram_g2_out;
            47 : cal_map[3][14] <= sram_g2_out;
            48 : cal_map[3][15] <= sram_g2_out;
            49 : cal_map[3][16] <= sram_g2_out;
            50 : cal_map[4][1] <= sram_g2_out;
            51 : cal_map[4][2] <= sram_g2_out;
            52 : cal_map[4][3] <= sram_g2_out;
            53 : cal_map[4][4] <= sram_g2_out;
            54 : cal_map[4][5] <= sram_g2_out;
            55 : cal_map[4][6] <= sram_g2_out;
            56 : cal_map[4][7] <= sram_g2_out;
            57 : cal_map[4][8] <= sram_g2_out;
            58 : cal_map[4][9] <= sram_g2_out;
            59 : cal_map[4][10] <= sram_g2_out;
            60 : cal_map[4][11] <= sram_g2_out;
            61 : cal_map[4][12] <= sram_g2_out;
            62 : cal_map[4][13] <= sram_g2_out;
            63 : cal_map[4][14] <= sram_g2_out;
            64 : cal_map[4][15] <= sram_g2_out;
            65 : cal_map[4][16] <= sram_g2_out;
            66 : cal_map[5][1] <= sram_g2_out;
            67 : cal_map[5][2] <= sram_g2_out;
            68 : cal_map[5][3] <= sram_g2_out;
            69 : cal_map[5][4] <= sram_g2_out;
            70 : cal_map[5][5] <= sram_g2_out;
            71 : cal_map[5][6] <= sram_g2_out;
            72 : cal_map[5][7] <= sram_g2_out;
            73 : cal_map[5][8] <= sram_g2_out;
            74 : cal_map[5][9] <= sram_g2_out;
            75 : cal_map[5][10] <= sram_g2_out;
            76 : cal_map[5][11] <= sram_g2_out;
            77 : cal_map[5][12] <= sram_g2_out;
            78 : cal_map[5][13] <= sram_g2_out;
            79 : cal_map[5][14] <= sram_g2_out;
            80 : cal_map[5][15] <= sram_g2_out;
            81 : cal_map[5][16] <= sram_g2_out;
            82 : cal_map[6][1] <= sram_g2_out;
            83 : cal_map[6][2] <= sram_g2_out;
            84 : cal_map[6][3] <= sram_g2_out;
            85 : cal_map[6][4] <= sram_g2_out;
            86 : cal_map[6][5] <= sram_g2_out;
            87 : cal_map[6][6] <= sram_g2_out;
            88 : cal_map[6][7] <= sram_g2_out;
            89 : cal_map[6][8] <= sram_g2_out;
            90 : cal_map[6][9] <= sram_g2_out;
            91 : cal_map[6][10] <= sram_g2_out;
            92 : cal_map[6][11] <= sram_g2_out;
            93 : cal_map[6][12] <= sram_g2_out;
            94 : cal_map[6][13] <= sram_g2_out;
            95 : cal_map[6][14] <= sram_g2_out;
            96 : cal_map[6][15] <= sram_g2_out;
            97 : cal_map[6][16] <= sram_g2_out;
            98 : cal_map[7][1] <= sram_g2_out;
            99 : cal_map[7][2] <= sram_g2_out;
            100 : cal_map[7][3] <= sram_g2_out;
            101 : cal_map[7][4] <= sram_g2_out;
            102 : cal_map[7][5] <= sram_g2_out;
            103 : cal_map[7][6] <= sram_g2_out;
            104 : cal_map[7][7] <= sram_g2_out;
            105 : cal_map[7][8] <= sram_g2_out;
            106 : cal_map[7][9] <= sram_g2_out;
            107 : cal_map[7][10] <= sram_g2_out;
            108 : cal_map[7][11] <= sram_g2_out;
            109 : cal_map[7][12] <= sram_g2_out;
            110 : cal_map[7][13] <= sram_g2_out;
            111 : cal_map[7][14] <= sram_g2_out;
            112 : cal_map[7][15] <= sram_g2_out;
            113 : cal_map[7][16] <= sram_g2_out;
            114 : cal_map[8][1] <= sram_g2_out;
            115 : cal_map[8][2] <= sram_g2_out;
            116 : cal_map[8][3] <= sram_g2_out;
            117 : cal_map[8][4] <= sram_g2_out;
            118 : cal_map[8][5] <= sram_g2_out;
            119 : cal_map[8][6] <= sram_g2_out;
            120 : cal_map[8][7] <= sram_g2_out;
            121 : cal_map[8][8] <= sram_g2_out;
            122 : cal_map[8][9] <= sram_g2_out;
            123 : cal_map[8][10] <= sram_g2_out;
            124 : cal_map[8][11] <= sram_g2_out;
            125 : cal_map[8][12] <= sram_g2_out;
            126 : cal_map[8][13] <= sram_g2_out;
            127 : cal_map[8][14] <= sram_g2_out;
            128 : cal_map[8][15] <= sram_g2_out;
            129 : cal_map[8][16] <= sram_g2_out;
            130 : cal_map[9][1] <= sram_g2_out;
            131 : cal_map[9][2] <= sram_g2_out;
            132 : cal_map[9][3] <= sram_g2_out;
            133 : cal_map[9][4] <= sram_g2_out;
            134 : cal_map[9][5] <= sram_g2_out;
            135 : cal_map[9][6] <= sram_g2_out;
            136 : cal_map[9][7] <= sram_g2_out;
            137 : cal_map[9][8] <= sram_g2_out;
            138 : cal_map[9][9] <= sram_g2_out;
            139 : cal_map[9][10] <= sram_g2_out;
            140 : cal_map[9][11] <= sram_g2_out;
            141 : cal_map[9][12] <= sram_g2_out;
            142 : cal_map[9][13] <= sram_g2_out;
            143 : cal_map[9][14] <= sram_g2_out;
            144 : cal_map[9][15] <= sram_g2_out;
            145 : cal_map[9][16] <= sram_g2_out;
            146 : cal_map[10][1] <= sram_g2_out;
            147 : cal_map[10][2] <= sram_g2_out;
            148 : cal_map[10][3] <= sram_g2_out;
            149 : cal_map[10][4] <= sram_g2_out;
            150 : cal_map[10][5] <= sram_g2_out;
            151 : cal_map[10][6] <= sram_g2_out;
            152 : cal_map[10][7] <= sram_g2_out;
            153 : cal_map[10][8] <= sram_g2_out;
            154 : cal_map[10][9] <= sram_g2_out;
            155 : cal_map[10][10] <= sram_g2_out;
            156 : cal_map[10][11] <= sram_g2_out;
            157 : cal_map[10][12] <= sram_g2_out;
            158 : cal_map[10][13] <= sram_g2_out;
            159 : cal_map[10][14] <= sram_g2_out;
            160 : cal_map[10][15] <= sram_g2_out;
            161 : cal_map[10][16] <= sram_g2_out;
            162 : cal_map[11][1] <= sram_g2_out;
            163 : cal_map[11][2] <= sram_g2_out;
            164 : cal_map[11][3] <= sram_g2_out;
            165 : cal_map[11][4] <= sram_g2_out;
            166 : cal_map[11][5] <= sram_g2_out;
            167 : cal_map[11][6] <= sram_g2_out;
            168 : cal_map[11][7] <= sram_g2_out;
            169 : cal_map[11][8] <= sram_g2_out;
            170 : cal_map[11][9] <= sram_g2_out;
            171 : cal_map[11][10] <= sram_g2_out;
            172 : cal_map[11][11] <= sram_g2_out;
            173 : cal_map[11][12] <= sram_g2_out;
            174 : cal_map[11][13] <= sram_g2_out;
            175 : cal_map[11][14] <= sram_g2_out;
            176 : cal_map[11][15] <= sram_g2_out;
            177 : cal_map[11][16] <= sram_g2_out;
            178 : cal_map[12][1] <= sram_g2_out;
            179 : cal_map[12][2] <= sram_g2_out;
            180 : cal_map[12][3] <= sram_g2_out;
            181 : cal_map[12][4] <= sram_g2_out;
            182 : cal_map[12][5] <= sram_g2_out;
            183 : cal_map[12][6] <= sram_g2_out;
            184 : cal_map[12][7] <= sram_g2_out;
            185 : cal_map[12][8] <= sram_g2_out;
            186 : cal_map[12][9] <= sram_g2_out;
            187 : cal_map[12][10] <= sram_g2_out;
            188 : cal_map[12][11] <= sram_g2_out;
            189 : cal_map[12][12] <= sram_g2_out;
            190 : cal_map[12][13] <= sram_g2_out;
            191 : cal_map[12][14] <= sram_g2_out;
            192 : cal_map[12][15] <= sram_g2_out;
            193 : cal_map[12][16] <= sram_g2_out;
            194 : cal_map[13][1] <= sram_g2_out;
            195 : cal_map[13][2] <= sram_g2_out;
            196 : cal_map[13][3] <= sram_g2_out;
            197 : cal_map[13][4] <= sram_g2_out;
            198 : cal_map[13][5] <= sram_g2_out;
            199 : cal_map[13][6] <= sram_g2_out;
            200 : cal_map[13][7] <= sram_g2_out;
            201 : cal_map[13][8] <= sram_g2_out;
            202 : cal_map[13][9] <= sram_g2_out;
            203 : cal_map[13][10] <= sram_g2_out;
            204 : cal_map[13][11] <= sram_g2_out;
            205 : cal_map[13][12] <= sram_g2_out;
            206 : cal_map[13][13] <= sram_g2_out;
            207 : cal_map[13][14] <= sram_g2_out;
            208 : cal_map[13][15] <= sram_g2_out;
            209 : cal_map[13][16] <= sram_g2_out;
            210 : cal_map[14][1] <= sram_g2_out;
            211 : cal_map[14][2] <= sram_g2_out;
            212 : cal_map[14][3] <= sram_g2_out;
            213 : cal_map[14][4] <= sram_g2_out;
            214 : cal_map[14][5] <= sram_g2_out;
            215 : cal_map[14][6] <= sram_g2_out;
            216 : cal_map[14][7] <= sram_g2_out;
            217 : cal_map[14][8] <= sram_g2_out;
            218 : cal_map[14][9] <= sram_g2_out;
            219 : cal_map[14][10] <= sram_g2_out;
            220 : cal_map[14][11] <= sram_g2_out;
            221 : cal_map[14][12] <= sram_g2_out;
            222 : cal_map[14][13] <= sram_g2_out;
            223 : cal_map[14][14] <= sram_g2_out;
            224 : cal_map[14][15] <= sram_g2_out;
            225 : cal_map[14][16] <= sram_g2_out;
            226 : cal_map[15][1] <= sram_g2_out;
            227 : cal_map[15][2] <= sram_g2_out;
            228 : cal_map[15][3] <= sram_g2_out;
            229 : cal_map[15][4] <= sram_g2_out;
            230 : cal_map[15][5] <= sram_g2_out;
            231 : cal_map[15][6] <= sram_g2_out;
            232 : cal_map[15][7] <= sram_g2_out;
            233 : cal_map[15][8] <= sram_g2_out;
            234 : cal_map[15][9] <= sram_g2_out;
            235 : cal_map[15][10] <= sram_g2_out;
            236 : cal_map[15][11] <= sram_g2_out;
            237 : cal_map[15][12] <= sram_g2_out;
            238 : cal_map[15][13] <= sram_g2_out;
            239 : cal_map[15][14] <= sram_g2_out;
            240 : cal_map[15][15] <= sram_g2_out;
            241 : cal_map[15][16] <= sram_g2_out;
            242 : cal_map[16][1] <= sram_g2_out;
            243 : cal_map[16][2] <= sram_g2_out;
            244 : cal_map[16][3] <= sram_g2_out;
            245 : cal_map[16][4] <= sram_g2_out;
            246 : cal_map[16][5] <= sram_g2_out;
            247 : cal_map[16][6] <= sram_g2_out;
            248 : cal_map[16][7] <= sram_g2_out;
            249 : cal_map[16][8] <= sram_g2_out;
            250 : cal_map[16][9] <= sram_g2_out;
            251 : cal_map[16][10] <= sram_g2_out;
            252 : cal_map[16][11] <= sram_g2_out;
            253 : cal_map[16][12] <= sram_g2_out;
            254 : cal_map[16][13] <= sram_g2_out;
            255 : cal_map[16][14] <= sram_g2_out;
            256 : cal_map[16][15] <= sram_g2_out;
            257 : cal_map[16][16] <= sram_g2_out;
        endcase
    end
    else if(current_state == CAL)begin
        if(act_in[counter_act] == 4 && image_size_in == 0) begin//neg0
            for(i = 1; i < 5 ; i = i + 1) begin
                for(j = 1; j < 5; j = j + 1) begin
                    cal_map[i][j] <= 255-cal_map[i][j];
                end
            end
        end
        else if(act_in[counter_act] == 4 && image_size_in == 1) begin//neg1
            for(i = 1; i < 9 ; i = i + 1) begin
                for(j = 1; j < 9; j = j + 1) begin
                    cal_map[i][j] <= 255-cal_map[i][j];
                end
            end
        end
        else if(act_in[counter_act] == 4 && image_size_in == 2) begin//neg2
            for(i = 1; i < 17 ; i = i + 1) begin
                for(j = 1; j < 17; j = j + 1) begin
                    cal_map[i][j] <= 255-cal_map[i][j];
                end
            end
        end
        else if(act_in[counter_act] == 5 && image_size_in == 0) begin//Flip
            for(i = 1; i < 5 ; i = i + 1) begin
                cal_map[i][1] <= cal_map[i][4];
                cal_map[i][2] <= cal_map[i][3];
                cal_map[i][4] <= cal_map[i][1];
                cal_map[i][3] <= cal_map[i][2];
            end
        end
        else if(act_in[counter_act] == 5 && image_size_in == 1) begin//Flip1
            for(i = 1; i < 9 ; i = i + 1) begin
                cal_map[i][1] <= cal_map[i][8];
                cal_map[i][2] <= cal_map[i][7];
                cal_map[i][3] <= cal_map[i][6];
                cal_map[i][4] <= cal_map[i][5];
                cal_map[i][5] <= cal_map[i][4];
                cal_map[i][6] <= cal_map[i][3];
                cal_map[i][7] <= cal_map[i][2];
                cal_map[i][8] <= cal_map[i][1];
            end
        end
        else if(act_in[counter_act] == 5 && image_size_in == 2) begin//Flip2
            for(i = 1; i < 17 ; i = i + 1) begin
                cal_map[i][1]  <= cal_map[i][16];
                cal_map[i][2]  <= cal_map[i][15];
                cal_map[i][3]  <= cal_map[i][14];
                cal_map[i][4]  <= cal_map[i][13];
                cal_map[i][5]  <= cal_map[i][12];
                cal_map[i][6]  <= cal_map[i][11];
                cal_map[i][7]  <= cal_map[i][10];
                cal_map[i][8]  <= cal_map[i][9];
                cal_map[i][9]  <= cal_map[i][8];
                cal_map[i][10] <= cal_map[i][7];
                cal_map[i][11] <= cal_map[i][6];
                cal_map[i][12] <= cal_map[i][5];
                cal_map[i][13] <= cal_map[i][4];
                cal_map[i][14] <= cal_map[i][3];
                cal_map[i][15] <= cal_map[i][2];
                cal_map[i][16] <= cal_map[i][1];
            end
        end
        else if(act_in[counter_act] == 3 && image_size_in == 0) begin//MaxPool
            for(i = 1; i < 5; i = i + 1) begin
                for(j = 1; j < 5; j = j + 1) begin
                    cal_map[i][j] <= cal_map[i][j];
                end
            end
        end
        else if(act_in[counter_act] == 3 && image_size_in == 1 && counter_cal == 65) begin//MaxPool1
            for(i = 0; i < 9; i = i + 1) begin
                cal_map[0][i] <= 0;
            end
            for(i = 0; i < 9; i = i + 1) begin
                cal_map[i][0] <= 0;
            end
            for(i = 5; i < 18; i = i + 1) begin
                for(j = 0; j < 18; j = j + 1) begin
                    cal_map[i][j] <= 0;
                end
            end
            for(i = 0; i < 5; i = i + 1) begin
                for(j = 5; j < 18; j = j + 1) begin
                    cal_map[i][j] <= 0;
                end
            end
        end
        else if(act_in[counter_act] == 3 && image_size_in == 1) begin//MaxPool1
            for(i = 1; i < 5; i = i + 1) begin
                for(j = 1; j < 5; j = j + 1) begin
                    cal_map[i][j] <= cal_map[i][j];
                end
            end
            case(counter_cal)
                1  : cal_map[1][1] <= compall;
                2  : cal_map[1][2] <= compall;
                3  : cal_map[1][3] <= compall;
                4  : cal_map[1][4] <= compall;
                5  : cal_map[1][5] <= compall;
                6  : cal_map[1][6] <= compall;
                7  : cal_map[1][7] <= compall;
                8  : cal_map[1][8] <= compall;
                9  : cal_map[2][1] <= compall;
                10 : cal_map[2][2] <= compall;
                11 : cal_map[2][3] <= compall;
                12 : cal_map[2][4] <= compall;
                13 : cal_map[2][5] <= compall;
                14 : cal_map[2][6] <= compall;
                15 : cal_map[2][7] <= compall;
                16 : cal_map[2][8] <= compall;
                17 : cal_map[3][1] <= compall;
                18 : cal_map[3][2] <= compall;
                19 : cal_map[3][3] <= compall;
                20 : cal_map[3][4] <= compall;
                21 : cal_map[3][5] <= compall;
                22 : cal_map[3][6] <= compall;
                23 : cal_map[3][7] <= compall;
                24 : cal_map[3][8] <= compall;
                25 : cal_map[4][1] <= compall;
                26 : cal_map[4][2] <= compall;
                27 : cal_map[4][3] <= compall;
                28 : cal_map[4][4] <= compall;
                29 : cal_map[4][5] <= compall;
                30 : cal_map[4][6] <= compall;
                31 : cal_map[4][7] <= compall;
                32 : cal_map[4][8] <= compall;
                33 : cal_map[5][1] <= compall;
                34 : cal_map[5][2] <= compall;
                35 : cal_map[5][3] <= compall;
                36 : cal_map[5][4] <= compall;
                37 : cal_map[5][5] <= compall;
                38 : cal_map[5][6] <= compall;
                39 : cal_map[5][7] <= compall;
                40 : cal_map[5][8] <= compall;
                41 : cal_map[6][1] <= compall;
                42 : cal_map[6][2] <= compall;
                43 : cal_map[6][3] <= compall;
                44 : cal_map[6][4] <= compall;
                45 : cal_map[6][5] <= compall;
                46 : cal_map[6][6] <= compall;
                47 : cal_map[6][7] <= compall;
                48 : cal_map[6][8] <= compall;
                49 : cal_map[7][1] <= compall;
                50 : cal_map[7][2] <= compall;
                51 : cal_map[7][3] <= compall;
                52 : cal_map[7][4] <= compall;
                53 : cal_map[7][5] <= compall;
                54 : cal_map[7][6] <= compall;
                55 : cal_map[7][7] <= compall;
                56 : cal_map[7][8] <= compall;
                57 : cal_map[8][1] <= compall;
                58 : cal_map[8][2] <= compall;
                59 : cal_map[8][3] <= compall;
                60 : cal_map[8][4] <= compall;
                61 : cal_map[8][5] <= compall;
                62 : cal_map[8][6] <= compall;
                63 : cal_map[8][7] <= compall;
                64 : cal_map[8][8] <= compall;
            endcase
        end
        else if(act_in[counter_act] == 3 && image_size_in == 2 && counter_cal == 65) begin//MaxPool2
            for(i = 0; i < 9; i = i + 1) begin
                cal_map[0][i] <= 0;
            end
            for(i = 0; i < 9; i = i + 1) begin
                cal_map[i][0] <= 0;
            end
            for(i = 9; i < 18; i = i + 1) begin
                for(j = 0; j < 18; j = j + 1) begin
                    cal_map[i][j] <= 0;
                end
            end
            for(i = 0; i < 9; i = i + 1) begin
                for(j = 9; j < 18; j = j + 1) begin
                    cal_map[i][j] <= 0;
                end
            end
        end
        else if(act_in[counter_act] == 3 && image_size_in == 2) begin//MaxPool2
            case(counter_cal)
                1  : cal_map[1][1] <= compall;
                2  : cal_map[1][2] <= compall;
                3  : cal_map[1][3] <= compall;
                4  : cal_map[1][4] <= compall;
                5  : cal_map[1][5] <= compall;
                6  : cal_map[1][6] <= compall;
                7  : cal_map[1][7] <= compall;
                8  : cal_map[1][8] <= compall;
                9  : cal_map[2][1] <= compall;
                10 : cal_map[2][2] <= compall;
                11 : cal_map[2][3] <= compall;
                12 : cal_map[2][4] <= compall;
                13 : cal_map[2][5] <= compall;
                14 : cal_map[2][6] <= compall;
                15 : cal_map[2][7] <= compall;
                16 : cal_map[2][8] <= compall;
                17 : cal_map[3][1] <= compall;
                18 : cal_map[3][2] <= compall;
                19 : cal_map[3][3] <= compall;
                20 : cal_map[3][4] <= compall;
                21 : cal_map[3][5] <= compall;
                22 : cal_map[3][6] <= compall;
                23 : cal_map[3][7] <= compall;
                24 : cal_map[3][8] <= compall;
                25 : cal_map[4][1] <= compall;
                26 : cal_map[4][2] <= compall;
                27 : cal_map[4][3] <= compall;
                28 : cal_map[4][4] <= compall;
                29 : cal_map[4][5] <= compall;
                30 : cal_map[4][6] <= compall;
                31 : cal_map[4][7] <= compall;
                32 : cal_map[4][8] <= compall;
                33 : cal_map[5][1] <= compall;
                34 : cal_map[5][2] <= compall;
                35 : cal_map[5][3] <= compall;
                36 : cal_map[5][4] <= compall;
                37 : cal_map[5][5] <= compall;
                38 : cal_map[5][6] <= compall;
                39 : cal_map[5][7] <= compall;
                40 : cal_map[5][8] <= compall;
                41 : cal_map[6][1] <= compall;
                42 : cal_map[6][2] <= compall;
                43 : cal_map[6][3] <= compall;
                44 : cal_map[6][4] <= compall;
                45 : cal_map[6][5] <= compall;
                46 : cal_map[6][6] <= compall;
                47 : cal_map[6][7] <= compall;
                48 : cal_map[6][8] <= compall;
                49 : cal_map[7][1] <= compall;
                50 : cal_map[7][2] <= compall;
                51 : cal_map[7][3] <= compall;
                52 : cal_map[7][4] <= compall;
                53 : cal_map[7][5] <= compall;
                54 : cal_map[7][6] <= compall;
                55 : cal_map[7][7] <= compall;
                56 : cal_map[7][8] <= compall;
                57 : cal_map[8][1] <= compall;
                58 : cal_map[8][2] <= compall;
                59 : cal_map[8][3] <= compall;
                60 : cal_map[8][4] <= compall;
                61 : cal_map[8][5] <= compall;
                62 : cal_map[8][6] <= compall;
                63 : cal_map[8][7] <= compall;
                64 : cal_map[8][8] <= compall;
            endcase
        end
        else if(act_in[counter_act] == 7) begin//conv
            case(counter_cal)
                1  : cal_map[0][0] <= conv_all;
                2  : cal_map[0][1] <= conv_all;
                3  : cal_map[0][2] <= conv_all;
                4  : cal_map[0][3] <= conv_all;
                5  : cal_map[0][4] <= conv_all;
                6  : cal_map[0][5] <= conv_all;
                7  : cal_map[0][6] <= conv_all;
                8  : cal_map[0][7] <= conv_all;
                9  : cal_map[0][8] <= conv_all;
                10 : cal_map[0][9] <= conv_all;
                11 : cal_map[0][10] <= conv_all;
                12 : cal_map[0][11] <= conv_all;
                13 : cal_map[0][12] <= conv_all;
                14 : cal_map[0][13] <= conv_all;
                15 : cal_map[0][14] <= conv_all;
                16 : cal_map[0][15] <= conv_all;

                17 : cal_map[1][0] <= conv_all;
                18 : cal_map[1][1] <= conv_all;
                19 : cal_map[1][2] <= conv_all;
                20 : cal_map[1][3] <= conv_all;
                21 : cal_map[1][4] <= conv_all;
                22 : cal_map[1][5] <= conv_all;
                23 : cal_map[1][6] <= conv_all;
                24 : cal_map[1][7] <= conv_all;
                25 : cal_map[1][8] <= conv_all;
                26 : cal_map[1][9] <= conv_all;
                27 : cal_map[1][10] <= conv_all;
                28 : cal_map[1][11] <= conv_all;
                29 : cal_map[1][12] <= conv_all;
                30 : cal_map[1][13] <= conv_all;
                31 : cal_map[1][14] <= conv_all;
                32 : cal_map[1][15] <= conv_all;

                33 : cal_map[2][0] <= conv_all;
                34 : cal_map[2][1] <= conv_all;
                35 : cal_map[2][2] <= conv_all;
                36 : cal_map[2][3] <= conv_all;
                37 : cal_map[2][4] <= conv_all;
                38 : cal_map[2][5] <= conv_all;
                39 : cal_map[2][6] <= conv_all;
                40 : cal_map[2][7] <= conv_all;
                41 : cal_map[2][8] <= conv_all;
                42 : cal_map[2][9] <= conv_all;
                43 : cal_map[2][10] <= conv_all;
                44 : cal_map[2][11] <= conv_all;
                45 : cal_map[2][12] <= conv_all;
                46 : cal_map[2][13] <= conv_all;
                47 : cal_map[2][14] <= conv_all;
                48 : cal_map[2][15] <= conv_all;

                49 : cal_map[3][0] <= conv_all;
                50 : cal_map[3][1] <= conv_all;
                51 : cal_map[3][2] <= conv_all;
                52 : cal_map[3][3] <= conv_all;
                53 : cal_map[3][4] <= conv_all;
                54 : cal_map[3][5] <= conv_all;
                55 : cal_map[3][6] <= conv_all;
                56 : cal_map[3][7] <= conv_all;
                57 : cal_map[3][8] <= conv_all;
                58 : cal_map[3][9] <= conv_all;
                59 : cal_map[3][10] <= conv_all;
                60 : cal_map[3][11] <= conv_all;
                61 : cal_map[3][12] <= conv_all;
                62 : cal_map[3][13] <= conv_all;
                63 : cal_map[3][14] <= conv_all;
                64 : cal_map[3][15] <= conv_all;

                65 : cal_map[4][0] <= conv_all;
                66 : cal_map[4][1] <= conv_all;
                67 : cal_map[4][2] <= conv_all;
                68 : cal_map[4][3] <= conv_all;
                69 : cal_map[4][4] <= conv_all;
                70 : cal_map[4][5] <= conv_all;
                71 : cal_map[4][6] <= conv_all;
                72 : cal_map[4][7] <= conv_all;
                73 : cal_map[4][8] <= conv_all;
                74 : cal_map[4][9] <= conv_all;
                75 : cal_map[4][10] <= conv_all;
                76 : cal_map[4][11] <= conv_all;
                77 : cal_map[4][12] <= conv_all;
                78 : cal_map[4][13] <= conv_all;
                79 : cal_map[4][14] <= conv_all;
                80 : cal_map[4][15] <= conv_all;

                81 : cal_map[5][0] <= conv_all;
                82 : cal_map[5][1] <= conv_all;
                83 : cal_map[5][2] <= conv_all;
                84 : cal_map[5][3] <= conv_all;
                85 : cal_map[5][4] <= conv_all;
                86 : cal_map[5][5] <= conv_all;
                87 : cal_map[5][6] <= conv_all;
                88 : cal_map[5][7] <= conv_all;
                89 : cal_map[5][8] <= conv_all;
                90 : cal_map[5][9] <= conv_all;
                91 : cal_map[5][10] <= conv_all;
                92 : cal_map[5][11] <= conv_all;
                93 : cal_map[5][12] <= conv_all;
                94 : cal_map[5][13] <= conv_all;
                95 : cal_map[5][14] <= conv_all;
                96 : cal_map[5][15] <= conv_all;

                97 : cal_map[6][0] <= conv_all;
                98 : cal_map[6][1] <= conv_all;
                99 : cal_map[6][2] <= conv_all;
                100 : cal_map[6][3] <= conv_all;
                101 : cal_map[6][4] <= conv_all;
                102 : cal_map[6][5] <= conv_all;
                103 : cal_map[6][6] <= conv_all;
                104 : cal_map[6][7] <= conv_all;
                105 : cal_map[6][8] <= conv_all;
                106 : cal_map[6][9] <= conv_all;
                107 : cal_map[6][10] <= conv_all;
                108 : cal_map[6][11] <= conv_all;
                109 : cal_map[6][12] <= conv_all;
                110 : cal_map[6][13] <= conv_all;
                111 : cal_map[6][14] <= conv_all;
                112 : cal_map[6][15] <= conv_all;

                113 : cal_map[7][0] <= conv_all;
                114 : cal_map[7][1] <= conv_all;
                115 : cal_map[7][2] <= conv_all;
                116 : cal_map[7][3] <= conv_all;
                117 : cal_map[7][4] <= conv_all;
                118 : cal_map[7][5] <= conv_all;
                119 : cal_map[7][6] <= conv_all;
                120 : cal_map[7][7] <= conv_all;
                121 : cal_map[7][8] <= conv_all;
                122 : cal_map[7][9] <= conv_all;
                123 : cal_map[7][10] <= conv_all;
                124 : cal_map[7][11] <= conv_all;
                125 : cal_map[7][12] <= conv_all;
                126 : cal_map[7][13] <= conv_all;
                127 : cal_map[7][14] <= conv_all;
                128 : cal_map[7][15] <= conv_all;

                129 : cal_map[8][0] <= conv_all;
                130 : cal_map[8][1] <= conv_all;
                131 : cal_map[8][2] <= conv_all;
                132 : cal_map[8][3] <= conv_all;
                133 : cal_map[8][4] <= conv_all;
                134 : cal_map[8][5] <= conv_all;
                135 : cal_map[8][6] <= conv_all;
                136 : cal_map[8][7] <= conv_all;
                137 : cal_map[8][8] <= conv_all;
                138 : cal_map[8][9] <= conv_all;
                139 : cal_map[8][10] <= conv_all;
                140 : cal_map[8][11] <= conv_all;
                141 : cal_map[8][12] <= conv_all;
                142 : cal_map[8][13] <= conv_all;
                143 : cal_map[8][14] <= conv_all;
                144 : cal_map[8][15] <= conv_all;

                145 : cal_map[9][0] <= conv_all;
                146 : cal_map[9][1] <= conv_all;
                147 : cal_map[9][2] <= conv_all;
                148 : cal_map[9][3] <= conv_all;
                149 : cal_map[9][4] <= conv_all;
                150 : cal_map[9][5] <= conv_all;
                151 : cal_map[9][6] <= conv_all;
                152 : cal_map[9][7] <= conv_all;
                153 : cal_map[9][8] <= conv_all;
                154 : cal_map[9][9] <= conv_all;
                155 : cal_map[9][10] <= conv_all;
                156 : cal_map[9][11] <= conv_all;
                157 : cal_map[9][12] <= conv_all;
                158 : cal_map[9][13] <= conv_all;
                159 : cal_map[9][14] <= conv_all;
                160 : cal_map[9][15] <= conv_all;

                161 : cal_map[10][0] <= conv_all;
                162 : cal_map[10][1] <= conv_all;
                163 : cal_map[10][2] <= conv_all;
                164 : cal_map[10][3] <= conv_all;
                165 : cal_map[10][4] <= conv_all;
                166 : cal_map[10][5] <= conv_all;
                167 : cal_map[10][6] <= conv_all;
                168 : cal_map[10][7] <= conv_all;
                169 : cal_map[10][8] <= conv_all;
                170 : cal_map[10][9] <= conv_all;
                171 : cal_map[10][10] <= conv_all;
                172 : cal_map[10][11] <= conv_all;
                173 : cal_map[10][12] <= conv_all;
                174 : cal_map[10][13] <= conv_all;
                175 : cal_map[10][14] <= conv_all;
                176 : cal_map[10][15] <= conv_all;

                177 : cal_map[11][0] <= conv_all;
                178 : cal_map[11][1] <= conv_all;
                179 : cal_map[11][2] <= conv_all;
                180 : cal_map[11][3] <= conv_all;
                181 : cal_map[11][4] <= conv_all;
                182 : cal_map[11][5] <= conv_all;
                183 : cal_map[11][6] <= conv_all;
                184 : cal_map[11][7] <= conv_all;
                185 : cal_map[11][8] <= conv_all;
                186 : cal_map[11][9] <= conv_all;
                187 : cal_map[11][10] <= conv_all;
                188 : cal_map[11][11] <= conv_all;
                189 : cal_map[11][12] <= conv_all;
                190 : cal_map[11][13] <= conv_all;
                191 : cal_map[11][14] <= conv_all;
                192 : cal_map[11][15] <= conv_all;

                193 : cal_map[12][0] <= conv_all;
                194 : cal_map[12][1] <= conv_all;
                195 : cal_map[12][2] <= conv_all;
                196 : cal_map[12][3] <= conv_all;
                197 : cal_map[12][4] <= conv_all;
                198 : cal_map[12][5] <= conv_all;
                199 : cal_map[12][6] <= conv_all;
                200 : cal_map[12][7] <= conv_all;
                201 : cal_map[12][8] <= conv_all;
                202 : cal_map[12][9] <= conv_all;
                203 : cal_map[12][10] <= conv_all;
                204 : cal_map[12][11] <= conv_all;
                205 : cal_map[12][12] <= conv_all;
                206 : cal_map[12][13] <= conv_all;
                207 : cal_map[12][14] <= conv_all;
                208 : cal_map[12][15] <= conv_all;

                209 : cal_map[13][0] <= conv_all;
                210 : cal_map[13][1] <= conv_all;
                211 : cal_map[13][2] <= conv_all;
                212 : cal_map[13][3] <= conv_all;
                213 : cal_map[13][4] <= conv_all;
                214 : cal_map[13][5] <= conv_all;
                215 : cal_map[13][6] <= conv_all;
                216 : cal_map[13][7] <= conv_all;
                217 : cal_map[13][8] <= conv_all;
                218 : cal_map[13][9] <= conv_all;
                219 : cal_map[13][10] <= conv_all;
                220 : cal_map[13][11] <= conv_all;
                221 : cal_map[13][12] <= conv_all;
                222 : cal_map[13][13] <= conv_all;
                223 : cal_map[13][14] <= conv_all;
                224 : cal_map[13][15] <= conv_all;

                225 : cal_map[14][0] <= conv_all;
                226 : cal_map[14][1] <= conv_all;
                227 : cal_map[14][2] <= conv_all;
                228 : cal_map[14][3] <= conv_all;
                229 : cal_map[14][4] <= conv_all;
                230 : cal_map[14][5] <= conv_all;
                231 : cal_map[14][6] <= conv_all;
                232 : cal_map[14][7] <= conv_all;
                233 : cal_map[14][8] <= conv_all;
                234 : cal_map[14][9] <= conv_all;
                235 : cal_map[14][10] <= conv_all;
                236 : cal_map[14][11] <= conv_all;
                237 : cal_map[14][12] <= conv_all;
                238 : cal_map[14][13] <= conv_all;
                239 : cal_map[14][14] <= conv_all;
                240 : cal_map[14][15] <= conv_all;

                241 : cal_map[15][0] <= conv_all;
                242 : cal_map[15][1] <= conv_all;
                243 : cal_map[15][2] <= conv_all;
                244 : cal_map[15][3] <= conv_all;
                245 : cal_map[15][4] <= conv_all;
                246 : cal_map[15][5] <= conv_all;
                247 : cal_map[15][6] <= conv_all;
                248 : cal_map[15][7] <= conv_all;
                249 : cal_map[15][8] <= conv_all;
                250 : cal_map[15][9] <= conv_all;
                251 : cal_map[15][10] <= conv_all;
                252 : cal_map[15][11] <= conv_all;
                253 : cal_map[15][12] <= conv_all;
                254 : cal_map[15][13] <= conv_all;
                255 : cal_map[15][14] <= conv_all;
                256 : cal_map[15][15] <= conv_all;    
            endcase
        end
        else if(act_in[counter_act] == 6 && counter_cal==0 && image_size_in == 0) begin
            cal_map[0][0] <= cal_map[1][1];
            cal_map[0][5] <= cal_map[1][4];
            cal_map[5][0] <= cal_map[4][1];
            cal_map[5][5] <= cal_map[4][4];
            for(i = 1; i < 5; i = i + 1) begin
                cal_map[0][i] <= cal_map[1][i];
            end
            for(i = 1; i < 5; i = i + 1) begin
                cal_map[i][0] <= cal_map[i][1];
            end
            for(i = 1; i < 5; i = i + 1) begin
                cal_map[i][5] <= cal_map[i][4];
            end
            for(i = 1; i < 5; i = i + 1) begin
                cal_map[5][i] <= cal_map[4][i];
            end
        end
        else if(act_in[counter_act] == 6 && counter_cal==257 && image_size_in == 0) begin
            for(i = 0; i < 4; i = i + 1) begin
                for(j = 0; j < 4; j = j + 1) begin
                    cal_map[i+1][j+1] <= cal_map[i][j];
                end
            end
            for(i = 0; i < 5; i = i + 1) begin
                cal_map[0][i] <= 0;
            end
            for(i = 0; i < 5; i = i + 1) begin
                cal_map[i][0] <= 0;
            end
            for(i = 5; i < 18; i = i + 1) begin
                for(j = 0; j < 18; j = j + 1) begin
                    cal_map[i][j] <= 0;
                end
            end
            for(i = 5; i < 18; i = i + 1) begin
                for(j = 0; j < 5; j = j + 1) begin
                    cal_map[i][j] <= 0;
                end
            end
        end
        else if(act_in[counter_act] == 6 && counter_cal==0 && image_size_in == 1) begin
            cal_map[0][0] <= cal_map[1][1];
            cal_map[0][9] <= cal_map[1][8];
            cal_map[9][0] <= cal_map[8][1];
            cal_map[9][9] <= cal_map[8][8];
            for(i = 1; i < 9; i = i + 1) begin
                cal_map[0][i] <= cal_map[1][i];
            end
            for(i = 1; i < 9; i = i + 1) begin
                cal_map[i][0] <= cal_map[i][1];
            end
            for(i = 1; i < 9; i = i + 1) begin
                cal_map[i][9] <= cal_map[i][8];
            end
            for(i = 1; i < 9; i = i + 1) begin
                cal_map[9][i] <= cal_map[8][i];
            end
        end
        else if(act_in[counter_act] == 6 && counter_cal==257 && image_size_in == 1) begin
            for(i = 0; i < 8; i = i + 1) begin
                for(j = 0; j < 8; j = j + 1) begin
                    cal_map[i+1][j+1] <= cal_map[i][j];
                end
            end
            for(i = 0; i < 9; i = i + 1) begin
                cal_map[0][i] <= 0;
            end
            for(i = 0; i < 9; i = i + 1) begin
                cal_map[i][0] <= 0;
            end
            for(i = 9; i < 18; i = i + 1) begin
                for(j = 0; j < 18; j = j + 1) begin
                    cal_map[i][j] <= 0;
                end
            end
            for(i = 9; i < 18; i = i + 1) begin
                for(j = 0; j < 9; j = j + 1) begin
                    cal_map[i][j] <= 0;
                end
            end
        end
        else if(act_in[counter_act] == 6 && counter_cal==0 && image_size_in == 2) begin
            cal_map[0][0] <= cal_map[1][1];
            cal_map[0][17] <= cal_map[1][16];
            cal_map[17][0] <= cal_map[16][1];
            cal_map[17][17] <= cal_map[16][16];
            for(i = 1; i < 17; i = i + 1) begin
                cal_map[0][i] <= cal_map[1][i];
            end
            for(i = 1; i < 17; i = i + 1) begin
                cal_map[i][0] <= cal_map[i][1];
            end
            for(i = 1; i < 17; i = i + 1) begin
                cal_map[i][17] <= cal_map[i][16];
            end
            for(i = 1; i < 17; i = i + 1) begin
                cal_map[17][i] <= cal_map[16][i];
            end
        end
        else if(act_in[counter_act] == 6 && counter_cal==257 && image_size_in == 2) begin
            for(i = 0; i < 17; i = i + 1) begin
                for(j = 0; j < 17; j = j + 1) begin
                    cal_map[i+1][j+1] <= cal_map[i][j];
                end
            end
            for(i = 0; i < 18; i = i + 1) begin
                cal_map[0][i] <= 0;
            end
            for(i = 0; i < 18; i = i + 1) begin
                cal_map[i][0] <= 0;
            end
            for(i = 1; i < 18; i = i + 1) begin
                cal_map[17][i] <= 0;
            end
            for(i = 1; i < 17; i = i + 1) begin
                cal_map[i][17] <= 0;
            end
        end
        else if(act_in[counter_act] == 6) begin//medi
            case(counter_cal)
                1  : cal_map[0][0] <= median;
                2  : cal_map[0][1] <= median;
                3  : cal_map[0][2] <= median;
                4  : cal_map[0][3] <= median;
                5  : cal_map[0][4] <= median;
                6  : cal_map[0][5] <= median;
                7  : cal_map[0][6] <= median;
                8  : cal_map[0][7] <= median;
                9  : cal_map[0][8] <= median;
                10 : cal_map[0][9] <= median;
                11 : cal_map[0][10] <= median;
                12 : cal_map[0][11] <= median;
                13 : cal_map[0][12] <= median;
                14 : cal_map[0][13] <= median;
                15 : cal_map[0][14] <= median;
                16 : cal_map[0][15] <= median;

                17 : cal_map[1][0] <= median;
                18 : cal_map[1][1] <= median;
                19 : cal_map[1][2] <= median;
                20 : cal_map[1][3] <= median;
                21 : cal_map[1][4] <= median;
                22 : cal_map[1][5] <= median;
                23 : cal_map[1][6] <= median;
                24 : cal_map[1][7] <= median;
                25 : cal_map[1][8] <= median;
                26 : cal_map[1][9] <= median;
                27 : cal_map[1][10] <= median;
                28 : cal_map[1][11] <= median;
                29 : cal_map[1][12] <= median;
                30 : cal_map[1][13] <= median;
                31 : cal_map[1][14] <= median;
                32 : cal_map[1][15] <= median;

                33 : cal_map[2][0] <= median;
                34 : cal_map[2][1] <= median;
                35 : cal_map[2][2] <= median;
                36 : cal_map[2][3] <= median;
                37 : cal_map[2][4] <= median;
                38 : cal_map[2][5] <= median;
                39 : cal_map[2][6] <= median;
                40 : cal_map[2][7] <= median;
                41 : cal_map[2][8] <= median;
                42 : cal_map[2][9] <= median;
                43 : cal_map[2][10] <= median;
                44 : cal_map[2][11] <= median;
                45 : cal_map[2][12] <= median;
                46 : cal_map[2][13] <= median;
                47 : cal_map[2][14] <= median;
                48 : cal_map[2][15] <= median;

                49 : cal_map[3][0] <= median;
                50 : cal_map[3][1] <= median;
                51 : cal_map[3][2] <= median;
                52 : cal_map[3][3] <= median;
                53 : cal_map[3][4] <= median;
                54 : cal_map[3][5] <= median;
                55 : cal_map[3][6] <= median;
                56 : cal_map[3][7] <= median;
                57 : cal_map[3][8] <= median;
                58 : cal_map[3][9] <= median;
                59 : cal_map[3][10] <= median;
                60 : cal_map[3][11] <= median;
                61 : cal_map[3][12] <= median;
                62 : cal_map[3][13] <= median;
                63 : cal_map[3][14] <= median;
                64 : cal_map[3][15] <= median;

                65 : cal_map[4][0] <= median;
                66 : cal_map[4][1] <= median;
                67 : cal_map[4][2] <= median;
                68 : cal_map[4][3] <= median;
                69 : cal_map[4][4] <= median;
                70 : cal_map[4][5] <= median;
                71 : cal_map[4][6] <= median;
                72 : cal_map[4][7] <= median;
                73 : cal_map[4][8] <= median;
                74 : cal_map[4][9] <= median;
                75 : cal_map[4][10] <= median;
                76 : cal_map[4][11] <= median;
                77 : cal_map[4][12] <= median;
                78 : cal_map[4][13] <= median;
                79 : cal_map[4][14] <= median;
                80 : cal_map[4][15] <= median;

                81 : cal_map[5][0] <= median;
                82 : cal_map[5][1] <= median;
                83 : cal_map[5][2] <= median;
                84 : cal_map[5][3] <= median;
                85 : cal_map[5][4] <= median;
                86 : cal_map[5][5] <= median;
                87 : cal_map[5][6] <= median;
                88 : cal_map[5][7] <= median;
                89 : cal_map[5][8] <= median;
                90 : cal_map[5][9] <= median;
                91 : cal_map[5][10] <= median;
                92 : cal_map[5][11] <= median;
                93 : cal_map[5][12] <= median;
                94 : cal_map[5][13] <= median;
                95 : cal_map[5][14] <= median;
                96 : cal_map[5][15] <= median;

                97 : cal_map[6][0] <= median;
                98 : cal_map[6][1] <= median;
                99 : cal_map[6][2] <= median;
                100 : cal_map[6][3] <= median;
                101 : cal_map[6][4] <= median;
                102 : cal_map[6][5] <= median;
                103 : cal_map[6][6] <= median;
                104 : cal_map[6][7] <= median;
                105 : cal_map[6][8] <= median;
                106 : cal_map[6][9] <= median;
                107 : cal_map[6][10] <= median;
                108 : cal_map[6][11] <= median;
                109 : cal_map[6][12] <= median;
                110 : cal_map[6][13] <= median;
                111 : cal_map[6][14] <= median;
                112 : cal_map[6][15] <= median;

                113 : cal_map[7][0] <= median;
                114 : cal_map[7][1] <= median;
                115 : cal_map[7][2] <= median;
                116 : cal_map[7][3] <= median;
                117 : cal_map[7][4] <= median;
                118 : cal_map[7][5] <= median;
                119 : cal_map[7][6] <= median;
                120 : cal_map[7][7] <= median;
                121 : cal_map[7][8] <= median;
                122 : cal_map[7][9] <= median;
                123 : cal_map[7][10] <= median;
                124 : cal_map[7][11] <= median;
                125 : cal_map[7][12] <= median;
                126 : cal_map[7][13] <= median;
                127 : cal_map[7][14] <= median;
                128 : cal_map[7][15] <= median;

                129 : cal_map[8][0] <= median;
                130 : cal_map[8][1] <= median;
                131 : cal_map[8][2] <= median;
                132 : cal_map[8][3] <= median;
                133 : cal_map[8][4] <= median;
                134 : cal_map[8][5] <= median;
                135 : cal_map[8][6] <= median;
                136 : cal_map[8][7] <= median;
                137 : cal_map[8][8] <= median;
                138 : cal_map[8][9] <= median;
                139 : cal_map[8][10] <= median;
                140 : cal_map[8][11] <= median;
                141 : cal_map[8][12] <= median;
                142 : cal_map[8][13] <= median;
                143 : cal_map[8][14] <= median;
                144 : cal_map[8][15] <= median;

                145 : cal_map[9][0] <= median;
                146 : cal_map[9][1] <= median;
                147 : cal_map[9][2] <= median;
                148 : cal_map[9][3] <= median;
                149 : cal_map[9][4] <= median;
                150 : cal_map[9][5] <= median;
                151 : cal_map[9][6] <= median;
                152 : cal_map[9][7] <= median;
                153 : cal_map[9][8] <= median;
                154 : cal_map[9][9] <= median;
                155 : cal_map[9][10] <= median;
                156 : cal_map[9][11] <= median;
                157 : cal_map[9][12] <= median;
                158 : cal_map[9][13] <= median;
                159 : cal_map[9][14] <= median;
                160 : cal_map[9][15] <= median;

                161 : cal_map[10][0] <= median;
                162 : cal_map[10][1] <= median;
                163 : cal_map[10][2] <= median;
                164 : cal_map[10][3] <= median;
                165 : cal_map[10][4] <= median;
                166 : cal_map[10][5] <= median;
                167 : cal_map[10][6] <= median;
                168 : cal_map[10][7] <= median;
                169 : cal_map[10][8] <= median;
                170 : cal_map[10][9] <= median;
                171 : cal_map[10][10] <= median;
                172 : cal_map[10][11] <= median;
                173 : cal_map[10][12] <= median;
                174 : cal_map[10][13] <= median;
                175 : cal_map[10][14] <= median;
                176 : cal_map[10][15] <= median;

                177 : cal_map[11][0] <= median;
                178 : cal_map[11][1] <= median;
                179 : cal_map[11][2] <= median;
                180 : cal_map[11][3] <= median;
                181 : cal_map[11][4] <= median;
                182 : cal_map[11][5] <= median;
                183 : cal_map[11][6] <= median;
                184 : cal_map[11][7] <= median;
                185 : cal_map[11][8] <= median;
                186 : cal_map[11][9] <= median;
                187 : cal_map[11][10] <= median;
                188 : cal_map[11][11] <= median;
                189 : cal_map[11][12] <= median;
                190 : cal_map[11][13] <= median;
                191 : cal_map[11][14] <= median;
                192 : cal_map[11][15] <= median;

                193 : cal_map[12][0] <= median;
                194 : cal_map[12][1] <= median;
                195 : cal_map[12][2] <= median;
                196 : cal_map[12][3] <= median;
                197 : cal_map[12][4] <= median;
                198 : cal_map[12][5] <= median;
                199 : cal_map[12][6] <= median;
                200 : cal_map[12][7] <= median;
                201 : cal_map[12][8] <= median;
                202 : cal_map[12][9] <= median;
                203 : cal_map[12][10] <= median;
                204 : cal_map[12][11] <= median;
                205 : cal_map[12][12] <= median;
                206 : cal_map[12][13] <= median;
                207 : cal_map[12][14] <= median;
                208 : cal_map[12][15] <= median;

                209 : cal_map[13][0] <= median;
                210 : cal_map[13][1] <= median;
                211 : cal_map[13][2] <= median;
                212 : cal_map[13][3] <= median;
                213 : cal_map[13][4] <= median;
                214 : cal_map[13][5] <= median;
                215 : cal_map[13][6] <= median;
                216 : cal_map[13][7] <= median;
                217 : cal_map[13][8] <= median;
                218 : cal_map[13][9] <= median;
                219 : cal_map[13][10] <= median;
                220 : cal_map[13][11] <= median;
                221 : cal_map[13][12] <= median;
                222 : cal_map[13][13] <= median;
                223 : cal_map[13][14] <= median;
                224 : cal_map[13][15] <= median;

                225 : cal_map[14][0] <= median;
                226 : cal_map[14][1] <= median;
                227 : cal_map[14][2] <= median;
                228 : cal_map[14][3] <= median;
                229 : cal_map[14][4] <= median;
                230 : cal_map[14][5] <= median;
                231 : cal_map[14][6] <= median;
                232 : cal_map[14][7] <= median;
                233 : cal_map[14][8] <= median;
                234 : cal_map[14][9] <= median;
                235 : cal_map[14][10] <= median;
                236 : cal_map[14][11] <= median;
                237 : cal_map[14][12] <= median;
                238 : cal_map[14][13] <= median;
                239 : cal_map[14][14] <= median;
                240 : cal_map[14][15] <= median;

                241 : cal_map[15][0] <= median;
                242 : cal_map[15][1] <= median;
                243 : cal_map[15][2] <= median;
                244 : cal_map[15][3] <= median;
                245 : cal_map[15][4] <= median;
                246 : cal_map[15][5] <= median;
                247 : cal_map[15][6] <= median;
                248 : cal_map[15][7] <= median;
                249 : cal_map[15][8] <= median;
                250 : cal_map[15][9] <= median;
                251 : cal_map[15][10] <= median;
                252 : cal_map[15][11] <= median;
                253 : cal_map[15][12] <= median;
                254 : cal_map[15][13] <= median;
                255 : cal_map[15][14] <= median;
                256 : cal_map[15][15] <= median;    
            endcase
        end
    end
    /*else if(counter==25 && Opt_in==1)begin//padding
        image1[0][0] <= image1[1][1];
        image1[0][1] <= image1[1][1];
        image1[0][2] <= image1[1][2];
        image1[0][3] <= image1[1][3];
        image1[0][4] <= image1[1][4];
        image1[0][5] <= image1[1][5];
        image1[0][6] <= image1[1][5];
        image1[1][0] <= image1[1][1];
        image1[1][6] <= image1[1][5];
        image1[2][0] <= image1[2][1];   
        image1[2][6] <= image1[2][5];   
        image1[3][0] <= image1[3][1];   
        image1[3][6] <= image1[3][5];   
        image1[4][0] <= image1[4][1];   
        image1[4][6] <= image1[4][5];   
        image1[5][0] <= image1[5][1];  
        image1[5][6] <= image1[5][5];   
        image1[6][0] <= image1[5][1];
        image1[6][1] <= image1[5][1];
        image1[6][2] <= image1[5][2];
        image1[6][3] <= image1[5][3];
        image1[6][4] <= image1[5][4];
        image1[6][5] <= image1[5][5];
        image1[6][6] <= image1[5][5];
    end */
end

always @(*)begin//comp
    case(counter_cal)
        1 : begin
            comp1 = cal_map[1][1];
            comp2 = cal_map[1][2];
            comp3 = cal_map[2][1];
            comp4 = cal_map[2][2];
        end
        2 : begin
            comp1 = cal_map[1][3];
            comp2 = cal_map[1][4];
            comp3 = cal_map[2][3];
            comp4 = cal_map[2][4];
        end
        3 : begin
            comp1 = cal_map[1][5];
            comp2 = cal_map[1][6];
            comp3 = cal_map[2][5];
            comp4 = cal_map[2][6];
        end
        4 : begin
            comp1 = cal_map[1][7];
            comp2 = cal_map[1][8];
            comp3 = cal_map[2][7];
            comp4 = cal_map[2][8];
        end
        5 : begin
            comp1 = cal_map[1][9];
            comp2 = cal_map[1][10];
            comp3 = cal_map[2][9];
            comp4 = cal_map[2][10];
        end
        6 : begin
            comp1 = cal_map[1][11];
            comp2 = cal_map[1][12];
            comp3 = cal_map[2][11];
            comp4 = cal_map[2][12];
        end
        7 : begin
            comp1 = cal_map[1][13];
            comp2 = cal_map[1][14];
            comp3 = cal_map[2][13];
            comp4 = cal_map[2][14];
        end
        8 : begin
            comp1 = cal_map[1][15];
            comp2 = cal_map[1][16];
            comp3 = cal_map[2][15];
            comp4 = cal_map[2][16];
        end
        9 : begin
            comp1 = cal_map[3][1];
            comp2 = cal_map[3][2];
            comp3 = cal_map[4][1];
            comp4 = cal_map[4][2];
        end
        10 : begin
            comp1 = cal_map[3][3];
            comp2 = cal_map[3][4];
            comp3 = cal_map[4][3];
            comp4 = cal_map[4][4];
        end
        11 : begin
            comp1 = cal_map[3][5];
            comp2 = cal_map[3][6];
            comp3 = cal_map[4][5];
            comp4 = cal_map[4][6];
        end
        12 : begin
            comp1 = cal_map[3][7];
            comp2 = cal_map[3][8];
            comp3 = cal_map[4][7];
            comp4 = cal_map[4][8];
        end
        13 : begin
            comp1 = cal_map[3][9];
            comp2 = cal_map[3][10];
            comp3 = cal_map[4][9];
            comp4 = cal_map[4][10];
        end
        14 : begin
            comp1 = cal_map[3][11];
            comp2 = cal_map[3][12];
            comp3 = cal_map[4][11];
            comp4 = cal_map[4][12];
        end
        15 : begin
            comp1 = cal_map[3][13];
            comp2 = cal_map[3][14];
            comp3 = cal_map[4][13];
            comp4 = cal_map[4][14];
        end
        16 : begin
            comp1 = cal_map[3][15];
            comp2 = cal_map[3][16];
            comp3 = cal_map[4][15];
            comp4 = cal_map[4][16];
        end
        17 : begin
            comp1 = cal_map[5][1];
            comp2 = cal_map[5][2];
            comp3 = cal_map[6][1];
            comp4 = cal_map[6][2];
        end
        18 : begin
            comp1 = cal_map[5][3];
            comp2 = cal_map[5][4];
            comp3 = cal_map[6][3];
            comp4 = cal_map[6][4];
        end
        19 : begin
            comp1 = cal_map[5][5];
            comp2 = cal_map[5][6];
            comp3 = cal_map[6][5];
            comp4 = cal_map[6][6];
        end
        20 : begin
            comp1 = cal_map[5][7];
            comp2 = cal_map[5][8];
            comp3 = cal_map[6][7];
            comp4 = cal_map[6][8];
        end
        21 : begin
            comp1 = cal_map[5][9];
            comp2 = cal_map[5][10];
            comp3 = cal_map[6][9];
            comp4 = cal_map[6][10];
        end
        22 : begin
            comp1 = cal_map[5][11];
            comp2 = cal_map[5][12];
            comp3 = cal_map[6][11];
            comp4 = cal_map[6][12];
        end
        23 : begin
            comp1 = cal_map[5][13];
            comp2 = cal_map[5][14];
            comp3 = cal_map[6][13];
            comp4 = cal_map[6][14];
        end
        24 : begin
            comp1 = cal_map[5][15];
            comp2 = cal_map[5][16];
            comp3 = cal_map[6][15];
            comp4 = cal_map[6][16];
        end
        25 : begin
            comp1 = cal_map[7][1];
            comp2 = cal_map[7][2];
            comp3 = cal_map[8][1];
            comp4 = cal_map[8][2];
        end
        26 : begin
            comp1 = cal_map[7][3];
            comp2 = cal_map[7][4];
            comp3 = cal_map[8][3];
            comp4 = cal_map[8][4];
        end
        27 : begin
            comp1 = cal_map[7][5];
            comp2 = cal_map[7][6];
            comp3 = cal_map[8][5];
            comp4 = cal_map[8][6];
        end
        28 : begin
            comp1 = cal_map[7][7];
            comp2 = cal_map[7][8];
            comp3 = cal_map[8][7];
            comp4 = cal_map[8][8];
        end
        29 : begin
            comp1 = cal_map[7][9];
            comp2 = cal_map[7][10];
            comp3 = cal_map[8][9];
            comp4 = cal_map[8][10];
        end
        30 : begin
            comp1 = cal_map[7][11];
            comp2 = cal_map[7][12];
            comp3 = cal_map[8][11];
            comp4 = cal_map[8][12];
        end
        31 : begin
            comp1 = cal_map[7][13];
            comp2 = cal_map[7][14];
            comp3 = cal_map[8][13];
            comp4 = cal_map[8][14];
        end
        32 : begin
            comp1 = cal_map[7][15];
            comp2 = cal_map[7][16];
            comp3 = cal_map[8][15];
            comp4 = cal_map[8][16];
        end
        33 : begin
            comp1 = cal_map[9][1];
            comp2 = cal_map[9][2];
            comp3 = cal_map[10][1];
            comp4 = cal_map[10][2];
        end
        34 : begin
            comp1 = cal_map[9][3];
            comp2 = cal_map[9][4];
            comp3 = cal_map[10][3];
            comp4 = cal_map[10][4];
        end
        35 : begin
            comp1 = cal_map[9][5];
            comp2 = cal_map[9][6];
            comp3 = cal_map[10][5];
            comp4 = cal_map[10][6];
        end
        36 : begin
            comp1 = cal_map[9][7];
            comp2 = cal_map[9][8];
            comp3 = cal_map[10][7];
            comp4 = cal_map[10][8];
        end
        37 : begin
            comp1 = cal_map[9][9];
            comp2 = cal_map[9][10];
            comp3 = cal_map[10][9];
            comp4 = cal_map[10][10];
        end
        38 : begin
            comp1 = cal_map[9][11];
            comp2 = cal_map[9][12];
            comp3 = cal_map[10][11];
            comp4 = cal_map[10][12];
        end
        39 : begin
            comp1 = cal_map[9][13];
            comp2 = cal_map[9][14];
            comp3 = cal_map[10][13];
            comp4 = cal_map[10][14];
        end
        40 : begin
            comp1 = cal_map[9][15];
            comp2 = cal_map[9][16];
            comp3 = cal_map[10][15];
            comp4 = cal_map[10][16];
        end
        41 : begin
            comp1 = cal_map[11][1];
            comp2 = cal_map[11][2];
            comp3 = cal_map[12][1];
            comp4 = cal_map[12][2];
        end
        42 : begin
            comp1 = cal_map[11][3];
            comp2 = cal_map[11][4];
            comp3 = cal_map[12][3];
            comp4 = cal_map[12][4];
        end
        43 : begin
            comp1 = cal_map[11][5];
            comp2 = cal_map[11][6];
            comp3 = cal_map[12][5];
            comp4 = cal_map[12][6];
        end
        44 : begin
            comp1 = cal_map[11][7];
            comp2 = cal_map[11][8];
            comp3 = cal_map[12][7];
            comp4 = cal_map[12][8];
        end
        45 : begin
            comp1 = cal_map[11][9];
            comp2 = cal_map[11][10];
            comp3 = cal_map[12][9];
            comp4 = cal_map[12][10];
        end
        46 : begin
            comp1 = cal_map[11][11];
            comp2 = cal_map[11][12];
            comp3 = cal_map[12][11];
            comp4 = cal_map[12][12];
        end
        47 : begin
            comp1 = cal_map[11][13];
            comp2 = cal_map[11][14];
            comp3 = cal_map[12][13];
            comp4 = cal_map[12][14];
        end
        48 : begin
            comp1 = cal_map[11][15];
            comp2 = cal_map[11][16];
            comp3 = cal_map[12][15];
            comp4 = cal_map[12][16];
        end
        49 : begin
            comp1 = cal_map[13][1];
            comp2 = cal_map[13][2];
            comp3 = cal_map[14][1];
            comp4 = cal_map[14][2];
        end
        50 : begin
            comp1 = cal_map[13][3];
            comp2 = cal_map[13][4];
            comp3 = cal_map[14][3];
            comp4 = cal_map[14][4];
        end
        51 : begin
            comp1 = cal_map[13][5];
            comp2 = cal_map[13][6];
            comp3 = cal_map[14][5];
            comp4 = cal_map[14][6];
        end
        52 : begin
            comp1 = cal_map[13][7];
            comp2 = cal_map[13][8];
            comp3 = cal_map[14][7];
            comp4 = cal_map[14][8];
        end
        53 : begin
            comp1 = cal_map[13][9];
            comp2 = cal_map[13][10];
            comp3 = cal_map[14][9];
            comp4 = cal_map[14][10];
        end
        54 : begin
            comp1 = cal_map[13][11];
            comp2 = cal_map[13][12];
            comp3 = cal_map[14][11];
            comp4 = cal_map[14][12];
        end
        55 : begin
            comp1 = cal_map[13][13];
            comp2 = cal_map[13][14];
            comp3 = cal_map[14][13];
            comp4 = cal_map[14][14];
        end
        56 : begin
            comp1 = cal_map[13][15];
            comp2 = cal_map[13][16];
            comp3 = cal_map[14][15];
            comp4 = cal_map[14][16];
        end
        57 : begin
            comp1 = cal_map[15][1];
            comp2 = cal_map[15][2];
            comp3 = cal_map[16][1];
            comp4 = cal_map[16][2];
        end
        58 : begin
            comp1 = cal_map[15][3];
            comp2 = cal_map[15][4];
            comp3 = cal_map[16][3];
            comp4 = cal_map[16][4];
        end
        59 : begin
            comp1 = cal_map[15][5];
            comp2 = cal_map[15][6];
            comp3 = cal_map[16][5];
            comp4 = cal_map[16][6];
        end
        60 : begin
            comp1 = cal_map[15][7];
            comp2 = cal_map[15][8];
            comp3 = cal_map[16][7];
            comp4 = cal_map[16][8];
        end
        61 : begin
            comp1 = cal_map[15][9];
            comp2 = cal_map[15][10];
            comp3 = cal_map[16][9];
            comp4 = cal_map[16][10];
        end
        62 : begin
            comp1 = cal_map[15][11];
            comp2 = cal_map[15][12];
            comp3 = cal_map[16][11];
            comp4 = cal_map[16][12];
        end
        63 : begin
            comp1 = cal_map[15][13];
            comp2 = cal_map[15][14];
            comp3 = cal_map[16][13];
            comp4 = cal_map[16][14];
        end
        64 : begin
            comp1 = cal_map[15][15];
            comp2 = cal_map[15][16];
            comp3 = cal_map[16][15];
            comp4 = cal_map[16][16];
        end

        default: begin
            comp1 = 0;
            comp2 = 0;
            comp3 = 0;
            comp4 = 0;
        end

    endcase
end

always @ (*) begin //com
    comp12 = (comp1>comp2)?comp1:comp2;
    comp34 = (comp3>comp4)?comp3:comp4;
    compall = (comp12>comp34)?comp12:comp34;
end

always @(*)begin //conv
    case(counter_cal)
        1 : begin 
            conv1 = cal_map[0][0];
            conv2 = cal_map[0][1];
            conv3 = cal_map[0][2];
            conv4 = cal_map[1][0];
            conv5 = cal_map[1][1];
            conv6 = cal_map[1][2];
            conv7 = cal_map[2][0];
            conv8 = cal_map[2][1];
            conv9 = cal_map[2][2];
        end
        2 : begin 
            conv1 = cal_map[0][1];
            conv2 = cal_map[0][2];
            conv3 = cal_map[0][3];
            conv4 = cal_map[1][1];
            conv5 = cal_map[1][2];
            conv6 = cal_map[1][3];
            conv7 = cal_map[2][1];
            conv8 = cal_map[2][2];
            conv9 = cal_map[2][3];
        end
        3 : begin 
            conv1 = cal_map[0][2];
            conv2 = cal_map[0][3];
            conv3 = cal_map[0][4];
            conv4 = cal_map[1][2];
            conv5 = cal_map[1][3];
            conv6 = cal_map[1][4];
            conv7 = cal_map[2][2];
            conv8 = cal_map[2][3];
            conv9 = cal_map[2][4];
        end
        4 : begin 
            conv1 = cal_map[0][3];
            conv2 = cal_map[0][4];
            conv3 = cal_map[0][5];
            conv4 = cal_map[1][3];
            conv5 = cal_map[1][4];
            conv6 = cal_map[1][5];
            conv7 = cal_map[2][3];
            conv8 = cal_map[2][4];
            conv9 = cal_map[2][5];
        end
        5 : begin 
            conv1 = cal_map[0][4];
            conv2 = cal_map[0][5];
            conv3 = cal_map[0][6];
            conv4 = cal_map[1][4];
            conv5 = cal_map[1][5];
            conv6 = cal_map[1][6];
            conv7 = cal_map[2][4];
            conv8 = cal_map[2][5];
            conv9 = cal_map[2][6];
        end
        6 : begin 
            conv1 = cal_map[0][5];
            conv2 = cal_map[0][6];
            conv3 = cal_map[0][7];
            conv4 = cal_map[1][5];
            conv5 = cal_map[1][6];
            conv6 = cal_map[1][7];
            conv7 = cal_map[2][5];
            conv8 = cal_map[2][6];
            conv9 = cal_map[2][7];
        end
        7 : begin 
            conv1 = cal_map[0][6];
            conv2 = cal_map[0][7];
            conv3 = cal_map[0][8];
            conv4 = cal_map[1][6];
            conv5 = cal_map[1][7];
            conv6 = cal_map[1][8];
            conv7 = cal_map[2][6];
            conv8 = cal_map[2][7];
            conv9 = cal_map[2][8];
        end
        8 : begin 
            conv1 = cal_map[0][7];
            conv2 = cal_map[0][8];
            conv3 = cal_map[0][9];
            conv4 = cal_map[1][7];
            conv5 = cal_map[1][8];
            conv6 = cal_map[1][9];
            conv7 = cal_map[2][7];
            conv8 = cal_map[2][8];
            conv9 = cal_map[2][9];
        end
        9 : begin 
            conv1 = cal_map[0][8];
            conv2 = cal_map[0][9];
            conv3 = cal_map[0][10];
            conv4 = cal_map[1][8];
            conv5 = cal_map[1][9];
            conv6 = cal_map[1][10];
            conv7 = cal_map[2][8];
            conv8 = cal_map[2][9];
            conv9 = cal_map[2][10];
        end
        10 : begin 
            conv1 = cal_map[0][9];
            conv2 = cal_map[0][10];
            conv3 = cal_map[0][11];
            conv4 = cal_map[1][9];
            conv5 = cal_map[1][10];
            conv6 = cal_map[1][11];
            conv7 = cal_map[2][9];
            conv8 = cal_map[2][10];
            conv9 = cal_map[2][11];
        end
        11 : begin 
            conv1 = cal_map[0][10];
            conv2 = cal_map[0][11];
            conv3 = cal_map[0][12];
            conv4 = cal_map[1][10];
            conv5 = cal_map[1][11];
            conv6 = cal_map[1][12];
            conv7 = cal_map[2][10];
            conv8 = cal_map[2][11];
            conv9 = cal_map[2][12];
        end
        12 : begin 
            conv1 = cal_map[0][11];
            conv2 = cal_map[0][12];
            conv3 = cal_map[0][13];
            conv4 = cal_map[1][11];
            conv5 = cal_map[1][12];
            conv6 = cal_map[1][13];
            conv7 = cal_map[2][11];
            conv8 = cal_map[2][12];
            conv9 = cal_map[2][13];
        end
        13 : begin 
            conv1 = cal_map[0][12];
            conv2 = cal_map[0][13];
            conv3 = cal_map[0][14];
            conv4 = cal_map[1][12];
            conv5 = cal_map[1][13];
            conv6 = cal_map[1][14];
            conv7 = cal_map[2][12];
            conv8 = cal_map[2][13];
            conv9 = cal_map[2][14];
        end
        14 : begin 
            conv1 = cal_map[0][13];
            conv2 = cal_map[0][14];
            conv3 = cal_map[0][15];
            conv4 = cal_map[1][13];
            conv5 = cal_map[1][14];
            conv6 = cal_map[1][15];
            conv7 = cal_map[2][13];
            conv8 = cal_map[2][14];
            conv9 = cal_map[2][15];
        end
        15 : begin 
            conv1 = cal_map[0][14];
            conv2 = cal_map[0][15];
            conv3 = cal_map[0][16];
            conv4 = cal_map[1][14];
            conv5 = cal_map[1][15];
            conv6 = cal_map[1][16];
            conv7 = cal_map[2][14];
            conv8 = cal_map[2][15];
            conv9 = cal_map[2][16];
        end
        16 : begin 
            conv1 = cal_map[0][15];
            conv2 = cal_map[0][16];
            conv3 = cal_map[0][17];
            conv4 = cal_map[1][15];
            conv5 = cal_map[1][16];
            conv6 = cal_map[1][17];
            conv7 = cal_map[2][15];
            conv8 = cal_map[2][16];
            conv9 = cal_map[2][17];
        end
        17 : begin 
            conv1 = cal_map[1][0];
            conv2 = cal_map[1][1];
            conv3 = cal_map[1][2];
            conv4 = cal_map[2][0];
            conv5 = cal_map[2][1];
            conv6 = cal_map[2][2];
            conv7 = cal_map[3][0];
            conv8 = cal_map[3][1];
            conv9 = cal_map[3][2];
        end
                18 : begin 
            conv1 = cal_map[1][1];
            conv2 = cal_map[1][2];
            conv3 = cal_map[1][3];
            conv4 = cal_map[2][1];
            conv5 = cal_map[2][2];
            conv6 = cal_map[2][3];
            conv7 = cal_map[3][1];
            conv8 = cal_map[3][2];
            conv9 = cal_map[3][3];
        end
        19 : begin 
            conv1 = cal_map[1][2];
            conv2 = cal_map[1][3];
            conv3 = cal_map[1][4];
            conv4 = cal_map[2][2];
            conv5 = cal_map[2][3];
            conv6 = cal_map[2][4];
            conv7 = cal_map[3][2];
            conv8 = cal_map[3][3];
            conv9 = cal_map[3][4];
        end
        20 : begin 
            conv1 = cal_map[1][3];
            conv2 = cal_map[1][4];
            conv3 = cal_map[1][5];
            conv4 = cal_map[2][3];
            conv5 = cal_map[2][4];
            conv6 = cal_map[2][5];
            conv7 = cal_map[3][3];
            conv8 = cal_map[3][4];
            conv9 = cal_map[3][5];
        end
        21 : begin 
            conv1 = cal_map[1][4];
            conv2 = cal_map[1][5];
            conv3 = cal_map[1][6];
            conv4 = cal_map[2][4];
            conv5 = cal_map[2][5];
            conv6 = cal_map[2][6];
            conv7 = cal_map[3][4];
            conv8 = cal_map[3][5];
            conv9 = cal_map[3][6];
        end
        22 : begin 
            conv1 = cal_map[1][5];
            conv2 = cal_map[1][6];
            conv3 = cal_map[1][7];
            conv4 = cal_map[2][5];
            conv5 = cal_map[2][6];
            conv6 = cal_map[2][7];
            conv7 = cal_map[3][5];
            conv8 = cal_map[3][6];
            conv9 = cal_map[3][7];
        end
        23 : begin 
            conv1 = cal_map[1][6];
            conv2 = cal_map[1][7];
            conv3 = cal_map[1][8];
            conv4 = cal_map[2][6];
            conv5 = cal_map[2][7];
            conv6 = cal_map[2][8];
            conv7 = cal_map[3][6];
            conv8 = cal_map[3][7];
            conv9 = cal_map[3][8];
        end
        24 : begin 
            conv1 = cal_map[1][7];
            conv2 = cal_map[1][8];
            conv3 = cal_map[1][9];
            conv4 = cal_map[2][7];
            conv5 = cal_map[2][8];
            conv6 = cal_map[2][9];
            conv7 = cal_map[3][7];
            conv8 = cal_map[3][8];
            conv9 = cal_map[3][9];
        end
        25 : begin 
            conv1 = cal_map[1][8];
            conv2 = cal_map[1][9];
            conv3 = cal_map[1][10];
            conv4 = cal_map[2][8];
            conv5 = cal_map[2][9];
            conv6 = cal_map[2][10];
            conv7 = cal_map[3][8];
            conv8 = cal_map[3][9];
            conv9 = cal_map[3][10];
        end
        26 : begin 
            conv1 = cal_map[1][9];
            conv2 = cal_map[1][10];
            conv3 = cal_map[1][11];
            conv4 = cal_map[2][9];
            conv5 = cal_map[2][10];
            conv6 = cal_map[2][11];
            conv7 = cal_map[3][9];
            conv8 = cal_map[3][10];
            conv9 = cal_map[3][11];
        end
        27 : begin 
            conv1 = cal_map[1][10];
            conv2 = cal_map[1][11];
            conv3 = cal_map[1][12];
            conv4 = cal_map[2][10];
            conv5 = cal_map[2][11];
            conv6 = cal_map[2][12];
            conv7 = cal_map[3][10];
            conv8 = cal_map[3][11];
            conv9 = cal_map[3][12];
        end
        28 : begin 
            conv1 = cal_map[1][11];
            conv2 = cal_map[1][12];
            conv3 = cal_map[1][13];
            conv4 = cal_map[2][11];
            conv5 = cal_map[2][12];
            conv6 = cal_map[2][13];
            conv7 = cal_map[3][11];
            conv8 = cal_map[3][12];
            conv9 = cal_map[3][13];
        end
        29 : begin 
            conv1 = cal_map[1][12];
            conv2 = cal_map[1][13];
            conv3 = cal_map[1][14];
            conv4 = cal_map[2][12];
            conv5 = cal_map[2][13];
            conv6 = cal_map[2][14];
            conv7 = cal_map[3][12];
            conv8 = cal_map[3][13];
            conv9 = cal_map[3][14];
        end
        30 : begin 
            conv1 = cal_map[1][13];
            conv2 = cal_map[1][14];
            conv3 = cal_map[1][15];
            conv4 = cal_map[2][13];
            conv5 = cal_map[2][14];
            conv6 = cal_map[2][15];
            conv7 = cal_map[3][13];
            conv8 = cal_map[3][14];
            conv9 = cal_map[3][15];
        end
        31 : begin 
            conv1 = cal_map[1][14];
            conv2 = cal_map[1][15];
            conv3 = cal_map[1][16];
            conv4 = cal_map[2][14];
            conv5 = cal_map[2][15];
            conv6 = cal_map[2][16];
            conv7 = cal_map[3][14];
            conv8 = cal_map[3][15];
            conv9 = cal_map[3][16];
        end
        32 : begin 
            conv1 = cal_map[1][15];
            conv2 = cal_map[1][16];
            conv3 = cal_map[1][17];
            conv4 = cal_map[2][15];
            conv5 = cal_map[2][16];
            conv6 = cal_map[2][17];
            conv7 = cal_map[3][15];
            conv8 = cal_map[3][16];
            conv9 = cal_map[3][17];
        end
        33 : begin 
            conv1 = cal_map[2][0];
            conv2 = cal_map[2][1];
            conv3 = cal_map[2][2];
            conv4 = cal_map[3][0];
            conv5 = cal_map[3][1];
            conv6 = cal_map[3][2];
            conv7 = cal_map[4][0];
            conv8 = cal_map[4][1];
            conv9 = cal_map[4][2];
        end
        34 : begin 
            conv1 = cal_map[2][1];
            conv2 = cal_map[2][2];
            conv3 = cal_map[2][3];
            conv4 = cal_map[3][1];
            conv5 = cal_map[3][2];
            conv6 = cal_map[3][3];
            conv7 = cal_map[4][1];
            conv8 = cal_map[4][2];
            conv9 = cal_map[4][3];
        end
        35 : begin 
            conv1 = cal_map[2][2];
            conv2 = cal_map[2][3];
            conv3 = cal_map[2][4];
            conv4 = cal_map[3][2];
            conv5 = cal_map[3][3];
            conv6 = cal_map[3][4];
            conv7 = cal_map[4][2];
            conv8 = cal_map[4][3];
            conv9 = cal_map[4][4];
        end
        36 : begin 
            conv1 = cal_map[2][3];
            conv2 = cal_map[2][4];
            conv3 = cal_map[2][5];
            conv4 = cal_map[3][3];
            conv5 = cal_map[3][4];
            conv6 = cal_map[3][5];
            conv7 = cal_map[4][3];
            conv8 = cal_map[4][4];
            conv9 = cal_map[4][5];
        end
        37 : begin 
            conv1 = cal_map[2][4];
            conv2 = cal_map[2][5];
            conv3 = cal_map[2][6];
            conv4 = cal_map[3][4];
            conv5 = cal_map[3][5];
            conv6 = cal_map[3][6];
            conv7 = cal_map[4][4];
            conv8 = cal_map[4][5];
            conv9 = cal_map[4][6];
        end
        38 : begin 
            conv1 = cal_map[2][5];
            conv2 = cal_map[2][6];
            conv3 = cal_map[2][7];
            conv4 = cal_map[3][5];
            conv5 = cal_map[3][6];
            conv6 = cal_map[3][7];
            conv7 = cal_map[4][5];
            conv8 = cal_map[4][6];
            conv9 = cal_map[4][7];
        end
        39 : begin 
            conv1 = cal_map[2][6];
            conv2 = cal_map[2][7];
            conv3 = cal_map[2][8];
            conv4 = cal_map[3][6];
            conv5 = cal_map[3][7];
            conv6 = cal_map[3][8];
            conv7 = cal_map[4][6];
            conv8 = cal_map[4][7];
            conv9 = cal_map[4][8];
        end
        40 : begin 
            conv1 = cal_map[2][7];
            conv2 = cal_map[2][8];
            conv3 = cal_map[2][9];
            conv4 = cal_map[3][7];
            conv5 = cal_map[3][8];
            conv6 = cal_map[3][9];
            conv7 = cal_map[4][7];
            conv8 = cal_map[4][8];
            conv9 = cal_map[4][9];
        end
        41 : begin 
            conv1 = cal_map[2][8];
            conv2 = cal_map[2][9];
            conv3 = cal_map[2][10];
            conv4 = cal_map[3][8];
            conv5 = cal_map[3][9];
            conv6 = cal_map[3][10];
            conv7 = cal_map[4][8];
            conv8 = cal_map[4][9];
            conv9 = cal_map[4][10];
        end
        42 : begin 
            conv1 = cal_map[2][9];
            conv2 = cal_map[2][10];
            conv3 = cal_map[2][11];
            conv4 = cal_map[3][9];
            conv5 = cal_map[3][10];
            conv6 = cal_map[3][11];
            conv7 = cal_map[4][9];
            conv8 = cal_map[4][10];
            conv9 = cal_map[4][11];
        end
        43 : begin 
            conv1 = cal_map[2][10];
            conv2 = cal_map[2][11];
            conv3 = cal_map[2][12];
            conv4 = cal_map[3][10];
            conv5 = cal_map[3][11];
            conv6 = cal_map[3][12];
            conv7 = cal_map[4][10];
            conv8 = cal_map[4][11];
            conv9 = cal_map[4][12];
        end
        44 : begin 
            conv1 = cal_map[2][11];
            conv2 = cal_map[2][12];
            conv3 = cal_map[2][13];
            conv4 = cal_map[3][11];
            conv5 = cal_map[3][12];
            conv6 = cal_map[3][13];
            conv7 = cal_map[4][11];
            conv8 = cal_map[4][12];
            conv9 = cal_map[4][13];
        end
        45 : begin 
            conv1 = cal_map[2][12];
            conv2 = cal_map[2][13];
            conv3 = cal_map[2][14];
            conv4 = cal_map[3][12];
            conv5 = cal_map[3][13];
            conv6 = cal_map[3][14];
            conv7 = cal_map[4][12];
            conv8 = cal_map[4][13];
            conv9 = cal_map[4][14];
        end
        46 : begin 
            conv1 = cal_map[2][13];
            conv2 = cal_map[2][14];
            conv3 = cal_map[2][15];
            conv4 = cal_map[3][13];
            conv5 = cal_map[3][14];
            conv6 = cal_map[3][15];
            conv7 = cal_map[4][13];
            conv8 = cal_map[4][14];
            conv9 = cal_map[4][15];
        end
        47 : begin 
            conv1 = cal_map[2][14];
            conv2 = cal_map[2][15];
            conv3 = cal_map[2][16];
            conv4 = cal_map[3][14];
            conv5 = cal_map[3][15];
            conv6 = cal_map[3][16];
            conv7 = cal_map[4][14];
            conv8 = cal_map[4][15];
            conv9 = cal_map[4][16];
        end
        48 : begin 
            conv1 = cal_map[2][15];
            conv2 = cal_map[2][16];
            conv3 = cal_map[2][17];
            conv4 = cal_map[3][15];
            conv5 = cal_map[3][16];
            conv6 = cal_map[3][17];
            conv7 = cal_map[4][15];
            conv8 = cal_map[4][16];
            conv9 = cal_map[4][17];
        end
        49 : begin 
            conv1 = cal_map[3][0];
            conv2 = cal_map[3][1];
            conv3 = cal_map[3][2];
            conv4 = cal_map[4][0];
            conv5 = cal_map[4][1];
            conv6 = cal_map[4][2];
            conv7 = cal_map[5][0];
            conv8 = cal_map[5][1];
            conv9 = cal_map[5][2];
        end
        50 : begin 
            conv1 = cal_map[3][1];
            conv2 = cal_map[3][2];
            conv3 = cal_map[3][3];
            conv4 = cal_map[4][1];
            conv5 = cal_map[4][2];
            conv6 = cal_map[4][3];
            conv7 = cal_map[5][1];
            conv8 = cal_map[5][2];
            conv9 = cal_map[5][3];
        end
        51 : begin 
            conv1 = cal_map[3][2];
            conv2 = cal_map[3][3];
            conv3 = cal_map[3][4];
            conv4 = cal_map[4][2];
            conv5 = cal_map[4][3];
            conv6 = cal_map[4][4];
            conv7 = cal_map[5][2];
            conv8 = cal_map[5][3];
            conv9 = cal_map[5][4];
        end
        52 : begin 
            conv1 = cal_map[3][3];
            conv2 = cal_map[3][4];
            conv3 = cal_map[3][5];
            conv4 = cal_map[4][3];
            conv5 = cal_map[4][4];
            conv6 = cal_map[4][5];
            conv7 = cal_map[5][3];
            conv8 = cal_map[5][4];
            conv9 = cal_map[5][5];
        end
        53 : begin 
            conv1 = cal_map[3][4];
            conv2 = cal_map[3][5];
            conv3 = cal_map[3][6];
            conv4 = cal_map[4][4];
            conv5 = cal_map[4][5];
            conv6 = cal_map[4][6];
            conv7 = cal_map[5][4];
            conv8 = cal_map[5][5];
            conv9 = cal_map[5][6];
        end
        54 : begin 
            conv1 = cal_map[3][5];
            conv2 = cal_map[3][6];
            conv3 = cal_map[3][7];
            conv4 = cal_map[4][5];
            conv5 = cal_map[4][6];
            conv6 = cal_map[4][7];
            conv7 = cal_map[5][5];
            conv8 = cal_map[5][6];
            conv9 = cal_map[5][7];
        end
        55 : begin 
            conv1 = cal_map[3][6];
            conv2 = cal_map[3][7];
            conv3 = cal_map[3][8];
            conv4 = cal_map[4][6];
            conv5 = cal_map[4][7];
            conv6 = cal_map[4][8];
            conv7 = cal_map[5][6];
            conv8 = cal_map[5][7];
            conv9 = cal_map[5][8];
        end
        56 : begin 
            conv1 = cal_map[3][7];
            conv2 = cal_map[3][8];
            conv3 = cal_map[3][9];
            conv4 = cal_map[4][7];
            conv5 = cal_map[4][8];
            conv6 = cal_map[4][9];
            conv7 = cal_map[5][7];
            conv8 = cal_map[5][8];
            conv9 = cal_map[5][9];
        end
        57 : begin 
            conv1 = cal_map[3][8];
            conv2 = cal_map[3][9];
            conv3 = cal_map[3][10];
            conv4 = cal_map[4][8];
            conv5 = cal_map[4][9];
            conv6 = cal_map[4][10];
            conv7 = cal_map[5][8];
            conv8 = cal_map[5][9];
            conv9 = cal_map[5][10];
        end
        58 : begin 
            conv1 = cal_map[3][9];
            conv2 = cal_map[3][10];
            conv3 = cal_map[3][11];
            conv4 = cal_map[4][9];
            conv5 = cal_map[4][10];
            conv6 = cal_map[4][11];
            conv7 = cal_map[5][9];
            conv8 = cal_map[5][10];
            conv9 = cal_map[5][11];
        end
        59 : begin 
            conv1 = cal_map[3][10];
            conv2 = cal_map[3][11];
            conv3 = cal_map[3][12];
            conv4 = cal_map[4][10];
            conv5 = cal_map[4][11];
            conv6 = cal_map[4][12];
            conv7 = cal_map[5][10];
            conv8 = cal_map[5][11];
            conv9 = cal_map[5][12];
        end
        60 : begin 
            conv1 = cal_map[3][11];
            conv2 = cal_map[3][12];
            conv3 = cal_map[3][13];
            conv4 = cal_map[4][11];
            conv5 = cal_map[4][12];
            conv6 = cal_map[4][13];
            conv7 = cal_map[5][11];
            conv8 = cal_map[5][12];
            conv9 = cal_map[5][13];
        end
        61 : begin 
            conv1 = cal_map[3][12];
            conv2 = cal_map[3][13];
            conv3 = cal_map[3][14];
            conv4 = cal_map[4][12];
            conv5 = cal_map[4][13];
            conv6 = cal_map[4][14];
            conv7 = cal_map[5][12];
            conv8 = cal_map[5][13];
            conv9 = cal_map[5][14];
        end
        62 : begin 
            conv1 = cal_map[3][13];
            conv2 = cal_map[3][14];
            conv3 = cal_map[3][15];
            conv4 = cal_map[4][13];
            conv5 = cal_map[4][14];
            conv6 = cal_map[4][15];
            conv7 = cal_map[5][13];
            conv8 = cal_map[5][14];
            conv9 = cal_map[5][15];
        end
        63 : begin 
            conv1 = cal_map[3][14];
            conv2 = cal_map[3][15];
            conv3 = cal_map[3][16];
            conv4 = cal_map[4][14];
            conv5 = cal_map[4][15];
            conv6 = cal_map[4][16];
            conv7 = cal_map[5][14];
            conv8 = cal_map[5][15];
            conv9 = cal_map[5][16];
        end
        64 : begin 
            conv1 = cal_map[3][15];
            conv2 = cal_map[3][16];
            conv3 = cal_map[3][17];
            conv4 = cal_map[4][15];
            conv5 = cal_map[4][16];
            conv6 = cal_map[4][17];
            conv7 = cal_map[5][15];
            conv8 = cal_map[5][16];
            conv9 = cal_map[5][17];
        end
        65 : begin 
            conv1 = cal_map[4][0];
            conv2 = cal_map[4][1];
            conv3 = cal_map[4][2];
            conv4 = cal_map[5][0];
            conv5 = cal_map[5][1];
            conv6 = cal_map[5][2];
            conv7 = cal_map[6][0];
            conv8 = cal_map[6][1];
            conv9 = cal_map[6][2];
        end
        66 : begin 
            conv1 = cal_map[4][1];
            conv2 = cal_map[4][2];
            conv3 = cal_map[4][3];
            conv4 = cal_map[5][1];
            conv5 = cal_map[5][2];
            conv6 = cal_map[5][3];
            conv7 = cal_map[6][1];
            conv8 = cal_map[6][2];
            conv9 = cal_map[6][3];
        end
        67 : begin 
            conv1 = cal_map[4][2];
            conv2 = cal_map[4][3];
            conv3 = cal_map[4][4];
            conv4 = cal_map[5][2];
            conv5 = cal_map[5][3];
            conv6 = cal_map[5][4];
            conv7 = cal_map[6][2];
            conv8 = cal_map[6][3];
            conv9 = cal_map[6][4];
        end
        68 : begin 
            conv1 = cal_map[4][3];
            conv2 = cal_map[4][4];
            conv3 = cal_map[4][5];
            conv4 = cal_map[5][3];
            conv5 = cal_map[5][4];
            conv6 = cal_map[5][5];
            conv7 = cal_map[6][3];
            conv8 = cal_map[6][4];
            conv9 = cal_map[6][5];
        end
        69 : begin 
            conv1 = cal_map[4][4];
            conv2 = cal_map[4][5];
            conv3 = cal_map[4][6];
            conv4 = cal_map[5][4];
            conv5 = cal_map[5][5];
            conv6 = cal_map[5][6];
            conv7 = cal_map[6][4];
            conv8 = cal_map[6][5];
            conv9 = cal_map[6][6];
        end
        70 : begin 
            conv1 = cal_map[4][5];
            conv2 = cal_map[4][6];
            conv3 = cal_map[4][7];
            conv4 = cal_map[5][5];
            conv5 = cal_map[5][6];
            conv6 = cal_map[5][7];
            conv7 = cal_map[6][5];
            conv8 = cal_map[6][6];
            conv9 = cal_map[6][7];
        end
        71 : begin 
            conv1 = cal_map[4][6];
            conv2 = cal_map[4][7];
            conv3 = cal_map[4][8];
            conv4 = cal_map[5][6];
            conv5 = cal_map[5][7];
            conv6 = cal_map[5][8];
            conv7 = cal_map[6][6];
            conv8 = cal_map[6][7];
            conv9 = cal_map[6][8];
        end
        72 : begin 
            conv1 = cal_map[4][7];
            conv2 = cal_map[4][8];
            conv3 = cal_map[4][9];
            conv4 = cal_map[5][7];
            conv5 = cal_map[5][8];
            conv6 = cal_map[5][9];
            conv7 = cal_map[6][7];
            conv8 = cal_map[6][8];
            conv9 = cal_map[6][9];
        end
        73 : begin 
            conv1 = cal_map[4][8];
            conv2 = cal_map[4][9];
            conv3 = cal_map[4][10];
            conv4 = cal_map[5][8];
            conv5 = cal_map[5][9];
            conv6 = cal_map[5][10];
            conv7 = cal_map[6][8];
            conv8 = cal_map[6][9];
            conv9 = cal_map[6][10];
        end
        74 : begin 
            conv1 = cal_map[4][9];
            conv2 = cal_map[4][10];
            conv3 = cal_map[4][11];
            conv4 = cal_map[5][9];
            conv5 = cal_map[5][10];
            conv6 = cal_map[5][11];
            conv7 = cal_map[6][9];
            conv8 = cal_map[6][10];
            conv9 = cal_map[6][11];
        end
        75 : begin 
            conv1 = cal_map[4][10];
            conv2 = cal_map[4][11];
            conv3 = cal_map[4][12];
            conv4 = cal_map[5][10];
            conv5 = cal_map[5][11];
            conv6 = cal_map[5][12];
            conv7 = cal_map[6][10];
            conv8 = cal_map[6][11];
            conv9 = cal_map[6][12];
        end
        76 : begin 
            conv1 = cal_map[4][11];
            conv2 = cal_map[4][12];
            conv3 = cal_map[4][13];
            conv4 = cal_map[5][11];
            conv5 = cal_map[5][12];
            conv6 = cal_map[5][13];
            conv7 = cal_map[6][11];
            conv8 = cal_map[6][12];
            conv9 = cal_map[6][13];
        end
        77 : begin 
            conv1 = cal_map[4][12];
            conv2 = cal_map[4][13];
            conv3 = cal_map[4][14];
            conv4 = cal_map[5][12];
            conv5 = cal_map[5][13];
            conv6 = cal_map[5][14];
            conv7 = cal_map[6][12];
            conv8 = cal_map[6][13];
            conv9 = cal_map[6][14];
        end
        78 : begin 
            conv1 = cal_map[4][13];
            conv2 = cal_map[4][14];
            conv3 = cal_map[4][15];
            conv4 = cal_map[5][13];
            conv5 = cal_map[5][14];
            conv6 = cal_map[5][15];
            conv7 = cal_map[6][13];
            conv8 = cal_map[6][14];
            conv9 = cal_map[6][15];
        end
        79 : begin 
            conv1 = cal_map[4][14];
            conv2 = cal_map[4][15];
            conv3 = cal_map[4][16];
            conv4 = cal_map[5][14];
            conv5 = cal_map[5][15];
            conv6 = cal_map[5][16];
            conv7 = cal_map[6][14];
            conv8 = cal_map[6][15];
            conv9 = cal_map[6][16];
        end
        80 : begin 
            conv1 = cal_map[4][15];
            conv2 = cal_map[4][16];
            conv3 = cal_map[4][17];
            conv4 = cal_map[5][15];
            conv5 = cal_map[5][16];
            conv6 = cal_map[5][17];
            conv7 = cal_map[6][15];
            conv8 = cal_map[6][16];
            conv9 = cal_map[6][17];
        end
        81 : begin 
            conv1 = cal_map[5][0];
            conv2 = cal_map[5][1];
            conv3 = cal_map[5][2];
            conv4 = cal_map[6][0];
            conv5 = cal_map[6][1];
            conv6 = cal_map[6][2];
            conv7 = cal_map[7][0];
            conv8 = cal_map[7][1];
            conv9 = cal_map[7][2];
        end
        82 : begin 
            conv1 = cal_map[5][1];
            conv2 = cal_map[5][2];
            conv3 = cal_map[5][3];
            conv4 = cal_map[6][1];
            conv5 = cal_map[6][2];
            conv6 = cal_map[6][3];
            conv7 = cal_map[7][1];
            conv8 = cal_map[7][2];
            conv9 = cal_map[7][3];
        end
        83 : begin 
            conv1 = cal_map[5][2];
            conv2 = cal_map[5][3];
            conv3 = cal_map[5][4];
            conv4 = cal_map[6][2];
            conv5 = cal_map[6][3];
            conv6 = cal_map[6][4];
            conv7 = cal_map[7][2];
            conv8 = cal_map[7][3];
            conv9 = cal_map[7][4];
        end
        84 : begin 
            conv1 = cal_map[5][3];
            conv2 = cal_map[5][4];
            conv3 = cal_map[5][5];
            conv4 = cal_map[6][3];
            conv5 = cal_map[6][4];
            conv6 = cal_map[6][5];
            conv7 = cal_map[7][3];
            conv8 = cal_map[7][4];
            conv9 = cal_map[7][5];
        end
         85 : begin 
            conv1 = cal_map[5][4];
            conv2 = cal_map[5][5];
            conv3 = cal_map[5][6];
            conv4 = cal_map[6][4];
            conv5 = cal_map[6][5];
            conv6 = cal_map[6][6];
            conv7 = cal_map[7][4];
            conv8 = cal_map[7][5];
            conv9 = cal_map[7][6];
        end
        86 : begin 
        conv1 = cal_map[5][5];
        conv2 = cal_map[5][6];
        conv3 = cal_map[5][7];
        conv4 = cal_map[6][5];
        conv5 = cal_map[6][6];
        conv6 = cal_map[6][7];
        conv7 = cal_map[7][5];
        conv8 = cal_map[7][6];
        conv9 = cal_map[7][7];
    end

    87 : begin 
        conv1 = cal_map[5][6];
        conv2 = cal_map[5][7];
        conv3 = cal_map[5][8];
        conv4 = cal_map[6][6];
        conv5 = cal_map[6][7];
        conv6 = cal_map[6][8];
        conv7 = cal_map[7][6];
        conv8 = cal_map[7][7];
        conv9 = cal_map[7][8];
    end

    88 : begin 
        conv1 = cal_map[5][7];
        conv2 = cal_map[5][8];
        conv3 = cal_map[5][9];
        conv4 = cal_map[6][7];
        conv5 = cal_map[6][8];
        conv6 = cal_map[6][9];
        conv7 = cal_map[7][7];
        conv8 = cal_map[7][8];
        conv9 = cal_map[7][9];
    end

    89 : begin 
        conv1 = cal_map[5][8];
        conv2 = cal_map[5][9];
        conv3 = cal_map[5][10];
        conv4 = cal_map[6][8];
        conv5 = cal_map[6][9];
        conv6 = cal_map[6][10];
        conv7 = cal_map[7][8];
        conv8 = cal_map[7][9];
        conv9 = cal_map[7][10];
    end

    90 : begin 
        conv1 = cal_map[5][9];
        conv2 = cal_map[5][10];
        conv3 = cal_map[5][11];
        conv4 = cal_map[6][9];
        conv5 = cal_map[6][10];
        conv6 = cal_map[6][11];
        conv7 = cal_map[7][9];
        conv8 = cal_map[7][10];
        conv9 = cal_map[7][11];
    end

    91 : begin 
        conv1 = cal_map[5][10];
        conv2 = cal_map[5][11];
        conv3 = cal_map[5][12];
        conv4 = cal_map[6][10];
        conv5 = cal_map[6][11];
        conv6 = cal_map[6][12];
        conv7 = cal_map[7][10];
        conv8 = cal_map[7][11];
        conv9 = cal_map[7][12];
    end

    92 : begin 
        conv1 = cal_map[5][11];
        conv2 = cal_map[5][12];
        conv3 = cal_map[5][13];
        conv4 = cal_map[6][11];
        conv5 = cal_map[6][12];
        conv6 = cal_map[6][13];
        conv7 = cal_map[7][11];
        conv8 = cal_map[7][12];
        conv9 = cal_map[7][13];
    end

    93 : begin 
        conv1 = cal_map[5][12];
        conv2 = cal_map[5][13];
        conv3 = cal_map[5][14];
        conv4 = cal_map[6][12];
        conv5 = cal_map[6][13];
        conv6 = cal_map[6][14];
        conv7 = cal_map[7][12];
        conv8 = cal_map[7][13];
        conv9 = cal_map[7][14];
    end

    94 : begin 
        conv1 = cal_map[5][13];
        conv2 = cal_map[5][14];
        conv3 = cal_map[5][15];
        conv4 = cal_map[6][13];
        conv5 = cal_map[6][14];
        conv6 = cal_map[6][15];
        conv7 = cal_map[7][13];
        conv8 = cal_map[7][14];
        conv9 = cal_map[7][15];
    end

    95 : begin 
        conv1 = cal_map[5][14];
        conv2 = cal_map[5][15];
        conv3 = cal_map[5][16];
        conv4 = cal_map[6][14];
        conv5 = cal_map[6][15];
        conv6 = cal_map[6][16];
        conv7 = cal_map[7][14];
        conv8 = cal_map[7][15];
        conv9 = cal_map[7][16];
    end

    96 : begin 
        conv1 = cal_map[5][15];
        conv2 = cal_map[5][16];
        conv3 = cal_map[5][17];
        conv4 = cal_map[6][15];
        conv5 = cal_map[6][16];
        conv6 = cal_map[6][17];
        conv7 = cal_map[7][15];
        conv8 = cal_map[7][16];
        conv9 = cal_map[7][17];
    end

    97 : begin 
        conv1 = cal_map[6][0];
        conv2 = cal_map[6][1];
        conv3 = cal_map[6][2];
        conv4 = cal_map[7][0];
        conv5 = cal_map[7][1];
        conv6 = cal_map[7][2];
        conv7 = cal_map[8][0];
        conv8 = cal_map[8][1];
        conv9 = cal_map[8][2];
    end

    98 : begin 
        conv1 = cal_map[6][1];
        conv2 = cal_map[6][2];
        conv3 = cal_map[6][3];
        conv4 = cal_map[7][1];
        conv5 = cal_map[7][2];
        conv6 = cal_map[7][3];
        conv7 = cal_map[8][1];
        conv8 = cal_map[8][2];
        conv9 = cal_map[8][3];
    end

    99 : begin 
        conv1 = cal_map[6][2];
        conv2 = cal_map[6][3];
        conv3 = cal_map[6][4];
        conv4 = cal_map[7][2];
        conv5 = cal_map[7][3];
        conv6 = cal_map[7][4];
        conv7 = cal_map[8][2];
        conv8 = cal_map[8][3];
        conv9 = cal_map[8][4];
    end

    100 : begin 
        conv1 = cal_map[6][3];
        conv2 = cal_map[6][4];
        conv3 = cal_map[6][5];
        conv4 = cal_map[7][3];
        conv5 = cal_map[7][4];
        conv6 = cal_map[7][5];
        conv7 = cal_map[8][3];
        conv8 = cal_map[8][4];
        conv9 = cal_map[8][5];
    end

    101 : begin 
        conv1 = cal_map[6][4];
        conv2 = cal_map[6][5];
        conv3 = cal_map[6][6];
        conv4 = cal_map[7][4];
        conv5 = cal_map[7][5];
        conv6 = cal_map[7][6];
        conv7 = cal_map[8][4];
        conv8 = cal_map[8][5];
        conv9 = cal_map[8][6];
    end

    102 : begin 
        conv1 = cal_map[6][5];
        conv2 = cal_map[6][6];
        conv3 = cal_map[6][7];
        conv4 = cal_map[7][5];
        conv5 = cal_map[7][6];
        conv6 = cal_map[7][7];
        conv7 = cal_map[8][5];
        conv8 = cal_map[8][6];
        conv9 = cal_map[8][7];
    end

    103 : begin 
        conv1 = cal_map[6][6];
        conv2 = cal_map[6][7];
        conv3 = cal_map[6][8];
        conv4 = cal_map[7][6];
        conv5 = cal_map[7][7];
        conv6 = cal_map[7][8];
        conv7 = cal_map[8][6];
        conv8 = cal_map[8][7];
        conv9 = cal_map[8][8];
    end

    104 : begin 
        conv1 = cal_map[6][7];
        conv2 = cal_map[6][8];
        conv3 = cal_map[6][9];
        conv4 = cal_map[7][7];
        conv5 = cal_map[7][8];
        conv6 = cal_map[7][9];
        conv7 = cal_map[8][7];
        conv8 = cal_map[8][8];
        conv9 = cal_map[8][9];
    end

    105 : begin 
        conv1 = cal_map[6][8];
        conv2 = cal_map[6][9];
        conv3 = cal_map[6][10];
        conv4 = cal_map[7][8];
        conv5 = cal_map[7][9];
        conv6 = cal_map[7][10];
        conv7 = cal_map[8][8];
        conv8 = cal_map[8][9];
        conv9 = cal_map[8][10];
    end

    106 : begin 
        conv1 = cal_map[6][9];
        conv2 = cal_map[6][10];
        conv3 = cal_map[6][11];
        conv4 = cal_map[7][9];
        conv5 = cal_map[7][10];
        conv6 = cal_map[7][11];
        conv7 = cal_map[8][9];
        conv8 = cal_map[8][10];
        conv9 = cal_map[8][11];
    end

    107 : begin 
        conv1 = cal_map[6][10];
        conv2 = cal_map[6][11];
        conv3 = cal_map[6][12];
        conv4 = cal_map[7][10];
        conv5 = cal_map[7][11];
        conv6 = cal_map[7][12];
        conv7 = cal_map[8][10];
        conv8 = cal_map[8][11];
        conv9 = cal_map[8][12];
    end

    108 : begin 
        conv1 = cal_map[6][11];
        conv2 = cal_map[6][12];
        conv3 = cal_map[6][13];
        conv4 = cal_map[7][11];
        conv5 = cal_map[7][12];
        conv6 = cal_map[7][13];
        conv7 = cal_map[8][11];
        conv8 = cal_map[8][12];
        conv9 = cal_map[8][13];
    end

    109 : begin 
        conv1 = cal_map[6][12];
        conv2 = cal_map[6][13];
        conv3 = cal_map[6][14];
        conv4 = cal_map[7][12];
        conv5 = cal_map[7][13];
        conv6 = cal_map[7][14];
        conv7 = cal_map[8][12];
        conv8 = cal_map[8][13];
        conv9 = cal_map[8][14];
    end

    110 : begin 
        conv1 = cal_map[6][13];
        conv2 = cal_map[6][14];
        conv3 = cal_map[6][15];
        conv4 = cal_map[7][13];
        conv5 = cal_map[7][14];
        conv6 = cal_map[7][15];
        conv7 = cal_map[8][13];
        conv8 = cal_map[8][14];
        conv9 = cal_map[8][15];
    end

    111 : begin 
        conv1 = cal_map[6][14];
        conv2 = cal_map[6][15];
        conv3 = cal_map[6][16];
        conv4 = cal_map[7][14];
        conv5 = cal_map[7][15];
        conv6 = cal_map[7][16];
        conv7 = cal_map[8][14];
        conv8 = cal_map[8][15];
        conv9 = cal_map[8][16];
    end

    112 : begin 
        conv1 = cal_map[6][15];
        conv2 = cal_map[6][16];
        conv3 = cal_map[6][17];
        conv4 = cal_map[7][15];
        conv5 = cal_map[7][16];
        conv6 = cal_map[7][17];
        conv7 = cal_map[8][15];
        conv8 = cal_map[8][16];
        conv9 = cal_map[8][17];
    end

    113 : begin 
        conv1 = cal_map[7][0];
        conv2 = cal_map[7][1];
        conv3 = cal_map[7][2];
        conv4 = cal_map[8][0];
        conv5 = cal_map[8][1];
        conv6 = cal_map[8][2];
        conv7 = cal_map[9][0];
        conv8 = cal_map[9][1];
        conv9 = cal_map[9][2];
    end

    114 : begin 
        conv1 = cal_map[7][1];
        conv2 = cal_map[7][2];
        conv3 = cal_map[7][3];
        conv4 = cal_map[8][1];
        conv5 = cal_map[8][2];
        conv6 = cal_map[8][3];
        conv7 = cal_map[9][1];
        conv8 = cal_map[9][2];
        conv9 = cal_map[9][3];
    end

    115 : begin 
        conv1 = cal_map[7][2];
        conv2 = cal_map[7][3];
        conv3 = cal_map[7][4];
        conv4 = cal_map[8][2];
        conv5 = cal_map[8][3];
        conv6 = cal_map[8][4];
        conv7 = cal_map[9][2];
        conv8 = cal_map[9][3];
        conv9 = cal_map[9][4];
    end

    116 : begin 
        conv1 = cal_map[7][3];
        conv2 = cal_map[7][4];
        conv3 = cal_map[7][5];
        conv4 = cal_map[8][3];
        conv5 = cal_map[8][4];
        conv6 = cal_map[8][5];
        conv7 = cal_map[9][3];
        conv8 = cal_map[9][4];
        conv9 = cal_map[9][5];
    end

    117 : begin 
        conv1 = cal_map[7][4];
        conv2 = cal_map[7][5];
        conv3 = cal_map[7][6];
        conv4 = cal_map[8][4];
        conv5 = cal_map[8][5];
        conv6 = cal_map[8][6];
        conv7 = cal_map[9][4];
        conv8 = cal_map[9][5];
        conv9 = cal_map[9][6];
    end

    118 : begin 
        conv1 = cal_map[7][5];
        conv2 = cal_map[7][6];
        conv3 = cal_map[7][7];
        conv4 = cal_map[8][5];
        conv5 = cal_map[8][6];
        conv6 = cal_map[8][7];
        conv7 = cal_map[9][5];
        conv8 = cal_map[9][6];
        conv9 = cal_map[9][7];
    end

    119 : begin 
        conv1 = cal_map[7][6];
        conv2 = cal_map[7][7];
        conv3 = cal_map[7][8];
        conv4 = cal_map[8][6];
        conv5 = cal_map[8][7];
        conv6 = cal_map[8][8];
        conv7 = cal_map[9][6];
        conv8 = cal_map[9][7];
        conv9 = cal_map[9][8];
    end

    120 : begin 
        conv1 = cal_map[7][7];
        conv2 = cal_map[7][8];
        conv3 = cal_map[7][9];
        conv4 = cal_map[8][7];
        conv5 = cal_map[8][8];
        conv6 = cal_map[8][9];
        conv7 = cal_map[9][7];
        conv8 = cal_map[9][8];
        conv9 = cal_map[9][9];
    end

    121 : begin 
        conv1 = cal_map[7][8];
        conv2 = cal_map[7][9];
        conv3 = cal_map[7][10];
        conv4 = cal_map[8][8];
        conv5 = cal_map[8][9];
        conv6 = cal_map[8][10];
        conv7 = cal_map[9][8];
        conv8 = cal_map[9][9];
        conv9 = cal_map[9][10];
    end

    122 : begin 
        conv1 = cal_map[7][9];
        conv2 = cal_map[7][10];
        conv3 = cal_map[7][11];
        conv4 = cal_map[8][9];
        conv5 = cal_map[8][10];
        conv6 = cal_map[8][11];
        conv7 = cal_map[9][9];
        conv8 = cal_map[9][10];
        conv9 = cal_map[9][11];
    end

    123 : begin 
        conv1 = cal_map[7][10];
        conv2 = cal_map[7][11];
        conv3 = cal_map[7][12];
        conv4 = cal_map[8][10];
        conv5 = cal_map[8][11];
        conv6 = cal_map[8][12];
        conv7 = cal_map[9][10];
        conv8 = cal_map[9][11];
        conv9 = cal_map[9][12];
    end

    124 : begin 
        conv1 = cal_map[7][11];
        conv2 = cal_map[7][12];
        conv3 = cal_map[7][13];
        conv4 = cal_map[8][11];
        conv5 = cal_map[8][12];
        conv6 = cal_map[8][13];
        conv7 = cal_map[9][11];
        conv8 = cal_map[9][12];
        conv9 = cal_map[9][13];
    end

    125 : begin 
        conv1 = cal_map[7][12];
        conv2 = cal_map[7][13];
        conv3 = cal_map[7][14];
        conv4 = cal_map[8][12];
        conv5 = cal_map[8][13];
        conv6 = cal_map[8][14];
        conv7 = cal_map[9][12];
        conv8 = cal_map[9][13];
        conv9 = cal_map[9][14];
    end

    126 : begin 
        conv1 = cal_map[7][13];
        conv2 = cal_map[7][14];
        conv3 = cal_map[7][15];
        conv4 = cal_map[8][13];
        conv5 = cal_map[8][14];
        conv6 = cal_map[8][15];
        conv7 = cal_map[9][13];
        conv8 = cal_map[9][14];
        conv9 = cal_map[9][15];
    end

    127 : begin 
        conv1 = cal_map[7][14];
        conv2 = cal_map[7][15];
        conv3 = cal_map[7][16];
        conv4 = cal_map[8][14];
        conv5 = cal_map[8][15];
        conv6 = cal_map[8][16];
        conv7 = cal_map[9][14];
        conv8 = cal_map[9][15];
        conv9 = cal_map[9][16];
    end

    128 : begin 
        conv1 = cal_map[7][15];
        conv2 = cal_map[7][16];
        conv3 = cal_map[7][17];
        conv4 = cal_map[8][15];
        conv5 = cal_map[8][16];
        conv6 = cal_map[8][17];
        conv7 = cal_map[9][15];
        conv8 = cal_map[9][16];
        conv9 = cal_map[9][17];
    end

    129 : begin 
        conv1 = cal_map[8][0];
        conv2 = cal_map[8][1];
        conv3 = cal_map[8][2];
        conv4 = cal_map[9][0];
        conv5 = cal_map[9][1];
        conv6 = cal_map[9][2];
        conv7 = cal_map[10][0];
        conv8 = cal_map[10][1];
        conv9 = cal_map[10][2];
    end

    130 : begin 
        conv1 = cal_map[8][1];
        conv2 = cal_map[8][2];
        conv3 = cal_map[8][3];
        conv4 = cal_map[9][1];
        conv5 = cal_map[9][2];
        conv6 = cal_map[9][3];
        conv7 = cal_map[10][1];
        conv8 = cal_map[10][2];
        conv9 = cal_map[10][3];
    end

    131 : begin 
        conv1 = cal_map[8][2];
        conv2 = cal_map[8][3];
        conv3 = cal_map[8][4];
        conv4 = cal_map[9][2];
        conv5 = cal_map[9][3];
        conv6 = cal_map[9][4];
        conv7 = cal_map[10][2];
        conv8 = cal_map[10][3];
        conv9 = cal_map[10][4];
    end

    132 : begin 
        conv1 = cal_map[8][3];
        conv2 = cal_map[8][4];
        conv3 = cal_map[8][5];
        conv4 = cal_map[9][3];
        conv5 = cal_map[9][4];
        conv6 = cal_map[9][5];
        conv7 = cal_map[10][3];
        conv8 = cal_map[10][4];
        conv9 = cal_map[10][5];
    end

    133 : begin 
        conv1 = cal_map[8][4];
        conv2 = cal_map[8][5];
        conv3 = cal_map[8][6];
        conv4 = cal_map[9][4];
        conv5 = cal_map[9][5];
        conv6 = cal_map[9][6];
        conv7 = cal_map[10][4];
        conv8 = cal_map[10][5];
        conv9 = cal_map[10][6];
    end

    134 : begin 
        conv1 = cal_map[8][5];
        conv2 = cal_map[8][6];
        conv3 = cal_map[8][7];
        conv4 = cal_map[9][5];
        conv5 = cal_map[9][6];
        conv6 = cal_map[9][7];
        conv7 = cal_map[10][5];
        conv8 = cal_map[10][6];
        conv9 = cal_map[10][7];
    end

    135 : begin 
        conv1 = cal_map[8][6];
        conv2 = cal_map[8][7];
        conv3 = cal_map[8][8];
        conv4 = cal_map[9][6];
        conv5 = cal_map[9][7];
        conv6 = cal_map[9][8];
        conv7 = cal_map[10][6];
        conv8 = cal_map[10][7];
        conv9 = cal_map[10][8];
    end

    136 : begin 
        conv1 = cal_map[8][7];
        conv2 = cal_map[8][8];
        conv3 = cal_map[8][9];
        conv4 = cal_map[9][7];
        conv5 = cal_map[9][8];
        conv6 = cal_map[9][9];
        conv7 = cal_map[10][7];
        conv8 = cal_map[10][8];
        conv9 = cal_map[10][9];
    end

    137 : begin 
        conv1 = cal_map[8][8];
        conv2 = cal_map[8][9];
        conv3 = cal_map[8][10];
        conv4 = cal_map[9][8];
        conv5 = cal_map[9][9];
        conv6 = cal_map[9][10];
        conv7 = cal_map[10][8];
        conv8 = cal_map[10][9];
        conv9 = cal_map[10][10];
    end

    138 : begin 
        conv1 = cal_map[8][9];
        conv2 = cal_map[8][10];
        conv3 = cal_map[8][11];
        conv4 = cal_map[9][9];
        conv5 = cal_map[9][10];
        conv6 = cal_map[9][11];
        conv7 = cal_map[10][9];
        conv8 = cal_map[10][10];
        conv9 = cal_map[10][11];
    end

    139 : begin 
        conv1 = cal_map[8][10];
        conv2 = cal_map[8][11];
        conv3 = cal_map[8][12];
        conv4 = cal_map[9][10];
        conv5 = cal_map[9][11];
        conv6 = cal_map[9][12];
        conv7 = cal_map[10][10];
        conv8 = cal_map[10][11];
        conv9 = cal_map[10][12];
    end

    140 : begin 
        conv1 = cal_map[8][11];
        conv2 = cal_map[8][12];
        conv3 = cal_map[8][13];
        conv4 = cal_map[9][11];
        conv5 = cal_map[9][12];
        conv6 = cal_map[9][13];
        conv7 = cal_map[10][11];
        conv8 = cal_map[10][12];
        conv9 = cal_map[10][13];
    end

    141 : begin 
        conv1 = cal_map[8][12];
        conv2 = cal_map[8][13];
        conv3 = cal_map[8][14];
        conv4 = cal_map[9][12];
        conv5 = cal_map[9][13];
        conv6 = cal_map[9][14];
        conv7 = cal_map[10][12];
        conv8 = cal_map[10][13];
        conv9 = cal_map[10][14];
    end

    142 : begin 
        conv1 = cal_map[8][13];
        conv2 = cal_map[8][14];
        conv3 = cal_map[8][15];
        conv4 = cal_map[9][13];
        conv5 = cal_map[9][14];
        conv6 = cal_map[9][15];
        conv7 = cal_map[10][13];
        conv8 = cal_map[10][14];
        conv9 = cal_map[10][15];
    end

    143 : begin 
        conv1 = cal_map[8][14];
        conv2 = cal_map[8][15];
        conv3 = cal_map[8][16];
        conv4 = cal_map[9][14];
        conv5 = cal_map[9][15];
        conv6 = cal_map[9][16];
        conv7 = cal_map[10][14];
        conv8 = cal_map[10][15];
        conv9 = cal_map[10][16];
    end

    144 : begin 
        conv1 = cal_map[8][15];
        conv2 = cal_map[8][16];
        conv3 = cal_map[8][17];
        conv4 = cal_map[9][15];
        conv5 = cal_map[9][16];
        conv6 = cal_map[9][17];
        conv7 = cal_map[10][15];
        conv8 = cal_map[10][16];
        conv9 = cal_map[10][17];
    end

    145 : begin 
        conv1 = cal_map[9][0];
        conv2 = cal_map[9][1];
        conv3 = cal_map[9][2];
        conv4 = cal_map[10][0];
        conv5 = cal_map[10][1];
        conv6 = cal_map[10][2];
        conv7 = cal_map[11][0];
        conv8 = cal_map[11][1];
        conv9 = cal_map[11][2];
    end

    146 : begin 
        conv1 = cal_map[9][1];
        conv2 = cal_map[9][2];
        conv3 = cal_map[9][3];
        conv4 = cal_map[10][1];
        conv5 = cal_map[10][2];
        conv6 = cal_map[10][3];
        conv7 = cal_map[11][1];
        conv8 = cal_map[11][2];
        conv9 = cal_map[11][3];
    end

    147 : begin 
        conv1 = cal_map[9][2];
        conv2 = cal_map[9][3];
        conv3 = cal_map[9][4];
        conv4 = cal_map[10][2];
        conv5 = cal_map[10][3];
        conv6 = cal_map[10][4];
        conv7 = cal_map[11][2];
        conv8 = cal_map[11][3];
        conv9 = cal_map[11][4];
    end

    148 : begin 
        conv1 = cal_map[9][3];
        conv2 = cal_map[9][4];
        conv3 = cal_map[9][5];
        conv4 = cal_map[10][3];
        conv5 = cal_map[10][4];
        conv6 = cal_map[10][5];
        conv7 = cal_map[11][3];
        conv8 = cal_map[11][4];
        conv9 = cal_map[11][5];
    end

    149 : begin 
        conv1 = cal_map[9][4];
        conv2 = cal_map[9][5];
        conv3 = cal_map[9][6];
        conv4 = cal_map[10][4];
        conv5 = cal_map[10][5];
        conv6 = cal_map[10][6];
        conv7 = cal_map[11][4];
        conv8 = cal_map[11][5];
        conv9 = cal_map[11][6];
    end

    150 : begin 
        conv1 = cal_map[9][5];
        conv2 = cal_map[9][6];
        conv3 = cal_map[9][7];
        conv4 = cal_map[10][5];
        conv5 = cal_map[10][6];
        conv6 = cal_map[10][7];
        conv7 = cal_map[11][5];
        conv8 = cal_map[11][6];
        conv9 = cal_map[11][7];
    end

    151 : begin 
        conv1 = cal_map[9][6];
        conv2 = cal_map[9][7];
        conv3 = cal_map[9][8];
        conv4 = cal_map[10][6];
        conv5 = cal_map[10][7];
        conv6 = cal_map[10][8];
        conv7 = cal_map[11][6];
        conv8 = cal_map[11][7];
        conv9 = cal_map[11][8];
    end

    152 : begin 
        conv1 = cal_map[9][7];
        conv2 = cal_map[9][8];
        conv3 = cal_map[9][9];
        conv4 = cal_map[10][7];
        conv5 = cal_map[10][8];
        conv6 = cal_map[10][9];
        conv7 = cal_map[11][7];
        conv8 = cal_map[11][8];
        conv9 = cal_map[11][9];
    end

    153 : begin 
        conv1 = cal_map[9][8];
        conv2 = cal_map[9][9];
        conv3 = cal_map[9][10];
        conv4 = cal_map[10][8];
        conv5 = cal_map[10][9];
        conv6 = cal_map[10][10];
        conv7 = cal_map[11][8];
        conv8 = cal_map[11][9];
        conv9 = cal_map[11][10];
    end

    154 : begin 
        conv1 = cal_map[9][9];
        conv2 = cal_map[9][10];
        conv3 = cal_map[9][11];
        conv4 = cal_map[10][9];
        conv5 = cal_map[10][10];
        conv6 = cal_map[10][11];
        conv7 = cal_map[11][9];
        conv8 = cal_map[11][10];
        conv9 = cal_map[11][11];
    end

    155 : begin 
        conv1 = cal_map[9][10];
        conv2 = cal_map[9][11];
        conv3 = cal_map[9][12];
        conv4 = cal_map[10][10];
        conv5 = cal_map[10][11];
        conv6 = cal_map[10][12];
        conv7 = cal_map[11][10];
        conv8 = cal_map[11][11];
        conv9 = cal_map[11][12];
    end

    156 : begin 
        conv1 = cal_map[9][11];
        conv2 = cal_map[9][12];
        conv3 = cal_map[9][13];
        conv4 = cal_map[10][11];
        conv5 = cal_map[10][12];
        conv6 = cal_map[10][13];
        conv7 = cal_map[11][11];
        conv8 = cal_map[11][12];
        conv9 = cal_map[11][13];
    end

    157 : begin 
        conv1 = cal_map[9][12];
        conv2 = cal_map[9][13];
        conv3 = cal_map[9][14];
        conv4 = cal_map[10][12];
        conv5 = cal_map[10][13];
        conv6 = cal_map[10][14];
        conv7 = cal_map[11][12];
        conv8 = cal_map[11][13];
        conv9 = cal_map[11][14];
    end

    158 : begin 
        conv1 = cal_map[9][13];
        conv2 = cal_map[9][14];
        conv3 = cal_map[9][15];
        conv4 = cal_map[10][13];
        conv5 = cal_map[10][14];
        conv6 = cal_map[10][15];
        conv7 = cal_map[11][13];
        conv8 = cal_map[11][14];
        conv9 = cal_map[11][15];
    end

    159 : begin 
        conv1 = cal_map[9][14];
        conv2 = cal_map[9][15];
        conv3 = cal_map[9][16];
        conv4 = cal_map[10][14];
        conv5 = cal_map[10][15];
        conv6 = cal_map[10][16];
        conv7 = cal_map[11][14];
        conv8 = cal_map[11][15];
        conv9 = cal_map[11][16];
    end

    160 : begin 
        conv1 = cal_map[9][15];
        conv2 = cal_map[9][16];
        conv3 = cal_map[9][17];
        conv4 = cal_map[10][15];
        conv5 = cal_map[10][16];
        conv6 = cal_map[10][17];
        conv7 = cal_map[11][15];
        conv8 = cal_map[11][16];
        conv9 = cal_map[11][17];
    end

    161 : begin 
        conv1 = cal_map[10][0];
        conv2 = cal_map[10][1];
        conv3 = cal_map[10][2];
        conv4 = cal_map[11][0];
        conv5 = cal_map[11][1];
        conv6 = cal_map[11][2];
        conv7 = cal_map[12][0];
        conv8 = cal_map[12][1];
        conv9 = cal_map[12][2];
    end

    162 : begin 
        conv1 = cal_map[10][1];
        conv2 = cal_map[10][2];
        conv3 = cal_map[10][3];
        conv4 = cal_map[11][1];
        conv5 = cal_map[11][2];
        conv6 = cal_map[11][3];
        conv7 = cal_map[12][1];
        conv8 = cal_map[12][2];
        conv9 = cal_map[12][3];
    end

    163 : begin 
        conv1 = cal_map[10][2];
        conv2 = cal_map[10][3];
        conv3 = cal_map[10][4];
        conv4 = cal_map[11][2];
        conv5 = cal_map[11][3];
        conv6 = cal_map[11][4];
        conv7 = cal_map[12][2];
        conv8 = cal_map[12][3];
        conv9 = cal_map[12][4];
    end

    164 : begin 
        conv1 = cal_map[10][3];
        conv2 = cal_map[10][4];
        conv3 = cal_map[10][5];
        conv4 = cal_map[11][3];
        conv5 = cal_map[11][4];
        conv6 = cal_map[11][5];
        conv7 = cal_map[12][3];
        conv8 = cal_map[12][4];
        conv9 = cal_map[12][5];
    end

    165 : begin 
        conv1 = cal_map[10][4];
        conv2 = cal_map[10][5];
        conv3 = cal_map[10][6];
        conv4 = cal_map[11][4];
        conv5 = cal_map[11][5];
        conv6 = cal_map[11][6];
        conv7 = cal_map[12][4];
        conv8 = cal_map[12][5];
        conv9 = cal_map[12][6];
    end

    166 : begin 
        conv1 = cal_map[10][5];
        conv2 = cal_map[10][6];
        conv3 = cal_map[10][7];
        conv4 = cal_map[11][5];
        conv5 = cal_map[11][6];
        conv6 = cal_map[11][7];
        conv7 = cal_map[12][5];
        conv8 = cal_map[12][6];
        conv9 = cal_map[12][7];
    end

    167 : begin 
        conv1 = cal_map[10][6];
        conv2 = cal_map[10][7];
        conv3 = cal_map[10][8];
        conv4 = cal_map[11][6];
        conv5 = cal_map[11][7];
        conv6 = cal_map[11][8];
        conv7 = cal_map[12][6];
        conv8 = cal_map[12][7];
        conv9 = cal_map[12][8];
    end

    168 : begin 
        conv1 = cal_map[10][7];
        conv2 = cal_map[10][8];
        conv3 = cal_map[10][9];
        conv4 = cal_map[11][7];
        conv5 = cal_map[11][8];
        conv6 = cal_map[11][9];
        conv7 = cal_map[12][7];
        conv8 = cal_map[12][8];
        conv9 = cal_map[12][9];
    end

    169 : begin 
        conv1 = cal_map[10][8];
        conv2 = cal_map[10][9];
        conv3 = cal_map[10][10];
        conv4 = cal_map[11][8];
        conv5 = cal_map[11][9];
        conv6 = cal_map[11][10];
        conv7 = cal_map[12][8];
        conv8 = cal_map[12][9];
        conv9 = cal_map[12][10];
    end

    170 : begin 
        conv1 = cal_map[10][9];
        conv2 = cal_map[10][10];
        conv3 = cal_map[10][11];
        conv4 = cal_map[11][9];
        conv5 = cal_map[11][10];
        conv6 = cal_map[11][11];
        conv7 = cal_map[12][9];
        conv8 = cal_map[12][10];
        conv9 = cal_map[12][11];
    end

    171 : begin 
        conv1 = cal_map[10][10];
        conv2 = cal_map[10][11];
        conv3 = cal_map[10][12];
        conv4 = cal_map[11][10];
        conv5 = cal_map[11][11];
        conv6 = cal_map[11][12];
        conv7 = cal_map[12][10];
        conv8 = cal_map[12][11];
        conv9 = cal_map[12][12];
    end

    172 : begin 
        conv1 = cal_map[10][11];
        conv2 = cal_map[10][12];
        conv3 = cal_map[10][13];
        conv4 = cal_map[11][11];
        conv5 = cal_map[11][12];
        conv6 = cal_map[11][13];
        conv7 = cal_map[12][11];
        conv8 = cal_map[12][12];
        conv9 = cal_map[12][13];
    end

    173 : begin 
        conv1 = cal_map[10][12];
        conv2 = cal_map[10][13];
        conv3 = cal_map[10][14];
        conv4 = cal_map[11][12];
        conv5 = cal_map[11][13];
        conv6 = cal_map[11][14];
        conv7 = cal_map[12][12];
        conv8 = cal_map[12][13];
        conv9 = cal_map[12][14];
    end

    174 : begin 
        conv1 = cal_map[10][13];
        conv2 = cal_map[10][14];
        conv3 = cal_map[10][15];
        conv4 = cal_map[11][13];
        conv5 = cal_map[11][14];
        conv6 = cal_map[11][15];
        conv7 = cal_map[12][13];
        conv8 = cal_map[12][14];
        conv9 = cal_map[12][15];
    end

    175 : begin 
        conv1 = cal_map[10][14];
        conv2 = cal_map[10][15];
        conv3 = cal_map[10][16];
        conv4 = cal_map[11][14];
        conv5 = cal_map[11][15];
        conv6 = cal_map[11][16];
        conv7 = cal_map[12][14];
        conv8 = cal_map[12][15];
        conv9 = cal_map[12][16];
    end

    176 : begin 
        conv1 = cal_map[10][15];
        conv2 = cal_map[10][16];
        conv3 = cal_map[10][17];
        conv4 = cal_map[11][15];
        conv5 = cal_map[11][16];
        conv6 = cal_map[11][17];
        conv7 = cal_map[12][15];
        conv8 = cal_map[12][16];
        conv9 = cal_map[12][17];
    end

    177 : begin 
        conv1 = cal_map[11][0];
        conv2 = cal_map[11][1];
        conv3 = cal_map[11][2];
        conv4 = cal_map[12][0];
        conv5 = cal_map[12][1];
        conv6 = cal_map[12][2];
        conv7 = cal_map[13][0];
        conv8 = cal_map[13][1];
        conv9 = cal_map[13][2];
    end

    178 : begin 
        conv1 = cal_map[11][1];
        conv2 = cal_map[11][2];
        conv3 = cal_map[11][3];
        conv4 = cal_map[12][1];
        conv5 = cal_map[12][2];
        conv6 = cal_map[12][3];
        conv7 = cal_map[13][1];
        conv8 = cal_map[13][2];
        conv9 = cal_map[13][3];
    end

    179 : begin 
        conv1 = cal_map[11][2];
        conv2 = cal_map[11][3];
        conv3 = cal_map[11][4];
        conv4 = cal_map[12][2];
        conv5 = cal_map[12][3];
        conv6 = cal_map[12][4];
        conv7 = cal_map[13][2];
        conv8 = cal_map[13][3];
        conv9 = cal_map[13][4];
    end

    180 : begin 
        conv1 = cal_map[11][3];
        conv2 = cal_map[11][4];
        conv3 = cal_map[11][5];
        conv4 = cal_map[12][3];
        conv5 = cal_map[12][4];
        conv6 = cal_map[12][5];
        conv7 = cal_map[13][3];
        conv8 = cal_map[13][4];
        conv9 = cal_map[13][5];
    end

    181 : begin 
        conv1 = cal_map[11][4];
        conv2 = cal_map[11][5];
        conv3 = cal_map[11][6];
        conv4 = cal_map[12][4];
        conv5 = cal_map[12][5];
        conv6 = cal_map[12][6];
        conv7 = cal_map[13][4];
        conv8 = cal_map[13][5];
        conv9 = cal_map[13][6];
    end

    182 : begin 
        conv1 = cal_map[11][5];
        conv2 = cal_map[11][6];
        conv3 = cal_map[11][7];
        conv4 = cal_map[12][5];
        conv5 = cal_map[12][6];
        conv6 = cal_map[12][7];
        conv7 = cal_map[13][5];
        conv8 = cal_map[13][6];
        conv9 = cal_map[13][7];
    end

    183 : begin 
        conv1 = cal_map[11][6];
        conv2 = cal_map[11][7];
        conv3 = cal_map[11][8];
        conv4 = cal_map[12][6];
        conv5 = cal_map[12][7];
        conv6 = cal_map[12][8];
        conv7 = cal_map[13][6];
        conv8 = cal_map[13][7];
        conv9 = cal_map[13][8];
    end

    184 : begin 
        conv1 = cal_map[11][7];
        conv2 = cal_map[11][8];
        conv3 = cal_map[11][9];
        conv4 = cal_map[12][7];
        conv5 = cal_map[12][8];
        conv6 = cal_map[12][9];
        conv7 = cal_map[13][7];
        conv8 = cal_map[13][8];
        conv9 = cal_map[13][9];
    end

    185 : begin 
        conv1 = cal_map[11][8];
        conv2 = cal_map[11][9];
        conv3 = cal_map[11][10];
        conv4 = cal_map[12][8];
        conv5 = cal_map[12][9];
        conv6 = cal_map[12][10];
        conv7 = cal_map[13][8];
        conv8 = cal_map[13][9];
        conv9 = cal_map[13][10];
    end

    186 : begin 
        conv1 = cal_map[11][9];
        conv2 = cal_map[11][10];
        conv3 = cal_map[11][11];
        conv4 = cal_map[12][9];
        conv5 = cal_map[12][10];
        conv6 = cal_map[12][11];
        conv7 = cal_map[13][9];
        conv8 = cal_map[13][10];
        conv9 = cal_map[13][11];
    end

    187 : begin 
        conv1 = cal_map[11][10];
        conv2 = cal_map[11][11];
        conv3 = cal_map[11][12];
        conv4 = cal_map[12][10];
        conv5 = cal_map[12][11];
        conv6 = cal_map[12][12];
        conv7 = cal_map[13][10];
        conv8 = cal_map[13][11];
        conv9 = cal_map[13][12];
    end

    188 : begin 
        conv1 = cal_map[11][11];
        conv2 = cal_map[11][12];
        conv3 = cal_map[11][13];
        conv4 = cal_map[12][11];
        conv5 = cal_map[12][12];
        conv6 = cal_map[12][13];
        conv7 = cal_map[13][11];
        conv8 = cal_map[13][12];
        conv9 = cal_map[13][13];
    end

    189 : begin 
        conv1 = cal_map[11][12];
        conv2 = cal_map[11][13];
        conv3 = cal_map[11][14];
        conv4 = cal_map[12][12];
        conv5 = cal_map[12][13];
        conv6 = cal_map[12][14];
        conv7 = cal_map[13][12];
        conv8 = cal_map[13][13];
        conv9 = cal_map[13][14];
    end

    190 : begin 
        conv1 = cal_map[11][13];
        conv2 = cal_map[11][14];
        conv3 = cal_map[11][15];
        conv4 = cal_map[12][13];
        conv5 = cal_map[12][14];
        conv6 = cal_map[12][15];
        conv7 = cal_map[13][13];
        conv8 = cal_map[13][14];
        conv9 = cal_map[13][15];
    end

    191 : begin 
        conv1 = cal_map[11][14];
        conv2 = cal_map[11][15];
        conv3 = cal_map[11][16];
        conv4 = cal_map[12][14];
        conv5 = cal_map[12][15];
        conv6 = cal_map[12][16];
        conv7 = cal_map[13][14];
        conv8 = cal_map[13][15];
        conv9 = cal_map[13][16];
    end

    192 : begin 
        conv1 = cal_map[11][15];
        conv2 = cal_map[11][16];
        conv3 = cal_map[11][17];
        conv4 = cal_map[12][15];
        conv5 = cal_map[12][16];
        conv6 = cal_map[12][17];
        conv7 = cal_map[13][15];
        conv8 = cal_map[13][16];
        conv9 = cal_map[13][17];
    end

    193 : begin 
        conv1 = cal_map[12][0];
        conv2 = cal_map[12][1];
        conv3 = cal_map[12][2];
        conv4 = cal_map[13][0];
        conv5 = cal_map[13][1];
        conv6 = cal_map[13][2];
        conv7 = cal_map[14][0];
        conv8 = cal_map[14][1];
        conv9 = cal_map[14][2];
    end

    194 : begin 
        conv1 = cal_map[12][1];
        conv2 = cal_map[12][2];
        conv3 = cal_map[12][3];
        conv4 = cal_map[13][1];
        conv5 = cal_map[13][2];
        conv6 = cal_map[13][3];
        conv7 = cal_map[14][1];
        conv8 = cal_map[14][2];
        conv9 = cal_map[14][3];
    end

    195 : begin 
        conv1 = cal_map[12][2];
        conv2 = cal_map[12][3];
        conv3 = cal_map[12][4];
        conv4 = cal_map[13][2];
        conv5 = cal_map[13][3];
        conv6 = cal_map[13][4];
        conv7 = cal_map[14][2];
        conv8 = cal_map[14][3];
        conv9 = cal_map[14][4];
    end

    196 : begin 
        conv1 = cal_map[12][3];
        conv2 = cal_map[12][4];
        conv3 = cal_map[12][5];
        conv4 = cal_map[13][3];
        conv5 = cal_map[13][4];
        conv6 = cal_map[13][5];
        conv7 = cal_map[14][3];
        conv8 = cal_map[14][4];
        conv9 = cal_map[14][5];
    end

    197 : begin 
        conv1 = cal_map[12][4];
        conv2 = cal_map[12][5];
        conv3 = cal_map[12][6];
        conv4 = cal_map[13][4];
        conv5 = cal_map[13][5];
        conv6 = cal_map[13][6];
        conv7 = cal_map[14][4];
        conv8 = cal_map[14][5];
        conv9 = cal_map[14][6];
    end

    198 : begin 
        conv1 = cal_map[12][5];
        conv2 = cal_map[12][6];
        conv3 = cal_map[12][7];
        conv4 = cal_map[13][5];
        conv5 = cal_map[13][6];
        conv6 = cal_map[13][7];
        conv7 = cal_map[14][5];
        conv8 = cal_map[14][6];
        conv9 = cal_map[14][7];
    end

    199 : begin 
        conv1 = cal_map[12][6];
        conv2 = cal_map[12][7];
        conv3 = cal_map[12][8];
        conv4 = cal_map[13][6];
        conv5 = cal_map[13][7];
        conv6 = cal_map[13][8];
        conv7 = cal_map[14][6];
        conv8 = cal_map[14][7];
        conv9 = cal_map[14][8];
    end

    200 : begin 
        conv1 = cal_map[12][7];
        conv2 = cal_map[12][8];
        conv3 = cal_map[12][9];
        conv4 = cal_map[13][7];
        conv5 = cal_map[13][8];
        conv6 = cal_map[13][9];
        conv7 = cal_map[14][7];
        conv8 = cal_map[14][8];
        conv9 = cal_map[14][9];
    end

    201 : begin 
        conv1 = cal_map[12][8];
        conv2 = cal_map[12][9];
        conv3 = cal_map[12][10];
        conv4 = cal_map[13][8];
        conv5 = cal_map[13][9];
        conv6 = cal_map[13][10];
        conv7 = cal_map[14][8];
        conv8 = cal_map[14][9];
        conv9 = cal_map[14][10];
    end

    202 : begin 
        conv1 = cal_map[12][9];
        conv2 = cal_map[12][10];
        conv3 = cal_map[12][11];
        conv4 = cal_map[13][9];
        conv5 = cal_map[13][10];
        conv6 = cal_map[13][11];
        conv7 = cal_map[14][9];
        conv8 = cal_map[14][10];
        conv9 = cal_map[14][11];
    end

    203 : begin 
        conv1 = cal_map[12][10];
        conv2 = cal_map[12][11];
        conv3 = cal_map[12][12];
        conv4 = cal_map[13][10];
        conv5 = cal_map[13][11];
        conv6 = cal_map[13][12];
        conv7 = cal_map[14][10];
        conv8 = cal_map[14][11];
        conv9 = cal_map[14][12];
    end

    204 : begin 
        conv1 = cal_map[12][11];
        conv2 = cal_map[12][12];
        conv3 = cal_map[12][13];
        conv4 = cal_map[13][11];
        conv5 = cal_map[13][12];
        conv6 = cal_map[13][13];
        conv7 = cal_map[14][11];
        conv8 = cal_map[14][12];
        conv9 = cal_map[14][13];
    end

    205 : begin 
        conv1 = cal_map[12][12];
        conv2 = cal_map[12][13];
        conv3 = cal_map[12][14];
        conv4 = cal_map[13][12];
        conv5 = cal_map[13][13];
        conv6 = cal_map[13][14];
        conv7 = cal_map[14][12];
        conv8 = cal_map[14][13];
        conv9 = cal_map[14][14];
    end

    206 : begin 
        conv1 = cal_map[12][13];
        conv2 = cal_map[12][14];
        conv3 = cal_map[12][15];
        conv4 = cal_map[13][13];
        conv5 = cal_map[13][14];
        conv6 = cal_map[13][15];
        conv7 = cal_map[14][13];
        conv8 = cal_map[14][14];
        conv9 = cal_map[14][15];
    end

    207 : begin 
        conv1 = cal_map[12][14];
        conv2 = cal_map[12][15];
        conv3 = cal_map[12][16];
        conv4 = cal_map[13][14];
        conv5 = cal_map[13][15];
        conv6 = cal_map[13][16];
        conv7 = cal_map[14][14];
        conv8 = cal_map[14][15];
        conv9 = cal_map[14][16];
    end

    208 : begin 
        conv1 = cal_map[12][15];
        conv2 = cal_map[12][16];
        conv3 = cal_map[12][17];
        conv4 = cal_map[13][15];
        conv5 = cal_map[13][16];
        conv6 = cal_map[13][17];
        conv7 = cal_map[14][15];
        conv8 = cal_map[14][16];
        conv9 = cal_map[14][17];
    end

    209 : begin 
        conv1 = cal_map[13][0];
        conv2 = cal_map[13][1];
        conv3 = cal_map[13][2];
        conv4 = cal_map[14][0];
        conv5 = cal_map[14][1];
        conv6 = cal_map[14][2];
        conv7 = cal_map[15][0];
        conv8 = cal_map[15][1];
        conv9 = cal_map[15][2];
    end

    210 : begin 
        conv1 = cal_map[13][1];
        conv2 = cal_map[13][2];
        conv3 = cal_map[13][3];
        conv4 = cal_map[14][1];
        conv5 = cal_map[14][2];
        conv6 = cal_map[14][3];
        conv7 = cal_map[15][1];
        conv8 = cal_map[15][2];
        conv9 = cal_map[15][3];
    end

    211 : begin 
        conv1 = cal_map[13][2];
        conv2 = cal_map[13][3];
        conv3 = cal_map[13][4];
        conv4 = cal_map[14][2];
        conv5 = cal_map[14][3];
        conv6 = cal_map[14][4];
        conv7 = cal_map[15][2];
        conv8 = cal_map[15][3];
        conv9 = cal_map[15][4];
    end

    212 : begin 
        conv1 = cal_map[13][3];
        conv2 = cal_map[13][4];
        conv3 = cal_map[13][5];
        conv4 = cal_map[14][3];
        conv5 = cal_map[14][4];
        conv6 = cal_map[14][5];
        conv7 = cal_map[15][3];
        conv8 = cal_map[15][4];
        conv9 = cal_map[15][5];
    end

    213 : begin 
        conv1 = cal_map[13][4];
        conv2 = cal_map[13][5];
        conv3 = cal_map[13][6];
        conv4 = cal_map[14][4];
        conv5 = cal_map[14][5];
        conv6 = cal_map[14][6];
        conv7 = cal_map[15][4];
        conv8 = cal_map[15][5];
        conv9 = cal_map[15][6];
    end

    214 : begin 
        conv1 = cal_map[13][5];
        conv2 = cal_map[13][6];
        conv3 = cal_map[13][7];
        conv4 = cal_map[14][5];
        conv5 = cal_map[14][6];
        conv6 = cal_map[14][7];
        conv7 = cal_map[15][5];
        conv8 = cal_map[15][6];
        conv9 = cal_map[15][7];
    end

    215 : begin 
        conv1 = cal_map[13][6];
        conv2 = cal_map[13][7];
        conv3 = cal_map[13][8];
        conv4 = cal_map[14][6];
        conv5 = cal_map[14][7];
        conv6 = cal_map[14][8];
        conv7 = cal_map[15][6];
        conv8 = cal_map[15][7];
        conv9 = cal_map[15][8];
    end

    216 : begin 
        conv1 = cal_map[13][7];
        conv2 = cal_map[13][8];
        conv3 = cal_map[13][9];
        conv4 = cal_map[14][7];
        conv5 = cal_map[14][8];
        conv6 = cal_map[14][9];
        conv7 = cal_map[15][7];
        conv8 = cal_map[15][8];
        conv9 = cal_map[15][9];
    end

    217 : begin 
        conv1 = cal_map[13][8];
        conv2 = cal_map[13][9];
        conv3 = cal_map[13][10];
        conv4 = cal_map[14][8];
        conv5 = cal_map[14][9];
        conv6 = cal_map[14][10];
        conv7 = cal_map[15][8];
        conv8 = cal_map[15][9];
        conv9 = cal_map[15][10];
    end

    218 : begin 
        conv1 = cal_map[13][9];
        conv2 = cal_map[13][10];
        conv3 = cal_map[13][11];
        conv4 = cal_map[14][9];
        conv5 = cal_map[14][10];
        conv6 = cal_map[14][11];
        conv7 = cal_map[15][9];
        conv8 = cal_map[15][10];
        conv9 = cal_map[15][11];
    end

    219 : begin 
        conv1 = cal_map[13][10];
        conv2 = cal_map[13][11];
        conv3 = cal_map[13][12];
        conv4 = cal_map[14][10];
        conv5 = cal_map[14][11];
        conv6 = cal_map[14][12];
        conv7 = cal_map[15][10];
        conv8 = cal_map[15][11];
        conv9 = cal_map[15][12];
    end

    220 : begin 
        conv1 = cal_map[13][11];
        conv2 = cal_map[13][12];
        conv3 = cal_map[13][13];
        conv4 = cal_map[14][11];
        conv5 = cal_map[14][12];
        conv6 = cal_map[14][13];
        conv7 = cal_map[15][11];
        conv8 = cal_map[15][12];
        conv9 = cal_map[15][13];
    end

    221 : begin 
        conv1 = cal_map[13][12];
        conv2 = cal_map[13][13];
        conv3 = cal_map[13][14];
        conv4 = cal_map[14][12];
        conv5 = cal_map[14][13];
        conv6 = cal_map[14][14];
        conv7 = cal_map[15][12];
        conv8 = cal_map[15][13];
        conv9 = cal_map[15][14];
    end

    222 : begin 
        conv1 = cal_map[13][13];
        conv2 = cal_map[13][14];
        conv3 = cal_map[13][15];
        conv4 = cal_map[14][13];
        conv5 = cal_map[14][14];
        conv6 = cal_map[14][15];
        conv7 = cal_map[15][13];
        conv8 = cal_map[15][14];
        conv9 = cal_map[15][15];
    end

    223 : begin 
        conv1 = cal_map[13][14];
        conv2 = cal_map[13][15];
        conv3 = cal_map[13][16];
        conv4 = cal_map[14][14];
        conv5 = cal_map[14][15];
        conv6 = cal_map[14][16];
        conv7 = cal_map[15][14];
        conv8 = cal_map[15][15];
        conv9 = cal_map[15][16];
    end

    224 : begin 
        conv1 = cal_map[13][15];
        conv2 = cal_map[13][16];
        conv3 = cal_map[13][17];
        conv4 = cal_map[14][15];
        conv5 = cal_map[14][16];
        conv6 = cal_map[14][17];
        conv7 = cal_map[15][15];
        conv8 = cal_map[15][16];
        conv9 = cal_map[15][17];
    end

    225 : begin 
        conv1 = cal_map[14][0];
        conv2 = cal_map[14][1];
        conv3 = cal_map[14][2];
        conv4 = cal_map[15][0];
        conv5 = cal_map[15][1];
        conv6 = cal_map[15][2];
        conv7 = cal_map[16][0];
        conv8 = cal_map[16][1];
        conv9 = cal_map[16][2];
    end

    226 : begin 
        conv1 = cal_map[14][1];
        conv2 = cal_map[14][2];
        conv3 = cal_map[14][3];
        conv4 = cal_map[15][1];
        conv5 = cal_map[15][2];
        conv6 = cal_map[15][3];
        conv7 = cal_map[16][1];
        conv8 = cal_map[16][2];
        conv9 = cal_map[16][3];
    end

    227 : begin 
        conv1 = cal_map[14][2];
        conv2 = cal_map[14][3];
        conv3 = cal_map[14][4];
        conv4 = cal_map[15][2];
        conv5 = cal_map[15][3];
        conv6 = cal_map[15][4];
        conv7 = cal_map[16][2];
        conv8 = cal_map[16][3];
        conv9 = cal_map[16][4];
    end

    228 : begin 
        conv1 = cal_map[14][3];
        conv2 = cal_map[14][4];
        conv3 = cal_map[14][5];
        conv4 = cal_map[15][3];
        conv5 = cal_map[15][4];
        conv6 = cal_map[15][5];
        conv7 = cal_map[16][3];
        conv8 = cal_map[16][4];
        conv9 = cal_map[16][5];
    end

    229 : begin 
        conv1 = cal_map[14][4];
        conv2 = cal_map[14][5];
        conv3 = cal_map[14][6];
        conv4 = cal_map[15][4];
        conv5 = cal_map[15][5];
        conv6 = cal_map[15][6];
        conv7 = cal_map[16][4];
        conv8 = cal_map[16][5];
        conv9 = cal_map[16][6];
    end

    230 : begin 
        conv1 = cal_map[14][5];
        conv2 = cal_map[14][6];
        conv3 = cal_map[14][7];
        conv4 = cal_map[15][5];
        conv5 = cal_map[15][6];
        conv6 = cal_map[15][7];
        conv7 = cal_map[16][5];
        conv8 = cal_map[16][6];
        conv9 = cal_map[16][7];
    end

    231 : begin 
        conv1 = cal_map[14][6];
        conv2 = cal_map[14][7];
        conv3 = cal_map[14][8];
        conv4 = cal_map[15][6];
        conv5 = cal_map[15][7];
        conv6 = cal_map[15][8];
        conv7 = cal_map[16][6];
        conv8 = cal_map[16][7];
        conv9 = cal_map[16][8];
    end

    232 : begin 
        conv1 = cal_map[14][7];
        conv2 = cal_map[14][8];
        conv3 = cal_map[14][9];
        conv4 = cal_map[15][7];
        conv5 = cal_map[15][8];
        conv6 = cal_map[15][9];
        conv7 = cal_map[16][7];
        conv8 = cal_map[16][8];
        conv9 = cal_map[16][9];
    end

    233 : begin 
        conv1 = cal_map[14][8];
        conv2 = cal_map[14][9];
        conv3 = cal_map[14][10];
        conv4 = cal_map[15][8];
        conv5 = cal_map[15][9];
        conv6 = cal_map[15][10];
        conv7 = cal_map[16][8];
        conv8 = cal_map[16][9];
        conv9 = cal_map[16][10];
    end

    234 : begin 
        conv1 = cal_map[14][9];
        conv2 = cal_map[14][10];
        conv3 = cal_map[14][11];
        conv4 = cal_map[15][9];
        conv5 = cal_map[15][10];
        conv6 = cal_map[15][11];
        conv7 = cal_map[16][9];
        conv8 = cal_map[16][10];
        conv9 = cal_map[16][11];
    end

    235 : begin 
        conv1 = cal_map[14][10];
        conv2 = cal_map[14][11];
        conv3 = cal_map[14][12];
        conv4 = cal_map[15][10];
        conv5 = cal_map[15][11];
        conv6 = cal_map[15][12];
        conv7 = cal_map[16][10];
        conv8 = cal_map[16][11];
        conv9 = cal_map[16][12];
    end

    236 : begin 
        conv1 = cal_map[14][11];
        conv2 = cal_map[14][12];
        conv3 = cal_map[14][13];
        conv4 = cal_map[15][11];
        conv5 = cal_map[15][12];
        conv6 = cal_map[15][13];
        conv7 = cal_map[16][11];
        conv8 = cal_map[16][12];
        conv9 = cal_map[16][13];
    end

    237 : begin 
        conv1 = cal_map[14][12];
        conv2 = cal_map[14][13];
        conv3 = cal_map[14][14];
        conv4 = cal_map[15][12];
        conv5 = cal_map[15][13];
        conv6 = cal_map[15][14];
        conv7 = cal_map[16][12];
        conv8 = cal_map[16][13];
        conv9 = cal_map[16][14];
    end

    238 : begin 
        conv1 = cal_map[14][13];
        conv2 = cal_map[14][14];
        conv3 = cal_map[14][15];
        conv4 = cal_map[15][13];
        conv5 = cal_map[15][14];
        conv6 = cal_map[15][15];
        conv7 = cal_map[16][13];
        conv8 = cal_map[16][14];
        conv9 = cal_map[16][15];
    end

    239 : begin 
        conv1 = cal_map[14][14];
        conv2 = cal_map[14][15];
        conv3 = cal_map[14][16];
        conv4 = cal_map[15][14];
        conv5 = cal_map[15][15];
        conv6 = cal_map[15][16];
        conv7 = cal_map[16][14];
        conv8 = cal_map[16][15];
        conv9 = cal_map[16][16];
    end

    240 : begin 
        conv1 = cal_map[14][15];
        conv2 = cal_map[14][16];
        conv3 = cal_map[14][17];
        conv4 = cal_map[15][15];
        conv5 = cal_map[15][16];
        conv6 = cal_map[15][17];
        conv7 = cal_map[16][15];
        conv8 = cal_map[16][16];
        conv9 = cal_map[16][17];
    end

    241 : begin 
        conv1 = cal_map[15][0];
        conv2 = cal_map[15][1];
        conv3 = cal_map[15][2];
        conv4 = cal_map[16][0];
        conv5 = cal_map[16][1];
        conv6 = cal_map[16][2];
        conv7 = cal_map[17][0];
        conv8 = cal_map[17][1];
        conv9 = cal_map[17][2];
    end

    242 : begin 
        conv1 = cal_map[15][1];
        conv2 = cal_map[15][2];
        conv3 = cal_map[15][3];
        conv4 = cal_map[16][1];
        conv5 = cal_map[16][2];
        conv6 = cal_map[16][3];
        conv7 = cal_map[17][1];
        conv8 = cal_map[17][2];
        conv9 = cal_map[17][3];
    end

    243 : begin 
        conv1 = cal_map[15][2];
        conv2 = cal_map[15][3];
        conv3 = cal_map[15][4];
        conv4 = cal_map[16][2];
        conv5 = cal_map[16][3];
        conv6 = cal_map[16][4];
        conv7 = cal_map[17][2];
        conv8 = cal_map[17][3];
        conv9 = cal_map[17][4];
    end

    244 : begin 
        conv1 = cal_map[15][3];
        conv2 = cal_map[15][4];
        conv3 = cal_map[15][5];
        conv4 = cal_map[16][3];
        conv5 = cal_map[16][4];
        conv6 = cal_map[16][5];
        conv7 = cal_map[17][3];
        conv8 = cal_map[17][4];
        conv9 = cal_map[17][5];
    end

    245 : begin 
        conv1 = cal_map[15][4];
        conv2 = cal_map[15][5];
        conv3 = cal_map[15][6];
        conv4 = cal_map[16][4];
        conv5 = cal_map[16][5];
        conv6 = cal_map[16][6];
        conv7 = cal_map[17][4];
        conv8 = cal_map[17][5];
        conv9 = cal_map[17][6];
    end

    246 : begin 
        conv1 = cal_map[15][5];
        conv2 = cal_map[15][6];
        conv3 = cal_map[15][7];
        conv4 = cal_map[16][5];
        conv5 = cal_map[16][6];
        conv6 = cal_map[16][7];
        conv7 = cal_map[17][5];
        conv8 = cal_map[17][6];
        conv9 = cal_map[17][7];
    end

    247 : begin 
        conv1 = cal_map[15][6];
        conv2 = cal_map[15][7];
        conv3 = cal_map[15][8];
        conv4 = cal_map[16][6];
        conv5 = cal_map[16][7];
        conv6 = cal_map[16][8];
        conv7 = cal_map[17][6];
        conv8 = cal_map[17][7];
        conv9 = cal_map[17][8];
    end

    248 : begin 
        conv1 = cal_map[15][7];
        conv2 = cal_map[15][8];
        conv3 = cal_map[15][9];
        conv4 = cal_map[16][7];
        conv5 = cal_map[16][8];
        conv6 = cal_map[16][9];
        conv7 = cal_map[17][7];
        conv8 = cal_map[17][8];
        conv9 = cal_map[17][9];
    end

    249 : begin 
        conv1 = cal_map[15][8];
        conv2 = cal_map[15][9];
        conv3 = cal_map[15][10];
        conv4 = cal_map[16][8];
        conv5 = cal_map[16][9];
        conv6 = cal_map[16][10];
        conv7 = cal_map[17][8];
        conv8 = cal_map[17][9];
        conv9 = cal_map[17][10];
    end

    250 : begin 
        conv1 = cal_map[15][9];
        conv2 = cal_map[15][10];
        conv3 = cal_map[15][11];
        conv4 = cal_map[16][9];
        conv5 = cal_map[16][10];
        conv6 = cal_map[16][11];
        conv7 = cal_map[17][9];
        conv8 = cal_map[17][10];
        conv9 = cal_map[17][11];
    end

    251 : begin 
        conv1 = cal_map[15][10];
        conv2 = cal_map[15][11];
        conv3 = cal_map[15][12];
        conv4 = cal_map[16][10];
        conv5 = cal_map[16][11];
        conv6 = cal_map[16][12];
        conv7 = cal_map[17][10];
        conv8 = cal_map[17][11];
        conv9 = cal_map[17][12];
    end

    252 : begin 
        conv1 = cal_map[15][11];
        conv2 = cal_map[15][12];
        conv3 = cal_map[15][13];
        conv4 = cal_map[16][11];
        conv5 = cal_map[16][12];
        conv6 = cal_map[16][13];
        conv7 = cal_map[17][11];
        conv8 = cal_map[17][12];
        conv9 = cal_map[17][13];
    end

    253 : begin 
        conv1 = cal_map[15][12];
        conv2 = cal_map[15][13];
        conv3 = cal_map[15][14];
        conv4 = cal_map[16][12];
        conv5 = cal_map[16][13];
        conv6 = cal_map[16][14];
        conv7 = cal_map[17][12];
        conv8 = cal_map[17][13];
        conv9 = cal_map[17][14];
    end

    254 : begin 
        conv1 = cal_map[15][13];
        conv2 = cal_map[15][14];
        conv3 = cal_map[15][15];
        conv4 = cal_map[16][13];
        conv5 = cal_map[16][14];
        conv6 = cal_map[16][15];
        conv7 = cal_map[17][13];
        conv8 = cal_map[17][14];
        conv9 = cal_map[17][15];
    end

    255 : begin 
        conv1 = cal_map[15][14];
        conv2 = cal_map[15][15];
        conv3 = cal_map[15][16];
        conv4 = cal_map[16][14];
        conv5 = cal_map[16][15];
        conv6 = cal_map[16][16];
        conv7 = cal_map[17][14];
        conv8 = cal_map[17][15];
        conv9 = cal_map[17][16];
    end

    256 : begin 
        conv1 = cal_map[15][15];
        conv2 = cal_map[15][16];
        conv3 = cal_map[15][17];
        conv4 = cal_map[16][15];
        conv5 = cal_map[16][16];
        conv6 = cal_map[16][17];
        conv7 = cal_map[17][15];
        conv8 = cal_map[17][16];
        conv9 = cal_map[17][17];
    end
        default: begin
            conv1 = 0;
            conv2 = 0;
            conv3 = 0;
            conv4 = 0;
            conv5 = 0;
            conv6 = 0;
            conv7 = 0;
            conv8 = 0;
            conv9 = 0;
        end

    endcase
end

always @ (*) begin //conv
    conv_all = conv1*template_in[0][0] + conv2*template_in[0][1] + conv3*template_in[0][2] + conv4*template_in[1][0] + conv5*template_in[1][1] + conv6*template_in[1][2] + conv7*template_in[2][0] + conv8*template_in[2][1] + conv9*template_in[2][2] ;
end

always @ (*) begin //CS_WEB
    sram_CS = 1 ;
	/*case (current_state)
		IDLE    : sram_WEB = 0 ;
		IN_DATA : sram_WEB = 0 ;
        WAIT    : sram_WEB = 0 ;
		CAL     : sram_WEB = 1 ;
		OUT     : sram_WEB = 1 ;
		default : sram_WEB = 1 ;
	endcase*/
    if ((counter>=0 && counter<=49) && image_size_in==0)sram_WEB = 0;
    else if ((counter>=0 && counter<=193) && image_size_in==1)sram_WEB = 0;
    else if ((counter>=0 && counter<=769) && image_size_in==2)sram_WEB = 0;
    else sram_WEB = 1;

end

always @ (*) begin //address
	case (current_state)
		IDLE     : begin
            addr_g0 = 0 ;
            addr_g1 = 0 ;
            addr_g2 = 0 ;
        end
		IN_DATA  : begin
            addr_g0 = word_count_seq ; 
            addr_g1 = word_count_seq ; 
            addr_g2 = word_count_seq ; 
        end
        WAIT      : begin
            addr_g0 = word_count_seq ;
            addr_g1 = word_count_seq ;
            addr_g2 = word_count_seq ;
        end
        IN_DATA2  : begin
            addr_g0 = counter_inD2_seq ;
            addr_g1 = counter_inD2_seq ;
            addr_g2 = counter_inD2_seq ;
        end
		CAL      : begin
            addr_g0 = counter_inD2_seq ;
            addr_g1 = counter_inD2_seq ;
            addr_g2 = counter_inD2_seq ;
        end
		default  : begin
            addr_g0 = 0 ;
            addr_g1 = 0 ;
            addr_g2 = 0 ;
        end
	endcase 
end

always @ (*) begin//sram_in
	case (current_state)
		IDLE     : begin
            sram_g0 = 0 ;
            sram_g1 = 0 ;
            sram_g2 = 0 ;
        end
		IN_DATA,WAIT  : begin
            sram_g0 = (counter_RGB == 1)? gray_0_seq : 0; 
            sram_g1 = (counter_RGB == 1)? gray_1_seq : 0; 
            sram_g2 = (counter_RGB == 1)? gray_2_seq : 0; 
        end
		default  : begin
            sram_g0 = 0 ;
            sram_g1 = 0 ;
            sram_g2 = 0 ;
        end
	endcase 
end


always @ (*) begin
    cor_ab = (conv1 > conv2) ? 1 : 0;
    cor_ac = (conv1 > conv3) ? 1 : 0;
    cor_ad = (conv1 > conv4) ? 1 : 0;
    cor_ae = (conv1 > conv5) ? 1 : 0;
    cor_af = (conv1 > conv6) ? 1 : 0;
    cor_ag = (conv1 > conv7) ? 1 : 0;
    cor_ah = (conv1 > conv8) ? 1 : 0;
    cor_ai = (conv1 > conv9) ? 1 : 0;

    cor_ba = ~cor_ab;
    cor_bc = (conv2 > conv3) ? 1 : 0;
    cor_bd = (conv2 > conv4) ? 1 : 0;
    cor_be = (conv2 > conv5) ? 1 : 0;
    cor_bf = (conv2 > conv6) ? 1 : 0;
    cor_bg = (conv2 > conv7) ? 1 : 0;
    cor_bh = (conv2 > conv8) ? 1 : 0;
    cor_bi = (conv2 > conv9) ? 1 : 0;

    cor_ca = ~cor_ac;
    cor_cb = ~cor_bc;
    cor_cd = (conv3 > conv4) ? 1 : 0;
    cor_ce = (conv3 > conv5) ? 1 : 0;
    cor_cf = (conv3 > conv6) ? 1 : 0;
    cor_cg = (conv3 > conv7) ? 1 : 0;
    cor_ch = (conv3 > conv8) ? 1 : 0;
    cor_ci = (conv3 > conv9) ? 1 : 0;

    cor_da = ~cor_ad;
    cor_db = ~cor_bd;
    cor_dc = ~cor_cd;
    cor_de = (conv4 > conv5) ? 1 : 0;
    cor_df = (conv4 > conv6) ? 1 : 0;
    cor_dg = (conv4 > conv7) ? 1 : 0;
    cor_dh = (conv4 > conv8) ? 1 : 0;
    cor_di = (conv4 > conv9) ? 1 : 0;

    cor_ea = ~cor_ae;
    cor_eb = ~cor_be;
    cor_ec = ~cor_ce;
    cor_ed = ~cor_de;
    cor_ef = (conv5 > conv6) ? 1 : 0;
    cor_eg = (conv5 > conv7) ? 1 : 0;
    cor_eh = (conv5 > conv8) ? 1 : 0;
    cor_ei = (conv5 > conv9) ? 1 : 0;

    cor_fa = ~cor_af;
    cor_fb = ~cor_bf;
    cor_fc = ~cor_cf;
    cor_fd = ~cor_df;
    cor_fe = ~cor_ef;
    cor_fg = (conv6 > conv7) ? 1 : 0;
    cor_fh = (conv6 > conv8) ? 1 : 0;
    cor_fi = (conv6 > conv9) ? 1 : 0;

    cor_ga = ~cor_ag;
    cor_gb = ~cor_bg;
    cor_gc = ~cor_cg;
    cor_gd = ~cor_dg;
    cor_ge = ~cor_eg;
    cor_gf = ~cor_fg;
    cor_gh = (conv7 > conv8) ? 1 : 0;
    cor_gi = (conv7 > conv9) ? 1 : 0;

    cor_ha = ~cor_ah;
    cor_hb = ~cor_bh;
    cor_hc = ~cor_ch;
    cor_hd = ~cor_dh;
    cor_he = ~cor_eh;
    cor_hf = ~cor_fh;
    cor_hg = ~cor_gh;
    cor_hi = (conv8 > conv9) ? 1 : 0;

    cor_ia = ~cor_ai;
    cor_ib = ~cor_bi;
    cor_ic = ~cor_ci;
    cor_id = ~cor_di;
    cor_ie = ~cor_ei;
    cor_if = ~cor_fi;
    cor_ig = ~cor_gi;
    cor_ih = ~cor_hi;

    sum_a = cor_ab + cor_ac + cor_ad + cor_ae + cor_af + cor_ag + cor_ah + cor_ai;
    sum_b = cor_ba + cor_bc + cor_bd + cor_be + cor_bf + cor_bg + cor_bh + cor_bi;
    sum_c = cor_ca + cor_cb + cor_cd + cor_ce + cor_cf + cor_cg + cor_ch + cor_ci;
    sum_d = cor_da + cor_db + cor_dc + cor_de + cor_df + cor_dg + cor_dh + cor_di;
    sum_e = cor_ea + cor_eb + cor_ec + cor_ed + cor_ef + cor_eg + cor_eh + cor_ei;
    sum_f = cor_fa + cor_fb + cor_fc + cor_fd + cor_fe + cor_fg + cor_fh + cor_fi;
    sum_g = cor_ga + cor_gb + cor_gc + cor_gd + cor_ge + cor_gf + cor_gh + cor_gi;
    sum_h = cor_ha + cor_hb + cor_hc + cor_hd + cor_he + cor_hf + cor_hg + cor_hi;
    sum_i = cor_ia + cor_ib + cor_ic + cor_id + cor_ie + cor_if + cor_ig + cor_ih;
end

always @ (*) begin
    median =(sum_a == 4) ? conv1 :
            (sum_b == 4) ? conv2 :
            (sum_c == 4) ? conv3 :
            (sum_d == 4) ? conv4 :
            (sum_e == 4) ? conv5 :
            (sum_f == 4) ? conv6 :
            (sum_g == 4) ? conv7 :
            (sum_h == 4) ? conv8 :
            (sum_i == 4) ? conv9 : 0;
end

always @ (posedge clk or negedge rst_n) begin 
	if (!rst_n) word_count_seq <= 0 ;
	else word_count_seq <= word_count;
end

always @(*) begin
    img_RG = (img_R  > img_G) ? img_R  : img_G ;
    gray_0 = (img_RG > img_B) ? img_RG : img_B ;
    gray_1 = (img_R + img_G + img_B)   /  3    ;
    gray_2 = (img_R>> 2) + (img_G>> 1) + (img_B >> 2) ; 
end

always @ (posedge clk or negedge rst_n) begin 
	if (!rst_n)begin
        gray_0_seq <= 0 ;
        gray_1_seq <= 0 ;
        gray_2_seq <= 0 ;
    end
	else begin
        gray_0_seq <= gray_0 ;
        gray_1_seq <= gray_1 ;
        gray_2_seq <= gray_2 ;
    end   
end

always @(*) begin
    if (current_state == OUT && image_size_in == 0)begin
       out_value = cal_map[counter_out/4][counter_out%4][19-counter_out_bit];
    end
    else if (current_state == OUT && image_size_in == 1)begin
       out_value = cal_map[counter_out/8][counter_out%8][19-counter_out_bit];
    end
    else if (current_state == OUT && image_size_in == 2)begin
       out_value = cal_map[counter_out/16][counter_out%16][19-counter_out_bit];
    end
    else out_value = 0;
end


always @(*) begin
    if(current_state == OUT && next_state != WAIT && next_state != IDLE)begin
        out_valid = 1;
    end
    else out_valid = 0;
end

//==================================================================
// SRAM
//==================================================================

SRAM_256X8 GRAY0(
    .A0 (addr_g0[0]), .A1 (addr_g0[1]) ,.A2 (addr_g0[2]), .A3 (addr_g0[3]), 
    .A4 (addr_g0[4]), .A5 (addr_g0[5]) ,.A6 (addr_g0[6]), .A7 (addr_g0[7]),

    .DI0 (sram_g0[0]),.DI1 (sram_g0[1]),.DI2 (sram_g0[2]),.DI3 (sram_g0[3]),
    .DI4 (sram_g0[4]),.DI5 (sram_g0[5]),.DI6 (sram_g0[6]),.DI7 (sram_g0[7]), 

    .DO0 (sram_g0_out[0]),.DO1 (sram_g0_out[1]),.DO2 (sram_g0_out[2]),.DO3 (sram_g0_out[3]), 
    .DO4 (sram_g0_out[4]),.DO5 (sram_g0_out[5]),.DO6 (sram_g0_out[6]),.DO7 (sram_g0_out[7]), 
    .CK(clk), .WEB(sram_WEB), .OE(1'b1) , .CS(sram_CS)
); 

SRAM_256X8 GRAY1(
    .A0 (addr_g1[0]), .A1 (addr_g1[1]) ,.A2 (addr_g1[2]), .A3 (addr_g1[3]), 
    .A4 (addr_g1[4]), .A5 (addr_g1[5]) ,.A6 (addr_g1[6]), .A7 (addr_g1[7]),

    .DI0 (sram_g1[0]),.DI1 (sram_g1[1]),.DI2 (sram_g1[2]),.DI3 (sram_g1[3]),
    .DI4 (sram_g1[4]),.DI5 (sram_g1[5]),.DI6 (sram_g1[6]),.DI7 (sram_g1[7]), 

    .DO0 (sram_g1_out[0]),.DO1 (sram_g1_out[1]),.DO2 (sram_g1_out[2]),.DO3 (sram_g1_out[3]), 
    .DO4 (sram_g1_out[4]),.DO5 (sram_g1_out[5]),.DO6 (sram_g1_out[6]),.DO7 (sram_g1_out[7]), 
    .CK(clk), .WEB(sram_WEB), .OE(1'b1) , .CS(sram_CS)
); 

SRAM_256X8 GRAY2(
    .A0 (addr_g2[0]), .A1 (addr_g2[1]) ,.A2 (addr_g2[2]), .A3 (addr_g2[3]), 
    .A4 (addr_g2[4]), .A5 (addr_g2[5]) ,.A6 (addr_g2[6]), .A7 (addr_g2[7]),

    .DI0 (sram_g2[0]),.DI1 (sram_g2[1]),.DI2 (sram_g2[2]),.DI3 (sram_g2[3]),
    .DI4 (sram_g2[4]),.DI5 (sram_g2[5]),.DI6 (sram_g2[6]),.DI7 (sram_g2[7]), 

    .DO0 (sram_g2_out[0]),.DO1 (sram_g2_out[1]),.DO2 (sram_g2_out[2]),.DO3 (sram_g2_out[3]), 
    .DO4 (sram_g2_out[4]),.DO5 (sram_g2_out[5]),.DO6 (sram_g2_out[6]),.DO7 (sram_g2_out[7]), 
    .CK(clk), .WEB(sram_WEB), .OE(1'b1) , .CS(sram_CS)
); 


endmodule