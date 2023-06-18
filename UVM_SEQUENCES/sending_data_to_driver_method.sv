`include "uvm_macros.svh"
 import uvm_pkg::*;
////////////////////////////////////////////
 
 
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
 
////////////////////////////////////////////
class sequence1 extends uvm_sequence#(transaction);
  `uvm_object_utils(sequence1)
    transaction trans;
 
  
  function new(string path = "sequence1");
    super.new(path);    
  endfunction
  
 /*
  virtual task body();
    repeat(5) begin
      `uvm_do(trans);
      `uvm_info("SEQ", $sformatf("a : %0d b:%0d", trans.a, trans.b), UVM_NONE);
    end
  endtask
*/
  
   virtual task body();
      repeat(5) begin
      trans = transaction::type_id::create("trans");
      start._item(trans);
      assert(trans.randomize);
      finish_item(trans);
      `uvm_info("SEQ", $sformatf("a : %0d b:%0d", trans.a, trans.b), UVM_NONE);
    end
      
  
 
      
  endtask
 
  
endclass
///////////////////////////////////////////////
 
class driver extends uvm_driver#(transaction);
`uvm_component_utils(driver)
 transaction trans;
 
function new(input string inst = "DRV", uvm_component c);
super.new(inst,c);
endfunction
 
  virtual task run_phase(uvm_phase phase); 
    trans = transaction::type_id::create("trans");
    forever begin
      seq_item_port.get_next_item(trans);
      `uvm_info("DRV", $sformatf("a : %0d b:%0d", trans.a, trans.b), UVM_NONE);
      seq_item_port.item_done();     
    end
    
  endtask
 
endclass
 
 
//////////////////////////////////////////////////////
 
class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  uvm_sequencer#(transaction) seqr;
  driver d;
 
  
  function new(string path = "agent", uvm_component parent = null);
    super.new(path, parent); 
  endfunction
  
   virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     d = driver::type_id::create("DRV",this);
     seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
   endfunction
  
  virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
    d.seq_item_port.connect(seqr.seq_item_export);
endfunction
    
endclass
 
//////////////////////////////////////////////////////
//////////////////////running sequence with start method approach 1
 
class env extends uvm_env;
  `uvm_component_utils(env)
  
  agent a;
  sequence1 s1;
  
  function new(string path = "env", uvm_component parent = null);
    super.new(path, parent); 
  endfunction
  
   virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     a = agent::type_id::create("a", this);
     s1= sequence1::type_id::create("s1");
   endfunction
 
  virtual task run_phase(uvm_phase phase);
  phase.raise_objection(this);
  s1.start(a.seqr);
  phase.drop_objection(this);
  endtask
 
  
endclass
 
///////////////////////////////////////////////
 
class test extends uvm_test;
  `uvm_component_utils(test)
  
  env e;
  
  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent); 
  endfunction
  
   virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
     e = env::type_id::create("e", this);  
   endfunction
  
 
 
 
endclass
 
//////////////////////////////////////////////////////////////
 
 
module tb;
 
  
  initial begin
    run_test("test");
  end
  
  
endmodule


/*


# KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 0: uvm_test_top.e.a.DRV [DRV] a : 12 b:10
# KERNEL: UVM_INFO /home/runner/testbench.sv(49) @ 0: uvm_test_top.e.a.seqr@@s1 [SEQ] a : 12 b:10
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 0: uvm_test_top.e.a.DRV [DRV] a : 9 b:3
# KERNEL: UVM_INFO /home/runner/testbench.sv(49) @ 0: uvm_test_top.e.a.seqr@@s1 [SEQ] a : 9 b:3
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 0: uvm_test_top.e.a.DRV [DRV] a : 3 b:5
# KERNEL: UVM_INFO /home/runner/testbench.sv(49) @ 0: uvm_test_top.e.a.seqr@@s1 [SEQ] a : 3 b:5
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 0: uvm_test_top.e.a.DRV [DRV] a : 10 b:0
# KERNEL: UVM_INFO /home/runner/testbench.sv(49) @ 0: uvm_test_top.e.a.seqr@@s1 [SEQ] a : 10 b:0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 0: uvm_test_top.e.a.DRV [DRV] a : 14 b:4
# KERNEL: UVM_INFO /home/runner/testbench.sv(49) @ 0: uvm_test_top.e.a.seqr@@s1 [SEQ] a : 14 b:4
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 0: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER] 


*/