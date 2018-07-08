module ror(
  input [31:0] in,
  input [ 4:0] sh,
  output reg [31:0] out,
  output cout
);

/*wire [32:0] net[0:31];
assign net[0] = {in, in[31]};
genvar i;
generate
for (i=1; i<32; i=i+1) begin: gen_net
  assign net[i] = {in[i-1:0], in[31:i], in[i-1]};
end
endgenerate*/

always @* begin
  case (sh)
    5'd 0: out = in;
    5'd 1: out = {in[ 0:0], in[31: 1]};
    5'd 2: out = {in[ 1:0], in[31: 2]};
    5'd 3: out = {in[ 2:0], in[31: 3]};
    5'd 4: out = {in[ 3:0], in[31: 4]};
    5'd 5: out = {in[ 4:0], in[31: 5]};
    5'd 6: out = {in[ 5:0], in[31: 6]};
    5'd 7: out = {in[ 6:0], in[31: 7]};
    5'd 8: out = {in[ 7:0], in[31: 8]};
    5'd 9: out = {in[ 8:0], in[31: 9]};
    5'd10: out = {in[ 9:0], in[31:10]};
    5'd11: out = {in[10:0], in[31:11]};
    5'd12: out = {in[11:0], in[31:12]};
    5'd13: out = {in[12:0], in[31:13]};
    5'd14: out = {in[13:0], in[31:14]};
    5'd15: out = {in[14:0], in[31:15]};
    5'd16: out = {in[15:0], in[31:16]};
    5'd17: out = {in[16:0], in[31:17]};
    5'd18: out = {in[17:0], in[31:18]};
    5'd19: out = {in[18:0], in[31:19]};
    5'd20: out = {in[19:0], in[31:20]};
    5'd21: out = {in[20:0], in[31:21]};
    5'd22: out = {in[21:0], in[31:22]};
    5'd23: out = {in[22:0], in[31:23]};
    5'd24: out = {in[23:0], in[31:24]};
    5'd25: out = {in[24:0], in[31:25]};
    5'd26: out = {in[25:0], in[31:26]};
    5'd27: out = {in[26:0], in[31:27]};
    5'd28: out = {in[27:0], in[31:28]};
    5'd29: out = {in[28:0], in[31:29]};
    5'd30: out = {in[29:0], in[31:30]};
    5'd31: out = {in[30:0], in[31:31]};
  endcase
end
assign cout = out[31];

endmodule
