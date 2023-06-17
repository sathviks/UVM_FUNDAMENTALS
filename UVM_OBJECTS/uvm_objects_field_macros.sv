`include "uvm_macros.svh"
import uvm_pkg::*;
 



class obj extends uvm_object;
//  `uvm_object_utils(obj)
 
  function new(string path = "obj");
    super.new(path);
  endfunction
  
  rand bit [3:0] a;
  rand bit [7:0] b;
 
  `uvm_object_utils_begin(obj)
  `uvm_field_int(a, UVM_NOPRINT | UVM_BIN);
  `uvm_field_int(b, UVM_DEFAULT | UVM_DEC);
  `uvm_object_utils_end
 
  
endclass
//method1 
module tb;
  obj o;
  
  initial begin
    o = new("obj");
    o.randomize();
    o.print(uvm_default_table_printer);
  end
  
endmodule
/*


Method 1: Data members --> use field macros--> call core method (COPY,COMPARE,CLONE,CREATE,RECORD,PRINT,PACK,UNPACK)


Method 2 : specify implementation for core method --> call core method


*/