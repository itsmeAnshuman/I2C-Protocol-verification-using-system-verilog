`include "environment.sv"

class test;
  environment env;
  virtual i2c_if vif;

  function new(virtual i2c_if vif);
    this.vif = vif;
    env = new(vif);
  endfunction

  task pre_test();
    env.drv.reset();
  endtask

  task test();
    fork
      env.gen.run();
      env.drv.run();
      env.mon.run();
      env.sco.run();
    join_any
  endtask

  task post_test();
    wait(env.gen.done.triggered);
    $finish();
  endtask

  task run();
    pre_test();
    test();
    post_test();
  endtask
endclass


