module testram (
    input Clk,
    input [3:0] Addr,    // 對應 LSU 的 Mem_addr
    input [7:0] Din,     // 對應 LSU 的 Mem_value
    input We,            // 對應 LSU 的 Mem_w
    input Re,            // 對應 LSU 的 Mem_r
    output reg [7:0] Dout // 對應 LSU 的 Mem_data
);

    // 定義 16 個 8-bit 的記憶體單元 (4-bit 地址線)
    reg [7:0] mem [0:15];
    reg [3:0] delay;
    // 初始化記憶體數據 (測試用)
    initial begin
        mem[0] = 8'h00;
        mem[1] = 8'b0001_1001; // LDA @h9
        mem[2] = 8'b0010_1001; // ADD @h9
        mem[3] = 8'b0011_1000; // STO @h8
        mem[4] = 8'h00;
        mem[5] = 8'h00;
        mem[6] = 8'h00;
        mem[7] = 8'h00;
        mem[8] = 8'h00;
        mem[9] = 8'hBB;
        mem[10] = 8'hCC;
        mem[11] = 8'hDD;
        mem[12] = 8'h00;
        mem[13] = 8'hBB;
        mem[14] = 8'hCC;
        mem[14] = 8'hDD;
    end

    always@(posedge Clk)begin
        delay <= Addr;
    end

    always @(posedge Clk) begin
        if (We) mem[delay] <= Din;  // 寫入操作

        if (Re) Dout <= mem[delay]; // 讀取操作（同步讀取，會延遲一拍）
        else    Dout <= Dout;

    end

endmodule