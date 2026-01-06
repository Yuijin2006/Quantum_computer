module instruction_memory (
    input wire [31:0] pc,
    output wire [31:0] instr
);
    reg [31:0] rom [0:63]; // Bộ nhớ 64 lệnh

    initial begin
        // --- KỊCH BẢN TEST: TẠO TRẠNG THÁI BELL (RỐI LƯỢNG TỬ) ---
        
        // 1. ADDI $t0, $0, 5 (Lệnh MIPS thường - Khởi động)
        // Hex: 20080005
        rom[0] = 32'h20080005;

        // 2. Q_H $1 (Lệnh Quantum: Cổng H lên Qubit 1)
        // Opcode COP2 (010010) | rs=0 | rt=1 | funct=01
        // Binary: 010010_00000_00001_00000_00000_000001 -> Hex: 48020001
        rom[1] = 32'h48020001;

        // 3. Q_CNOT $1, $2 (Lệnh Quantum: Control=Q1, Target=Q2)
        // Opcode COP2 (010010) | rs=1 | rt=2 | funct=04
        // Binary: 010010_00001_00010_00000_00000_000100 -> Hex: 48220004
        rom[2] = 32'h48220004;
        
        // 4. JUMP về lại dòng 1 (Tạo vòng lặp vô tận để dừng)
        // Opcode J (000010) | Address = 1
        // Hex: 08000001
        rom[3] = 32'h08000001;
    end

    // MIPS địa chỉ theo Byte, nên bỏ 2 bit cuối để lấy index mảng
    assign instr = rom[pc[31:2]];
endmodule