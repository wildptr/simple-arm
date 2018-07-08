module lsl(
  input [32:0] in,
  input [ 7:0] sh,
  output [32:0] out
);
assign out = in << sh;
endmodule
