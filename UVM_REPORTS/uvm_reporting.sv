`include "uvm_macros.svh"
import uvm_pkg::*;
 
module tb;
  
int data = 56;
  
  initial begin
    `uvm_info("TB_TOP", $sformatf("Value of data : %0d",data), UVM_NONE);
  end
  
  
  
endmodule


/* UVM Severity For Reporing




to change verbosity levels :set_report_verbostiy_level(UVM_HIGH)

1. `uvm_info_____(this has verbosity)

* action for this : UVM_DISPLAY

syntex:
 `uvm_info(ID,MSG,VERBOSITY)


2.`uvm_warning ,`uvm_error ,`uvm_fatal 

    `uvm_warning(ID,MSG)---> UVM_DISPLAY
    `uvm_error(ID,MSG)---> UVM_DISPLAY|UVM_COUNT--->toset count -->UVM_TOP.set_max_quit_count();
    `uvm_fatal(ID,MSG)---> UVM_DISPLAY|UVM_EXIT


*/
