class scoreboard;
  
  transaction tr;
  mailbox #(transaction) mbxms;
  event sconext;
  
  bit [7:0] temp;  
  bit [7:0] mem[128] = '{default:0};
 
  function new( mailbox #(transaction) mbxms );
    this.mbxms = mbxms;
    
    for(int i = 0; i < 128; i++)
     begin
     mem[i] <= i;
     end
    endfunction
  
  task run();
    forever begin
      mbxms.get(tr);
      temp = mem[tr.addr];          
      if(tr.op == 1'b0)
                begin   
                  mem[tr.addr] = tr.din;
                  $display("[SCO]: DATA STORED -> ADDR : %0d DATA : %0d", tr.addr, tr.din);
                  $display("-----------------------------------------------");
                end
       else 
                begin
                 
                  if( (tr.dout == temp))// || (tr.dout == tr.addr) )
                    $display("[SCO] :DATA READ -> Data Matched exp: %0d rec:%0d",temp,tr.dout);
                 else
                    $display("[SCO] :DATA READ -> DATA MISMATCHED exp: %0d rec:%0d",temp,tr.dout);
                         
                $display("-----------------------------------------------");
               end
  ->sconext;
    end 
  endtask  
endclass
