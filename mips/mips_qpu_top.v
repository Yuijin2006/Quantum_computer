`timescale 1ns/1ps

// Top-level: MIPS front-end + Quantum Controller (QPU)
// - program_counter: giữ PC
// - instruction_memory: ROM chứa chương trình mẫu (cả lệnh MIPS và COP2 quantum)
// - mips_decoder: giải mã opcode, bật quantum_en khi gặp COP2 (010010)
// - quantum_controller: nhận cmd_gate/cmd_execute để tác động lên qubit

module mips_qpu_top (
    input  wire        clk,
    input  wire        reset,

    // Monitor outputs
    output wire [31:0] pc,
    output wire [31:0] instr,
    output wire        quantum_en,
    output wire [1:0]  q_status,
    output wire [31:0] q_alpha,
    output wire [31:0] q_beta,
    output wire        q_busy
);

    // ==================== PC & INSTRUCTION FETCH ====================
    wire [31:0] next_pc;

    program_counter pc_reg (
        .clk(clk),
        .rst(reset),
        .next_pc(next_pc),
        .pc(pc)
    );

    instruction_memory imem (
        .pc(pc),
        .instr(instr)
    );

    // ==================== DECODE OPCODE ====================
    wire [5:0] opcode = instr[31:26];

    // Tín hiệu điều khiển MIPS cổ điển (chưa dùng hết trong demo)
    wire reg_dst, branch, jump;
    wire mem_read, mem_to_reg, mem_write;
    wire alu_src, reg_write;
    wire [1:0] alu_op;

    mips_decoder decoder (
        .opcode(opcode),
        .reg_dst(reg_dst),
        .branch(branch),
        .jump(jump),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write),
        .alu_op(alu_op),
        .quantum_en(quantum_en)
    );

    // ==================== SIMPLE NEXT_PC LOGIC ====================
    wire [31:0] pc_plus_4 = pc + 32'd4;
    wire [25:0] j_addr    = instr[25:0];

    // Hỗ trợ JUMP cơ bản; chưa xử lý BRANCH trong demo
    assign next_pc = jump ? {pc[31:28], j_addr, 2'b00} : pc_plus_4;

    // ==================== QUANTUM CONTROLLER INTERFACE ====================
    reg  [2:0] cmd_gate;
    reg        cmd_execute;
    reg        prev_quantum_en;

    // Dùng các output để quan sát trạng thái qubit
    quantum_controller qctrl (
        .clk(clk),
        .reset(reset),
        .cmd_gate(cmd_gate),
        .cmd_execute(cmd_execute),
        .status(q_status),
        .display_alpha(q_alpha),
        .display_beta(q_beta),
        .gate_busy(q_busy)
    );

    // Phát xung cmd_execute khi gặp lệnh COP2 (quantum_en lên mức 1)
    // và giải mã một phần trường funct (instr[5:0]) thành loại cổng
    // Lưu ý: thiết kế hiện tại chỉ có cổng đơn qubit (H, X, Z, Y).
    // Lệnh Q_H ($funct = 6'b000001) được map sang H.
    // Lệnh Q_CNOT ($funct = 6'b000100) tạm map sang Y như một ví dụ
    // (vì hệ QPU hiện tại chỉ có 1 qubit, chưa hỗ trợ CNOT thật sự).

    wire [5:0] funct = instr[5:0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            prev_quantum_en <= 1'b0;
            cmd_execute    <= 1'b0;
            cmd_gate       <= 3'b000; // Identity
        end else begin
            // Mặc định không phát xung
            cmd_execute <= 1'b0;

            // Phát xung khi quantum_en chuyển từ 0 -> 1
            if (quantum_en && !prev_quantum_en) begin
                cmd_execute <= 1'b1;

                // Giải mã trường funct cho lệnh quantum
                case (funct)
                    6'd1:  cmd_gate <= 3'b001; // Q_H  -> Hadamard
                    6'd2:  cmd_gate <= 3'b010; // dự phòng: có thể dùng cho X
                    6'd3:  cmd_gate <= 3'b011; // dự phòng: có thể dùng cho Z
                    6'd4:  cmd_gate <= 3'b100; // Q_CNOT tạm map sang Y
                    default: cmd_gate <= 3'b000; // Không cổng (Identity)
                endcase
            end

            prev_quantum_en <= quantum_en;
        end
    end

endmodule
