
class environment;
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;

  mailbox #(transaction) mbxgd, mbxms;
  event nextgd;
  event nextgs;

  virtual i2c_if vif;

  function new(virtual i2c_if vif);
    this.vif = vif;
    mbxgd = new();
    mbxms = new();

    gen = new(mbxgd);
    drv = new(mbxgd);
    mon = new(mbxms);
    sco = new(mbxms);

    gen.count = 20;

    drv.vif = vif;
    mon.vif = vif;

    gen.drvnext = nextgd;
    drv.drvnext = nextgd;

    gen.sconext = nextgs;
    sco.sconext = nextgs;
  endfunction
endclass
