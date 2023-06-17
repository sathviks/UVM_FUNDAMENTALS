`include "uvm_macros.svh"
import uvm_pkg::*;
 
 
class first extends uvm_object; 
  
  rand bit [3:0] data;
  
  function new(string path = "first");
    super.new(path);
  endfunction 
  
  `uvm_object_utils_begin(first)
  `uvm_field_int(data, UVM_DEFAULT);
  `uvm_object_utils_end
  
endclass
/////////////////////////////////////
class first_mod extends first;
  rand bit ack;
  
  function new(string path = "first_mod");
    super.new(path);
  endfunction 
  
  `uvm_object_utils_begin(first_mod)
  `uvm_field_int(ack, UVM_DEFAULT);
  `uvm_object_utils_end
  
  
endclass
 
 
 
////////////////////////////////////////////
 
class comp extends uvm_component;
  `uvm_component_utils(comp)
  
  first f;
  
  function new(string path = "second", uvm_component parent = null);
    super.new(path, parent);
    f = first::type_id::create("f");
    f.randomize();
    f.print();
  endfunction 
  
  
endclass
 
 
/////////////////////////////////////////////
 
module tb;
 
  comp c;
  
  initial begin
    c.set_type_override_by_type(first::get_type, first_mod::get_type); 
    c = comp::type_id::create("comp", null); 
  end
 
  
endmodule


/*

(i.e ::). scope resolution operator uses to access static members class
The difference is that with type_id::create you get type checking at compile or elaboration time, whereas the $cast is a run-time type check.




# KERNEL: ------------------------------
# KERNEL: Name    Type       Size  Value
# KERNEL: ------------------------------
# KERNEL: f       first_mod  -     @344 
# KERNEL:   data  integral   4     'hc  
# KERNEL:   ack   integral   1     'h1  
# KERNEL: ------------------------------

*/