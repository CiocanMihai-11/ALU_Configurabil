`include "req_ack_if.sv"
`include "req_ack_item.sv"
class req_ack_driver extends uvm_driver #(req_ack_item);

  virtual req_ack_if vif;

  `uvm_component_utils(req_ack_driver)

  function new(string name, uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual req_ack_if)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","Virtual interface not set")
  endfunction

  task drive_reset();
    forever begin
      if (!vif.rst_n) begin
        vif.req <= 0;
        vif.req_data <= 0;
      end
      @(posedge vif.clk);
    end
  endtask

  // Task principal de drivere REQ
  task run_phase(uvm_phase phase);
    req_ack_item req;

    fork
      drive_reset();  
      begin
        forever begin
          seq_item_port.get_next_item(req);

          repeat(req.delay) @(posedge vif.clk);

          wait(vif.rst_n == 1);
          vif.req <= 1;
          vif.req_data <= req.data;
          wait(vif.ack == 1); 
          @(posedge vif.clk);
          vif.req <= 0;
          vif.req_data <= 0;

          seq_item_port.item_done();
        end
      end
    join_none
  endtask

endclass