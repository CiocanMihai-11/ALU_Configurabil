`include "req_ack_interface_dut.sv"
`include "tranzactie_req_ack.sv"
class req_ack_monitor extends uvm_monitor;

  virtual req_ack_interface vif;

  `uvm_component_utils(req_ack_monitor)
  
  uvm_analysis_port #(req_ack_item) port_date_monitor_req_ack;
  
  req_ack_item starea_preluata_a_req_ack, aux_tr_req_ack;
  
  function new(string name, uvm_component parent);
    super.new(name,parent);
     port_date_monitor_req_ack = new("port_date_monitor_req_ack", this);
    //se creeaza obiectul (tranzactia) in care se vor retine datele colectate de pe interfata la fiecare tact de ceas
    starea_preluata_a_req_ack = req_ack_item::type_id::create("date_noi");
    
    aux_tr_req_ack = req_ack_item::type_id::create("date_noi");
  endfunction

  function void build_phase(uvm_phase phase);
    if(!uvm_config_db#(virtual req_ack_interface)::get(this,"","vif",vif))
      `uvm_fatal("NOVIF","Virtual interface not set")
  endfunction
      
virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
    forever begin
      
      //!!!!sa astept ca datele sa fie valide
      wait(vif.req && vif.ack); 
      //vreau sa citesc semnalul valid_i doar pe fronturile descrescatoare de ceas
      @(negedge vif.clk); 
      //preiau datele de pe interfata de iesire a DUT-ului (interfata_semafoare)
      starea_preluata_a_req_ack.result  = vif.result;
    
      aux_tr_req_ack = starea_preluata_a_req_ack.copy();//nu vreau sa folosesc pointerul starea_preluata_a_apb pentru a trimite datele, deoarece continutul acestuia se schimba, iar scoreboardul va citi alte date 
      
       //tranzactia cuprinzand datele culese de pe interfata se pune la dispozitie pe portul monitorului, daca modulul nu este in reset
      port_date_monitor_req_ack.write(aux_tr_req_ack); 
      `uvm_info("MONITOR_apb", $sformatf("S-a receptionat tranzactia cu informatiile:"), UVM_NONE)
      aux_tr_req_ack.afiseaza_informatia_tranzactiei();
      
      @(negedge vif.clk); //acest wait il adaug deoarece uneori o tranzactie este interpretata a fi doua tranzactii identice back to back (validul este citit ca fiind 1 pe doua fronturi consecutive de ceas); in implementarea curenta nu se poate sa vina doua tranzactii back to back
      
      
    end//forever begin
  endtask

endclass