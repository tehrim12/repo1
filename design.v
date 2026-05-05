`timescale 1ns / 1ps

module Eight_bit_ALU_rtl_design#(parameter N=4,parameter M=8)
(OPA,OPB,CIN,CLK,RST,CMD,inp_valid,CE,MODE,COUT,OFLOW,RES,G,E,L,ERR);

input signed [N-1:0] OPA,OPB;
input CLK,RST,CE,MODE,CIN;
input [3:0] CMD;
input [1:0] inp_valid;

output reg [M-1:0] RES = 8'b0;
output reg COUT = 1'b0;
output reg OFLOW = 1'b0;
output reg G = 1'b0;
output reg E = 1'b0;
output reg L = 1'b0;
output reg ERR = 1'bz;

reg [N-1:0] OPA_1, OPB_1;
reg [1:0] count;
reg [1:0] cnt9, cnt10;
reg [M-1:0] temp9, temp10;

always @(*) begin
    OPA_1 = OPA_1;
    OPB_1 = OPB_1;

    case (inp_valid)
        2'b00: begin
            OPA_1 = OPA_1;
            OPB_1 = OPB_1;
        end
        2'b01: OPA_1 = OPA;
        2'b10: OPB_1 = OPB;
        2'b11: begin
            OPA_1 = OPA;
            OPB_1 = OPB;
        end
        default: begin
            OPA_1 = 4'b0;
            OPB_1 = 4'b0;
        end
    endcase
end

always @(posedge CLK or posedge RST) begin
    if (CE) begin
        if (RST) begin
            RES <= {M{1'b0}};
            COUT <= 1'b0;
            OFLOW <= 1'b0;
            G <= 1'b0;
            E <= 1'b0;
            L <= 1'b0;
            ERR <= 1'b0;
            count = 0;
        end
        else if (MODE) begin
            RES <= {M{1'b0}};
            COUT <= 1'b0;
            OFLOW <= 1'b0;
            G <= 1'b0;
            E <= 1'b0;
            L <= 1'b0;
            ERR <= 1'b0;

            case (CMD)
                4'b0000: if(inp_valid==2'b11) begin
                    RES = OPA_1 + OPB_1;
                    COUT = RES[N];
                end

                4'b0001: if(inp_valid==2'b11) begin
                    OFLOW = (OPA_1 < OPB_1);
                    RES = OPA_1 - OPB_1;
                end

                4'b0010: if(inp_valid==2'b11) begin
                    RES = OPA_1 + OPB_1 + CIN;
                    COUT = RES[N];
                end

                4'b0011: if(inp_valid==2'b11) begin
                    OFLOW = (OPA_1 < OPB_1);
                    RES = OPA_1 - OPB_1 - CIN;
                end

                4'b0100: if(inp_valid==2'b01) RES = OPA_1 + 1;
                4'b0101: if(inp_valid==2'b01) RES = OPA_1 - 1;
                4'b0110: if(inp_valid==2'b01) RES = OPB_1 + 1;
                4'b0111: if(inp_valid==2'b01) RES = OPB_1 - 1;

                4'b1000: if(inp_valid==2'b11) begin
                    if (OPA_1 == OPB_1) begin E=1; G=0; L=0; end
                    else if (OPA_1 > OPB_1) begin E=0; G=1; L=0; end
                    else begin E=0; G=0; L=1; end
                end

                4'b1001: if(inp_valid==2'b11)
                    case (cnt9)
                        2'd0: begin temp9 <= (OPA_1+1)*(OPB_1+1); cnt9 <= 1; end
                        2'd1: cnt9 <= 2;
                        2'd2: begin RES <= temp9; cnt9 <= 0; end
                        default: cnt9 <= 0;
                    endcase

                4'b1010: if(inp_valid==2'b11)
                    case (cnt10)
                        2'd0: begin temp10 <= (OPA_1<<1)*OPB_1; cnt10 <= 1; end
                        2'd1: cnt10 <= 2;
                        2'd2: begin RES <= temp10; cnt10 <= 0; end
                        default: cnt10 <= 0;
                    endcase
            endcase
        end
        else begin
            RES = 0;
            COUT = 0;
            OFLOW = 0;
            G = 0;
            E = 0;
            L = 0;
            ERR = 0;

            case (CMD)
                4'b0000: if(inp_valid==2'b11) RES={1'b0,OPA_1&OPB_1};
                4'b0001: if(inp_valid==2'b11) RES={1'b0,~(OPA_1&OPB_1)};
                4'b0010: if(inp_valid==2'b11) RES={1'b0,OPA_1|OPB_1};
                4'b0011: if(inp_valid==2'b11) RES={1'b0,~(OPA_1|OPB_1)};
                4'b0100: if(inp_valid==2'b11) RES={1'b0,OPA_1^OPB_1};
                4'b0101: if(inp_valid==2'b11) RES={1'b0,~(OPA_1^OPB_1)};
                4'b0110: if(inp_valid==2'b01) RES={1'b0,~OPA_1};
                4'b0111: if(inp_valid==2'b10) RES={1'b0,~OPB_1};
                4'b1000: if(inp_valid==2'b01) RES={1'b0,OPA_1>>1};
                4'b1001: if(inp_valid==2'b01) RES={1'b0,OPA_1<<1};
                4'b1010: if(inp_valid==2'b10) RES={1'b0,OPB_1>>1};
                4'b1011: if(inp_valid==2'b10) RES={1'b0,OPB_1<<1};

                4'b1100: if(inp_valid==2'b11) begin
                    ERR = 0;
                    if (OPB_1[N-1:3] != 0) begin
                        ERR = 1;
                        RES = {1'b1, OPA_1};
                    end else if (OPB_1[2:0]==0)
                        RES = {1'b0, OPA_1};
                    else
                        RES = {1'b0,(OPA_1<<OPB_1[2:0])|(OPA_1>>(N-OPB_1[2:0]))};
                end

                4'b1101: if(inp_valid==2'b11) begin
                    ERR = 0;
                    if (OPB_1[N-1:3] != 0) begin
                        ERR = 1;
                        RES = {1'b1, OPA_1};
                    end else if (OPB_1[2:0]==0)
                        RES = {1'b0, OPA_1};
                    else
                        RES = {1'b0,(OPA_1>>OPB_1[2:0])|(OPA_1<<(N-OPB_1[2:0]))};
                end
            endcase
        end
    end
end

endmodule
