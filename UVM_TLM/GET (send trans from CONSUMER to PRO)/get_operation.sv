`include "uvm_macros.svh"
import uvm_pkg::*;

/*
Primary diff b/w get and  put 
put: send data to consumer
get : get data from consumer

*/

 
class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  uvm_blocking_get_port #(int) port;
  
  int data = 0;// temp type that u rescive from consumer
  
  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    port   = new("port", this);
  endfunction
  
  task main_phase(uvm_phase phase);
  phase.raise_objection(this);
  port.get(data);
  `uvm_info("PROD", $sformatf("Data Recv : %0d", data), UVM_NONE); 
  phase.drop_objection(this);
 endtask
  
  
endclass
////////////////////////////////////////////////
 
class consumer extends uvm_component;
  `uvm_component_utils(consumer)
  
  int data = 12;
  
  uvm_blocking_get_imp#(int, consumer) imp;
  
  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    imp  = new("imp", this);
  endfunction
  
  virtual task get(output int datar);// here you want to send the data so it should be output
    `uvm_info("CONS", $sformatf("Data Sent : %0d", data), UVM_NONE); 
     datar = data;
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
  c = consumer::type_id::create("c", this);
  p = producer::type_id::create("p",this);
endfunction
 
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
  p.port.connect(c.imp);
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
# KERNEL: ASDB file was created in location /home/runner/dataset.asdb
# KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
# KERNEL: UVM_INFO /home/runner/testbench.sv(57) @ 0: uvm_test_top.e.c [CONS] Data Sent : 12
# KERNEL: UVM_INFO /home/runner/testbench.sv(31) @ 0: uvm_test_top.e.p [PROD] Data Recv : 12
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
-*/
 