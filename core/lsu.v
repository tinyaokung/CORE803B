module lsu(
    input Clk,
    input Rst_n,
    //面相CPU外 記憶體控制訊號
    input [7:0] Mem_data_i,
    output [7:0] Mem_store_data_o,
    output Mem_w_o,
    output Mem_r_o,
    output [3:0]Mem_adr_o, 
    //面向cpu
    input Ctrl_w_i,
    input Ctrl_r_i,
    input Ctrl_adr_valid_i,
    input [3:0] Ctrl_adr_i,
    input [7:0] Ctrl_store_data_i,
    output [7:0] Core_data_o,
    output Core_data_valid_o,
    output Stall_o
);
    reg busy;
    reg [1:0] cnt;

    wire ram_delay  = (cnt == 2'd2);

    always@(*)begin
        busy = 1'b0;
        if(Ctrl_adr_valid_i && (Ctrl_r_i || Ctrl_w_i))   busy = 1'b1;
        if(ram_delay)                       busy = 1'b0; 
    end

    always@(posedge Clk or negedge Rst_n)begin
        if(!Rst_n)    cnt <= 2'b0;
        else if(busy) cnt <= cnt + 1'b1;
        else          cnt <= 2'b0;
    end

    assign Mem_adr_o         = {4{Ctrl_adr_valid_i}} & Ctrl_adr_i;
    assign Mem_r_o           = (Ctrl_adr_valid_i) & Ctrl_r_i;
    assign Mem_w_o           = (Ctrl_adr_valid_i) & Ctrl_w_i;
    assign Mem_store_data_o  = {8{Ctrl_adr_valid_i}} & Ctrl_store_data_i;

    assign Core_data_o       = Mem_data_i;
    assign Core_data_valid_o = ram_delay;
    
    assign Stall_o           = busy;

endmodule