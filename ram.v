module ram(clk, we, addr, din, dout);

input clk;
input [3:0] we;
input [11:2] addr;
input [31:0] din;
output reg [31:0] dout;

reg [31:0] m[0:2**12-1];

always @(posedge clk) begin
  dout <= m[addr];
  if (we[0]) m[addr][ 7: 0] <= din[ 7: 0];
  if (we[1]) m[addr][15: 8] <= din[15: 8];
  if (we[2]) m[addr][23:16] <= din[23:16];
  if (we[3]) m[addr][31:24] <= din[31:24];
end

endmodule
