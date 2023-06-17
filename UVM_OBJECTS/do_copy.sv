`include "uvm_macros.svh"
import uvm_pkg::*;
 
class obj extends uvm_object;
  `uvm_object_utils(obj)
  
  function new(string path = "obj");
    super.new(path);
  endfunction
  
  rand bit [3:0] a;
  rand bit [4:0] b;
   
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field_int("a :", a, $bits(a), UVM_DEC);
    printer.print_field_int("b :", b, $bits(b), UVM_DEC);
  endfunction
  
  
  virtual function void do_copy(uvm_object rhs);
    obj temp;
    $cast(temp, rhs);
    super.do_copy(rhs);
    
     this.a = temp.a;
     this.b = temp.b;
 
  endfunction
 
  
endclass  
 
 
module tb;
  obj o1,o2;
  
  initial begin
    o1 = obj::type_id::create("o1");
    o2 = obj::type_id::create("o2");
    
    
    o1.randomize();
    o1.print();
    o2.copy(o1);
    o2.print();
   
  end
 
endmodule