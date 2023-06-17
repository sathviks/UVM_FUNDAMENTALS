`include "uvm_macros.svh"
import uvm_pkg::*;
/////Default Timeout = 9200sec
 /*

Total time you are considering is time that DUT take to respond but DUT take slightly more so we add buffer

that is handled effectively by drain time 

 drain time : it allow a buffer of time when we move to other phase



 */
 
class comp extends uvm_component;
  `uvm_component_utils(comp)
  
 
  function new(string path = "comp", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  task reset_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("comp","Reset Started", UVM_NONE);
     #10;
    `uvm_info("comp","Reset Completed", UVM_NONE);
    phase.drop_objection(this);
  endtask
  
  task main_phase(uvm_phase phase);


    phase.phase_done.set_drain_time(this,200);



    phase.raise_objection(this);
    `uvm_info("mon", " Main Phase Started", UVM_NONE);
    #100;
    `uvm_info("mon", " Main Phase Ended", UVM_NONE);
    phase.drop_objection(this);
  endtask
  
  task post_main_phase(uvm_phase phase);
    `uvm_info("mon", " Post-Main Phase Started", UVM_NONE);
  endtask
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
  endfunction
  
  
endclass
 
///////////////////////////////////////////////////////////////////////////
module tb;
  
  initial begin
   // uvm_top.set_timeout(100ns, 0);
    
    run_test("comp");
  end
  
 
endmodule

/*


# KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
# KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 0: uvm_test_top [comp] Reset Started
# KERNEL: UVM_INFO /home/runner/testbench.sv(28) @ 10: uvm_test_top [comp] Reset Completed
# KERNEL: UVM_INFO /home/runner/testbench.sv(40) @ 10: uvm_test_top [mon]  Main Phase Started
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 110: uvm_test_top [mon]  Main Phase Ended
# KERNEL: UVM_INFO /home/runner/testbench.sv(47) @ 310: uvm_test_top [mon]  Post-Main Phase Started
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 310: reporter [UVM/REPORT/SERVER] 
# KERNEL: --- UVM Report Summary ---
# KERNEL: 
# KERNEL: ** Report counts by severity
# KERNEL: UVM_INFO :    7
# KERNEL: UVM_WARNING :    0
# KERNEL: UVM_ERROR :    0
# KERNEL: UVM_FATAL :    0
# KERNEL: ** Report counts by id
# KERNEL: [RNTST]     1
# KERNEL: [UVM/RELNOTES]     1
# KERNEL: [comp]     2
# KERNEL: [mon]     3
# KERNEL: 
# RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.

*/