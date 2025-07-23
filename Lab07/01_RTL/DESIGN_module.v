module CLK_1_MODULE (
    clk,
    rst_n,
    in_valid,
	in_row,
    in_kernel,
    out_idle,
    handshake_sready,
    handshake_din,

    flag_handshake_to_clk1,
    flag_clk1_to_handshake,

	fifo_empty,
    fifo_rdata,
    fifo_rinc,
    out_valid,
    out_data,

    flag_clk1_to_fifo,
    flag_fifo_to_clk1
);
input clk;
input rst_n;
input in_valid;
input [17:0] in_row;
input [11:0] in_kernel;
input out_idle;
output reg handshake_sready;
output reg [29:0] handshake_din;
// You can use the the custom flag ports for your design
input  flag_handshake_to_clk1;
output flag_clk1_to_handshake;

input fifo_empty;
input [7:0] fifo_rdata;
output fifo_rinc;
output reg out_valid;
output reg [7:0] out_data;
// You can use the the custom flag ports for your design
output flag_clk1_to_fifo;
input flag_fifo_to_clk1;

//---------------------------------------------------------------------
//   Para & Int
//---------------------------------------------------------------------
integer i,j;
parameter IDLE = 0;
parameter IN_DATA = 1;
parameter TRAN = 2;

//---------------------------------------------------------------------
//   Reg & Wires
//---------------------------------------------------------------------
reg [1:0]current_state_s,next_state_s;
reg [17:0]matrix[0:5];
reg [11:0]kernal[0:5];
reg fifo_empty_seq ;
reg fifo_empty_seq2;
reg [4:0] counter_in;
reg [7:0] counter_tran;
//---------------------------------------------------------------------
//   FSM design
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) current_state_s <= 0;
	else current_state_s <= next_state_s;
end

always @(*) begin
	case(current_state_s)
        IDLE:begin//0
            if(in_valid) next_state_s = IN_DATA;
            else next_state_s = IDLE;
        end
        IN_DATA:begin//1
            if(counter_in==5) next_state_s = TRAN;
            else next_state_s = IN_DATA;
        end
        TRAN:begin//2
            if(counter_tran==151) next_state_s = IDLE;
            else next_state_s = TRAN;
        end
        default:next_state_s = IDLE;
	endcase
end
//---------------------------------------------------------------------
//   counter design
//---------------------------------------------------------------------
always@(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_in <= 0;
    else if(in_valid) counter_in <= counter_in + 1;
    else if(current_state_s == IDLE) counter_in <= 0;
end

/*always@(posedge clk) begin
    if(in_valid) begin 
        matrix[counter_in] <= in_row;
        kernal[counter_in] <= in_kernel;
    end
end*/
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 6; i = i + 1) begin
            matrix[i] <= 0;
            kernal[i] <= 0;
        end
    end
    else if(next_state_s == IDLE) begin
        for(i = 0; i < 6; i = i + 1) begin
            matrix[i] <= 0;
            kernal[i] <= 0;
        end
    end
    else if(in_valid)begin
        case(counter_in)
            0  : begin
                matrix[0] <= in_row;
                kernal[0] <= in_kernel;
            end
            1  : begin
                matrix[1] <= in_row;
                kernal[1] <= in_kernel;
            end
            2  : begin
                matrix[2] <= in_row;
                kernal[2] <= in_kernel;
            end
            3  : begin
                matrix[3] <= in_row;
                kernal[3] <= in_kernel;
            end
            4  :begin
                matrix[4] <= in_row;
                kernal[4] <= in_kernel;
            end
            5  :begin
                matrix[5] <= in_row;
                kernal[5] <= in_kernel;
            end
        endcase
    end
end


//---------------------------------------------------------------------
//   sent design
//---------------------------------------------------------------------

always @(*)begin
    if(counter_in != 6)handshake_sready = 0;
    else handshake_sready = out_idle;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)  counter_tran <= 0;
    else if(current_state_s == TRAN) begin 
        if(handshake_sready) begin 
            if(counter_tran<151) counter_tran <= counter_tran + 1;
        end
    end
    else if(current_state_s == IDLE)counter_tran <= 0;
end

