`timescale 1ns/1ns
`define CP 20
module tb();
    reg Clk;
    reg Rst_n;
    wire [7:0] Mem_data;
    wire Mem_r;
    wire Mem_w;
    wire [7:0] Mem_store_data;
    wire [3:0] Mem_addr;
    core core(
        .Clk(Clk),
        .Rst_n(Rst_n), 
        //記憶體介面
        .Mem_data_i(Mem_data),
        .Mem_r_o(Mem_r),
        .Mem_w_o(Mem_w),
        .Mem_store_data_o(Mem_store_data),
        .Mem_adr_o(Mem_addr)
    );
    testram testram (
        .Clk(Clk),
        .Addr(Mem_addr),     
        .Din(Mem_store_data),     
        .We(Mem_w),           
        .Re(Mem_r),            
        .Dout(Mem_data)
    );
    initial Clk = 1;
    always #(`CP / 2) Clk = ~Clk;

    initial begin
        Rst_n = 1;
        #(`CP*2);
        Rst_n = 0;
        #(`CP + 4);
        Rst_n = 1;
        #(`CP * 100);
        $stop;
    end 

endmodule