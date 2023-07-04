`include "uvm_macros.svh"
import uvm_pkg::*;
 


// Code your testbench here
// or browse Examples
interface alu_interface(input logic clock);
  logic reset;
  logic [7:0] a, b;
  logic [3:0] op_code;
  logic [15:0] result;
endinterface: alu_interface


class alu_sequence_item extends uvm_sequence_item;
  `uvm_object_utils(alu_sequence_item)

  //--------------------------------------------------------
  //Instantiation
  //--------------------------------------------------------
  rand logic reset;
  rand logic [7:0] a, b;
  rand logic [3:0] op_code;
  
  logic [15:0] result; //output


  //--------------------------------------------------------
  //Default Constraints
  //--------------------------------------------------------
  constraint input1_c {a inside {[10:20]};}
  constraint input2_c {b inside {[1:10]};}
  constraint op_code_c {op_code inside {0,1,2,3,4,5,8,9,10,11,12,13,14};}
  
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "alu_sequence_item");
    super.new(name);

  endfunction: new

endclass: alu_sequence_item




class alu_base_sequence extends uvm_sequence;
  `uvm_object_utils(alu_base_sequence)
  
  alu_sequence_item reset_pkt;
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name= "alu_base_sequence");
    super.new(name);
    `uvm_info("BASE_SEQ", "Inside Constructor!", UVM_HIGH)
  endfunction
  
  
  //--------------------------------------------------------
  //Body Task
  //--------------------------------------------------------
  task body();
    `uvm_info("BASE_SEQ", "Inside body task!", UVM_HIGH)
    
    reset_pkt = alu_sequence_item::type_id::create("reset_pkt");
    start_item(reset_pkt);
    assert(reset_pkt.randomize());
    reset_pkt.reset=1'b1;
    finish_item(reset_pkt);
        
  endtask: body
  
  
endclass: alu_base_sequence




class alu_test_sequence extends alu_base_sequence;
  `uvm_object_utils(alu_test_sequence)
  
  alu_sequence_item item;
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name= "alu_test_sequence");
    super.new(name);
    `uvm_info("TEST_SEQ", "Inside Constructor!", UVM_HIGH)
  endfunction
  
  
  //--------------------------------------------------------
  //Body Task
  //--------------------------------------------------------
  task body();
    `uvm_info("TEST_SEQ", "Inside body task!", UVM_HIGH)
    
    item = alu_sequence_item::type_id::create("item");
    start_item(item);
    assert(item.randomize());
   	item.reset=1'b0;
    finish_item(item);
        
  endtask: body
  
  
endclass: alu_test_sequence




class alu_sequencer extends uvm_sequencer#(alu_sequence_item);
  `uvm_component_utils(alu_sequencer)
  
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "alu_sequencer", uvm_component parent);
    super.new(name, parent);
    `uvm_info("SEQR_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SEQR_CLASS", "Build Phase!", UVM_HIGH)
    
  endfunction: build_phase
  
  
  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("SEQR_CLASS", "Connect Phase!", UVM_HIGH)
    
  endfunction: connect_phase
  
  
  
endclass: alu_sequencer



