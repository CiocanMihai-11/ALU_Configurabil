`ifndef REQ_ACK_ITEM
`define REQ_ACK_ITEM
import uvm_pkg::*;
class req_ack_item extends uvm_sequence_item;

  rand int delay;
  rand int data;

  `uvm_object_utils(req_ack_item)

  function new(string name = "req_ack_item");
    super.new(name);
  endfunction

endclass

`endif // REQ_ACK_ITEM