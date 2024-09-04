module Instr_mem # (parameter DATA_WIDTH=32, MEM_DEPTH=10)
(
    input wire [DATA_WIDTH-1:0] Addr,
    output wire [DATA_WIDTH-1:0] Instr
);
reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1] ; //*
wire [DATA_WIDTH-1:0] address;
assign address = Addr>>2; // div of 4

always @(*) begin
    Instr = mem [address];  
end 
   

///////////////////////R-type instructions:
//add $s0,$s1,$s2
assign mem [0] = 32'h02240020; 
//sub $s3,$s1,$s0
assign mem [1] = 32'h021EC022; 
//and $t2,$t1,$t0
assign mem [2] = 32'h01285024; 
//or $t9,$t8,$t7
assign mem [3] = 32'h031F2025;
//slt $s0,$s2,$s1 
assign mem [4] = 32'h0232202A; 
/////////////////////
//lw $t2, 32($0) 
assign mem[5] = 32'h8C0A0020;
///////////////////////
//sw $s1, 4($t1)
assign mem[6] = 32'hAD310004;
///////////////////////
//beq $t0, $0, else
assign mem[7] = 32'h11000004;
//////////////////////
//addi $t0 , %t0, 5
assign mem[8] = 32'h21380005;
///////////////////////
//j loop
assign mem[9] = 32'h080A0000;

endmodule







  