`include "uvm_macros.svh"
import uvm_pkg::*;
 
class obj extends uvm_object;
  `uvm_object_utils(obj)
 
  function new(string path = "obj");
    super.new(path);
  endfunction
  
  rand bit [3:0] a;
  
endclass
 
module tb;
  obj o;
  
  initial begin
    o = new("obj");
    o.randomize();
    `uvm_info("TB_TOP", $sformatf("Value of a : %0d", o.a), UVM_NONE);
  end
  
endmodule
