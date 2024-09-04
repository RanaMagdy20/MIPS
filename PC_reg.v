module PC_reg # (parameter DATA_WIDTH =32)
(
    input wire CLK,RST,
    input wire [DATA_WIDTH-1:0] prog_counter,
    output reg [DATA_WIDTH-1:0] PC
);

always @(posedge CLK or negedge RST)
begin
    if (!RST)
    PC <= 'd0;
    else
    PC <= prog_counter;
end
endmodule 