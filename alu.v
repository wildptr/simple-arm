module alu(
  input  [31:0] a,
  input  [31:0] b,
  input         cin,
  input  [ 3:0] op,
  input         sh_cout,
  input         vin,

  output [31:0] out,
  output [ 3:0] nzcv
);

reg [31:0] y;

localparam AND = 4'b0000;
localparam EOR = 4'b0001;
localparam SUB = 4'b0010;
localparam RSB = 4'b0011;
localparam ADD = 4'b0100;
localparam ADC = 4'b0101;
localparam SBC = 4'b0110;
localparam RSC = 4'b0111;
localparam TST = 4'b1000;
localparam TEQ = 4'b1001;
localparam CMP = 4'b1010;
localparam CMN = 4'b1011;
localparam ORR = 4'b1100;
localparam MOV = 4'b1101;
localparam BIC = 4'b1110;
localparam MVN = 4'b1111;

// sub =  a + ~b + 1'b1;
// rsb = ~a +  b + 1'b1;
// add =  a +  b + 1'b0;
// adc =  a +  b + cin;
// sbc =  a + ~b + cin;
// rsc = ~a +  b + cin;

wire [31:0] in1, in2, adder_out;
wire adder_cin;
wire use_adder;

assign in1 = a ^ {32{op == RSB | op == RSC}};
assign in2 = b ^ {32{op == SUB | op == SBC | op == CMP}};
assign adder_cin =
  (op == SUB | op == RSB | op == CMP) |
  {op == ADC | op == SBC | op == RSC} & cin;

wire adder_cout;
wire adder_vout;

alu_adder u_alu_adder(
  .in1(in1),
  .in2(in2),
  .cin(adder_cin),
  .out(adder_out),
  .c(adder_cout),
  .v(adder_vout)
);

assign out = y;

assign nzcv[3] = y[31];
assign nzcv[2] = ~|y;
assign nzcv[1] = use_adder ? adder_cout : sh_cout ;
assign nzcv[0] = use_adder ? adder_vout : vin ;

// y
always @* begin
  casez (op)
    4'b?000: y = a & b; // AND(TST)
    4'b?001: y = a ^ b; // EOR(TEQ)
    4'b?01?: y = adder_out;
    4'b01??: y = adder_out;
    4'b1100: y = a | b; // ORR
    4'b1101: y =     b; // MOV
    4'b1110: y = a &~b; // BIC
    4'b1111: y =    ~b; // MVN
  endcase
end

assign use_adder = op[2] ? ~op[3] : op[1];

endmodule
