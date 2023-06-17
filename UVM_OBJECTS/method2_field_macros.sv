`include "uvm_macros.svh"
import uvm_pkg::*;
 
class obj extends uvm_object;
  `uvm_object_utils(obj)
  
  function new(string path = "OBJ");
    super.new(path);
  endfunction
  
  bit [3:0] a = 4;
  string b = "UVM";
  real c   = 12.34;
  
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    
    printer.print_field_int("a", a, $bits(a), UVM_HEX);
    printer.print_string("b", b);
    printer.print_real("c", c);
    
  endfunction
  
  
endclass  
 
 
module tb;
  obj o;
  
  initial begin
    o = obj::type_id::create("o");
    o.print();
  end
 
endmodule