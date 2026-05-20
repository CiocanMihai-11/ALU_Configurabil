`ifndef REQ_ACK_ITEM
`define REQ_ACK_ITEM
import uvm_pkg::*;
class req_ack_item extends uvm_sequence_item;

  rand int delay;
  rand int result;

  `uvm_object_utils(req_ack_item)

  function new(string name = "req_ack_item");
    super.new(name);
  endfunction
  
   //functie de afisare a unei tranzactii
  function void afiseaza_informatia_tranzactiei();
    $display("Valoarea result: %0h", result);
  endfunction

  function req_ack_item copy();
	copy = new();
	copy.result = this.result;
	return copy;
  endfunction
endclass

`endif // REQ_ACK_ITEM