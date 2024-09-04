module ALU # (parameter DATA_WIDTH =32)
(
    input wire [DATA_WIDTH-1:0] SrcA,SrcB,
    input wire [4:0] shamt,
    input wire [3:0] ALU_CTRL,
    output wire Zero,
    output reg [DATA_WIDTH-1:0] ALU_Result 
);
always @ (*)
begin
    case (ALU_CTRL)
    'd0 : ALU_Result = SrcA & SrcB; //and
    'd1 : ALU_Result = SrcA | SrcB; //or
    'd2 : ALU_Result = SrcA + SrcB; //add,addu
    'd3 : ALU_Result = SrcA ^ SrcB; //xor
   // 'd4 : ALU_Result = SrcA & ~SrcB; // A and ~B
    //'d5 : ALU_Result = SrcA | ~SrcB; //A or ~B
    'd6 : ALU_Result = $signed(SrcA) - $signed(SrcB); //signed sub 
    'd7 : ALU_Result = ($signed(SrcA) < $signed(SrcB))? 1'b1 : 1'b0; //slt
    'd8 : ALU_Result = (SrcA < SrcB) ? 1'b1 : 1'b0; //sltu
    'd9 : ALU_Result = ~(SrcA | SrcB); //nor
    'd10 : ALU_Result = SrcA - SrcB; //unsigned sub
    'd11 : ALU_Result = SrcB << shamt;//sll
    'd12 : ALU_Result = SrcB >> shamt;//srl
    'd13 : ALU_Result = $signed(SrcB) >>> shamt;//sra
    'd14 : ALU_Result = SrcB << SrcA[4:0];//sllv
    'd15 : ALU_Result = SrcB >> SrcA[4:0];//srlv
    'd4  : ALU_Result = $signed(SrcB) >>> SrcA[4:0];//srav


    default : ALU_Result = SrcA;
endcase
end
//assign  Zero = (!ALU_Result) ? 1'b1 : 1'b0 ;
assign  Zero = ~| ALU_Result ;
endmodule
