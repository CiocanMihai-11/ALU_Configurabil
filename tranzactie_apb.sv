`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __apb_transaction
`define __apb_transaction

//o tranzactie este formata din totalitatea datelor transmise la un moment dat pe o interfata
class tranzactie_apb extends uvm_sequence_item;
  
  //componenta tranzactie se adauga in baza de date
  `uvm_object_utils(tranzactie_apb)
  
  rand bit[ 7:0] addr;
  rand bit[31:0] data;
  rand bit       wr_rd;
  
  
  //constructorul clasei; această funcție este apelată când se creează un obiect al clasei "tranzactie"
  function new(string name = "element_secventaa");//numele dat este ales aleatoriu, si nu mai este folosit in alta parte
    super.new(name);  
  	addr = 0;
  endfunction
  
  //functie de afisare a unei tranzactii
  function void afiseaza_informatia_tranzactiei();
    $display("Valoarea adresei: %0h datei: %0h wr_rd: %0h", addr, data, wr_rd);
  endfunction
  
  function tranzactie_apb copy();
	copy = new();
	copy.addr  = this.addr;
    copy.data  = this.data;
    copy.wr_rd = this.wr_rd;
	return copy;
  endfunction

endclass
`endif