`ifndef __apb_intf
`define __apb_intf

interface apb_interface_dut;

  logic        pclk; 
  logic        presetn;
  logic        psel;
  logic        penable;
  logic        pwrite;
  logic [7:0]  paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic        pready;
  
  import uvm_pkg::*;
     /* 
  // ASERTII
       // default clock
  default clocking cb @(posedge pclk); endclocking

  // 1. PENABLE trebuie activ doar după PSEL
  apb_enable_after_select: assert property (
    psel && !penable |=> penable
  ) else $error("APB ERROR: penable nu vine dupa psel");

  // 2. PSEL trebuie sa ramana activ pe durata transferului
  apb_psel_stable: assert property (
    psel && penable |-> psel
  ) else $error("APB ERROR: psel a fost dezactivat in timpul transferului");

  // 3. Adresa si datele trebuie sa fie stabile in faza ENABLE
  apb_addr_stable: assert property (
    psel && penable |-> $stable(paddr)
  ) else $error("APB ERROR: paddr nu e stabil");

  apb_wdata_stable: assert property (
    psel && penable && pwrite |-> $stable(pwdata)
  ) else $error("APB ERROR: PWDATA nu e stabil");

  // 4. Transferul se finalizeaza cand PREADY = 1
  apb_transfer_complete: assert property (
    psel && penable && pready |-> 1
  );

  // 5. Reset behavior
  apb_reset: assert property (
    !presetn |-> !psel && !penable
  ) else $error("APB ERROR: Semnale active in reset"); 
  */
endinterface

`endif