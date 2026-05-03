# CORE803B

> **作者**：F114級 龔庭耀 (Contact: f114152106@nkust.edu.tw)
> **教學定位**：由 SAP-1 架構延伸之教學用多週期 (Multi-cycle) 處理器模型，作為計算機組織與硬體加速研究的敲門磚。

## 專案簡介 (Project Overview)
CORE803B 是一個以 Simple-As-Possible (SAP) 為精神設計的小型處理器實作。有別於為了追求高效能而將指令重疊執行、甚至需實作 Forwarding 單元以解決 Data Hazard 的管線化 (Pipeline) 架構，本專案採用典型的**多週期 (Multi-cycle) 架構**。

透過一個全域的狀態機 (FSM) 分時控制，本專案能夠清楚展示一條組合語言指令如何被拆解為不同時脈週期中的「微操作 (Micro-operations)」。這對於理解微處理器的資料路徑 (Datapath)、控制邏輯 (Control Logic) 以及現代處理器模組化設計非常有幫助。

本專案高度啟發自：
* Albert Paul Malvino 著《Digital Computer Electronics》中的 SAP-1 模型。
* Ben Eater 的 [8-bit Breadboard Computer 教學系列](https://youtube.com/playlist?list=PLowKtXNTBypGqImE405J2565dvjafglHU&si=qLSlXr3hp5Pwnkk6)。

---

## 指令集架構：《RISC803》
本專案搭載專為教學與 803B 實驗室專題設計的指令集架構 **RISC803**。
目前為 8 位元設計版本（高 4 位元為 OP Code，低 4 位元為記憶體位址，可映射 16 個記憶體位置）。

**已定義之核心指令：**
* `LDA @(MEMadr)`：將位於 `MEMadr` 的資料載入至 A 暫存器。
* `ADD @(MEMadr)`：將 A 暫存器與位於 `MEMadr` 的資料相加，並將結果存入 ALU Buffer。
* `STO @(MEMadr)`：將 ALU Buffer 中的資料存回 `MEMadr` 記憶體位置。

---

## 微架構設計 (V8.0)
CORE803B 捨棄了 SAP-1 將記憶體與運算單元全綁在同一匯流排上的作法，重新解構並模組化，整體微架構由四大模組構成。目前的 V8.0 版本屬於**累加器架構 (Accumulator-based Processor)**，而非典型的 Load-Store 架構。

### 1. 控制單元 (Control Unit, CTRL)
CTRL 是 CORE803B 的心臟，負責解析指令並控制所有模組的運作。它維護以下五個核心暫存器：
* `opcode` (4-bit)：儲存當前指令的 OP Code。
* `oprand_idx` (4-bit)：儲存指令的記憶體位址（運算元）。
* `alu_buffer` (8-bit)：於特定指令（如 ADD）執行時，暫存 ALU 的計算結果。
* `pc` (4-bit, Program Counter)：記錄下一筆要抓取指令的實體記憶體位址（本版不支援虛擬記憶體）。
* `step` (2-bit)：指令週期的「計步器」(FSM State)。以 `LDA` 為例：
  * `step 0`：Fetch，讀取指令並寫入 `opcode` 與 `oprand_idx`。
  * `step 1`：Execute，讀取資料並寫入 A 暫存器。
  * *(註：V8.0 的 `step` 最高會上數至 3，依指令不同可能會產生等待週期。)*

### 2. 算術邏輯單元 (Arithmetic Logic Unit, ALU)
在 V8.0 中為最精簡設計，目前僅負責執行**加法 (Addition)** 運算。

### 3. 通用暫存器 (General-Purpose Registers)
包含 **A** 與 **B** 兩個暫存器，直接連接至 ALU 的輸入端。由於是累加器架構，多數運算都隱含使用 A 暫存器作為來源與寫回目標，並透過 `WA`、`WB` 訊號進行寫入控制。

### 4. 載入/儲存單元 (Load-Store Unit, LSU)
有別於直接將暫存器當作記憶體的初階實作，CORE803B 獨立出 LSU 來專責處理器與外部記憶體的溝通。
**記憶體延遲模擬：** 為了還原真實世界中「處理器運算速度遠大於記憶體存取速度」的 **Memory Wall (記憶體牆)** 瓶頸，LSU 的模擬特別加入了延遲機制（Delay）。處理器必須多等待一個週期才能取得資料，藉此訓練開發者如何處理記憶體延遲問題。

