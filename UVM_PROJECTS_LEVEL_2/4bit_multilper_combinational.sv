module mul(
  input [3:0] a,b,
  output [7:0] y
);
   
assign y = a * b;
  
endmodule
 
 
///////////////////////////////////////////
 
interface mul_if;
  logic [3:0] a;
  logic [3:0] b;
  logic [7:0] y;
  // it is smiple logic so we are not adding any mod port :)
endinterface





//////////////////////////////////////////


`include "uvm_macros.svh"
import uvm_pkg::*;
 
////////////////////////////////////////////////////////////
class transaction extends uvm_sequence_item;
`uvm_object_utils(transaction)
  
   rand bit [3:0] a;
   rand bit [3:0] b;
        bit [7:0] y;
        
   function new(input string path = "transaction");
    super.new(path);
   endfunction
  
 
endclass
 
 
 
 
////////////////////////////////////////////////////////////////////////
 
class generator extends uvm_sequence#(transaction);
`uvm_object_utils(generator)
  
    transaction tr;
 
   function new(input string path = "generator");
    super.new(path);
   endfunction
   
   
   virtual task body(); 
   repeat(15)
    tr = transaction::type_id::create("tr");
     begin
         start_item(tr);
         assert(tr.randomize());
         `uvm_info("SEQ", $sformatf("a : %0d  b : %0d  y : %0d", tr.a, tr.b, tr.y), UVM_NONE);
         finish_item(tr);     
     end
   endtask
 
endclass
//////////////////////////////////////////////////////////////////////////////
 
 
class drv extends uvm_driver#(transaction);
  `uvm_component_utils(drv)
 
  transaction tr;
  virtual mul_if mif;
 
  function new(input string path = "drv", uvm_component parent = null);
    super.new(path,parent);
  endfunction
 
  virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
    if(!uvm_config_db#(virtual mul_if)::get(this,"","mif",mif))//uvm_test_top.env.agent.drv.aif
      `uvm_error("drv","Unable to access Interface");
  endfunction
  
   virtual task run_phase(uvm_phase phase);
      tr = transaction::type_id::create("tr");
     forever begin
        seq_item_port.get_next_item(tr);
        mif.a <= tr.a;
        mif.b <= tr.b;
       `uvm_info("DRV", $sformatf("a : %0d  b : %0d  y : %0d", tr.a, tr.b, tr.y), UVM_NONE);
        seq_item_port.item_done();
        #20;   
      end
   endtask
 
endclass
 
//////////////////////////////////////////////////////////////////////////
class mon extends uvm_monitor;
`uvm_component_utils(mon)
 
