`ifndef __apb_intf
`define __apb_intf

interface apb_interface_dut;

  logic        PCLK; 
  logic        PRESETn;
  logic        PSEL;
  logic        PENABLE;
  logic        PWRITE;
  logic [7:0]  PADDR;
  logic [31:0] PWDATA;
  logic [31:0] PRDATA;
  logic        PREADY;
  
  import uvm_pkg::*;
      
  // ASERTII
       // default clock
  default clocking cb @(posedge PCLK); endclocking

  // 1. PENABLE trebuie activ doar după PSEL
  apb_enable_after_select: assert property (
    PSEL && !PENABLE |=> PENABLE
  ) else $error("APB ERROR: PENABLE nu vine dupa PSEL");

  // 2. PSEL trebuie sa ramana activ pe durata transferului
  apb_psel_stable: assert property (
    PSEL && PENABLE |-> PSEL
  ) else $error("APB ERROR: PSEL a fost dezactivat in timpul transferului");

  // 3. Adresa si datele trebuie sa fie stabile in faza ENABLE
  apb_addr_stable: assert property (
    PSEL && PENABLE |-> $stable(PADDR)
  ) else $error("APB ERROR: PADDR nu e stabil");

  apb_wdata_stable: assert property (
    PSEL && PENABLE && PWRITE |-> $stable(PWDATA)
  ) else $error("APB ERROR: PWDATA nu e stabil");

  // 4. Transferul se finalizeaza cand PREADY = 1
  apb_transfer_complete: assert property (
    PSEL && PENABLE && PREADY |-> 1
  );

  // 5. Reset behavior
  apb_reset: assert property (
    !PRESETn |-> !PSEL && !PENABLE
  ) else $error("APB ERROR: Semnale active in reset"); 
endinterface

`endif