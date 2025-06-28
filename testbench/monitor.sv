class monitor;   
  virtual i2c_if vif; 
  transaction tr;
  mailbox #(transaction) mbxms;
  
  function new( mailbox #(transaction) mbxms );
    this.mbxms = mbxms;
  endfunction
  
  task run();    
    tr = new();
    forever 
    begin
      //@(posedge vif.clk);
      @(posedge vif.done);
      tr.din = vif.din;
      tr.addr = vif.addr;
      tr.op = vif.op;
      tr.dout = vif.dout;
      repeat(5) @(posedge vif.clk);
      mbxms.put(tr); 
      $display("[MON] op:%0d, addr: %0d, din : %0d, dout:%0d", tr.op, tr.addr, tr.din, tr.dout);
     end
  endtask 
endclass
///////////////////////////////////////////////////////////////
