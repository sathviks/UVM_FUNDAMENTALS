`include "uvm_macros.svh"
import uvm_pkg::*;
 
 /*


 we us rasie and drop objection in sequencer

 when you want to hold simulator for specific time

 */
class comp extends uvm_component;
  `uvm_component_utils(comp)
  
 
  function new(string path = "comp", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    // this specifie carrent phase is using objection otherwise simulator will be not knowing when to exit
    `uvm_info("comp","Reset Started", UVM_NONE);
     #10;
    `uvm_info("comp","Reset Completed", UVM_NONE);
    phase.drop_objection(this);
  endtask
  
  
endclass
 
///////////////////////////////////////////////////////////////////////////
module tb;
  
  initial begin
    run_test("comp");
  end
  
 
endmodule

/*



# KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
# KERNEL: UVM_INFO /home/runner/testbench.sv(15) @ 0: uvm_test_top [comp] Reset Started
# KERNEL: UVM_INFO /home/runner/testbench.sv(17) @ 10: uvm_test_top [comp] Reset Completed
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 10: reporter [UVM/REPORT/SERVER] 
# KERNEL: --- UVM Report Summary ---
# KERNEL: 
# KERNEL: ** Report counts by severity
# KERNEL: UVM_INFO :    4
# KERNEL: UVM_WARNING :    0
# KERNEL: UVM_ERROR :    0
# KERNEL: UVM_FATAL :    0
# KERNEL: ** Report counts by id
# KERNEL: [RNTST]     1
# KERNEL: [UVM/RELNOTES]     1
# KERNEL: [comp]     2
# KERNEL: 
# RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.


*/