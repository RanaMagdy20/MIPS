module Reg_file # (parameter  DATA_WIDTH=32,DEPTH=32)
(
    input wire CLK,
    input wire WE,
    input wire [4:0] A1, A2, A3, //adrresses
    input wire [DATA_WIDTH-1:0] WD3,//write data 
    output reg [DATA_WIDTH-1:0] RD1,RD2 ,//read data
    output wire [DATA_WIDTH-1:0] s0
);

reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
assign s0=mem[16];
always @(posedge CLK) begin
    if (WE) 
        mem[A3] <= WD3; //rt or rd
end

always @(A1 or A2) begin

    RD1=(A1 != 'd0) ? mem[A1]:'d0; // rs
    RD2=(A2 != 'd0) ?mem[A2]:'d0; // rt

end

endmodule

