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
            FINISH = 1;

parameter PAR_NUM = 2;
reg [PAR_NUM - 1 : 0] cs,ns;

reg [3:0] x_tar [39:0];
reg [3:0] y_tar [39:0];
reg [5:0] cnt_39;

integer i;
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
                if(cnt_39 == 6'd39) ns[FINISH] = 1'd1;
                else ns[GET_TAR] = 1'd1;
            end
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
        DONE <= 1'd0;
        cnt_39 <= 'd0;
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
            end
            cs[FINISH]:begin
                cnt_39 <= 'd0;
                DONE <= 1'd1;
            end

        endcase
    end
end


endmodule
