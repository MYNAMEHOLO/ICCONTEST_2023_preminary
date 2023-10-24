module LASER (
input CLK,
input RST,
input [3:0] X,
input [3:0] Y,
output reg [3:0] C1X,
output reg [3:0] C1Y,
output reg [3:0] C2X,
output reg [3:0] C2Y,
output reg DONE);

///=========================//
// write my code here
///=========================//

// parameter here
parameter   GET_TAR = 0,
            C1_F = 1,
            COMPARE = 2,
            FINISH = 3;

parameter PAR_NUM = 3;
reg [PAR_NUM - 1 : 0] cs,ns;

// The 40 target point we want to hit
reg [3:0] x_tar [39:0];
reg [3:0] y_tar [39:0];
reg [5:0] cnt_39;
reg [5:0] hit_39;
reg [5:0] old_hit_39;
// golden flag for C1 and C2
reg golden_c1;
reg golden_c2;

// golden temp for C1X , C2X , C1Y , C2Y
reg [3:0] C1X_temp;
reg [3:0] C2X_temp;
reg [3:0] C1Y_temp;
reg [3:0] C2Y_temp;

integer i;
integer j;
// comb logic here

/// circular calculating circuit
// per cycle calculate 10 point;
reg [3:0] sub_x1 [9:0];
reg [3:0] sub_y1 [9:0];
reg [3:0] sub_x2 [9:0];
reg [3:0] sub_y2 [9:0];
reg [7:0] mult_x1 [9:0];
reg [7:0] mult_x2 [9:0];
reg [7:0] mult_y1 [9:0];
reg [7:0] mult_y2 [9:0];
reg [8:0] add_r1 [9:0];
reg [8:0] add_r2 [9:0];
reg [9:0] cir_cnt;
wire [3:0] cir_cnt_1cycle;

always@(*)begin
    for(j = 0,j <= 9 ; j = j+1)begin
        sub_x1[j] = (C1X > x_tar[j + cnt_39])? (C1X - x_tar[j + cnt_39]) : (x_tar[j + cnt_39] - C1X);
        sub_y1[j] = (C1Y > y_tar[j + cnt_39])? (C1Y - y_tar[j + cnt_39]) : (y_tar[j + cnt_39] - C1Y);
        sub_x2[j] = (C2X > x_tar[j + cnt_39])? (C2X - x_tar[j + cnt_39]) : (x_tar[j + cnt_39] - C2X);
        sub_y2[j] = (C2Y > y_tar[j + cnt_39])? (C2Y - y_tar[j + cnt_39]) : (y_tar[j + cnt_39] - C2Y);
        mult_x1[j] = sub_x1[j] * sub_x1[j];
        mult_x2[j] = sub_x2[j] * sub_x2[j];
        mult_y1[j] = sub_y1[j] * sub_y1[j];
        mult_y2[j] = sub_y2[j] * sub_y2[j];
        add_r1[j] = mult_x1[j] + mult_y1[j];
        add_r2[j] = mult_x2[j] + mult_y2[j];
        cir_cnt[j] = ((add_r1[j] >= 5'd16) ^ (add_r2[j] >= 5'd16))? 1'd1:1'd0;
    end
end
assign cir_cnt_1cycle = cir_cnt[0] + cir_cnt[1]+ cir_cnt[2]+ cir_cnt[3]+ cir_cnt[4]
                        + cir_cnt[5]+ cir_cnt[6]+ cir_cnt[7]+ cir_cnt[8]+ cir_cnt[9];






// cs logic here
always@(posedge CLK)begin
    if(RST) cs <= 'd1;
    else begin
        cs <= 'd0;
        cs <= ns;
    end
end

// ns logic here
always@(*)begin
    ns = 'd0;
    if(RST) ns[GET_TAR] = 1'd1;
    else begin
        case(1'b1)
            cs[GET_TAR]:begin
                if(cnt_39 == 6'd39) ns[C1_F] = 1'd1;
                else ns[GET_TAR] = 1'd1;
            end
            cs[C1_F]: ns[COMPARE] = 1'd1;
            cs[COMPARE]: ns
            cs[FINISH]: ns[FINISH] = 1'd1;
        default: ns = 'd0;
        endcase
    end
end

// output logic
always@(posedge CLK)begin
    if(RST)begin
        C1X <= 'd0;
        C1Y <= 'd0;
        C2X <= 'd0;
        C2Y <= 'd0;
        C1X_temp <= 'd0;
        C2X_temp <= 'd0;
        C1Y_temp <= 'd0;
        C2X_temp <= 'd0;
        DONE <= 1'd0;
        cnt_39 <= 'd0;
        hit_39 <= 'd0;
        old_hit_39 <= 'd0;
        golden_c1 <= 1'd0;
        golden_c2 <= 1'd0;
        for(i = 0; i <= 39; i = i+1)begin
            x_tar[i] <= 'd0;
            y_tar[i] <= 'd0;
        end
    end
    else begin
        case(1'd1)
            cs[GET_TAR]:begin
                x_tar[cnt_39] <= X;
                y_tar[cnt_39] <= Y;
                cnt_39 <= cnt_39 + 1'd1;
                C1X <= 'd0;
                C1Y <= 'd0;
                C2X <= 'd0;
                C2Y <= 'd0;
                C1X_temp <= 'd0;
                C2X_temp <= 'd0;
                C1Y_temp <= 'd0;
                C2X_temp <= 'd0;
                cnt_39 <= 'd0;
                hit_39 <= 'd0;
                old_hit_39 <= 'd0;
                golden_c1 <= 1'd0;
                golden_c2 <= 1'd0;
            end
            cs[C1_F]:begin
                cnt_39 <= 'd0;
                if((C1X == 4'd15) && (C1Y == 4'd15))begin
                    C1X <= 4'd0;
                    C1Y <= 4'd0;
                end
                else if(C1X == 4'15)begin
                    C1X <= 4'd0;
                    C1Y <= C1Y + 1'd1;
                end
                else C1X <= C1X + 1'd1;
            end
            cs[COMPARE]:begin
                cnt_39 <= cnt_39 + 4'd10;
                hit_39 <= hit_39 + cir_cnt_1cycle;
            end
            cs[FINISH]:begin
                cnt_39 <= 'd0;
                DONE <= 1'd1;
            end

        endcase
    end
end


endmodule
