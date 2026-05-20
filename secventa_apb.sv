`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __input_apb_sequence
`define __input_apb_sequence

//se declara o clasa care genereaza o secventa de date
class secventa_apb extends uvm_sequence #(tranzactie_apb);
  
  //noul tip de data (secventa) se adauga la baza de date UVM
  `uvm_object_utils(secventa_apb)

  int addr_vec[3] = {0,4,8};
  int data_vec[3] = {0,20,10};
  
  function new(string name="secventa_apb");
    super.new(name);
  endfunction
    
  
  virtual task body();
    
    //`ifdef DEBUG
    //	$display("phase_shift= ", phase_shift);
    //`endif;

    for(int i=0; i<3; i++) begin

      req = tranzactie_apb::type_id::create("req");
   
      start_item(req);
   
      req.addr = addr_vec[i];
      req.data = data_vec[i];
      req.wr_rd = 1;   
         `ifdef DEBUG
     `uvm_info("SECVENTA_apb", $sformatf("La timpul %0t s-a generat elementul %0d cu informatiile:\n ", $time, i), UVM_LOW)
           req.afiseaza_informatia_tranzactiei();
         `endif;
   
      finish_item(req);
   
   end

  endtask
endclass
`endif