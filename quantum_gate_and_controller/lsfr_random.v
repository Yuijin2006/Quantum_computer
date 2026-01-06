`timescale 1ns/1ps

module lfsr_random (
    input  wire        clk,
    input  wire        reset,      // Active high (đồng bộ với hệ thống MIPS)
    output wire [31:0] random_out  // Số ngẫu nhiên định dạng Q15.16 (0 <= val < 1)
);

    // Sử dụng đa thức tối ưu cho LFSR 32-bit: x^32 + x^22 + x^2 + x^1 + 1
    // Taps: 32, 22, 2, 1
    reg [31:0] lfsr_reg;
    
    wire feedback;
    assign feedback = lfsr_reg[31] ^ lfsr_reg[21] ^ lfsr_reg[1] ^ lfsr_reg[0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr_reg <= 32'hDEAD_BEEF; // Seed khác 0 để LFSR hoạt động
        end else begin
            lfsr_reg <= {lfsr_reg[30:0], feedback};
        end
    end

    // Chuyển đổi sang định dạng Q15.16
    // Cấu trúc Q15.16: [31: Sign][30:16 Integer][15:0 Fraction]
    // Ta muốn số trong khoảng [0, 1), tức là Integer = 0, chỉ có Fraction.
    // Lấy 16 bit thấp của LFSR đưa vào phần Fraction.
    
    assign random_out = {1'b0, 15'd0, lfsr_reg[15:0]}; 

endmodule