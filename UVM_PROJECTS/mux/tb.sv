`timescale 1ns / 1ps

/////////////////////////Transaction

`include "uvm_macros.svh"

import uvm_pkg::*;

class transaction extends uvm_sequence_item;

  rand bit [3:0] a, b, c, d;

  rand bit [1:0] sel;

  bit [3:0] y;

  function new(input string path = "transaction");

    super.new(path);

  endfunction

`uvm_object_utils_begin(transaction)

`uvm_field_int(a, UVM_DEFAULT)

`uvm_field_int(b, UVM_DEFAULT)

`uvm_field_int(c, UVM_DEFAULT)

`uvm_field_int(d, UVM_DEFAULT)

`uvm_field_int(sel, UVM_DEFAULT) 

`uvm_field_int(y, UVM_DEFAULT)

`uvm_object_utils_end

endclass

//////////////////////////////////////////////////////////////

class generator extends uvm_sequence #(transaction);

`uvm_object_utils(generator)

transaction t;

integer i;

  function new(input string path = "generator");

    super.new(path);

  endfunction

virtual task body();

  t = transaction::type_id::create("t");

  repeat(2)

    begin

    start_item(t);

    t.randomize();

      `uvm_info("GEN",$sformatf("Data send to Driver a :%0d , b :%0d, c :%0d, d :%0d sel: %0d", t.a,t.b, t.c, t.d, t.sel), UVM_NONE);

    finish_item(t);

    end

endtask

endclass

////////////////////////////////////////////////////////////////////

class driver extends uvm_driver #(transaction);

`uvm_component_utils(driver)

    function new(input string path = "driver", uvm_component parent = null);

      super.new(path, parent);

     endfunction

transaction tc;

virtual mux_if mif;

    virtual function void build_phase(uvm_phase phase);

      super.build_phase(phase);

      tc = transaction::type_id::create("tc");

      if(!uvm_config_db #(virtual mux_if)::get(this,"","mif",mif))

      `uvm_error("DRV","Unable to access uvm_config_db");

    endfunction

    virtual task run_phase(uvm_phase phase);

    forever begin

     

    seq_item_port.get_next_item(tc);

    mif.a <= tc.a;

    mif.b <= tc.b;

    mif.c <= tc.c;

    mif.d <= tc.d; 

    mif.sel<=tc.sel;     

      `uvm_info("DRV", $sformatf("Trigger DUT a: %0d ,b :  %0d, c :  %0d, d :  %0d, sel: %0d",tc.a, tc.b, tc.c, tc.d), UVM_NONE);

    seq_item_port.item_done();

    #10; 

     

    end

    endtask

endclass

////////////////////////////////////////////////////////////////////////

class monitor extends uvm_monitor;

`uvm_component_utils(monitor)

uvm_analysis_port #(transaction) send;

  function new(input string path = "monitor", uvm_component parent = null);

    super.new(path, parent);

    send = new("send", this);

  endfunction

  transaction t;

  virtual mux_if mif;

  virtual function void build_phase(uvm_phase phase);

   super.build_phase(phase);

    t = transaction::type_id::create("t");

   

    if(!uvm_config_db #(virtual mux_if)::get(this,"","mif",mif))

   `uvm_error("MON","Unable to access uvm_config_db");

  endfunction

    virtual task run_phase(uvm_phase phase);

    forever begin

    #10;

    t.a = mif.a;

    t.b = mif.b;

    t.c = mif.c;

    t.d = mif.d;

    t.sel = mif.sel;     

    t.y = mif.y;

      `uvm_info("MON", $sformatf("Data send to Scoreboard a : %0d , b : %0d c : %0d d : %0d sel : %0d and y : %0d", t.a,t.b,t.c, t.d, t.sel, t.y), UVM_NONE);

    send.write(t);

    end

    endtask

endclass

///////////////////////////////////////////////////////////////////////

class scoreboard extends uvm_scoreboard;

`uvm_component_utils(scoreboard)

uvm_analysis_imp #(transaction,scoreboard) recv;

transaction tr;

  function new(input string path = "scoreboard", uvm_component parent = null);

    super.new(path, parent);

    recv = new("recv", this);

  endfunction

  virtual function void build_phase(uvm_phase phase);

  super.build_phase(phase);

    tr = transaction::type_id::create("tr");

  endfunction

  virtual function void write(input transaction t);

   tr = t;

    `uvm_info("SCO",$sformatf("Data rcvd from Monitor a: %0d , b : %0d , c : %0d , d : %0d , sel : %0d and y : %0d",tr.a,tr.b,tr.c, tr.d, tr.sel, tr.y), UVM_NONE);

 

    case (tr.sel)

      2'd0: begin tr.y = tr.a;  `uvm_info("SCO","Test Passed with sel 0", UVM_NONE) end

      2'd1: begin tr.y = tr.b;  `uvm_info("SCO","Test Passed with sel 1", UVM_NONE) end

      2'd2: begin tr.y = tr.c;  `uvm_info("SCO","Test Passed with sel 2", UVM_NONE) end

      2'd3: begin tr.y = tr.d;  `uvm_info("SCO","Test Passed with sel 3", UVM_NONE) end

    endcase

   

   endfunction

 

 

 

endclass

////////////////////////////////////////////////

class agent extends uvm_agent;

`uvm_component_utils(agent)

function new(input string inst = "AGENT", uvm_component c);

super.new(inst, c);

endfunction

monitor m;

driver d;

uvm_sequencer #(transaction) seqr;

virtual function void build_phase(uvm_phase phase);

super.build_phase(phase);

  m = monitor::type_id::create("m",this);

  d = driver::type_id::create("d",this);

  seqr = uvm_sequencer #(transaction)::type_id::create("seqr",this);

endfunction

virtual function void connect_phase(uvm_phase phase);

super.connect_phase(phase);

  d.seq_item_port.connect(seqr.seq_item_export);

endfunction

endclass

/////////////////////////////////////////////////////

class env extends uvm_env;

`uvm_component_utils(env)

function new(input string inst = "ENV", uvm_component c);

super.new(inst, c);

endfunction

scoreboard s;

agent a;

virtual function void build_phase(uvm_phase phase);

super.build_phase(phase);

  s = scoreboard::type_id::create("s",this);

  a = agent::type_id::create("a",this);

endfunction

virtual function void connect_phase(uvm_phase phase);

super.connect_phase(phase);

a.m.send.connect(s.recv);

endfunction

endclass

////////////////////////////////////////////

class test extends uvm_test;

`uvm_component_utils(test)

function new(input string inst = "TEST", uvm_component c);

super.new(inst, c);

endfunction

generator gen;

env e;

virtual function void build_phase(uvm_phase phase);

super.build_phase(phase);

  gen = generator::type_id::create("gen");

  e = env::type_id::create("e",this);

endfunction

virtual task run_phase(uvm_phase phase);

   phase.raise_objection(this);

   gen.start(e.a.seqr);

   #50;

   phase.drop_objection(this);

endtask

endclass

//////////////////////////////////////

module mux_tb();

mux_if mif();

  mux dut (.a(mif.a), .b(mif.b), .c(mif.c), .d(mif.d), .sel(mif.sel), .y(mif.y));

initial begin

$dumpfile("dump.vcd");

$dumpvars;

end

 

initial begin 

  uvm_config_db #(virtual mux_if)::set(null, "uvm_test_top.e.a*", "mif", mif);

run_test("test");

end

endmodule





Give Feedback

