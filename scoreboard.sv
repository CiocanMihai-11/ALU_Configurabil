`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __scoreboard
`define __scoreboard

`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_req_ack)

class scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp_apb #(tranzactie_apb, scoreboard) port_pentru_datele_de_la_apb;
  uvm_analysis_imp_req_ack #(tranzactie_req_ack, scoreboard) port_pentru_datele_de_la_req_ack;

  tranzactie_apb    tranzactie_venita_de_la_apb;
  tranzactie_req_ack tranzactie_venita_de_la_req_ack;

  //tranzactie_apb    tranzactii_apb[$];
  //tranzactie_req_ack tranzactii_req_ack[$];

  bit enable;
  
  function new(string name="scoreboard", uvm_component parent=null);
    super.new(name, parent);
    port_pentru_datele_de_la_apb = new("pentru_datele_de_la_apb", this);
    port_pentru_datele_de_la_req_ack = new("pentru_datele_de_la_req_ack", this);
    
    tranzactie_venita_de_la_apb = new();   
    tranzactie_venita_de_la_req_ack = new();   
  endfunction
  
  virtual function void connect_phase (uvm_phase phase);
    super.connect_phase(phase);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
  function void write_apb(input tranzactie_apb tranzactie_noua_apb);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul apb tranzactia cu informatia:\n"), UVM_LOW)
    tranzactie_noua_apb.afiseaza_informatia_tranzactiei();
    
    $display($sformatf("cand s-au primit date de la apb, enable a fost %d", enable));
    
    tranzactie_venita_de_la_apb = tranzactie_noua_apb.copy();
    //tranzactii_apb.push_back(tranzactie_venita_de_la_apb);
  endfunction : write_apb

  function void write_req_ack(input tranzactie_req_ack tranzactie_noua_req_ack);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul req_ack tranzactia cu informatia:\n"), UVM_LOW)
    tranzactie_noua_req_ack.afiseaza_informatia_tranzactiei();
    
    $display($sformatf("cand s-au primit date de la req_ack, enable a fost %d", enable));
    
    tranzactie_venita_de_la_req_ack = tranzactie_noua_req_ack.copy();
    //tranzactii_req_ack.push_back(tranzactie_venita_de_la_req_ack);
  endfunction : write_req_ack

 /*  virtual function void check_phase (uvm_phase phase);
   foreach(tranzactii_req_ack[i]) begin
      //checker 1
      if (tranzactii_req_ack[i].irq == 1) begin
        if(tranzactii_req_ack[i].addr != tranzactii_apb[i].paddr)
          `uvm_error("SCOREBOARD checker 1", $sformatf("IRQ asserted wrong, address on apb is %h and on req_ack is %h", tranzactii_apb[i].paddr, tranzactii_req_ack[i].addr))
        else 
          `uvm_info("SCOREBOARD checker 1", "IRQ ASSERTED: OK", UVM_LOW)
      end
      //checker 2
      if((tranzactii_req_ack[i].addr == tranzactii_apb[i].paddr) && (tranzactii_req_ack[i].irq == 0))
        `uvm_error("SCOREBOARD checker 2", "IRQ expected but not asserted")
      else 
        `uvm_info("SCOREBOARD checker 2", "IRQ ASSERTED: OK", UVM_LOW)
    end
  endfunction*/
endclass
`endif
