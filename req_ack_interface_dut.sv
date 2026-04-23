`ifndef __req_agn_intf
`define __req_agn_intf

interface req_agn_interface;

  logic clk;
  logic req;
  logic ack;

  import uvm_pkg::*;

  // ASERTII
  // default clock
  default clocking cb @(posedge clk); endclocking

  // 1. req trebuie urmat de ack (eventual)
  req_followed_by_ack: assert property (
    req |-> ##[1:5] ack
  ) else $error("REQ/ACK ERROR: ack nu vine dupa req");

  // 2. ack nu apare fara req
  ack_only_when_req: assert property (
    ack |-> req
  ) else $error("REQ/ACK ERROR: ack fara req");

  // 3. req trebuie sa ramana activ pana vine ack
  req_stable_until_ack: assert property (
    req && !ack |=> req
  ) else $error("REQ/ACK ERROR: req a cazut inainte de ack");

  // 4. handshake complet
  handshake_complete: assert property (
    req ##[1:5] ack
  );

  // 5. ack nu trebuie sa stea activ permanent
  ack_not_stuck: assert property (
    ack |=> !ack
  ) else $error("REQ/ACK ERROR: ack blocat pe 1");
  
endinterface

`endif