module regfile(
    input Clk,
    input Rst_n,
    input [7:0] Lsu_data_i,
    input Ctrl_wa_en,
    input Ctrl_wb_en,
    output [7:0] Alu_a_o,
    output [7:0] Alu_b_o
);

    wire any_write = Ctrl_wa_en || Ctrl_wb_en ; 
    reg [7:0] gp_a, gp_b;
    
    always @(posedge Clk or negedge Rst_n ) begin
        if(!Rst_n) begin
            gp_a <= 8'd0;
            gp_b <= 8'd0;
        end
        else if(any_write)begin
            if(Ctrl_wa_en) gp_a <= Lsu_data_i;
            else           gp_b <= Lsu_data_i;
        end
        else begin
            gp_a <= gp_a;
            gp_b <= gp_b;
        end 
    end

    assign Alu_a_o = gp_a;
    assign Alu_b_o = gp_b; 

endmodule