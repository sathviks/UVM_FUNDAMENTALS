`include "uvm_macros.svh" ///this includes all the macros related to UVM
import uvm_pkg::*;//this includes all the packages and classes related to UVM
 
 
 
module tb;
  
  initial begin
    #50;
    `uvm_info("TB_TOP","Hello World", UVM_LOW); 
     $display("Hello World with Display");
  end
  
  
  
endmodule