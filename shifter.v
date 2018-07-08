module shifter(
  input  [ 2:0] op,
  input  [31:0] in,
  input         cin,
  input  [ 4:0] sh_imm,
  input  [ 7:0] sh_reg,
  output [31:0] out,
  output        cout
);

wire [5:0] shamtw; // 1..32

reg [31:0] y; // comb logic
reg  c; // comb logic

assign shamtw = {~|sh_imm, sh_imm};

assign out = y;
assign cout = c;

wire [32:0] lsl_out;
wire [32:0] lsr_out;
wire [32:0] asr_out;
wire [32:0] ror_out;

wire [7:0] lslamt;
wire [7:0] lsramt;
wire [4:0] roramt;

assign lslamt = op[0] ? sh_reg      : {3'b0, sh_imm} ;
assign lsramt = op[0] ? sh_reg      : {2'b0, shamtw} ;
assign roramt = op[0] ? sh_reg[4:0] :        sh_imm  ;

lsl u_lsl(
  .in({cin, in}),
  .sh(lslamt),
  .out(lsl_out)
);

lsr u_lsr(
  .in({in, cin}),
  .sh(lsramt),
  .out(lsr_out)
);

asr u_asr(
  .in({in, cin}),
  .sh(lsramt),
  .out(asr_out)
);

ror u_ror(
  .in(in),
  .sh(roramt),
  .out(ror_out[32:1]),
  .cout(ror_out[0])
);

always @* begin
  casez (op)
    /* LSL */
    3'b00?: {c, y} = lsl_out;
    /* LSR */
    3'b01?: {y, c} = lsr_out;
    /* ASR */
    3'b10?: {y, c} = asr_out;
    /* ROR #<shift_imm> */
    3'b110: {y, c} = |sh_imm ? ror_out : {cin, in[31:1], in[0]};
    /* ROR <Rs> */
    3'b111: begin
      y = ror_out[32:1];
      c = |sh_reg[7:0] ? ror_out[0] : cin;
    end
  endcase
end

endmodule
