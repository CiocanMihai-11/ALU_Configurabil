`include "req_ack_interface_dut.sv"
`include "tranzactie_req_ack.sv"
class req_ack_driver extends uvm_driver #(req_ack_item);

  virtual req_ack_interface vif;

  `uvm_component_utils(req_ack_driver)

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual req_ack_interface)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","Virtual interface not set")
  endfunction

  task drive_reset();
    forever begin
      if (!vif.rst_n) begin
        vif.ack <= 0;
      end
      @(posedge vif.clk);
    end
  endtask

  // Task principal de drivere REQ
  task run_phase(uvm_phase phase);

    fork
      drive_reset();  
      begin
        forever begin

          @(posedge vif.clk);

          wait(vif.req == 1); 
          @(posedge vif.clk);
          vif.ack <= 1;
          @(posedge vif.clk);
          vif.ack <= 0;

        end
      end
    join_none
  endtask

endclass