uvm_analysis_port#(transaction) send;
transaction tr;
virtual mul_if mif;
 
    function new(input string inst = "mon", uvm_component parent = null);
    super.new(inst,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tr = transaction::type_id::create("tr");
    send = new("send", this);
    if(!uvm_config_db#(virtual mul_if)::get(this,"","mif",mif))//uvm_test_top.env.agent.drv.aif
      `uvm_error("drv","Unable to access Interface");
    endfunction
    
    
    virtual task run_phase(uvm_phase phase);
    forever begin
    #20;
    tr.a = mif.a;
    tr.b = mif.b;
    tr.y = mif.y;
    `uvm_info("MON", $sformatf("a : %0d  b : %0d  y : %0d", tr.a, tr.b, tr.y), UVM_NONE);
    send.write(tr);
    end
   endtask 
 
endclass
 
/////////////////////////////////////////////////////////////////////////
class sco extends uvm_scoreboard;
`uvm_component_utils(sco)
 
  uvm_analysis_imp#(transaction,sco) recv;
 
 
    function new(input string inst = "sco", uvm_component parent = null);
    super.new(inst,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
    endfunction
    
    
  virtual function void write(transaction tr);
      if(tr.y == (tr.a * tr.b))
         `uvm_info("SCO", $sformatf("Test Passed -> a : %0d  b : %0d  y : %0d", tr.a, tr.b, tr.y), UVM_NONE)
      else
         `uvm_error("SCO", $sformatf("Test Failed -> a : %0d  b : %0d  y : %0d", tr.a, tr.b, tr.y))
      
    $display("----------------------------------------------------------------");
    endfunction
 
endclass
 
///////////////////////////////////////////////////////////////////////////
 
class agent extends uvm_agent;
`uvm_component_utils(agent)
 
function new(input string inst = "agent", uvm_component parent = null);
super.new(inst,parent);
endfunction
 
 drv d;
 uvm_sequencer#(transaction) seqr;
 mon m;
 
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
 d = drv::type_id::create("d",this);
 m = mon::type_id::create("m",this);
 seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this);
endfunction
 
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
d.seq_item_port.connect(seqr.seq_item_export);
endfunction
 
endclass
 
///////////////////////////////////////////////////////////////////////
 
class env extends uvm_env;
`uvm_component_utils(env)
 
function new(input string inst = "env", uvm_component c);
super.new(inst,c);
endfunction
 
agent a;
sco s;
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
  a = agent::type_id::create("a",this);
  s = sco::type_id::create("s", this);
endfunction
 
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
a.m.send.connect(s.recv);
endfunction
 
endclass
 
 
//////////////////////////////////////////////////////////////////
class test extends uvm_test;
`uvm_component_utils(test)
 
function new(input string inst = "test", uvm_component c);
super.new(inst,c);
endfunction
 
env e;
generator gen;
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
  e   = env::type_id::create("env",this);
  gen = generator::type_id::create("gen");
endfunction
 
virtual task run_phase(uvm_phase phase);
phase.raise_objection(this);
gen.start(e.a.seqr);
#20;
phase.drop_objection(this);
endtask
endclass
 
 
////////////////////////////////////////////////////////////////////
module tb;
 
  mul_if mif();
  
  mul dut (.a(mif.a), .b(mif.b), .y(mif.y));
 
  initial 
  begin
  uvm_config_db #(virtual mul_if)::set(null, "*", "mif", mif);
  run_test("test"); 
  end
 
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
endmodule
 


 /*



# KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test test...
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 0: uvm_test_top.env.a.seqr@@gen [SEQ] a : 14  b : 8  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 0: uvm_test_top.env.a.d [DRV] a : 14  b : 8  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 20: uvm_test_top.env.a.m [MON] a : 14  b : 8  y : 112
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 20: uvm_test_top.env.s [SCO] Test Passed -> a : 14  b : 8  y : 112
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 20: uvm_test_top.env.a.seqr@@gen [SEQ] a : 11  b : 1  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 20: uvm_test_top.env.a.d [DRV] a : 11  b : 1  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 40: uvm_test_top.env.a.m [MON] a : 11  b : 1  y : 11
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 40: uvm_test_top.env.s [SCO] Test Passed -> a : 11  b : 1  y : 11
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 40: uvm_test_top.env.a.seqr@@gen [SEQ] a : 5  b : 3  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 40: uvm_test_top.env.a.d [DRV] a : 5  b : 3  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 60: uvm_test_top.env.a.m [MON] a : 5  b : 3  y : 15
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 60: uvm_test_top.env.s [SCO] Test Passed -> a : 5  b : 3  y : 15
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 60: uvm_test_top.env.a.seqr@@gen [SEQ] a : 12  b : 14  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 60: uvm_test_top.env.a.d [DRV] a : 12  b : 14  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 80: uvm_test_top.env.a.m [MON] a : 12  b : 14  y : 168
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 80: uvm_test_top.env.s [SCO] Test Passed -> a : 12  b : 14  y : 168
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 80: uvm_test_top.env.a.seqr@@gen [SEQ] a : 0  b : 2  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 80: uvm_test_top.env.a.d [DRV] a : 0  b : 2  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 100: uvm_test_top.env.a.m [MON] a : 0  b : 2  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 100: uvm_test_top.env.s [SCO] Test Passed -> a : 0  b : 2  y : 0
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 100: uvm_test_top.env.a.seqr@@gen [SEQ] a : 1  b : 15  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 100: uvm_test_top.env.a.d [DRV] a : 1  b : 15  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 120: uvm_test_top.env.a.m [MON] a : 1  b : 15  y : 15
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 120: uvm_test_top.env.s [SCO] Test Passed -> a : 1  b : 15  y : 15
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 120: uvm_test_top.env.a.seqr@@gen [SEQ] a : 15  b : 5  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 120: uvm_test_top.env.a.d [DRV] a : 15  b : 5  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 140: uvm_test_top.env.a.m [MON] a : 15  b : 5  y : 75
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 140: uvm_test_top.env.s [SCO] Test Passed -> a : 15  b : 5  y : 75
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 140: uvm_test_top.env.a.seqr@@gen [SEQ] a : 10  b : 4  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 140: uvm_test_top.env.a.d [DRV] a : 10  b : 4  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 160: uvm_test_top.env.a.m [MON] a : 10  b : 4  y : 40
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 160: uvm_test_top.env.s [SCO] Test Passed -> a : 10  b : 4  y : 40
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 160: uvm_test_top.env.a.seqr@@gen [SEQ] a : 2  b : 12  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 160: uvm_test_top.env.a.d [DRV] a : 2  b : 12  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 180: uvm_test_top.env.a.m [MON] a : 2  b : 12  y : 24
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 180: uvm_test_top.env.s [SCO] Test Passed -> a : 2  b : 12  y : 24
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 180: uvm_test_top.env.a.seqr@@gen [SEQ] a : 7  b : 13  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 180: uvm_test_top.env.a.d [DRV] a : 7  b : 13  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 200: uvm_test_top.env.a.m [MON] a : 7  b : 13  y : 91
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 200: uvm_test_top.env.s [SCO] Test Passed -> a : 7  b : 13  y : 91
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 200: uvm_test_top.env.a.seqr@@gen [SEQ] a : 9  b : 7  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 200: uvm_test_top.env.a.d [DRV] a : 9  b : 7  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 220: uvm_test_top.env.a.m [MON] a : 9  b : 7  y : 63
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 220: uvm_test_top.env.s [SCO] Test Passed -> a : 9  b : 7  y : 63
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 220: uvm_test_top.env.a.seqr@@gen [SEQ] a : 8  b : 10  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 220: uvm_test_top.env.a.d [DRV] a : 8  b : 10  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 240: uvm_test_top.env.a.m [MON] a : 8  b : 10  y : 80
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 240: uvm_test_top.env.s [SCO] Test Passed -> a : 8  b : 10  y : 80
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 240: uvm_test_top.env.a.seqr@@gen [SEQ] a : 4  b : 6  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 240: uvm_test_top.env.a.d [DRV] a : 4  b : 6  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 260: uvm_test_top.env.a.m [MON] a : 4  b : 6  y : 24
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 260: uvm_test_top.env.s [SCO] Test Passed -> a : 4  b : 6  y : 24
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 260: uvm_test_top.env.a.seqr@@gen [SEQ] a : 13  b : 11  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 260: uvm_test_top.env.a.d [DRV] a : 13  b : 11  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 280: uvm_test_top.env.a.m [MON] a : 13  b : 11  y : 143
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 280: uvm_test_top.env.s [SCO] Test Passed -> a : 13  b : 11  y : 143
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM_INFO /home/runner/testbench.sv(42) @ 280: uvm_test_top.env.a.seqr@@gen [SEQ] a : 3  b : 9  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(73) @ 280: uvm_test_top.env.a.d [DRV] a : 3  b : 9  y : 0
# KERNEL: UVM_INFO /home/runner/testbench.sv(108) @ 300: uvm_test_top.env.a.m [MON] a : 3  b : 9  y : 27
# KERNEL: UVM_INFO /home/runner/testbench.sv(134) @ 300: uvm_test_top.env.s [SCO] Test Passed -> a : 3  b : 9  y : 27




*/
 
 