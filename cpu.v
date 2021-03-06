module cpu
  (clk, rst, dstb, dwe, ddati, ddato, dadr, dsel, dack,
   istb, iack, idati, iadr);

input clk;
input rst;
output reg dstb, dwe; // comb
output istb;
output [3:0] dsel;
input [31:0] ddati, idati;
output [31:0] ddato;
output [31:2] iadr;
output [31:2] dadr;
input dack, iack;

reg [31:0] dadr_full; // comb
assign dadr = dadr_full[31:2];

reg [31:2] pc;
reg [31:2] newpc; // comb
wire pc1 = pc+30'b1;

reg [2:0] state;
reg [2:0] next_state; // comb
wire [31:0] ir = idati;

assign iadr = pc;

// pc
always @(posedge clk)
  if (rst) pc <= 30'b0;
  else if (next_state == RESET | next_state == INIT) pc <= newpc;

localparam RESET = 0;
localparam INIT = 1;
localparam LOAD = 2;
localparam LDM = 3;
localparam STM = 4;

// state
always @(posedge clk)
  state <= rst ? RESET : next_state;

assign istb = next_state == INIT;

wire [31:0] r1, r2, r3;
reg [31:0] rf_wdat; // comb
reg [1:0] rf_wdat_sel; // comb
wire [3:0] r1_sel, r2_sel;
reg [3:0] r3_sel; // comb
reg [3:0] rf_wsel; // comb
reg rf_we; // comb

