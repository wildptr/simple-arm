module rf(clk, ra1_i, do1_o, ra2_i, do2_o, ra3_i, do3_o,
  we1_i, wa1_i, di1_i, pc_i);

input clk;
input [3:0] ra1_i, ra2_i, ra3_i;
output [31:0] do1_o, do2_o, do3_o;
input we1_i;
input [3:0] wa1_i;
input [31:0] di1_i;
input [31:0] pc_i;

reg [31:0] r[0:13];

assign do1_o = &ra1_i ? pc_i : r[ra1_i];
assign do2_o = &ra2_i ? pc_i : r[ra2_i];
assign do3_o = &ra3_i ? pc_i : r[ra3_i];

always @(posedge clk)
  if (we1_i & ~&wa1_i) r[wa1_i] <= di1_i;

endmodule
