module RAM # (parameter DATA_WIDTH=32, MEM_DEPTH=1024)
(
    input wire CLK,
    input  WE,
    input wire [$clog2(MEM_DEPTH)-1:0] A, //address
    input wire [DATA_WIDTH-1:0] WD,//write data 
    output wire [DATA_WIDTH-1:0] RD //read data
);

reg [7:0] mem [0:MEM_DEPTH-1] ;  //Byte addresable memory

// read operation :

assign  RD = {mem[A+3],mem[A+2],mem[A+1],mem[A]};
 //assign RD = mem[A>>2];

//write operation
always @(posedge CLK) begin
 if (WE)
    {mem[A+3],mem[A+2],mem[A+1],mem[A]} <= WD;
      // mem[A>>2] <= WD;
end
endmodule



























/*module Data_mem # (parameter DATA_WIDTH=32, MEM_DEPTH=2**32)
(
    input wire CLK,
    input wire WE,
    input wire [DATA_WIDTH-1:0] A, //address
    input wire [DATA_WIDTH-1:0] WD,//write data 
    output reg [DATA_WIDTH-1:0] RD //read data
);

reg [DATA_WIDTH-1:0] mem [0:MEM_DEPTH-1] ;

// read operation :
always @ (A or WD) begin
    RD = mem[A>>2];
end

//write operation
always @(posedge CLK) begin
    if (WE)
    mem[A>>2] <= WD;
end
endmodule


*/