rf rf(
  .clk(clk),
  .ra1_i(r1_sel),
  .do1_o(r1),
  .ra2_i(r2_sel),
  .do2_o(r2),
  .ra3_i(r3_sel),
  .do3_o(r3),
  .we1_i(rf_we),
  .wa1_i(rf_wsel),
  .di1_i(rf_wdat),
  .pc_i({pc1,2'b0})
);

reg cpsr_n, cpsr_z, cpsr_c, cpsr_v;

wire [31:0] alu_a, alu_b, alu_out;
wire [3:0] alu_op;
wire [3:0] alu_nzcv;

reg alu_b_imm; // comb

alu alu(
  .a(alu_a),
  .b(alu_b),
  .cin(cpsr_c),
  .op(alu_op),
  .sh_cout(),
  .vin(cpsr_v),
  .out(alu_out),
  .nzcv(alu_nzcv)
);

assign r1_sel = ir[19:16];
assign r2_sel = ir[3:0];

assign alu_op = ir[24:21];

wire dp_imm_dec_cout;
wire [31:0] dp_imm;

dp_imm_dec dp_imm_dec(
  .in(ir[11:0]),
  .out(dp_imm),
  .cin(cpsr_c),
  .cout(dp_imm_dec_cout)
);

wire [31:0] sh_out;
wire sh_cout;

shifter shifter(
  .op(ir[6:4]),
  .in(r2),
  .cin(cpsr_c),
  .sh_imm(ir[11:7]),
  .sh_reg(r3[7:0]),
  .out(sh_out),
  .cout(sh_cout)
);

assign alu_a = r1;
assign alu_b = alu_b_imm ? dp_imm : sh_out;

reg [2:0] dadr_sel;

localparam DADR_IMM_ADD = 0;
localparam DADR_IMM_SUB = 1;
localparam DADR_REG_ADD = 2;
localparam DADR_REG_SUB = 3;
localparam DADR_LSM = 4;

reg [31:2] lsm_addr;
reg [31:2] lsm_addr_next; // comb
reg [15:0] lsm_reglist;
reg [15:0] lsm_reglist_next; // comb

// lsm_addr
always @(posedge clk)
  lsm_addr <= lsm_addr_next;

// lsm_addr_next
always @*
  case (state)
    INIT: casez (ir)
      default: lsm_addr_next = 30'bx;
    endcase
    LDM, STM: lsm_addr_next = lsm_addr + 30'b1;
    default: lsm_addr_next = 30'bx;
  endcase

// lsm_reglist
always @(posedge clk)
  lsm_reglist <= lsm_reglist_next;

// lsm_reglist_next
always @*
  case (state)
    INIT: casez (ir)
      // LDM, STM
      32'b????100?????????????????????????: lsm_reglist_next = ir[15:0];
      default: lsm_reglist_next = 16'bx;
    endcase
    LDM, STM: lsm_reglist_next = (lsm_reglist-1)&lsm_reglist;
    default: lsm_reglist_next = 16'bx;
  endcase

// rf_we
always @*
  case (state)
    INIT: casez (ir)
      // DP
      32'b????00?0????????????????????????: rf_we = 1;
      32'b????00?11???????????????????????: rf_we = 1;
      // BL
      32'b????1011????????????????????????: rf_we = 1;
      default: rf_we = 0;
    endcase
    LOAD: rf_we = 1;
    LDM: rf_we = dack;
    default: rf_we = 0;
  endcase

// rf_wsel
always @*
  case (state)
    INIT: casez (ir)
      // DP
      32'b????00?0????????????????????????: rf_wsel = ir[15:12];
      32'b????00?11???????????????????????: rf_wsel = ir[15:12];
      // BL
      32'b????1011????????????????????????: rf_wsel = 4'he;
      default: rf_wsel = 4'bx;
    endcase
    LOAD: rf_wsel = ir[15:12];
    default: rf_wsel = 4'bx;
  endcase

// alu_b_imm
always @*
  casez (ir)
    32'b????001?????????????????????????: alu_b_imm = 1;
    default: alu_b_imm = 0;
  endcase

// dstb
always @*
  case (state)
    RESET: dstb = 0;
    INIT: casez (ir)
      // LDR, STR
      32'b????01??????????????????????????: dstb = 1;
      default: dstb = 0;
    endcase
    LDM: dstb = |lsm_reglist;
    STM: dstb = 1;
    default: dstb = 0;
  endcase

// dwe
always @*
  case (state)
    INIT: casez (ir)
      // STR
      32'b????01?????0????????????????????: dwe = 1;
      // LDR
      32'b????01?????1????????????????????: dwe = 0;
      default: dwe = 'bx;
    endcase
    LDM: dwe = 0;
    STM: dwe = 1;
    default: dwe = 'bx;
  endcase

// dadr_sel
always @*
  casez (ir)
    32'b????010?0???????????????????????: dadr_sel = DADR_IMM_SUB;
    32'b????010?1???????????????????????: dadr_sel = DADR_IMM_ADD;
    32'b????011?0???????????????????????: dadr_sel = DADR_REG_SUB;
    32'b????011?1???????????????????????: dadr_sel = DADR_REG_ADD;
    default: dadr_sel = 'bx;
  endcase

// r3_sel
always @*
  casez (ir)
    // DP
    32'b????000?????????????????????????: r3_sel = ir[11:8];
    // STR
    32'b????01?????0????????????????????: r3_sel = ir[15:12];
    default: r3_sel = 4'bx;
  endcase

// dadr_full
always @*
  case (dadr_sel)
    DADR_IMM_ADD : dadr_full = r1 + {{20{ir[11]}},ir[11:0]};
    DADR_IMM_SUB : dadr_full = r1 - {{20{ir[11]}},ir[11:0]};
    DADR_LSM : dadr_full = {lsm_addr,2'b0};
    default: dadr_full = 'bx;
  endcase

// next_state
always @*
  case (state)
    RESET: next_state = INIT;
    INIT: casez (ir)
      // LDR
      32'b????01?????1????????????????????: next_state = LOAD;
      // B
      32'b????101?????????????????????????: next_state = RESET;
      // LDM
      32'b????100????1????????????????????: next_state = LDM;
      // STM
      32'b????100????0????????????????????: next_state = STM;
      default: next_state = INIT;
    endcase
    LOAD: next_state = INIT;
    LDM: next_state = lsm_reglist ? LDM : INIT;
    STM: next_state = lsm_reglist_next ? STM : INIT;
    default: next_state = 'bx;
  endcase

localparam RF_WDAT_ALU = 0;
localparam RF_WDAT_MEM = 1;
localparam RF_WDAT_RETADDR = 2;

// rf_wdat_sel
always @*
  case (state)
    INIT: casez (ir)
      // DP
      32'b????00??????????????????????????: rf_wdat_sel = RF_WDAT_ALU;
      // BL
      32'b????1011????????????????????????: rf_wdat_sel = RF_WDAT_RETADDR;
      default: rf_wdat_sel = 'bx;
    endcase
    LOAD: rf_wdat_sel = RF_WDAT_MEM;
    default: rf_wdat_sel = 'bx;
  endcase

// rf_wdat
always @*
  case (rf_wdat_sel)
    RF_WDAT_ALU: rf_wdat = alu_out;
    RF_WDAT_MEM: rf_wdat = ddati;
    RF_WDAT_RETADDR: rf_wdat = {pc,2'b0};
    default: rf_wdat = 32'bx;
  endcase

// newpc
always @*
  case (state)
    INIT: casez (ir)
      32'b????101?????????????????????????:
        newpc = pc1 + {{6{ir[23]}},ir[23:0]};
      default: newpc = pc+30'b1;
    endcase
    default: newpc = pc+30'b1;
  endcase

assign ddato = r3;
assign dsel = 4'hf;

endmodule