always@(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        handshake_din <= 0;
    end
    else if(handshake_sready && current_state_s == TRAN)begin
        handshake_din <= {kernal[counter_tran],matrix[counter_tran]};
    end
end

//---------------------------------------------------------------------
//   read design
//---------------------------------------------------------------------
assign fifo_rinc = (!fifo_empty) ? 1 : 0;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        fifo_empty_seq <= 1 ;
        fifo_empty_seq2 <= 1 ;
    end
    else begin
        fifo_empty_seq <= fifo_empty ; 
        fifo_empty_seq2 <= fifo_empty_seq ; 
    end
end
//---------------------------------------------------------------------
//   out design
//---------------------------------------------------------------------

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)out_valid <= 0 ;
    else begin
        if(!fifo_empty_seq2) out_valid <= 1 ;
        else out_valid <= 0 ;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n)out_data <= 0 ;
    else begin
        if(!fifo_empty_seq2) out_data <= fifo_rdata ;
        else out_data <= 0 ;
    end
end

endmodule

module CLK_2_MODULE (
    clk,
    rst_n,
    in_valid,
    fifo_full,
    in_data,
    out_valid,
    out_data,
    busy,

    flag_handshake_to_clk2,
    flag_clk2_to_handshake,

    flag_fifo_to_clk2,
    flag_clk2_to_fifo
);

input clk;
input rst_n;
input in_valid;
input fifo_full;
input [29:0] in_data;
output reg out_valid;
output reg [7:0] out_data;
output reg busy;

// You can use the the custom flag ports for your design
input  flag_handshake_to_clk2;
output flag_clk2_to_handshake;

input  flag_fifo_to_clk2;
output flag_clk2_to_fifo;

//---------------------------------------------------------------------
//   Para & Int
//---------------------------------------------------------------------
integer i,j;
parameter IDLE = 0;
parameter SAVE = 1;
parameter WRITE = 2;
//---------------------------------------------------------------------
//   Para & Int
//---------------------------------------------------------------------
reg in_valid_seq ;
reg in_valid_pulse ;
reg [2:0]matrix[0:5][0:5];
reg [2:0]kernal1[0:1][0:1];
reg [2:0]kernal2[0:1][0:1];
reg [2:0]kernal3[0:1][0:1];
reg [2:0]kernal4[0:1][0:1];
reg [2:0]kernal5[0:1][0:1];
reg [2:0]kernal6[0:1][0:1];
reg [7:0] ans_arr [0:149] ;
reg [7:0] ans ;
reg [2:0] window1,window2,window3,window4;
reg [2:0] kernal11,kernal21,kernal31,kernal41;
reg [7:0] counter_in_q ;
reg [7:0] counter_write ;
reg [1:0]current_state_c,next_state_c;
//---------------------------------------------------------------------
//   FSM
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
	if(!rst_n) current_state_c <= 0;
	else current_state_c <= next_state_c;
end

always @(*) begin
	case(current_state_c)
        IDLE:begin//0
            if(in_valid) next_state_c = SAVE;
            else next_state_c = IDLE;
        end
        SAVE:begin//1
            if(counter_in_q==151) next_state_c = WRITE;
            else next_state_c = SAVE;
        end
        WRITE:begin//2
            if(counter_write==150) next_state_c = IDLE;
            else next_state_c = WRITE;
        end
        default:next_state_c = IDLE;
	endcase
end

//---------------------------------------------------------------------
//   busy
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) busy <= 0;
    else if(counter_in_q == 151 && counter_write != 150) busy <= 1;
    else if(counter_write == 150) busy <= 0;
end
//---------------------------------------------------------------------
//   save
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) in_valid_seq <= 0;
    else in_valid_seq <= in_valid;
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) in_valid_pulse <= 0 ;
    else if(!in_valid) in_valid_pulse <= (in_valid ^ in_valid_seq) ;
end

always@(posedge clk or negedge rst_n) begin
    if(~rst_n) counter_in_q <= 0;
    else begin
        if(counter_in_q < 151 && in_valid_pulse && current_state_c==SAVE) counter_in_q <= counter_in_q + 1;
        else if(counter_write == 150) counter_in_q <= 0;
    end
end

