`timescale 1ns/1ps

module quantum_controller(
    // SYSTEM SIGNALS
    input wire         clk,           // System clock
    input wire         reset,
    
    // COMMAND INPUTS
    input wire [2:0]   cmd_gate,      // Gate command
    input wire         cmd_execute,   // Execute pulse (1 cycle)
    
    // STATUS OUTPUTS  
    output reg [1:0]   status,        // 00: idle, 01: busy, 10: done
    output reg [31:0]  display_alpha, // For monitoring
    output reg [31:0]  display_beta,
    output reg         measure_result,// KẾT QUẢ ĐO MỚI (0 hoặc 1)
    
    // GATE TIMING CONTROL
    output wire        gate_busy      // High when executing
);
    // ==================== FSM STATES ====================
    localparam ST_IDLE    = 2'b00;
    localparam ST_EXECUTE = 2'b01; // Dùng cho Gate thông thường (có delay)
    localparam ST_UPDATE  = 2'b10; // Cập nhật trạng thái vào Register
    localparam ST_MEASURE = 2'b11; // TRẠNG THÁI MỚI: Đang đo lường
    
    reg [1:0] current_state;
    reg [1:0] next_state;

    // ==================== CONSTANTS & COMMANDS ====================
    parameter GATE_DELAY  = 32'd1000; // Giả lập thời gian thực thi cổng
    localparam CMD_MEASURE = 3'b101;  // Mã lệnh đo lường (5)

    reg [31:0] timer_counter;
    reg        timer_done;
    
    // ==================== INTERNAL SIGNALS ====================
    // Signals kết nối với Quantum State
    wire [31:0] state_alpha_out; // Hiện tại trong register
    wire [31:0] state_beta_out;
    wire [31:0] state_prob_0;    // Xác suất P(0)
    
    // Signals kết nối với Quantum Gate
    wire [31:0] gate_alpha_out;
    wire [31:0] gate_beta_out;

    // Signals kết nối với Measurement Unit
    wire [31:0] rng_value;       // Số ngẫu nhiên
    wire [31:0] meas_alpha_out;  // Trạng thái sau sụp đổ
    wire [31:0] meas_beta_out;
    wire        meas_bit;        // Bit kết quả (0/1)
    wire        meas_done_sig;   // Cờ báo đo xong
    reg         meas_trigger;    // Lệnh kích hoạt đo

    // Multiplexer: Chọn nguồn dữ liệu để update vào state (Gate hay Measure?)
    wire [31:0] next_alpha_in;
    wire [31:0] next_beta_in;
    
    reg         reg_update_en;
    reg [2:0]   current_gate;

    // ==================== MODULE INSTANCES ====================
    
    // 1. Random Number Generator (Chạy liên tục)
    lfsr_random rng_inst (
        .clk(clk),
        .reset(reset),
        .random_out(rng_value)
    );

    // 2. Measurement Unit
    measurement_unit meas_unit (
        .clk(clk),
        .reset(reset),
        .measure_en(meas_trigger),
        .prob_0(state_prob_0),    // Lấy từ quantum_state
        .random_val(rng_value),   // Lấy từ lfsr_random
        .measured_bit(meas_bit),
        .done(meas_done_sig),
        .new_alpha(meas_alpha_out),
        .new_beta(meas_beta_out)
    );

    // 3. Gate execution unit
    quantum_gate gate_unit (
        .alpha_in(state_alpha_out),
        .beta_in(state_beta_out),
        .gate_type(current_gate),
        .alpha_out(gate_alpha_out),
        .beta_out(gate_beta_out)
    );
    
    // Logic Multiplexer:
    // Nếu lệnh hiện tại là MEASURE -> Lấy kết quả từ bộ đo
    // Ngược lại -> Lấy kết quả từ cổng Gate
    assign next_alpha_in = (current_gate == CMD_MEASURE) ? meas_alpha_out : gate_alpha_out;
    assign next_beta_in  = (current_gate == CMD_MEASURE) ? meas_beta_out  : gate_beta_out;

    // 4. State register
    quantum_state state_reg (
        .clk(clk),
        .reset(reset),
        .update_en(reg_update_en),
        .alpha_in(next_alpha_in),  // Đã qua Mux
        .beta_in(next_beta_in),    // Đã qua Mux
        .alpha_out(state_alpha_out),
        .beta_out(state_beta_out),
        .prob_0(state_prob_0),     // KẾT NỐI MỚI
        .prob_1()                  // (Không dùng prob_1 ở đây)
    );
    
    // ==================== FSM: STATE REGISTER ====================
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= ST_IDLE;
            timer_counter <= 0;
            timer_done    <= 0;
            measure_result <= 1'b0;
        end
        else begin
            current_state <= next_state;
            
            // Timer logic (Chỉ dùng cho Gate thông thường)
            if (current_state == ST_EXECUTE) begin
                if (timer_counter < GATE_DELAY) begin
                    timer_counter <= timer_counter + 1;
                    timer_done <= 0;
                end
                else begin
                    timer_done <= 1;
                end
            end
            else begin
                timer_counter <= 0;
                timer_done <= 0;
            end

            // Lưu kết quả đo khi đo xong
            if (current_state == ST_MEASURE && meas_done_sig) begin
                measure_result <= meas_bit;
            end
        end
    end
    
    // ==================== FSM: NEXT STATE LOGIC ====================
    always @(*) begin
        // Default values
        next_state = current_state;
        reg_update_en = 0;
        status = ST_IDLE;
        meas_trigger = 0;
        
        case (current_state)
            ST_IDLE: begin
                status = ST_IDLE;
                if (cmd_execute && (cmd_gate != 3'b000)) begin
                    current_gate = cmd_gate; // Lưu lệnh
                    
                    // Phân loại lệnh: Đo lường hay Cổng thường?
                    if (cmd_gate == CMD_MEASURE)
                        next_state = ST_MEASURE;
                    else
                        next_state = ST_EXECUTE;
                end
            end
            
            // Xử lý Cổng thường (có delay giả lập)
            ST_EXECUTE: begin
                status = ST_EXECUTE; // Busy
                if (timer_done) begin
                    next_state = ST_UPDATE;
                end
            end

            // Xử lý Đo lường (nhanh, đợi tín hiệu done từ module)
            ST_MEASURE: begin
                status = ST_EXECUTE; // Vẫn báo Busy ra ngoài
                meas_trigger = 1;    // Kích xung đo
                
                if (meas_done_sig) begin
                    next_state = ST_UPDATE;
                end
            end
            
            // Cập nhật trạng thái mới vào Register
            ST_UPDATE: begin
                status = ST_EXECUTE;
                reg_update_en = 1; // Kích hoạt ghi alpha/beta mới
                next_state = ST_IDLE;
            end
            
            default: begin
                next_state = ST_IDLE;
            end
        endcase
    end
    
    // ==================== OUTPUT ASSIGNMENTS ====================
    always @(posedge clk) begin
        display_alpha <= state_alpha_out;
        display_beta  <= state_beta_out;
    end
    
    assign gate_busy = (current_state != ST_IDLE);
    
endmodule