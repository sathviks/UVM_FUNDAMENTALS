`include "uvm_macros.svh"
import uvm_pkg::*;
 /*
primary usasge will be share interphase b/w classes


 */
class env extends uvm_env;
  `uvm_component_utils(env)
  
  int data;
  

  function new(string path = "env", uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
    
    if(uvm_config_db#(int):: get(null, "uvm_test_top", "data", data))   // us if-else will getting value 
/*
    Assume that context and instance must be same for get and set method to access the data 
*/
      `uvm_info("ENV", $sformatf("Value of data : %0d", data), UVM_NONE)
     else
       `uvm_error("ENV", "Unable to access the Value");
     
    
  endfunction
  
  
  
endclass
///////////////////////////////////////////////////
  
 class test extends uvm_test;
   `uvm_component_utils(test)
  
   env e;
  
   function new(string path = "test", uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
   virtual function void build_phase(uvm_phase phase);
     super.build_phase(phase);
     e = env::type_id::create("e",this); // this refer to class in which we are createing instance . 
                                         // here ebv instances is added in test hence this will refer TEST(Test is parent of env)
                                        
     //////////////////////////////
     
     uvm_config_db#(int)::set(null,"uvm_test_top", "data", 12); ////context + instance name + key + value
/* syntax :  
 uvm_config_db#(data type which you are shareing)::set(context,"instance name", "key", value); 

context : can be null or this
null: refer to UVM_ROOT her assume when we add null in context every component/class can access value more on this as we progress further

*/
   endfunction
  
endclass 
 
///////////////////////////
 
module tb;
  
  initial begin
    run_test("test");
    
  end
  
  
endmodule
 

 /*



# KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
# KERNEL: UVM_INFO /home/runner/testbench.sv(23) @ 0: uvm_test_top.e [ENV] Value of data : 12
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER] 
# KERNEL: --- UVM Report Summary ---
# KERNEL: 
# KERNEL: ** Report counts by severity
# KERNEL: UVM_INFO :    3
# KERNEL: UVM_WARNING :    0
# KERNEL: UVM_ERROR :    0
# KERNEL: UVM_FATAL :    0
# KERNEL: ** Report counts by id
# KERNEL: [ENV]     1
# KERNEL: [RNTST]     1
# KERNEL: [UVM/RELNOTES]     1
# KERNEL: 
# RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.




*/