class alu_driver extends uvm_driver#(alu_sequence_item);
  `uvm_component_utils(alu_driver)
  
  virtual alu_interface vif;
  alu_sequence_item item;
  
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "alu_driver", uvm_component parent);
    super.new(name, parent);
    `uvm_info("DRIVER_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("DRIVER_CLASS", "Build Phase!", UVM_HIGH)
    
    if(!(uvm_config_db #(virtual alu_interface)::get(this, "*", "vif", vif))) begin
      `uvm_error("DRIVER_CLASS", "Failed to get VIF from config DB!")
    end
    
  endfunction: build_phase
  
  
  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("DRIVER_CLASS", "Connect Phase!", UVM_HIGH)
    
  endfunction: connect_phase
  
  
  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("DRIVER_CLASS", "Inside Run Phase!", UVM_HIGH)
    
    forever begin
      item = alu_sequence_item::type_id::create("item"); 
      seq_item_port.get_next_item(item);
      drive(item);
      seq_item_port.item_done();
    end
    
  endtask: run_phase
  
  
  //--------------------------------------------------------
  //[Method] Drive
  //--------------------------------------------------------
  task drive(alu_sequence_item item);
    @(posedge vif.clock);
    vif.reset <= item.reset;
    vif.a <= item.a;
    vif.b <= item.b;
    vif.op_code <= item.op_code;
  endtask: drive
  
  
endclass: alu_driver


class alu_monitor extends uvm_monitor;
  `uvm_component_utils(alu_monitor)
  
  virtual alu_interface vif;
  alu_sequence_item item;
  
  uvm_analysis_port #(alu_sequence_item) monitor_port;
  
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "alu_monitor", uvm_component parent);
    super.new(name, parent);
    `uvm_info("MONITOR_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("MONITOR_CLASS", "Build Phase!", UVM_HIGH)
    
    monitor_port = new("monitor_port", this);
    
    if(!(uvm_config_db #(virtual alu_interface)::get(this, "*", "vif", vif))) begin
      `uvm_error("MONITOR_CLASS", "Failed to get VIF from config DB!")
    end
    
  endfunction: build_phase
  
  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("MONITOR_CLASS", "Connect Phase!", UVM_HIGH)
    
  endfunction: connect_phase
  
  
  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("MONITOR_CLASS", "Inside Run Phase!", UVM_HIGH)
    
    forever begin
      item = alu_sequence_item::type_id::create("item");
      
      wait(!vif.reset);
      
      //sample inputs
      @(posedge vif.clock);
      item.a = vif.a;
      item.b = vif.b;
      item.op_code = vif.op_code;
      
      //sample output
      @(posedge vif.clock);
      item.result = vif.result;
      
      // send item to scoreboard
      monitor_port.write(item);
    end
        
  endtask: run_phase
  
  
endclass: alu_monitor




class alu_scoreboard extends uvm_test;
  `uvm_component_utils(alu_scoreboard)
  
  uvm_analysis_imp #(alu_sequence_item, alu_scoreboard) scoreboard_port;
  
  alu_sequence_item transactions[$];
  
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "alu_scoreboard", uvm_component parent);
    super.new(name, parent);
    `uvm_info("SCB_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("SCB_CLASS", "Build Phase!", UVM_HIGH)
   
    scoreboard_port = new("scoreboard_port", this);
    
  endfunction: build_phase
  
  
  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("SCB_CLASS", "Connect Phase!", UVM_HIGH)
    
   
  endfunction: connect_phase
  
  
  //--------------------------------------------------------
  //Write Method
  //--------------------------------------------------------
  function void write(alu_sequence_item item);
    transactions.push_back(item);
  endfunction: write 
  
  
  
  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("SCB_CLASS", "Run Phase!", UVM_HIGH)
   
    forever begin
      /*
      // get the packet
      // generate expected value
      // compare it with actual value
      // score the transactions accordingly
      */
      alu_sequence_item curr_trans;
      wait((transactions.size() != 0));
      curr_trans = transactions.pop_front();
      compare(curr_trans);
      
    end
    
  endtask: run_phase
  
  
  //--------------------------------------------------------
  //Compare : Generate Expected Result and Compare with Actual
  //--------------------------------------------------------
  task compare(alu_sequence_item curr_trans);
    logic [7:0] expected;
    logic [7:0] actual;
    
    case(curr_trans.op_code)
      0: begin //A + B
        expected = curr_trans.a + curr_trans.b;
      end
      1: begin //A - B
        expected = curr_trans.a - curr_trans.b;
      end
      2: begin //A * B
        expected = curr_trans.a * curr_trans.b;
      end
      3: begin //A / B
        expected = curr_trans.a / curr_trans.b;
      end
      4:begin// Logical shift left
        expected = curr_trans.a<<1;
      end
      5:begin// Logical shift right
        expected = curr_trans.a>>1;
      end
      8:begin//  Logical and 
        expected = curr_trans.a & curr_trans.b;
      end
      9:begin//  Logical or 
        expected = curr_trans.a | curr_trans.b; 
      end
      10:begin// Logical xor 
        expected = curr_trans.a ^ curr_trans.b; 
      end
      11:begin//  Logical nor
        expected = ~(curr_trans.a | curr_trans.b); 
      end
      12:begin//  Logical nand
        expected = ~(curr_trans.a & curr_trans.b); 
      end
      13:begin//   Logical xnor
        expected = ~(curr_trans.a ^ curr_trans.b); 
      end
        
      14:begin//  Greater comparison
        expected = (curr_trans.a > curr_trans.b)?8'd1:8'd0;
      end
      15:begin //   Equal comparison 
        expected = (curr_trans.a == curr_trans.b)?8'd1:8'd0; 
      end
    endcase
    
    actual = curr_trans.result;
    
    if(actual != expected) begin
      `uvm_error("COMPARE", $sformatf("Transaction failed! ACT=%d, EXP=%d", actual, expected))
    end
    else begin
      // Note: Can display the input and op_code as well if you want to see what's happening
      `uvm_info("COMPARE", $sformatf("Transaction Passed! opcode = %d ,a = %d ,b =%d ACT=%d, EXP=%d",curr_trans.op_code, curr_trans.a,curr_trans.b,actual, expected), UVM_LOW)
    end
    
  endtask: compare
  
  
endclass: alu_scoreboard



class alu_agent extends uvm_agent;
  `uvm_component_utils(alu_agent)
  
  alu_driver drv;
  alu_monitor mon;
  alu_sequencer seqr;
  
    
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "alu_agent", uvm_component parent);
    super.new(name, parent);
    `uvm_info("AGENT_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("AGENT_CLASS", "Build Phase!", UVM_HIGH)
    
    drv = alu_driver::type_id::create("drv", this);
    mon = alu_monitor::type_id::create("mon", this);
    seqr = alu_sequencer::type_id::create("seqr", this);
    
  endfunction: build_phase
  
  
  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("AGENT_CLASS", "Connect Phase!", UVM_HIGH)
    
    drv.seq_item_port.connect(seqr.seq_item_export);
    
  endfunction: connect_phase
  
  
  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    
  endtask: run_phase
  
  
endclass: alu_agent
  
class alu_env extends uvm_env;
  `uvm_component_utils(alu_env)
  
  alu_agent agnt;
  alu_scoreboard scb;
  
  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "alu_env", uvm_component parent);
    super.new(name, parent);
    `uvm_info("ENV_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new
  
  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("ENV_CLASS", "Build Phase!", UVM_HIGH)
    
    agnt = alu_agent::type_id::create("agnt", this);
    scb = alu_scoreboard::type_id::create("scb", this);
    
  endfunction: build_phase
  
  
  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("ENV_CLASS", "Connect Phase!", UVM_HIGH)
    
    agnt.mon.monitor_port.connect(scb.scoreboard_port);
    
  endfunction: connect_phase
  
  
  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    
  endtask: run_phase
  
  
endclass: alu_env
  
  

  
  
  class alu_test extends uvm_test;
  `uvm_component_utils(alu_test)

  alu_env env;
  alu_base_sequence reset_seq;
  alu_test_sequence test_seq;

  
  //--------------------------------------------------------
  //Constructor
  //--------------------------------------------------------
  function new(string name = "alu_test", uvm_component parent);
    super.new(name, parent);
    `uvm_info("TEST_CLASS", "Inside Constructor!", UVM_HIGH)
  endfunction: new

  
  //--------------------------------------------------------
  //Build Phase
  //--------------------------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    `uvm_info("TEST_CLASS", "Build Phase!", UVM_HIGH)

    env = alu_env::type_id::create("env", this);

  endfunction: build_phase

  
  //--------------------------------------------------------
  //Connect Phase
  //--------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    `uvm_info("TEST_CLASS", "Connect Phase!", UVM_HIGH)

  endfunction: connect_phase

  
  //--------------------------------------------------------
  //Run Phase
  //--------------------------------------------------------
  task run_phase (uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("TEST_CLASS", "Run Phase!", UVM_HIGH)

    phase.raise_objection(this);

    //reset_seq
    reset_seq = alu_base_sequence::type_id::create("reset_seq");
    reset_seq.start(env.agnt.seqr);
    #10;

    repeat(100) begin
      //test_seq
      test_seq = alu_test_sequence::type_id::create("test_seq");
      test_seq.start(env.agnt.seqr);
      #10;
    end
    
    phase.drop_objection(this);

  endtask: run_phase


endclass: alu_test
  
  


module top;
  
  //--------------------------------------------------------
  //Instantiation
  //--------------------------------------------------------

  logic clock;
  
  alu_interface intf(.clock(clock));
  
  alu dut(
    .clock(intf.clock),
    .reset(intf.reset),
    .a(intf.a),
    .b(intf.b),
    .ALU_Sel(intf.op_code),
    .ALU_Out(intf.result)
  );
  
  
  //--------------------------------------------------------
  //Interface Setting
  //--------------------------------------------------------
  initial begin
    uvm_config_db #(virtual alu_interface)::set(null, "*", "vif", intf );
    //-- Refer: https://www.synopsys.com/content/dam/synopsys/services/whitepapers/hierarchical-testbench-configuration-using-uvm.pdf
  end
  
  
  
  //--------------------------------------------------------
  //Start The Test
  //--------------------------------------------------------
  initial begin
    run_test("alu_test");
  end
  
  
  //--------------------------------------------------------
  //Clock Generation
  //--------------------------------------------------------
  initial begin
    clock = 0;
    #5;
    forever begin
      clock = ~clock;
      #2;
    end
  end
  
  
  //--------------------------------------------------------
  //Maximum Simulation Time
  //--------------------------------------------------------
  initial begin
    #5000;
    $display("Sorry! Ran out of clock cycles!");
    $finish();
  end
  
  
/*
*/
  
  
  
endmodule: top






/*




[2023-07-04 16:23:35 UTC] vlib work && vlog '-timescale' '1ns/1ns' +incdir+$RIVIERA_HOME/vlib/uvm-1.2/src -l uvm_1_2 -err VCP2947 W9 -err VCP2974 W9 -err VCP3003 W9 -err VCP5417 W9 -err VCP6120 W9 -err VCP7862 W9 -err VCP2129 W9 design.sv testbench.sv  && vsim -c -do "vsim +access+r; run -all; exit"  
VSIMSA: Configuration file changed: `/home/runner/library.cfg'
ALIB: Library "work" attached.
work = /home/runner/work/work.lib
MESSAGE "Pass 1. Scanning modules hierarchy."
MESSAGE_SP VCP2124 "Package uvm_pkg found in library uvm_1_2."
MESSAGE "Pass 2. Processing instantiations."
MESSAGE "Pass 3. Processing behavioral statements."
MESSAGE "Running Assertions Compiler."
MESSAGE "Running Optimizer."
MESSAGE "ELB/DAG code generating."
MESSAGE "Unit top modules: top."
MESSAGE "$root top modules: top."
SUCCESS "Compile success 0 Errors 0 Warnings  Analysis time: 3[s]."
ALOG: Warning: The source is compiled without the -dbg switch. Line breakpoints and assertion debug will not be available.
done
# Aldec, Inc. Riviera-PRO version 2022.04.117.8517 built for Linux64 on May 04, 2022.
# HDL, SystemC, and Assertions simulator, debugger, and design environment.
# (c) 1999-2022 Aldec, Inc. All rights reserved.
# ELBREAD: Elaboration process.
# ELBREAD: Warning: ELBREAD_0049 Package 'uvm_pkg' does not have a `timescale directive, but previous modules do.
# ELBREAD: Elaboration time 0.4 [s].
# KERNEL: Main thread initiated.
# KERNEL: Kernel process initialization phase.
# ELAB2: Elaboration final pass...
# KERNEL: PLI/VHPI kernel's engine initialization done.
# PLI: Loading library '/usr/share/Riviera-PRO/bin/libsystf.so'
# ELAB2: Create instances ...
# KERNEL: Info: Loading library:  /usr/share/Riviera-PRO/bin/uvm_1_2_dpi
# KERNEL: Time resolution set to 1ps.
# ELAB2: Create instances complete.
# SLP: Started
# SLP: Elaboration phase ...
# SLP: Elaboration phase ... done : 0.0 [s]
# SLP: Generation phase ...
# SLP: Generation phase ... done : 0.0 [s]
# SLP: Finished : 0.1 [s]
# SLP: 0 primitives and 4 (33.33%) other processes in SLP
# SLP: 19 (0.06%) signals in SLP and 16 (0.05%) interface signals
# ELAB2: Elaboration final pass complete - time: 1.5 [s].
# KERNEL: SLP loading done - time: 0.0 [s].
# KERNEL: Warning: You are using the Riviera-PRO EDU Edition. The performance of simulation is reduced.
# KERNEL: Warning: Contact Aldec for available upgrade options - sales@aldec.com.
# KERNEL: SLP simulation initialization done - time: 0.0 [s].
# KERNEL: Kernel process initialization done.
# Allocation: Simulator allocated 29793 kB (elbread=2094 elab2=22744 kernel=4954 sdf=0)
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_root.svh(392) @ 0: reporter [UVM/RELNOTES] 
# KERNEL: ----------------------------------------------------------------
# KERNEL: UVM-1.2
# KERNEL: (C) 2007-2014 Mentor Graphics Corporation
# KERNEL: (C) 2007-2014 Cadence Design Systems, Inc.
# KERNEL: (C) 2006-2014 Synopsys, Inc.
# KERNEL: (C) 2011-2013 Cypress Semiconductor Corp.
# KERNEL: (C) 2013-2014 NVIDIA Corporation
# KERNEL: ----------------------------------------------------------------
# KERNEL: 
# KERNEL:   ***********       IMPORTANT RELEASE NOTES         ************
# KERNEL: 
# KERNEL:   You are using a version of the UVM library that has been compiled
# KERNEL:   with `UVM_NO_DEPRECATED undefined.
# KERNEL:   See http://www.eda.org/svdb/view.php?id=3313 for more details.
# KERNEL: 
# KERNEL:   You are using a version of the UVM library that has been compiled
# KERNEL:   with `UVM_OBJECT_DO_NOT_NEED_CONSTRUCTOR undefined.
# KERNEL:   See http://www.eda.org/svdb/view.php?id=3770 for more details.
# KERNEL: 
# KERNEL:       (Specify +UVM_NO_RELNOTES to turn off this notice)
# KERNEL: 
# KERNEL: ASDB file was created in location /home/runner/dataset.asdb
# KERNEL: UVM_INFO @ 0: reporter [RNTST] Running test alu_test...
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 25000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  10 ,b =  5 ACT=  2, EXP=  2
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 33000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  10 ,b =  5 ACT=  2, EXP=  2
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 41000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 13 ,a =  18 ,b = 10 ACT=231, EXP=231
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 49000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  1 ,a =  10 ,b =  2 ACT=  8, EXP=  8
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 57000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  1 ,a =  10 ,b =  2 ACT=  8, EXP=  8
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 65000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  1 ,a =  17 ,b =  5 ACT= 12, EXP= 12
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 73000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  8 ,a =  10 ,b =  7 ACT=  2, EXP=  2
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 81000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  8 ,a =  10 ,b =  7 ACT=  2, EXP=  2
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 89000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 13 ,a =  13 ,b =  2 ACT=240, EXP=240
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 97000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  9 ,a =  20 ,b =  7 ACT= 23, EXP= 23
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 105000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  9 ,a =  20 ,b =  7 ACT= 23, EXP= 23
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 113000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  2 ,a =  17 ,b =  8 ACT=136, EXP=136
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 121000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 13 ,a =  17 ,b =  5 ACT=235, EXP=235
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 129000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 13 ,a =  17 ,b =  5 ACT=235, EXP=235
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 137000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 10 ,a =  13 ,b = 10 ACT=  7, EXP=  7
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 145000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  8 ,a =  19 ,b =  2 ACT=  2, EXP=  2
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 153000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  8 ,a =  19 ,b =  2 ACT=  2, EXP=  2
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 161000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  8 ,a =  15 ,b =  4 ACT=  4, EXP=  4
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 169000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 11 ,a =  11 ,b =  1 ACT=244, EXP=244
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 177000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 11 ,a =  11 ,b =  1 ACT=244, EXP=244
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 185000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  12 ,b =  1 ACT= 12, EXP= 12
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 193000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  2 ,a =  17 ,b =  7 ACT=119, EXP=119
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 201000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  2 ,a =  17 ,b =  7 ACT=119, EXP=119
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 209000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  8 ,a =  20 ,b =  4 ACT=  4, EXP=  4
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 217000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  4 ,a =  13 ,b =  8 ACT= 26, EXP= 26
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 225000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  4 ,a =  13 ,b =  8 ACT= 26, EXP= 26
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 233000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 10 ,a =  16 ,b = 10 ACT= 26, EXP= 26
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 241000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  2 ,a =  14 ,b =  4 ACT= 56, EXP= 56
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 249000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  2 ,a =  14 ,b =  4 ACT= 56, EXP= 56
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 257000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  20 ,b =  2 ACT= 10, EXP= 10
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 265000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  9 ,a =  10 ,b =  7 ACT= 15, EXP= 15
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 273000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  9 ,a =  10 ,b =  7 ACT= 15, EXP= 15
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 281000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 11 ,a =  20 ,b =  3 ACT=232, EXP=232
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 289000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  16 ,b =  7 ACT=  2, EXP=  2
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 297000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  16 ,b =  7 ACT=  2, EXP=  2
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 305000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 12 ,a =  17 ,b =  4 ACT=255, EXP=255
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 313000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 11 ,a =  16 ,b =  5 ACT=234, EXP=234
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 321000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 11 ,a =  16 ,b =  5 ACT=234, EXP=234
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 329000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 11 ,a =  11 ,b =  5 ACT=240, EXP=240
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 337000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  10 ,b =  2 ACT=  5, EXP=  5
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 345000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  10 ,b =  2 ACT=  5, EXP=  5
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 353000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  9 ,a =  17 ,b =  9 ACT= 25, EXP= 25
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 361000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  4 ,a =  11 ,b =  5 ACT= 22, EXP= 22
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 369000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  4 ,a =  11 ,b =  5 ACT= 22, EXP= 22
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 377000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  2 ,a =  15 ,b =  6 ACT= 90, EXP= 90
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 385000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  0 ,a =  15 ,b = 10 ACT= 25, EXP= 25
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 393000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  0 ,a =  15 ,b = 10 ACT= 25, EXP= 25
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 401000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  9 ,a =  19 ,b =  8 ACT= 27, EXP= 27
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 409000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  2 ,a =  11 ,b =  3 ACT= 33, EXP= 33
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 417000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  2 ,a =  11 ,b =  3 ACT= 33, EXP= 33
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 425000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 12 ,a =  12 ,b =  8 ACT=247, EXP=247
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 433000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  4 ,a =  17 ,b =  3 ACT= 34, EXP= 34
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 441000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  4 ,a =  17 ,b =  3 ACT= 34, EXP= 34
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 449000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  4 ,a =  18 ,b =  5 ACT= 36, EXP= 36
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 457000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 13 ,a =  11 ,b =  4 ACT=240, EXP=240
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 465000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 13 ,a =  11 ,b =  4 ACT=240, EXP=240
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 473000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 14 ,a =  12 ,b =  5 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 481000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 10 ,a =  16 ,b =  9 ACT= 25, EXP= 25
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 489000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 10 ,a =  16 ,b =  9 ACT= 25, EXP= 25
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 497000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  1 ,a =  20 ,b =  9 ACT= 11, EXP= 11
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 505000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 14 ,a =  20 ,b = 10 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 513000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 14 ,a =  20 ,b = 10 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 521000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  18 ,b =  7 ACT=  2, EXP=  2
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 529000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 14 ,a =  12 ,b =  6 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 537000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 14 ,a =  12 ,b =  6 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 545000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 11 ,a =  19 ,b =  2 ACT=236, EXP=236
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 553000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  16 ,b = 10 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 561000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  16 ,b = 10 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 569000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  4 ,a =  17 ,b =  5 ACT= 34, EXP= 34
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 577000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 12 ,a =  20 ,b =  4 ACT=251, EXP=251
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 585000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 12 ,a =  20 ,b =  4 ACT=251, EXP=251
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 593000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  4 ,a =  13 ,b =  2 ACT= 26, EXP= 26
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 601000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 11 ,a =  13 ,b =  2 ACT=240, EXP=240
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 609000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 11 ,a =  13 ,b =  2 ACT=240, EXP=240
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 617000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  2 ,a =  15 ,b =  7 ACT=105, EXP=105
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 625000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  13 ,b =  5 ACT=  6, EXP=  6
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 633000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  13 ,b =  5 ACT=  6, EXP=  6
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 641000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  0 ,a =  15 ,b =  9 ACT= 24, EXP= 24
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 649000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  8 ,a =  11 ,b =  7 ACT=  3, EXP=  3
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 657000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  8 ,a =  11 ,b =  7 ACT=  3, EXP=  3
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 665000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 11 ,a =  16 ,b =  1 ACT=238, EXP=238
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 673000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  4 ,a =  12 ,b =  6 ACT= 24, EXP= 24
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 681000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  4 ,a =  12 ,b =  6 ACT= 24, EXP= 24
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 689000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  10 ,b =  9 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 697000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 14 ,a =  15 ,b =  2 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 705000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 14 ,a =  15 ,b =  2 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 713000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  16 ,b =  6 ACT=  2, EXP=  2
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 721000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  9 ,a =  18 ,b =  2 ACT= 18, EXP= 18
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 729000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  9 ,a =  18 ,b =  2 ACT= 18, EXP= 18
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 737000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 11 ,a =  12 ,b =  4 ACT=243, EXP=243
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 745000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 10 ,a =  11 ,b =  4 ACT= 15, EXP= 15
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 753000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 10 ,a =  11 ,b =  4 ACT= 15, EXP= 15
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 761000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  14 ,b =  1 ACT=  7, EXP=  7
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 769000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 13 ,a =  10 ,b =  8 ACT=253, EXP=253
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 777000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 13 ,a =  10 ,b =  8 ACT=253, EXP=253
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 785000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  15 ,b =  2 ACT=  7, EXP=  7
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 793000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  13 ,b =  8 ACT=  6, EXP=  6
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 801000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  13 ,b =  8 ACT=  6, EXP=  6
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 809000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 12 ,a =  10 ,b = 10 ACT=245, EXP=245
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 817000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  1 ,a =  20 ,b =  1 ACT= 19, EXP= 19
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 825000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  1 ,a =  20 ,b =  1 ACT= 19, EXP= 19
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 833000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  11 ,b =  7 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 841000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 14 ,a =  10 ,b =  8 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 849000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 14 ,a =  10 ,b =  8 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 857000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  8 ,a =  18 ,b =  1 ACT=  0, EXP=  0
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 865000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  8 ,a =  18 ,b =  7 ACT=  2, EXP=  2
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 873000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  8 ,a =  18 ,b =  7 ACT=  2, EXP=  2
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 881000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  2 ,a =  14 ,b =  1 ACT= 14, EXP= 14
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 889000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 12 ,a =  15 ,b =  2 ACT=253, EXP=253
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 897000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 12 ,a =  15 ,b =  2 ACT=253, EXP=253
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 905000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  9 ,a =  14 ,b =  7 ACT= 15, EXP= 15
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 913000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  8 ,a =  12 ,b =  2 ACT=  0, EXP=  0
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 921000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  8 ,a =  12 ,b =  2 ACT=  0, EXP=  0
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 929000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  9 ,a =  15 ,b =  5 ACT= 15, EXP= 15
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 937000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  14 ,b = 10 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 945000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  14 ,b = 10 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 953000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  0 ,a =  18 ,b =  4 ACT= 22, EXP= 22
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 961000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 12 ,a =  19 ,b = 10 ACT=253, EXP=253
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 969000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 12 ,a =  19 ,b = 10 ACT=253, EXP=253
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 977000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  8 ,a =  19 ,b =  4 ACT=  0, EXP=  0
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 985000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  13 ,b =  8 ACT=  6, EXP=  6
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 993000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  13 ,b =  8 ACT=  6, EXP=  6
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1001000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 13 ,a =  11 ,b =  4 ACT=240, EXP=240
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1009000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  1 ,a =  20 ,b =  1 ACT= 19, EXP= 19
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1017000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  1 ,a =  20 ,b =  1 ACT= 19, EXP= 19
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1025000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 10 ,a =  14 ,b =  5 ACT= 11, EXP= 11
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1033000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 11 ,a =  11 ,b =  1 ACT=244, EXP=244
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1041000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 11 ,a =  11 ,b =  1 ACT=244, EXP=244
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1049000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  9 ,a =  10 ,b =  2 ACT= 10, EXP= 10
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1057000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  19 ,b = 10 ACT=  9, EXP=  9
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1065000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  19 ,b = 10 ACT=  9, EXP=  9
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1073000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 13 ,a =  13 ,b =  1 ACT=243, EXP=243
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1081000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  2 ,a =  16 ,b =  1 ACT= 16, EXP= 16
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1089000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  2 ,a =  16 ,b =  1 ACT= 16, EXP= 16
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1097000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  14 ,b =  4 ACT=  3, EXP=  3
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1105000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  2 ,a =  10 ,b =  5 ACT= 50, EXP= 50
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1113000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  2 ,a =  10 ,b =  5 ACT= 50, EXP= 50
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1121000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  16 ,b =  5 ACT=  3, EXP=  3
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1129000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  13 ,b =  9 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1137000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  3 ,a =  13 ,b =  9 ACT=  1, EXP=  1
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1145000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode = 11 ,a =  13 ,b =  4 ACT=242, EXP=242
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1153000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  1 ,a =  12 ,b =  7 ACT=  5, EXP=  5
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1161000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  1 ,a =  12 ,b =  7 ACT=  5, EXP=  5
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1169000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  9 ,a =  11 ,b = 10 ACT= 11, EXP= 11
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1177000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  20 ,b =  3 ACT= 10, EXP= 10
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1185000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  20 ,b =  3 ACT= 10, EXP= 10
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1193000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  1 ,a =  19 ,b =  7 ACT= 12, EXP= 12
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1201000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  17 ,b =  1 ACT=  8, EXP=  8
# KERNEL: UVM_INFO /home/runner/testbench.sv(438) @ 1209000: uvm_test_top.env.scb [COMPARE] Transaction Passed! opcode =  5 ,a =  17 ,b =  1 ACT=  8, EXP=  8
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_objection.svh(1271) @ 1215000: reporter [TEST_DONE] 'run' phase is ready to proceed to the 'extract' phase
# KERNEL: UVM_INFO /home/build/vlib1/vlib/uvm-1.2/src/base/uvm_report_server.svh(869) @ 1215000: reporter [UVM/REPORT/SERVER] 













*/