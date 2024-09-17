module TOP #(parameter DATA_WIDTH=32, INSTR_MEM_DEPTH=1024, Data_MEM_DEPTH=1024, REG_DEPTH=32)
(
    input wire CLK,WE,RST,
  input wire [DATA_WIDTH-1:0] INSTRUCTIONS, //to avoid optimization by synth tool
   output wire [DATA_WIDTH-1:0] s0 //to show  content of [s0]

);

wire [DATA_WIDTH-1:0] PC, PCBranch, PCPlus4,PC_next,PCJump,next,prog_counter;
wire [DATA_WIDTH-1:0] Result,Data_to_RF,Data_to_RF_1,final_Result;
wire [DATA_WIDTH-1:0] sign_Imm;
wire [DATA_WIDTH-1:0] ALU_Result;
wire [DATA_WIDTH-1:0] WriteData,RD2, ReadData ;
wire [DATA_WIDTH-1:0] Instr;
wire [DATA_WIDTH-1:0] SrcA,SrcB;
wire Jump,Branch,MemtoReg, MemWrite, RegDst, RegWrite,jr,jalr;
wire [2:0] load;
wire [1:0] store,MultoRF;
wire [4:0] ALUControl;
wire [4:0]WriteReg,WriteReg_addr; 
wire Zero, PCSrc_beq, PCSrc_bne, PCSrc_blez_bgtz, PCSrc_bltz_bgez, PCSrc ;
wire[1:0] ALUSrc;
//HI_LO:
wire [1:0] multiply,divide,HI_sel,LO_sel;
wire [2*DATA_WIDTH-1:0] mult_result,div_result;
wire [DATA_WIDTH-1:0] HI_out,LO_out,HI_IN,LO_IN;
wire [DATA_WIDTH-1:0]  sign_Imm_shifted;
assign PCJump = {PCPlus4[31:28],{Instr[25:0]<<2}}; ///////
assign PCPlus4= PC+'d4;
assign sign_Imm_shifted =sign_Imm<<2;
assign PCBranch=  sign_Imm_shifted + PCPlus4;
assign PCSrc_beq =Branch && Zero;
assign PCSrc_bne=Branch && !Zero;
assign PCSrc_blez_bgtz= Branch && ALU_Result;
assign PCSrc_bltz_bgez = Branch && ( ((|ALU_Result) && (&Instr[20:16])) || ((|ALU_Result) && (~|Instr[20:16])) );

assign PCSrc = PCSrc_beq || PCSrc_bne || PCSrc_blez_bgtz || PCSrc_bltz_bgez ;

mux2to1#(.WIDTH(DATA_WIDTH)) MUXtoBranch (
.in1(PCPlus4),
.in2(PCBranch),
.sel(PCSrc),
.out(next)
);
mux2to1 #(.WIDTH(DATA_WIDTH)) MUXtoJump (
.in1(next),
.in2(PCJump),
.sel(Jump),
.out(PC_next)
);

mux2to1 #(.WIDTH(DATA_WIDTH)) MUXtoJr (
.in1(PC_next),
.in2(SrcA), //[rs]
.sel(jr),
.out(prog_counter)
);

PC_reg #(.DATA_WIDTH(DATA_WIDTH)) PC_flipflop
(
.CLK(CLK),
.RST(RST),
.prog_counter(prog_counter),
.PC(PC)
);
//sw,sb,sh
mux3to1 #(.WIDTH(DATA_WIDTH)) MUXtoDataMem (
.in1(RD2),
.in2(RD2[7:0]),
.in3(RD2[15:0]),
.sel(store),
.out(WriteData)
);



RAM #(.DATA_WIDTH(DATA_WIDTH),.MEM_DEPTH(Data_MEM_DEPTH)) Data_memo
(
.CLK(CLK),
.WE(MemWrite),//write enable
.A(ALU_Result),//address
.WD(WriteData),
.RD(ReadData) 
);

RAM #(.DATA_WIDTH(DATA_WIDTH),.MEM_DEPTH(INSTR_MEM_DEPTH)) Instr_mem 
(
.CLK(CLK),
.WE(WE),//write enable
.A(PC),//address
.WD(INSTRUCTIONS),
.RD(Instr) 
);


mux2to1 #(.WIDTH(DATA_WIDTH)) MUXtoRegDst (
.in1(Instr[20:16]),
.in2(Instr[15:11]),
.sel(RegDst),
.out(WriteReg)
);


