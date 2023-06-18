 
`include "uvm_macros.svh"
import uvm_pkg::*;
 
/////////////////////////////////////////////////////////////
 
class transaction extends uvm_sequence_item;
  
  rand bit [3:0] a;
  rand bit [3:0] b;
       bit [4:0] y;
 
 
  function new(input string path = "transaction");
    super.new(path);
  endfunction
 
`uvm_object_utils_begin(transaction)
  `uvm_field_int(a,UVM_DEFAULT)
  `uvm_field_int(b,UVM_DEFAULT)
  `uvm_field_int(y,UVM_DEFAULT)
`uvm_object_utils_end
 
endclass
////////////////////////////////////////////////////////////////
 
class sequence1 extends uvm_sequence#(transaction);
  `uvm_object_utils(sequence1)
 
 
    function new(input string path = "sequence1");
      super.new(path);
    endfunction
 /*
build in methods pre buid post
 */
    virtual task pre_body();
      `uvm_info("SEQ1", "PRE-BODY EXECUTED", UVM_NONE);
    endtask
 
 
    virtual task body();
      `uvm_info("SEQ1", "BODY EXECUTED", UVM_NONE); // here we will have randomiz() in real case
    endtask
 
 
 
    virtual task post_body();
      `uvm_info("SEQ1", "POST-BODY EXECUTED", UVM_NONE);
    endtask
  
  
endclass
 
////////////////////////////////////////////////////



/*
we wont be writeing code for sequencer 
most of the case we just renameing to our user defined names

*/
 
class driver extends uvm_driver#(transaction);
`uvm_component_utils(driver)
 /*
since we will be reciving data from sequncer we need to store so we add transction
 */
transaction t;
 
 
  function new(input string path = "DRV", uvm_component parent = null);
    super.new(path,parent);
  endfunction
 
  
  virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
    
    t = transaction::type_id::create("t");
 
  endfunction
  
  
 
    virtual task run_phase(uvm_phase phase);
    forever begin
    /*
    we will be having seq_item_port in driver through which we will be accessing data
    seq_item_port:
    Derived driver classes should use this port to request items from the sequencer. 
     They may also use it to send responses back.
    */
    seq_item_port.get_next_item(t);//this tells driver is ready to recived data from seqencer
     //////apply seq to DUT 
    seq_item_port.item_done();//this says seqencer that we are able to complete trasnsfer that consist of seq to DUT
                             // ready to recive next seq
                             // NON BLOCKING in nature
    end
    endtask
 
endclass
 
//////////////////////////////////////////////////////////////
 
class agent extends uvm_agent;
`uvm_component_utils(agent)
 
  function new(input string path = "agent", uvm_component parent = null);
    super.new(path,parent);
  endfunction
 
  driver d;
  uvm_sequencer #(transaction) seqr;//sequencer  is created in agent 
 
 
    virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      d = driver::type_id::create("d",this);
      seqr = uvm_sequencer #(transaction)::type_id::create("seqr",this);
    endfunction
 


 /*
        #important

        we need to specfie the connection b/w driver and sequencer 

 */
    virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
      d.seq_item_port.connect(seqr.seq_item_export);
      /*
        seq_item_port
        seq_item_export

        are pre defined

        these are special port to perform communication b/w seqencer and driver
      */
    endfunction
endclass
 
////////////////////////////////////////////////////////////
 
class env extends uvm_env;
`uvm_component_utils(env)
 
  function new(input string path = "env", uvm_component parent= null);
    super.new(path,parent);
  endfunction
 
  agent a;
 
  virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  a = agent::type_id::create("a",this);
  endfunction
 
endclass
 
///////////////////////////////////////////////////////////////////
 
class test extends uvm_test;
`uvm_component_utils(test)
 
  function new(input string path = "test", uvm_component parent = null);
  super.new(path,parent);
  endfunction
 
	sequence1 seq1;
	env e;
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
  e = env::type_id::create("e",this);
  seq1 = sequence1::type_id::create("seq1");
endfunction
 /*
raise_objection: this will hold the simulator untill the process of sending all stimuli 
in sequence to DUT

 */
  virtual task run_phase(uvm_phase phase);
  phase.raise_objection(this);
    
  seq1.start(e.a.seqr);
/*
    sequence.start(sequencer)
*/
  phase.drop_objection(this);
  endtask
  
endclass
 
/////////////////////////////////////////////////////////
 
module ram_tb;
 
 
initial begin
  run_test("test");
end
 
 
endmodule


/*



# KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
# KERNEL: UVM_INFO /home/runner/testbench.sv(38) @ 0: uvm_test_top.e.a.seqr@@seq1 [SEQ1] PRE-BODY EXECUTED
# KERNEL: UVM_INFO /home/runner/testbench.sv(43) @ 0: uvm_test_top.e.a.seqr@@seq1 [SEQ1] BODY EXECUTED
# KERNEL: UVM_INFO /home/runner/testbench.sv(49) @ 0: uvm_test_top.e.a.seqr@@seq1 [SEQ1] POST-BODY EXECUTED
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 0: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER] 
# KERNEL: --- UVM Report Summary ---
# KERNEL: 
# KERNEL: ** Report counts by severity
# KERNEL: UVM_INFO :    6
# KERNEL: UVM_WARNING :    0
# KERNEL: UVM_ERROR :    0
# KERNEL: UVM_FATAL :    0
# KERNEL: ** Report counts by id
# KERNEL: [RNTST]     1
# KERNEL: [SEQ1]     3
# KERNEL: [TEST_DONE]     1
# KERNEL: [UVM/RELNOTES]     1
# KERNEL: 
# RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.


*/