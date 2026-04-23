`include "uvm_macros.svh"
import uvm_pkg::*;

class coverage_apb extends uvm_component;

  `uvm_component_utils(coverage_apb)

  // analysis export (primește tranzacții din monitor)
  uvm_analysis_imp #(tranzactie_apb, coverage_apb) analysis_export;

  // ultima tranzacție
  tranzactie_apb tr;

  // ---------------- COVERGROUP ----------------
  covergroup stari_apb_cg with function sample(tranzactie_apb t);
    option.per_instance = 1;

    // ---------------- ADDRESS ----------------
    addr_cp: coverpoint t.addr {
      bins reg_a   = {8'h00};
      bins reg_b   = {8'h04};
      bins reg_op  = {8'h08};
      bins reg_ctl = {8'h0C};
      bins reg_sts = {8'h10};
      bins reg_res = {8'h14};
      bins others  = default;
    }

    // ---------------- READ / WRITE ----------------
    write_cp: coverpoint t.write {
      bins read  = {0};
      bins write = {1};
    }

    // ---------------- DATA (simplificat) ----------------
    data_cp: coverpoint t.data {
      bins zero     = {0};
      bins small    = {[1:10]};
      bins medium   = {[11:100]};
      bins large    = {[101:1000]};
      bins others   = default;
    }

    // ---------------- CROSS COVERAGE ----------------
    addr_x_write: cross addr_cp, write_cp;

  endgroup

  // ---------------- CONSTRUCTOR ----------------
  function new(string name, uvm_component parent);
    super.new(name, parent);
    analysis_export = new("analysis_export", this);
    stari_apb_cg = new();
  endfunction

  // ---------------- WRITE (din monitor) ----------------
  function void write(tranzactie_apb t);
    tr = t;
    stari_apb_cg.sample(tr);
  endfunction

endclass