`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_driver
`define __apb_driver

//driverul va prelua date de tip "tranzactie", pe care le va trimite DUT-ului, conform protocolul de comunicatie de pe interfata
class driver_agent_apb extends uvm_driver #(tranzactie_apb);
  
  //driverul se adauga in baza de date UVM
  `uvm_component_utils (driver_agent_apb)
  
  //este declarata interfata pe care driverul va trimite datele
  virtual apb_interface_dut interfata_driverului_pentru_apb;
  
  //constructorul clasei
  function new(string name = "driver_agent_apb", uvm_component parent = null);
    //este apelat constructorul clasei parinte
    super.new(name, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    //este apelata mai intai functia build_phase din clasa parinte
    super.build_phase(phase);
    if (!uvm_config_db#(virtual apb_interface_dut)::get(this, "", "apb_interface_dut", interfata_driverului_pentru_apb))begin
      `uvm_fatal("DRIVER_AGENT_apb", "Nu s-a putut accesa interfata_apb")
    end
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      `uvm_info("DRIVER_AGENT_apb", $sformatf("Se asteapta o tranzactie de la sequencer"), UVM_LOW)
      seq_item_port.get_next_item(req);
      `uvm_info("DRIVER_AGENT_apb", $sformatf("S-a primit o tranzactie de la sequencer"), UVM_LOW)
      trimiterea_tranzactiei(req);
      `uvm_info("DRIVER_AGENT_apb", $sformatf("Tranzactia a fost transmisa pe interfata"), UVM_LOW)
      seq_item_port.item_done();
    end
  endtask
  
  task trimiterea_tranzactiei(tranzactie_apb t);

  // =====================
  // SETUP PHASE
  // =====================
  @(posedge interfata_driverului_pentru_apb.pclk);

  interfata_driverului_pentru_apb.psel    <= 1;
  interfata_driverului_pentru_apb.penable <= 0;
  interfata_driverului_pentru_apb.paddr   <= t.addr;
  interfata_driverului_pentru_apb.pwrite  <= t.wr_rd;

  if(t.wr_rd)
    interfata_driverului_pentru_apb.pwdata <= t.data;

  // =====================
  // ACCESS PHASE
  // =====================
  @(posedge interfata_driverului_pentru_apb.pclk);

  interfata_driverului_pentru_apb.penable <= 1;

  // IMPORTANT: wait for DUT
  wait(interfata_driverului_pentru_apb.pready == 1);

  @(posedge interfata_driverului_pentru_apb.pclk);

  // =====================
  // END TRANSFER
  // =====================
  interfata_driverului_pentru_apb.psel    <= 0;
  interfata_driverului_pentru_apb.penable <= 0;

endtask
  
endclass
`endif