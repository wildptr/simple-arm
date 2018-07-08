module dp_imm_dec(
  input  [11:0] in,
  output [31:0] out,
  input         cin,
  output        cout
);

wire [4:0] rotamt;

assign rotamt = {in[11:8], 1'b0};

// verilator lint_off PINCONNECTEMPTY
ror u_ror(
  .in({24'b0, in[7:0]}),
  .sh(rotamt),
  .out(out),
  .cout()
);
// verilator lint_on PINCONNECTEMPTY

assign cout = |rotamt ? out[31] : cin ;

endmodule
