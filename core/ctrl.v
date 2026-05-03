module ctrl(
    input Clk,
    input Rst_n, 
    //面相LSU
    input Lsu_data_valid_i,
    input [7:0] Lsu_data_i,
    input Stall_i,
    output [7:0] Lsu_store_data_o,
    output reg Lsu_adr_valid_o,
    output reg [3:0] Lsu_adr_o,
    output reg Lsu_r_o,
    output reg Lsu_w_o,
    //面向alu
    input [7:0] Alu_value_i,
    output [3:0] Alu_opcode_o,
    //面向gpreg
    output reg Reg_wa_o,
    output reg Reg_wb_o
);

    reg [3:0] opcode;
    reg [3:0] oprand_idx;
    reg [7:0] alu_buffer;
    reg [3:0] pc;
    reg [1:0] step;

    reg write_alu_buffer;

    wire inst_valid_i = (Lsu_adr_o > 4'd0) && ( Lsu_adr_o < 4'd8) && (Lsu_data_valid_i);

    wire step_0 = (step == 2'd0);
    wire step_1 = (step == 2'd1);
    wire step_2 = (step == 2'd2);
    wire step_3 = (step == 2'd3);

    wire LDA    = (opcode == 4'b0001);
    wire ADD    = (opcode == 4'b0010);
    wire STO    = (opcode == 4'b0011);

    always @(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)            step <= 2'd0;
        else if(inst_valid_i) step <= 2'd1;
        else if(Stall_i)      step <= step;
        else if(|step)        step <= step + 1'b1;
    end

    always @(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)            pc <= 4'd1;
        else if(pc == 4'd8)   pc <= 4'd1;
        else if(inst_valid_i) pc <= pc + 1'b1;
    end

    always @(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)begin
            opcode     <= 4'd0;
            oprand_idx <= 4'd0;
        end
        else if(inst_valid_i) begin
            opcode     <= Lsu_data_i[7:4];
            oprand_idx <= Lsu_data_i[3:0];
        end
    end

    always @(posedge Clk or negedge Rst_n) begin
        if(!Rst_n)                alu_buffer <= 8'd0;
        else if(write_alu_buffer) alu_buffer <= Alu_value_i;
    end

    always@(*)begin
        Lsu_r_o = 1'b0;
        if(step_0) 
            Lsu_r_o = 1'b1;
        if(step_1) 
            if(LDA) Lsu_r_o = 1'b1;
            if(ADD) Lsu_r_o = 1'b1;
        if(step_2)
            ;
        if(step_3)
            ;
    end

    always@(*)begin
        Lsu_w_o = 1'b0;
        if(step_0) 
            ;
        if(step_1) 
            ;
        if(step_2)
            if(STO) Lsu_w_o = 1'b1;
        if(step_3)
            ;
    end

    always@(*)begin
        Lsu_adr_o = 4'b0;
        Lsu_adr_valid_o = 1'b0;
        if(step_0)begin
            Lsu_adr_o = pc;
            Lsu_adr_valid_o = 1'b1;
        end
        if(step_1) begin
            Lsu_adr_o = oprand_idx;
            Lsu_adr_valid_o = 1'b1;
        end
        if(step_2) 
            Lsu_adr_o = oprand_idx;
            if(STO) Lsu_adr_valid_o = 1'b1;
        if(step_3)
            ;

    end

    always@(*)begin
        Reg_wa_o = 1'b0;
        if(step_0) 
            ;
        if(step_1) 
            Reg_wa_o = (LDA) & Lsu_data_valid_i; 
        if(step_2)
            ;
        if(step_3)
            ;

    end

    always@(*)begin
        Reg_wb_o = 1'b0;
        if(step_0) 
            ;
        if(step_1) 
            Reg_wb_o = (ADD) & Lsu_data_valid_i;    
        if(step_2)
            ;
        if(step_3)
            ;
    end

    always@(*)begin
        write_alu_buffer = 1'b0;
        if(step_0) 
            ;
        if(step_1) 
            ;  
        if(step_2) 
            write_alu_buffer = ADD;
        if(step_3)
            ;
    end

    assign Alu_opcode_o = opcode;
    assign Lsu_store_data_o = alu_buffer;

endmodule
