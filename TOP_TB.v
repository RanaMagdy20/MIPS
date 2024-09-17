module TOP_TB ();
parameter TCLK=10;
parameter DATA_WIDTH=32 , INSTR_MEM_DEPTH=4096, Data_MEM_DEPTH=4096, REG_DEPTH=32;
reg CLK,RST,WE;
reg [DATA_WIDTH-1:0] INSTRUCTIONS;
wire [DATA_WIDTH-1:0] s0;
integer i;
//clock generation:
always #(TCLK/2) CLK=~CLK;

TOP #(.DATA_WIDTH(DATA_WIDTH), .INSTR_MEM_DEPTH(INSTR_MEM_DEPTH), .Data_MEM_DEPTH(Data_MEM_DEPTH), .REG_DEPTH(REG_DEPTH)) DUT 
(
.CLK(CLK),
.WE(WE),
.RST(RST),
.INSTRUCTIONS(INSTRUCTIONS),
.s0(s0)
);



initial begin

  for (i=0; i<REG_DEPTH;i=i+1)
 DUT.RF.mem[i] = i;

    CLK=0;
    RST=1;
    WE=1;
    #TCLK;
    RST=0;
    #TCLK;
    RST=1;
    $readmemh("memm.txt",DUT.Instr_mem.mem);
    #(100*TCLK) $stop;

end
endmodule
