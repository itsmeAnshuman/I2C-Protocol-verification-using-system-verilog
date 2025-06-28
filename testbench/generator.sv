class generator;
  
  transaction tr;
  mailbox #(transaction) mbxgd;
  event done; ///gen completed sending requested no. of transaction
  event drvnext; /// dr complete its wor;
  event sconext; ///scoreboard complete its work
 
   int count = 0;
  
  function new( mailbox #(transaction) mbxgd);
    this.mbxgd = mbxgd;   
    tr =new();
  endfunction
  
    task run();
    
    repeat(count) begin
      assert(tr.randomize) else $error("Randomization Failed");
      //tr.addr = 7'h12;
      //tr.din  = 8'hff;
      mbxgd.put(tr);
      $display("[GEN]: op :%0d, addr : %0d, din : %0d", tr.op, tr.addr, tr.din);
      @(drvnext);
      @(sconext);
    end
    -> done;
  endtask
endclass
