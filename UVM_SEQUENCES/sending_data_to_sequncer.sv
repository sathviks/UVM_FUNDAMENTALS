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
Always add viual keyword whenever we orride and define implementation for any inbuilt method


  */
  virtual task body();
    repeat(5) begin
      `uvm_do(trans);
      /*

      This macro takes as an argument a uvm_sequence_item here it is transaction variable or object.  
      The argument is created using `uvm_create if necessary, then randomized.  
      In the case of an item, it is randomized after the call to uvm_sequence_base::start_item() returns.  
      This is called late-randomization.  In the case of a sequence, 
      the sub-sequence is started using uvm_sequence_base::start() with call_pre_post set to 0.  
      In the case of an item, the item is sent to the driver through the associated sequencer.
      */
      `uvm_info("SEQ", $sformatf("a : %0d b:%0d", trans.a, trans.b), UVM_NONE);
    end
  endtask
 
 
  
endclass



/*

sequnces and driver have hand shaking mechanism

*/
///////////////////////////////////////////////
 
class driver extends uvm_driver#(transaction);
`uvm_component_utils(driver)
 transaction trans;
 
function new(input string inst = "DRV", uvm_component c);
super.new(inst,c);
endfunction
 
  virtual task run_phase(uvm_phase phase); 
    trans = transaction::type_id::create("trans");// this is new compared to previce example  
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
 /*
only diffrance is we ue run test but here we us in env
 */ 
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
# KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 0: uvm_test_top.e.a.DRV [DRV] a : 9 b:3
# KERNEL: UVM_INFO /home/runner/testbench.sv(38) @ 0: uvm_test_top.e.a.seqr@@s1 [SEQ] a : 9 b:3
# KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 0: uvm_test_top.e.a.DRV [DRV] a : 10 b:0
# KERNEL: UVM_INFO /home/runner/testbench.sv(38) @ 0: uvm_test_top.e.a.seqr@@s1 [SEQ] a : 10 b:0
# KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 0: uvm_test_top.e.a.DRV [DRV] a : 15 b:1
# KERNEL: UVM_INFO /home/runner/testbench.sv(38) @ 0: uvm_test_top.e.a.seqr@@s1 [SEQ] a : 15 b:1
# KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 0: uvm_test_top.e.a.DRV [DRV] a : 8 b:6
# KERNEL: UVM_INFO /home/runner/testbench.sv(38) @ 0: uvm_test_top.e.a.seqr@@s1 [SEQ] a : 8 b:6
# KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 0: uvm_test_top.e.a.DRV [DRV] a : 5 b:15
# KERNEL: UVM_INFO /home/runner/testbench.sv(38) @ 0: uvm_test_top.e.a.seqr@@s1 [SEQ] a : 5 b:15
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 0: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER] 
*/