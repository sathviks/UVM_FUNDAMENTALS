`include "uvm_macros.svh"
import uvm_pkg::*;
 
class transaction extends uvm_sequence_item;
  rand bit [3:0] a;
  rand bit [3:0] b;
       bit [4:0] y;
 
 
  function new(input string inst = "transaction");
  super.new(inst);
  endfunction
 
`uvm_object_utils_begin(transaction)
  `uvm_field_int(a,UVM_DEFAULT)
  `uvm_field_int(b,UVM_DEFAULT)
  `uvm_field_int(y,UVM_DEFAULT)
`uvm_object_utils_end
 
endclass
//////////////////////////////////////////////////////
 
class sequence1 extends uvm_sequence#(transaction);
  `uvm_object_utils(sequence1)
 
transaction trans;
 
  function new(input string inst = "seq1");
  super.new(inst);
  endfunction
 
 virtual task body();
   `uvm_info("SEQ1", "Trans obj Created" , UVM_NONE); 
   
    trans = transaction::type_id::create("trans");
   `uvm_info("SEQ1", "Waiting for Grant from Driver" , UVM_NONE); 
    wait_for_grant();
   `uvm_info("SEQ1", "Rcvd Grant..Randomizing Data" , UVM_NONE);
   assert(trans.randomize()); 
   `uvm_info("SEQ1", "Randomization Done -> Sent Req to Drv" , UVM_NONE);
   send_request(trans);
   `uvm_info("SEQ1", "Waiting for Item Done Resp from Driver" , UVM_NONE);
   wait_for_item_done();
   `uvm_info("SEQ1", "SEQ1 Ended" , UVM_NONE); 
endtask
  
  
  
endclass
////////////////////////////////////////////////////////////////
 
 
 
class driver extends uvm_driver#(transaction);
`uvm_component_utils(driver)
 
transaction t;
virtual adder_if aif;
 
function new(input string inst = "DRV", uvm_component c);
super.new(inst,c);
endfunction
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
t = transaction::type_id::create("TRANS");
  if(!uvm_config_db#(virtual adder_if)::get(this,"","aif",aif))
`uvm_info("DRV", "Unable to access Interface", UVM_NONE);
endfunction
  
  virtual task run_phase(uvm_phase phase);
    forever begin
      `uvm_info("Drv", "Sending Grant for Sequence" , UVM_NONE);  
    seq_item_port.get_next_item(t);
      `uvm_info("Drv", "Applying Seq to DUT" , UVM_NONE);
      `uvm_info("Drv", "Sending Item Done Resp for Sequence" , UVM_NONE);
    seq_item_port.item_done();
    end
    
  endtask
 
 
endclass
 
 
 
class agent extends uvm_agent;
`uvm_component_utils(agent)
 
function new(input string inst = "AGENT", uvm_component c);
super.new(inst,c);
endfunction
 
driver d;
uvm_sequencer #(transaction) seq;
 
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
d = driver::type_id::create("DRV",this);
seq = uvm_sequencer #(transaction)::type_id::create("seq",this);
endfunction
 
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
d.seq_item_port.connect(seq.seq_item_export);
endfunction
endclass
 
 
class env extends uvm_env;
`uvm_component_utils(env)
 
function new(input string inst = "ENV", uvm_component c);
super.new(inst,c);
endfunction
 
agent a;
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
  a = agent::type_id::create("AGENT",this);
endfunction
 
endclass
 
 
class test extends uvm_test;
`uvm_component_utils(test)
 
function new(input string inst = "TEST", uvm_component c);
super.new(inst,c);
endfunction
 
sequence1 s1;
env e;
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
e = env::type_id::create("ENV",this);
s1 = sequence1::type_id::create("s1");
endfunction
 
virtual task run_phase(uvm_phase phase);
 
phase.raise_objection(this); 
s1.start(e.a.seq);
phase.drop_objection(this);
endtask
endclass
 
 
module ram_tb;
 
  adder_if aif();
 
 
 
initial begin
  uvm_config_db #(virtual adder_if)::set(null, "*", "aif", aif);
  run_test("test");
end
 
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule