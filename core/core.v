module core(
    input Clk,
    input Rst_n,
    //記憶體介面
    input [7:0] Mem_data_i,
    output Mem_r_o,
    output Mem_w_o,
    output [7:0] Mem_store_data_o,
    output [3:0] Mem_adr_o
);
    wire [7:0]ctrl_store_data;
    wire ctrl_addr_valid;
    wire [3:0] ctrl_addr;
    wire ctrl_read;
    wire ctrl_write;
    wire [3:0] ctrl_aluop;
    wire ctrl_write_gpa;
    wire ctrl_write_gpb;

    wire [7:0] lsu_data;
    wire lsu_data_valid;
    wire lsu_stall;

    wire [7:0] alu_value;

    wire [7:0] oprand_a, oprand_b;

    regfile regfile(
        .Clk(Clk),
        .Rst_n(Rst_n), 
        .Lsu_data_i(lsu_data),
        .Ctrl_wa_en(ctrl_write_gpa),
        .Ctrl_wb_en(ctrl_write_gpb),
        .Alu_a_o(oprand_a),
        .Alu_b_o(oprand_b)
    );


    alu alu(
        .Regfile_a_i(oprand_a),
        .Regfile_b_i(oprand_b),
        .Ctrl_aluop_i(ctrl_aluop),
        .Ctrl_aluvalue_o(alu_value)
    );


    ctrl ctrl(
        .Clk(Clk),
        .Rst_n(Rst_n), 
        //面相LSU
        .Lsu_data_valid_i(lsu_data_valid),
        .Lsu_data_i(lsu_data),
        .Stall_i(lsu_stall),
        .Lsu_store_data_o(ctrl_store_data),
        .Lsu_adr_valid_o(ctrl_addr_valid),
        .Lsu_adr_o(ctrl_addr),
        .Lsu_r_o(ctrl_read),
        .Lsu_w_o(ctrl_write),
        //面向alu
        .Alu_value_i(alu_value),
        .Alu_opcode_o(ctrl_aluop),
        //面向gpreg
        .Reg_wa_o(ctrl_write_gpa),
        .Reg_wb_o(ctrl_write_gpb)
    );

    lsu lsu(
        .Clk(Clk),
        .Rst_n(Rst_n), 
        //面相CPU外 記憶體控制訊號
        .Mem_data_i(Mem_data_i),
        .Mem_store_data_o(Mem_store_data_o),
        .Mem_w_o(Mem_w_o),
        .Mem_r_o(Mem_r_o),
        .Mem_adr_o(Mem_adr_o), 
        //面向cpu
        .Ctrl_w_i(ctrl_write),
        .Ctrl_r_i(ctrl_read),
        .Ctrl_adr_valid_i(ctrl_addr_valid),
        .Ctrl_adr_i(ctrl_addr),
        .Ctrl_store_data_i(ctrl_store_data),
        .Core_data_o(lsu_data),
        .Core_data_valid_o(lsu_data_valid),
        .Stall_o(lsu_stall)
    );
endmodule   
