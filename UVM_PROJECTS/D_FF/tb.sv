/ Code your testbench here

// or browse Examples

////////////////////////// Testbench Code

`timescale 1ns / 1ps

/////////////////////////Transaction

`include "uvm_macros.svh"

import uvm_pkg::*;

class transaction extends uvm_sequence_item;

rand bit din;

  bit dout;



  function new(input string inst = "transaction");

super.new(inst);

endfunction

`uvm_object_utils_begin(transaction)

  `uvm_field_int(din, UVM_DEFAULT)

`uvm_object_utils_end

endclass

//////////////////////////////////////////////////////////////

class generator extends uvm_sequence #(transaction);

`uvm_object_utils(generator)

transaction t;

function new(input string inst = "GEN");

super.new(inst);

endfunction

virtual task body();

  t = transaction::type_id::create("t");

  repeat(10)

    begin

    start_item(t);

    t.randomize();

    finish_item(t);

      `uvm_info("GEN",$sformatf("Data send to Driver din :%0d ",t.din), UVM_NONE); 

    end

endtask

endclass

////////////////////////////////////////////////////////////////////

class driver extends uvm_driver #(transaction);

`uvm_component_utils(driver)

function new(input string inst = " DRV", uvm_component c);

super.new(inst, c);

endfunction

transaction data;

virtual dff_if dif;

 

 

 

  ///////////////////reset logic

  task reset_dut();

    dif.rst <= 1'b1;

    dif.din   <= 0;

    repeat(5) @(posedge dif.clk);

    dif.rst <= 1'b0;

    `uvm_info("DRV", "Reset Done", UVM_NONE);

  endtask

 

 

////////////////////////////////////////////////////

virtual function void build_phase(uvm_phase phase);

super.build_phase(phase);

  data = transaction::type_id::create("data");

 

  if(!uvm_config_db #(virtual dff_if)::get(this,"","dif",dif))

`uvm_error("DRV","Unable to access uvm_config_db");

endfunction

 

 

   virtual task run_phase(uvm_phase phase);

    reset_dut();

    forever begin

      seq_item_port.get_next_item(data);

    dif.din <= data.din;

    seq_item_port.item_done();

      `uvm_info("DRV", $sformatf("Trigger DUT din: %0d",data.din), UVM_NONE);

    @(posedge dif.clk);

    @(posedge dif.clk);

    end

 

endtask

endclass

////////////////////////////////////////////////////////////////////////

class monitor extends uvm_monitor;

`uvm_component_utils(monitor)

uvm_analysis_port #(transaction) send;

function new(input string inst = "MON", uvm_component c);

super.new(inst, c);

send = new("Write", this);

endfunction

transaction t;

virtual dff_if dif;

virtual function void build_phase(uvm_phase phase);

super.build_phase(phase);

t = transaction::type_id::create("TRANS");

  if(!uvm_config_db #(virtual dff_if)::get(this,"","dif",dif))

`uvm_error("MON","Unable to access uvm_config_db");

endfunction

virtual task run_phase(uvm_phase phase);

  @(negedge dif.rst);

   forever begin

     repeat(2)@(posedge dif.clk);

    t.din = dif.din;

    t.dout = dif.dout;

     `uvm_info("MON", $sformatf("Data send to Scoreboard a : %0d and dout : %0d", t.din,t.dout), UVM_NONE);

    send.write(t);

   end

endtask

endclass

///////////////////////////////////////////////////////////////////////

class scoreboard extends uvm_scoreboard;

`uvm_component_utils(scoreboard)

 

uvm_analysis_imp #(transaction,scoreboard) recv;

transaction data;

function new(input string inst = "SCO", uvm_component c);

super.new(inst, c);

recv = new("Read", this);

endfunction

virtual function void build_phase(uvm_phase phase);

super.build_phase(phase);

data = transaction::type_id::create("TRANS");

endfunction

virtual function void write(input transaction t);

data = t;

  `uvm_info("SCO",$sformatf("Data rcvd from Monitor din: %0d and dout : %0d",t.din,t.dout), UVM_NONE);

  if(data.din == data.dout)

`uvm_info("SCO","Test Passed", UVM_NONE)

else

`uvm_info("SCO","Test Failed", UVM_NONE);

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

uvm_sequencer #(transaction) seq;

virtual function void build_phase(uvm_phase phase);

super.build_phase(phase);

m = monitor::type_id::create("MON",this);

d = driver::type_id::create("DRV",this);

seq = uvm_sequencer #(transaction)::type_id::create("SEQ",this);

endfunction

virtual function void connect_phase(uvm_phase phase);

super.connect_phase(phase);

d.seq_item_port.connect(seq.seq_item_export);

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

s = scoreboard::type_id::create("SCO",this);

a = agent::type_id::create("AGENT",this);

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

gen = generator::type_id::create("GEN",this);

e = env::type_id::create("ENV",this);

endfunction

virtual task run_phase(uvm_phase phase);

   phase.raise_objection(this);

   gen.start(e.a.seq);

   #60;

   phase.drop_objection(this);

endtask

endclass

//////////////////////////////////////

module dff_tb();

dff_if dif();

 

initial begin

  dif.clk = 0;

  dif.rst = 0;

end 

 

  always #10 dif.clk = ~dif.clk;

 

 

  dff dut (.din(dif.din), .dout(dif.dout), .clk(dif.clk), .rst(dif.rst));

initial begin

$dumpfile("dump.vcd");

$dumpvars;

end

 

initial begin 

  uvm_config_db #(virtual dff_if)::set(null, "*", "dif", dif);

run_test("test");

end

endmodule