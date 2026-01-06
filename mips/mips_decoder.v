module mips_decoder (
    input wire [5:0] opcode,      // 6 bit đầu của lệnh
    
    // Output điều khiển MIPS cổ điển
    output reg reg_dst, branch, jump,
    output reg mem_read, mem_to_reg, mem_write,
    output reg alu_src, reg_write,
    output reg [1:0] alu_op,
    
    // Output điều khiển Quantum (Cốt lõi của đồ án)
    output reg quantum_en         // Tín hiệu kích hoạt QPU
);

    always @(*) begin
        // 1. Reset trạng thái mặc định
        reg_dst = 0; branch = 0; jump = 0;
        mem_read = 0; mem_to_reg = 0; mem_write = 0;
        alu_src = 0; reg_write = 0; alu_op = 2'b00;
        quantum_en = 0;

        // 2. Giải mã Opcode
        case (opcode)
            // --- LỆNH MIPS CƠ BẢN ---
            6'b000000: begin // R-type (ADD, SUB...)
                reg_dst = 1; reg_write = 1; alu_op = 2'b10;
            end
            
            6'b001000: begin // ADDI
                alu_src = 1; reg_write = 1; alu_op = 2'b00;
            end
            
            6'b000010: begin // JUMP (J-type)
                jump = 1;
            end
            
            // --- LỆNH QUANTUM (COP2 - 010010) ---
            // Khi gặp lệnh này, CPU cổ điển dừng ghi, bật QPU lên
            6'b010010: begin 
                quantum_en = 1; // BẬT QPU
                reg_write = 0;  // TẮT ghi thanh ghi MIPS
                mem_write = 0;  // TẮT ghi RAM MIPS
            end
        endcase
    end
endmodule