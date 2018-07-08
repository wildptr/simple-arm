module system(clk, rst);

input clk, rst;

wire cpu_dstb, cpu_dwe, cpu_istb, cpu_dack, cpu_iack;
wire [31:2] cpu_dadr, cpu_iadr;
wire [31:0] cpu_ddati, cpu_ddato, cpu_idati;
wire [3:0] cpu_dsel;

cpu cpu(
  .clk(clk),
  .rst(rst),
  .dstb(cpu_dstb),
  .dwe(cpu_dwe),
  .dadr(cpu_dadr),
  .dsel(cpu_dsel),
  .dack(cpu_dack),
  .ddati(cpu_ddati),
  .ddato(cpu_ddato),
  .istb(cpu_istb),
  .iadr(cpu_iadr),
  .iack(cpu_iack),
  .idati(cpu_idati)
);

mem mem(
  .clk(clk),
  .stb1(cpu_dstb),
  .stb2(cpu_istb),
  .we1(cpu_dwe),
  .sel1(cpu_dsel),
  .adr1(cpu_dadr[15:2]),
  .adr2(cpu_iadr[15:2]),
  .dat1_i(cpu_ddato),
  .dat1_o(cpu_ddati),
  .dat2_o(cpu_idati),
  .ack1(cpu_dack),
  .ack2(cpu_iack)
);

endmodule
