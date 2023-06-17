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
 
class obj extends uvm_object;
//  `uvm_object_utils(obj)
  
  typedef enum bit [1:0] {s0 , s1, s2, s3} state_type;
  typedef enum bit [4:0] {a1,a2,a3,a4} states;



  rand states states;
  rand state_type state;
  
  real temp = 12.34; 
  string str = "UVM";
 
  function new(string path = "obj");
    super.new(path);
  endfunction
  
 
  `uvm_object_utils_begin(obj)
  `uvm_field_enum(states, states, UVM_DEFAULT);
  `uvm_field_enum(state_type, state, UVM_DEFAULT);
  `uvm_field_string(str,UVM_DEFAULT);
  `uvm_field_real(temp, UVM_DEFAULT);
  `uvm_object_utils_end
 
  
endclass
 
module tb;
  obj o;

  first f1,f2;
 
  
   initial begin
     f1 = first::type_id::create("f1");
     f2 = first::type_id::create("f2");
     
     f1.randomize();
     f2.randomize();
     
     f1.print();
     f2.print();
   end
  
  initial begin
    o = new("obj");
    o.randomize();
    o.print(uvm_default_table_printer);
  end
  
endmodule