module alu(
    input [7:0]Regfile_a_i,
    input [7:0]Regfile_b_i,
    input [3:0] Ctrl_aluop_i,
    output reg [7:0] Ctrl_aluvalue_o
);
    wire [7:0] add = Regfile_a_i + Regfile_b_i ; 

    always@(*)begin
        case(Ctrl_aluop_i)
            4'b0010 : Ctrl_aluvalue_o = add;
            default : Ctrl_aluvalue_o = 8'd0;
        endcase

    end

endmodule
