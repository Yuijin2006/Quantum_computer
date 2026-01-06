module program_counter (
    input wire clk,
    input wire rst,
    input wire [31:0] next_pc,  // Địa chỉ lệnh tiếp theo
    output reg [31:0] pc        // Địa chỉ hiện tại
);
    always @(posedge clk or posedge rst) begin
        if (rst) 
            pc <= 32'd0;        // Reset về 0
        else 
            pc <= next_pc;      // Cập nhật theo xung nhịp
    end
endmodule