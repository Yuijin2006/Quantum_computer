`timescale 1ns/1ps

module measurement_unit (
    input  wire        clk,
    input  wire        reset,
    input  wire        measure_en,    // Tín hiệu cho phép đo (từ Controller)
    input  wire [31:0] prob_0,        // Xác suất P(|0>) từ quantum_state (Q15.16)
    input  wire [31:0] random_val,    // Số ngẫu nhiên từ lfsr_random (Q15.16)
    
    output reg         measured_bit,  // Kết quả đo: 0 hoặc 1
    output reg         done,          // Cờ báo đo xong
    
    // Trạng thái mới sau khi sụp đổ (Collapse State)
    output reg [31:0]  new_alpha,
    output reg [31:0]  new_beta
);

    // Hằng số Fixed-Point Q15.16
    localparam [31:0] ONE  = 32'h0001_0000; // 1.0
    localparam [31:0] ZERO = 32'h0000_0000; // 0.0

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            measured_bit <= 1'b0;
            done         <= 1'b0;
            new_alpha    <= ONE;  // Mặc định về |0> khi reset
            new_beta     <= ZERO;
        end else begin
            if (measure_en) begin
                done <= 1'b1;
                
                // So sánh số ngẫu nhiên với xác suất P(|0>)
                // Nếu Random < P(|0>), đo được 0.
                if (random_val < prob_0) begin
                    measured_bit <= 1'b0;
                    // Sụp đổ về trạng thái |0>
                    new_alpha    <= ONE;
                    new_beta     <= ZERO;
                end else begin
                    measured_bit <= 1'b1;
                    // Sụp đổ về trạng thái |1>
                    new_alpha    <= ZERO;
                    new_beta     <= ONE;
                end
            end else begin
                done <= 1'b0; // Xóa cờ done khi không đo
            end
        end
    end

endmodule