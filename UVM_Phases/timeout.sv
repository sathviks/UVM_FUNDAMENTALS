`include "uvm_macros.svh"
import uvm_pkg::*;
///default : 9200sec
 
 /*
we us in TB

you will be working with UVM_ROOT--> UVM_TOP

This is provided so that the user can prevent the simulation from potentially consuming too many resources (Disk, Memory, CPU, etc) 
when the testbench is essentially hung.


function void set_timeout(
   	time 	timeout,	  	
   	bit 	overridable	 = 	1
)

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
    phase.raise_objection(this);
    `uvm_info("mon", " Main Phase Started", UVM_NONE);
    #100;
    `uvm_info("mon", " Main Phase Ended", UVM_NONE);
    phase.drop_objection(this);
  endtask
  
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase); 
  endfunction
  
  
endclass
 
///////////////////////////////////////////////////////////////////////////
module tb;
  
  initial begin
 
    uvm_top.set_timeout(100ns, 0);// ) 0: other component cannot overide
  end
  
 
endmodule



/*

# KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test comp...
# KERNEL: UVM_INFO /home/runner/testbench.sv(21) @ 0: uvm_test_top [comp] Reset Started
# KERNEL: UVM_INFO /home/runner/testbench.sv(23) @ 10: uvm_test_top [comp] Reset Completed
# KERNEL: UVM_INFO /home/runner/testbench.sv(29) @ 10: uvm_test_top [mon]  Main Phase Started
# KERNEL: UVM_FATAL /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_phase.svh(1508) @ 100: reporter [PH_TIMEOUT] Explicit timeout of 100 hit, indicating a probable testbench issue
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 100: reporter [UVM/REPORT/SERVER] 
# KERNEL: --- UVM Report Summary ---
# KERNEL: 
# KERNEL: ** Report counts by severity
# KERNEL: UVM_INFO :    5
# KERNEL: UVM_WARNING :    0
# KERNEL: UVM_ERROR :    0
# KERNEL: UVM_FATAL :    1
# KERNEL: ** Report counts by id
# KERNEL: [PH_TIMEOUT]     1
# KERNEL: [RNTST]     1
# KERNEL: [UVM/RELNOTES]     1
# KERNEL: [comp]     2
# KERNEL: [mon]     1
# KERNEL: 
# RUNTIME: Info: RUNTIME_0068 uvm_root.svh (135): $finish called.


*/