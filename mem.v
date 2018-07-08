module mem(
  input clk,
  input stb1, stb2,
  input [15:2] adr1, adr2,
  input we1,
  input [3:0] sel1,
  input [31:0] dat1_i,
  output reg [31:0] dat1_o, dat2_o,
  output reg ack1, ack2
);

reg [7:0] m[0:65535];

always @(posedge clk) begin
  if (stb1) begin
    if (we1) begin
      if (sel1[3]) m[{adr1,2'b00}] <= dat1_i[ 7: 0];
      if (sel1[2]) m[{adr1,2'b01}] <= dat1_i[15: 8];
      if (sel1[1]) m[{adr1,2'b10}] <= dat1_i[23:16];
      if (sel1[0]) m[{adr1,2'b11}] <= dat1_i[31:24];
    end else begin
      dat1_o <=
        {m[{adr1,2'b11}],
         m[{adr1,2'b10}],
         m[{adr1,2'b01}],
         m[{adr1,2'b00}]};
    end
  end;
  if (stb2)
    dat2_o <=
      {m[{adr2,2'b11}],
       m[{adr2,2'b10}],
       m[{adr2,2'b01}],
       m[{adr2,2'b00}]};
  ack1 <= stb1;
  ack2 <= stb2;
end

initial $readmemh("mem.hex", m);

endmodule
