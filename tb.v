module tb;

reg clk = 1;
reg rst = 1;
always #5 clk = ~clk;

initial $dumpvars(0);
initial #1 rst = 0;
initial #10000 $finish;

system system(clk, rst);

endmodule
