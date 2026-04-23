`include "req_ack_if.sv"
`include "req_ack_item.sv"
class req_ack_monitor extends uvm_monitor;

  virtual req_ack_if vif;

  `uvm_component_utils(req_ack_monitor)

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual req_ack_if)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","Virtual interface not set")
  endfunction
      
task run_phase(uvm_phase phase); 
    req_ack_item item; 
endtask

endclass