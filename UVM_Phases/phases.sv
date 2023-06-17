`include "uvm_macros.svh"
import uvm_pkg::*;
 
class test extends uvm_test;
  `uvm_component_utils(test)
  
  function new(string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  
  ////////////////////////////Construction Phases
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    
    `uvm_info("test","Build Phase Executed", UVM_NONE);
  endfunction
  
  
  
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("test","Connect Phase Executed", UVM_NONE);
  endfunction
 
  
  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    `uvm_info("test","End of Elaboration Phase Executed", UVM_NONE);
  endfunction
 
    function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info("test","Start of Simulation Phase Executed", UVM_NONE);
  endfunction
 
  
  //////////////////////////////Main Phases
  
  
  task run_phase(uvm_phase phase);
    `uvm_info("test", "Run Phase", UVM_NONE);   
  endtask
  
  
  //////////////////////////Cleanup Phases
  
  function void extract_phase(uvm_phase phase);
    super.extract_phase(phase);
    `uvm_info("test", "Extract Phase", UVM_NONE); 
  endfunction
  
  
  function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    `uvm_info("test", "Check Phase", UVM_NONE); 
  endfunction
  
  
  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("test", "Report Phase", UVM_NONE); 
  endfunction
  
  function void final_phase(uvm_phase phase);
    super.final_phase(phase);
      `uvm_info("test", "Final Phase", UVM_NONE); 
  endfunction
  
  
  
  
endclass
 
 
module tb;
  
  initial begin
    run_test("test");
  end
  
 
endmodule


/*

# KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
# KERNEL: UVM_INFO /home/runner/testbench.sv(18) @ 0: uvm_test_top [test] Build Phase Executed
# KERNEL: UVM_INFO /home/runner/testbench.sv(25) @ 0: uvm_test_top [test] Connect Phase Executed
# KERNEL: UVM_INFO /home/runner/testbench.sv(31) @ 0: uvm_test_top [test] End of Elaboration Phase Executed
# KERNEL: UVM_INFO /home/runner/testbench.sv(36) @ 0: uvm_test_top [test] Start of Simulation Phase Executed
# KERNEL: UVM_INFO /home/runner/testbench.sv(44) @ 0: uvm_test_top [test] Run Phase
# KERNEL: UVM_INFO /home/runner/testbench.sv(52) @ 0: uvm_test_top [test] Extract Phase
# KERNEL: UVM_INFO /home/runner/testbench.sv(58) @ 0: uvm_test_top [test] Check Phase
# KERNEL: UVM_INFO /home/runner/testbench.sv(64) @ 0: uvm_test_top [test] Report Phase
# KERNEL: UVM_INFO /home/runner/testbench.sv(69) @ 0: uvm_test_top [test] Final Phase
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER] 
# KERNEL: --- UVM Report Summary ---
# KERNEL: 
# KERNEL: ** Report counts by severity
# KERNEL: UVM_INFO :   11
# KERNEL: UVM_WARNING :    0
# KERNEL: UVM_ERROR :    0
# KERNEL: UVM_FATAL :    0
# KERNEL: ** Report counts by id
# KERNEL: [RNTST]     1
# KERNEL: [UVM/RELNOTES]     1
# KERNEL: [test]     9
# KERNEL: 
# RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.

*/