always @(posedge clk or negedge rst_n) begin//MATRIX
    if(!rst_n) begin
        for(i = 0; i < 6; i = i + 1) begin
            for(j = 0; j < 6; j = j + 1) begin
                matrix[i][j] <= 0;
            end
        end
    end
    else if(!rst_n) begin
        for(i = 0; i < 6; i = i + 1) begin
            for(j = 0; j < 6; j = j + 1) begin
                matrix[i][j] <= 0;
            end
        end
    end
    else if(in_valid)begin
        case(counter_in_q)
            0  : begin
                matrix[0][0] <= in_data[2:0];
                matrix[0][1] <= in_data[5:3];
                matrix[0][2] <= in_data[8:6];
                matrix[0][3] <= in_data[11:9];
                matrix[0][4] <= in_data[14:12];
                matrix[0][5] <= in_data[17:15];
            end
            1  : begin
                matrix[1][0] <= in_data[2:0];
                matrix[1][1] <= in_data[5:3];
                matrix[1][2] <= in_data[8:6];
                matrix[1][3] <= in_data[11:9];
                matrix[1][4] <= in_data[14:12];
                matrix[1][5] <= in_data[17:15];
            end
            2  : begin
                matrix[2][0] <= in_data[2:0];
                matrix[2][1] <= in_data[5:3];
                matrix[2][2] <= in_data[8:6];
                matrix[2][3] <= in_data[11:9];
                matrix[2][4] <= in_data[14:12];
                matrix[2][5] <= in_data[17:15];
            end
            3  : begin
                matrix[3][0] <= in_data[2:0];
                matrix[3][1] <= in_data[5:3];
                matrix[3][2] <= in_data[8:6];
                matrix[3][3] <= in_data[11:9];
                matrix[3][4] <= in_data[14:12];
                matrix[3][5] <= in_data[17:15];
            end
            4  :begin
                matrix[4][0] <= in_data[2:0];
                matrix[4][1] <= in_data[5:3];
                matrix[4][2] <= in_data[8:6];
                matrix[4][3] <= in_data[11:9];
                matrix[4][4] <= in_data[14:12];
                matrix[4][5] <= in_data[17:15];
            end
            5  :begin
                matrix[5][0] <= in_data[2:0];
                matrix[5][1] <= in_data[5:3];
                matrix[5][2] <= in_data[8:6];
                matrix[5][3] <= in_data[11:9];
                matrix[5][4] <= in_data[14:12];
                matrix[5][5] <= in_data[17:15];
            end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin//KERNAL
    if(!rst_n) begin
        for(i = 0; i < 2; i = i + 1) begin
            for(j = 0; j < 2; j = j + 1) begin
                kernal1[i][j] <= 0;
                kernal2[i][j] <= 0;
                kernal3[i][j] <= 0;
                kernal4[i][j] <= 0;
                kernal5[i][j] <= 0;
                kernal6[i][j] <= 0;
            end
        end
    end
    else if(current_state_c==IDLE) begin
        for(i = 0; i < 2; i = i + 1) begin
            for(j = 0; j < 2; j = j + 1) begin
                kernal1[i][j] <= 0;
                kernal2[i][j] <= 0;
                kernal3[i][j] <= 0;
                kernal4[i][j] <= 0;
                kernal5[i][j] <= 0;
                kernal6[i][j] <= 0;
            end
        end
    end
    else if(in_valid)begin
        case(counter_in_q)
            0  : begin
                kernal1[0][0] <= in_data[20:18];
                kernal1[0][1] <= in_data[23:21];
                kernal1[1][0] <= in_data[26:24];
                kernal1[1][1] <= in_data[29:27];
            end
            1  : begin
                kernal2[0][0] <= in_data[20:18];
                kernal2[0][1] <= in_data[23:21];
                kernal2[1][0] <= in_data[26:24];
                kernal2[1][1] <= in_data[29:27];
            end
            2  : begin
                kernal3[0][0] <= in_data[20:18];
                kernal3[0][1] <= in_data[23:21];
                kernal3[1][0] <= in_data[26:24];
                kernal3[1][1] <= in_data[29:27];
            end
            3  : begin
                kernal4[0][0] <= in_data[20:18];
                kernal4[0][1] <= in_data[23:21];
                kernal4[1][0] <= in_data[26:24];
                kernal4[1][1] <= in_data[29:27];
            end
            4  :begin
                kernal5[0][0] <= in_data[20:18];
                kernal5[0][1] <= in_data[23:21];
                kernal5[1][0] <= in_data[26:24];
                kernal5[1][1] <= in_data[29:27];
            end
            5  :begin
                kernal6[0][0] <= in_data[20:18];
                kernal6[0][1] <= in_data[23:21];
                kernal6[1][0] <= in_data[26:24];
                kernal6[1][1] <= in_data[29:27];
            end
        endcase
    end
