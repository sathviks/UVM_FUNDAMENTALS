`include "uvm_macros.svh"
import uvm_pkg::*;


/*
the solution for restriction can be resolved using  uvm_imp

this allow few predefind method
put and get

*/
 
class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  int data = 12;
  
  uvm_blocking_put_port #(int) send;
  
  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
    
    send  = new("send", this);
    
  endfunction
  
  
  task main_phase(uvm_phase phase);
   
    phase.raise_objection(this);
    send.put(data); //imp in consumer
    `uvm_info("PROD" , $sformatf("Data Sent : %0d", data), UVM_NONE);
    phase.drop_objection(this);
    
  endtask
  
 
    
endclass
////////////////////////////////////////////////
 
class consumer extends uvm_component;
  `uvm_component_utils(consumer)
  
  
  uvm_blocking_put_export #(int) recv;
  uvm_blocking_put_imp #(int, consumer) imp;
/*

 uvm_blocking_put_imp #(int, consumer) imp;


here consumer means class name you are recvieing data from

importent :  where ever you specfy put implimentaion you must specify the arragument as class name in put implimentation

*/

  
  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
    
    recv  = new("recv", this);
    imp   = new("imp" , this);
    
  endfunction
  
  task put(int datar); // this can be task or function what ever data sent by port will be argument for this method
    `uvm_info("CONS" , $sformatf("Data Rcvd : %0d", datar), UVM_NONE);
  endtask
  
  
endclass
 
//////////////////////////////////////////////////////////////////////////////////
 
class env extends uvm_env;
`uvm_component_utils(env)
 
producer p;
consumer c;
 
 
  function new(input string path = "env", uvm_component parent = null);
    super.new(path, parent);
  endfunction
 
 virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  p = producer::type_id::create("p",this);
  c = consumer::type_id::create("c", this);
 endfunction
 
  
  
 virtual function void connect_phase(uvm_phase phase);
 super.connect_phase(phase);
  
  p.send.connect(c.recv);
  c.recv.connect(c.imp); 
  
 endfunction
 
 
endclass
 
///////////////////////////////////////////////////
 
class test extends uvm_test;
`uvm_component_utils(test)
 
  env e;
 
  function new(input string path = "test", uvm_component parent = null);
    super.new(path, parent);
  endfunction
 
 
  virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  e = env::type_id::create("e",this);
  endfunction
 
 
endclass
 
//////////////////////////////////////////////
module tb;
 
 
initial begin
  run_test("test");
end
 
 
endmodule
 
 
 
 
 
 
 
 /*
 # KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
# KERNEL: UVM_INFO /home/runner/testbench.sv(66) @ 0: uvm_test_top.e.c [CONS] Data Rcvd : 12
# KERNEL: UVM_INFO /home/runner/testbench.sv(31) @ 0: uvm_test_top.e.p [PROD] Data Sent : 12
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER] 
# KERNEL: --- UVM Report Summary ---
# KERNEL: 
# KERNEL: ** Report counts by severity
# KERNEL: UVM_INFO :    4
# KERNEL: UVM_WARNING :    0
# KERNEL: UVM_ERROR :    0
# KERNEL: UVM_FATAL :    0
# KERNEL: ** Report counts by id
# KERNEL: [CONS]     1
# KERNEL: [PROD]     1
# KERNEL: [RNTST]     1
# KERNEL: [UVM/RELNOTES]     1
# KERNEL: 
# RUNTIME: Info: RUNTIME_0068 uvm_root.svh (521): $finish called.
*/
 
 
