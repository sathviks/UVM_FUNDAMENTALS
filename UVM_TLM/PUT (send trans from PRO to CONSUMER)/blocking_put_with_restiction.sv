`include "uvm_macros.svh"
import uvm_pkg::*;
/*


1.connection b/w DRV and Seq happens in connect_phase of agent
2.MON & SCO happens in connect_phase of env


*/
class producer extends uvm_component;
  `uvm_component_utils(producer)
  
  int data = 12;
  
  uvm_blocking_put_port #(int) send;

  
  function new(input string path = "producer", uvm_component parent = null);
    super.new(path, parent);
    
    send  = new("send", this);
/*
    function new (string  name,uvm_componet parent , int min_size =1,int max_size =1 )
    min and max number of interfaces that must be onnected to this port by end of elaboration
  */
  
  endfunction
 
    
endclass
////////////////////////////////////////////////
 
class consumer extends uvm_component;
  `uvm_component_utils(consumer)
  
  
  uvm_blocking_put_export #(int) recv;
  
  function new(input string path = "consumer", uvm_component parent = null);
    super.new(path, parent);
    
    recv  = new("recv", this);
    
  endfunction
  
  
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
  p.send.connect(c.recv); // wow eazy than SV
  
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
# KERNEL: UVM_ERROR @ 0: uvm_test_top.e.c.recv [Connection Error] connection count of 0 does not meet required minimum of 1
# KERNEL: UVM_ERROR @ 0: uvm_test_top.e.p.send [Connection Error] connection count of 0 does not meet required minimum of 1
# KERNEL: UVM_FATAL @ 0: reporter [BUILDERR] stopping due to build errors
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 0: reporter [UVM/REPORT/SERVER] 
# KERNEL: --- UVM Report Summary ---
# KERNEL: 
# KERNEL: ** Report counts by severity
# KERNEL: UVM_INFO :    2
# KERNEL: UVM_WARNING :    0
# KERNEL: UVM_ERROR :    2
# KERNEL: UVM_FATAL :    1
# KERNEL: ** Report counts by id
# KERNEL: [BUILDERR]     1
# KERNEL: [Connection Error]     2
# KERNEL: [RNTST]     1
# KERNEL: [UVM/RELNOTES]     1
# KERNEL: 
# RUNTIME: Info: RUNTIME_0068 uvm_root.svh (135): $finish called.



Restiction 1: as you can see there 2 fatal error and conclude that Port --> export is not end of TLM Communication but it is srictly not allowd in UVM
Restiction 2: we donot have any method to send or recvice data --> this is solved by uvm_component_put_imp
*/
 
 
 