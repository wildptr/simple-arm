module alu_adder(
  input  [31:0] in1,
  input  [31:0] in2,
  input         cin,
  output [31:0] out,
  output        c,
  output        v
);
assign {c, out} = in1 + in2 + {32'b0, cin};
assign v = in1[31]^in2[31]^out[31]^c;
endmodule
