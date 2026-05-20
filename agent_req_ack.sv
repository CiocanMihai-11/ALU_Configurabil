`include "driver_agent_req_ack.sv"
`include "monitor_req_ack.sv"
class agent_req_ack extends uvm_agent;

  req_ack_driver    drv;
  req_ack_monitor   mon;
  uvm_sequencer #(req_ack_item) seqr; 

  `uvm_component_utils(agent_req_ack)
  
  uvm_analysis_port #(req_ack_item) de_la_monitor_req_ack;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    seqr = uvm_sequencer#(req_ack_item)::type_id::create("seqr", this);
    drv  = req_ack_driver::type_id::create("drv", this);
    mon  = req_ack_monitor::type_id::create("mon", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    drv.seq_item_port.connect(seqr.seq_item_export);
    de_la_monitor_req_ack = mon.port_date_monitor_req_ack;
  endfunction

endclass