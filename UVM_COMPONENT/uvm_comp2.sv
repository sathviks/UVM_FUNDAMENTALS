`include "uvm_macros.svh"
import uvm_pkg::*;
 
 
  
////////////////////////////////////////////////////////////////////////
 
class a extends uvm_component;
  `uvm_component_utils(a)
  
  function new(string path = "a", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("a", "Class a executed", UVM_NONE);
  endfunction
  
endclass
 

////////////////////////////////////////////////////////////////


class d extends uvm_component;
  `uvm_component_utils(d)
  
  function new(string path = "d", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("a", "Class d executed", UVM_NONE);
  endfunction
  
endclass

class b extends uvm_component;
  `uvm_component_utils(b)
  
   d d_inst; 

  function new(string path = "b", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("a", "Class b executed", UVM_NONE);
     d_inst = d::type_id::create("d_inst",this);
  endfunction
  
  
endclass





 
//////////////////////////////////////////////////////////////////////
 
 
class c extends uvm_component;
  `uvm_component_utils(c)
  
  a a_inst;
  b b_inst;
  
  function new(string path = "c", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    a_inst = a::type_id::create("a_inst",this);
    b_inst = b::type_id::create("b_inst",this);
    `uvm_info("c", "Class c executed", UVM_NONE);

  endfunction
  
 virtual function void end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase);
   uvm_top.print_topology();
  endfunction
  
endclass
///////////////////////////////////////////////////////////////////////
 
module tb;
 
  initial begin
    run_test("c");    
  end
 
 
endmodule
/*

# KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test c...
# KERNEL: UVM_INFO /home/runner/testbench.sv(84) @ 0: uvm_test_top [c] Class c executed
# KERNEL: UVM_INFO /home/runner/testbench.sv(18) @ 0: uvm_test_top.a_inst [a] Class a executed
# KERNEL: UVM_INFO /home/runner/testbench.sv(54) @ 0: uvm_test_top.b_inst [a] Class b executed
# KERNEL: UVM_INFO /home/runner/testbench.sv(37) @ 0: uvm_test_top.b_inst.d_inst [a] Class d executed
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_root.svh(583) @ 0: reporter [UVMTOP] UVM testbench topology:
# KERNEL: -------------------------------
# KERNEL: Name          Type  Size  Value
# KERNEL: -------------------------------
# KERNEL: uvm_test_top  c     -     @335 
# KERNEL:   a_inst      a     -     @348 
# KERNEL:   b_inst      b     -     @357 
# KERNEL:     d_inst    d     -     @372 
# KERNEL: -------------------------------
# KERNEL: 
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER] 
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
# KERNEL: [UVMTOP]     1
# KERNEL: [a]     3
# KERNEL: [c]     1
# KERNEL: 
# RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.


*/