mux2to1 #(.WIDTH(DATA_WIDTH)) MUX_ra_rd_rt (
.in1(WriteReg),
.in2(5'd31), //$ra
.sel(jalr),
.out(WriteReg_addr)
);


 Reg_file #(.DATA_WIDTH(DATA_WIDTH),.DEPTH(REG_DEPTH)) RF
(
.CLK(CLK),
.WE(RegWrite),
.A1(Instr[25:21]),
.A2(Instr[20:16]),
.A3(WriteReg_addr), 
.WD3(Data_to_RF),
.RD1(SrcA),
.RD2(RD2),
.s0(s0)
);

Sign_Ext  #(.DATA_WIDTH(DATA_WIDTH)) Sign_extension
(
.instr_Imm(Instr[15:0]),
.sign_Imm(sign_Imm)
);

mux3to1 #(.WIDTH(DATA_WIDTH)) MUXtoALU (
.in1(RD2), //Data from RF
.in2(sign_Imm), //sign_extend
.in3({16'd0,Instr[15:0]}), //zero_extend
.sel(ALUSrc),
.out(SrcB)
);


ALU #(.DATA_WIDTH(DATA_WIDTH)) ALU_inst
(
.SrcA(SrcA),
.SrcB(SrcB),
.ALU_CTRL(ALUControl),
.Zero(Zero),
.ALU_Result(ALU_Result)  ,
.shamt(Instr[10:6])  
);

mux2to1 #(.WIDTH(DATA_WIDTH)) MUX_ALU_MEM_result (
.in1(ALU_Result),
.in2(ReadData),
.sel(MemtoReg),
.out(Result)
);

mux6to1 #(.WIDTH(DATA_WIDTH)) MUXtoload (
.in1(Result),
.in2({{24{Result[7]}},Result[7:0]}), //sign extend
.in3({{16{Result[7]}},Result[15:0]}), //sign extend
.in4({24'd0,Result[7:0]}), //zero ext
.in5({16'd0,Result[15:0]}) ,//zero ext
.in6({Instr[15:0],16'b0}),//lui
.sel(load),
.out(final_Result) //to RF
);


mux2to1 #(.WIDTH(DATA_WIDTH)) MUXtoJalr (
.in1(final_Result),
.in2(PCPlus4),
.sel(jalr),
.out(Data_to_RF_1)
);


CU control_unit
(.Opcode(Instr[31:26]),
.Funct(Instr[5:0]),
.MemtoReg(MemtoReg),
.MemWrite(MemWrite), 
.Branch(Branch), 
.ALUSrc(ALUSrc), 
.RegDst(RegDst), 
.RegWrite(RegWrite), 
.Jump(Jump),
.jr(jr),
.jalr(jalr),
.multiply(multiply),
.divide(divide),
.LO_sel(LO_sel),
.HI_sel(HI_sel),
//.bne(bne),
.load(load),
.store(store),
.MultoRF(MultoRF),
.ALUControl(ALUControl) 
);


mult #(.DATA_WIDTH(DATA_WIDTH)) Multiplyy
(
.A(SrcA),
.B(RD2),
.enable(multiply[1]), 
.sign(multiply[0]),  
.C(mult_result)
);

div #(.DATA_WIDTH(DATA_WIDTH)) Dividee
(
.A(SrcA),
.B(RD2),
.enable(divide[1]), 
.sign(divide[0]),  
.C(div_result)
);

mux3to1#(.WIDTH(DATA_WIDTH)) MUXtoHI (
.in1(SrcA), //mthi
.in2(mult_result[63:32]), //rs x rt
.in3(div_result[63:32]),
.sel(HI_sel),
.out(HI_IN)
);
mux3to1#(.WIDTH(DATA_WIDTH)) MUXtoLO (
.in1(SrcA), //mtlo
.in2(mult_result[31:0]), //[rs] x [rt]
.in3(div_result[31:0]), //[rs]/[rt]
.sel(LO_sel),
.out(LO_IN)
);

mux4to1 #(.WIDTH(DATA_WIDTH)) MUXtoRF (
.in1(Data_to_RF_1),  //not multiplication nor division
.in2(mult_result[31:0]), //mul result
.in3(HI_out),  //mfhi
.in4(LO_out),  //mflo
.sel(MultoRF),
.out(Data_to_RF)
);

GP_regs #(.DATA_WIDTH(DATA_WIDTH)) HI_LO
(
.CLK(CLK),
.RST(RST),
.D1(HI_IN),
.D2(LO_IN),
.HI_out(HI_out),
.LO_out(LO_out)
);



endmodule




