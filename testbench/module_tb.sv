module tb;
  i2c_if vif();
  test t;

  i2c_top dut (
    vif.clk, vif.rst,  vif.newd, vif.op, 
    vif.addr, vif.din, vif.dout, 
    vif.busy, vif.ack_err, vif.done
  );

  initial begin
    vif.clk <= 0;
  end

  always #5 vif.clk <= ~vif.clk;

  initial begin
    t = new(vif);
    t.run();
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb);
  end
endmodule
