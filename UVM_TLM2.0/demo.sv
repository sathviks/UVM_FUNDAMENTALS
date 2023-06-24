`include "uvm_macros.svh"
import uvm_pkg::*;
 /*
this is used b/w mon and sco 

 */
 
class sender extends uvm_component;
   `uvm_component_utils(sender)
  
  logic [3:0] data;
  
  uvm_blocking_put_port #(logic [3:0] ) send;
  
  function new(input string path = "sender", uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send = new("send", this);
  endfunction
  
   virtual task run_phase(uvm_phase phase);
     forever begin
       for(int i = 0 ; i < 5; i++)
          begin
            data = $random;
            `uvm_info("sender", $sformatf("Data : %0d iteration : %0d",data,i), UVM_NONE);
            send.put(data);
            #20;
          end
      end
   endtask
  
 
endclass
///////////////////////////////////////////////////////////////
 
class receiver extends uvm_component;
   `uvm_component_utils(receiver)
  
  logic [3:0] datar;
  
  uvm_blocking_get_port #(logic [3:0] ) recv;
  
  function new(input string path = "receiver", uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
  endfunction
  
   virtual task run_phase(uvm_phase phase);
     forever begin
       for(int i = 0 ; i < 5; i++)
          begin
            #40;
            recv.get(datar);
            `uvm_info("receiver", $sformatf("Data : %0d iteration : %0d",datar,i), UVM_NONE);
          end
      end
   endtask
  
 
endclass
////////////////////////////////////////////////////////////////////////
 
class test extends uvm_test;
   `uvm_component_utils(test)
  
  
  
  uvm_tlm_fifo #(logic [3:0]) fifo;

  sender s;
  receiver r;
  
  function new(input string path = "test", uvm_component parent = null);
    super.new(path,parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    fifo = new("fifo", this, 10);// new ( instance name , parent , deppth of fifo / defaiult is 1 )
    s = sender::type_id::create("s", this);
    r = receiver::type_id::create("r", this);
  endfunction
  
   virtual function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
     s.send.connect(fifo.put_export);
     r.recv.connect(fifo.get_export);
   endfunction
  
     virtual task run_phase(uvm_phase phase);
       phase.raise_objection(this);
       #200;
       phase.drop_objection(this);
     endtask
  
 
endclass
 
 
////////////////////////////////////////////////////////////////////////////
 
module tb;
  
  initial begin
    run_test("test");
  end
  
  
endmodule


/*






# KERNEL: ASDB file was created in location /home/runner/dataset.asdb
# KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
# KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 0: uvm_test_top.s [sender] Data : 4 iteration : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 20: uvm_test_top.s [sender] Data : 1 iteration : 1
# KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 40: uvm_test_top.r [receiver] Data : 4 iteration : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 40: uvm_test_top.s [sender] Data : 9 iteration : 2
# KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 60: uvm_test_top.s [sender] Data : 3 iteration : 3
# KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 80: uvm_test_top.r [receiver] Data : 1 iteration : 1
# KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 80: uvm_test_top.s [sender] Data : 13 iteration : 4
# KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 100: uvm_test_top.s [sender] Data : 13 iteration : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 120: uvm_test_top.r [receiver] Data : 9 iteration : 2
# KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 120: uvm_test_top.s [sender] Data : 5 iteration : 1
# KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 140: uvm_test_top.s [sender] Data : 2 iteration : 2
# KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 160: uvm_test_top.r [receiver] Data : 3 iteration : 3
# KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 160: uvm_test_top.s [sender] Data : 1 iteration : 3
# KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 180: uvm_test_top.s [sender] Data : 13 iteration : 4
# KERNEL: UVM_INFO /home/runner/testbench.sv(59) @ 200: uvm_test_top.r [receiver] Data : 13 iteration : 4
# KERNEL: UVM_INFO /home/runner/testbench.sv(26) @ 200: uvm_test_top.s [sender] Data : 6 iteration : 0
**/