end
//---------------------------------------------------------------------
//   cal conv
//---------------------------------------------------------------------  
always @(*)begin
    case(counter_in_q)
            2, 27, 52, 77, 102, 127 : begin
                window1 = matrix[0][0];
                window2 = matrix[0][1];
                window3 = matrix[1][0];
                window4 = matrix[1][1];
            end
            3, 28, 53, 78, 103, 128 : begin
                window1 = matrix[0][1];
                window2 = matrix[0][2];
                window3 = matrix[1][1];
                window4 = matrix[1][2];
            end
            4, 29, 54, 79, 104, 129 : begin
                window1 = matrix[0][2];
                window2 = matrix[0][3];
                window3 = matrix[1][2];
                window4 = matrix[1][3];
            end
            5, 30, 55, 80, 105, 130 : begin
                window1 = matrix[0][3];
                window2 = matrix[0][4];
                window3 = matrix[1][3];
                window4 = matrix[1][4];
            end
            6, 31, 56, 81, 106, 131 : begin
                window1 = matrix[0][4];
                window2 = matrix[0][5];
                window3 = matrix[1][4];
                window4 = matrix[1][5];
            end
            7, 32, 57, 82, 107, 132 : begin
                window1 = matrix[1][0];
                window2 = matrix[1][1];
                window3 = matrix[2][0];
                window4 = matrix[2][1];
            end
            8, 33, 58, 83, 108, 133 : begin
                window1 = matrix[1][1];
                window2 = matrix[1][2];
                window3 = matrix[2][1];
                window4 = matrix[2][2];
            end
            9, 34, 59, 84, 109, 134 : begin
                window1 = matrix[1][2];
                window2 = matrix[1][3];
                window3 = matrix[2][2];
                window4 = matrix[2][3];
            end
            10, 35, 60, 85, 110, 135 : begin
                window1 = matrix[1][3];
                window2 = matrix[1][4];
                window3 = matrix[2][3];
                window4 = matrix[2][4];
            end
            11, 36, 61, 86, 111, 136 : begin
                window1 = matrix[1][4];
                window2 = matrix[1][5];
                window3 = matrix[2][4];
                window4 = matrix[2][5];
            end
            12, 37, 62, 87, 112, 137 : begin
                window1 = matrix[2][0];
                window2 = matrix[2][1];
                window3 = matrix[3][0];
                window4 = matrix[3][1];
            end
            13, 38, 63, 88, 113, 138 : begin
                window1 = matrix[2][1];
                window2 = matrix[2][2];
                window3 = matrix[3][1];
                window4 = matrix[3][2];
            end
            14, 39, 64, 89, 114, 139 : begin
                window1 = matrix[2][2];
                window2 = matrix[2][3];
                window3 = matrix[3][2];
                window4 = matrix[3][3];
            end
            15, 40, 65, 90, 115, 140 : begin
                window1 = matrix[2][3];
                window2 = matrix[2][4];
                window3 = matrix[3][3];
                window4 = matrix[3][4];
            end
            16, 41, 66, 91, 116, 141 : begin
                window1 = matrix[2][4];
                window2 = matrix[2][5];
                window3 = matrix[3][4];
                window4 = matrix[3][5];
            end
            17, 42, 67, 92, 117, 142 : begin
                window1 = matrix[3][0];
                window2 = matrix[3][1];
                window3 = matrix[4][0];
                window4 = matrix[4][1];
            end
            18, 43, 68, 93, 118, 143 : begin
                window1 = matrix[3][1];
                window2 = matrix[3][2];
                window3 = matrix[4][1];
                window4 = matrix[4][2];
            end
            19, 44, 69, 94, 119, 144 : begin
                window1 = matrix[3][2];
                window2 = matrix[3][3];
                window3 = matrix[4][2];
                window4 = matrix[4][3];
            end
            20, 45, 70, 95, 120, 145 : begin
                window1 = matrix[3][3];
                window2 = matrix[3][4];
                window3 = matrix[4][3];
                window4 = matrix[4][4];
            end
            21, 46, 71, 96, 121, 146 : begin
                window1 = matrix[3][4];
                window2 = matrix[3][5];
                window3 = matrix[4][4];
                window4 = matrix[4][5];
            end
            22, 47, 72, 97, 122, 147 : begin
                window1 = matrix[4][0];
                window2 = matrix[4][1];
                window3 = matrix[5][0];
                window4 = matrix[5][1];
            end
            23, 48, 73, 98, 123, 148 : begin
                window1 = matrix[4][1];
                window2 = matrix[4][2];
                window3 = matrix[5][1];
                window4 = matrix[5][2];
            end
            24, 49, 74, 99, 124, 149 : begin
                window1 = matrix[4][2];
                window2 = matrix[4][3];
                window3 = matrix[5][2];
                window4 = matrix[5][3];
            end
            25, 50, 75, 100, 125, 150 : begin
                window1 = matrix[4][3];
                window2 = matrix[4][4];
                window3 = matrix[5][3];
                window4 = matrix[5][4];
            end
            26, 51, 76, 101, 126, 151 : begin
                window1 = matrix[4][4];
                window2 = matrix[4][5];
                window3 = matrix[5][4];
                window4 = matrix[5][5];
            end

        default: begin
                window1 = 0;
                window2 = 0;
                window3 = 0;
                window4 = 0;
            end
    endcase
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) begin
        kernal11 <= 0;
        kernal21 <= 0;
        kernal31 <= 0;
        kernal41 <= 0;
    end
    else if(current_state_c==IDLE) begin
        kernal11 <= 0;
        kernal21 <= 0;
        kernal31 <= 0;
        kernal41 <= 0;
    end
    else begin
        case(counter_in_q)
                2 : begin
                    kernal11 <= kernal1[0][0];
                    kernal21 <= kernal1[0][1];
                    kernal31 <= kernal1[1][0];
                    kernal41 <= kernal1[1][1];
                end
                27 : begin
                    kernal11 <= kernal2[0][0];
                    kernal21 <= kernal2[0][1];
                    kernal31 <= kernal2[1][0];
                    kernal41 <= kernal2[1][1];
                end
                52 : begin
                    kernal11 <= kernal3[0][0];
                    kernal21 <= kernal3[0][1];
                    kernal31 <= kernal3[1][0];
                    kernal41 <= kernal3[1][1];
                end
                77 : begin
                    kernal11 <= kernal4[0][0];
                    kernal21 <= kernal4[0][1];
                    kernal31 <= kernal4[1][0];
                    kernal41 <= kernal4[1][1];
                end
                102 : begin
                    kernal11 <= kernal5[0][0];
                    kernal21 <= kernal5[0][1];
                    kernal31 <= kernal5[1][0];
                    kernal41 <= kernal5[1][1];
                end
                127 : begin
                    kernal11 <= kernal6[0][0];
                    kernal21 <= kernal6[0][1];
                    kernal31 <= kernal6[1][0];
                    kernal41 <= kernal6[1][1];
                end
            default: begin
                    kernal11 <= kernal11;
                    kernal21 <= kernal21;
                    kernal31 <= kernal31;
                    kernal41 <= kernal41;
                end
        endcase
    end
end

always @(*)begin
    ans = window1*kernal11 + window2*kernal21 + window3*kernal31 + window4*kernal41;
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i = 0; i < 150; i = i + 1) begin
            ans_arr[i] <= 0;
        end
    end
    else ans_arr[counter_in_q-2] <= ans;
end

//---------------------------------------------------------------------
//   cal conv
//---------------------------------------------------------------------  
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) counter_write <= 0;
    else if(current_state_c==IDLE) counter_write <= 0;
    else if(busy && counter_write < 150 && !fifo_full) counter_write <= counter_write + 1;
    else counter_write <= counter_write;
end


always @(*) begin
    if(!rst_n)begin
        out_valid = 0 ;
        out_data = 0 ;
    end
    else if (busy && counter_write < 150 && !fifo_full)begin
        out_valid = 1 ;
        out_data = ans_arr[counter_write];
    end
    else begin
        out_valid = 0 ;
        out_data = 0 ;
    end
end

endmodule

