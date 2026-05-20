`include "uvm_macros.svh"
import uvm_pkg::*;

`ifndef __scoreboard
`define __scoreboard

`uvm_analysis_imp_decl(_apb)
`uvm_analysis_imp_decl(_req_ack)

class scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp_apb #(tranzactie_apb, scoreboard) port_pentru_datele_de_la_apb;
  uvm_analysis_imp_req_ack #(req_ack_item, scoreboard) port_pentru_datele_de_la_req_ack;

  tranzactie_apb    tranzactie_venita_de_la_apb;
  req_ack_item tranzactie_venita_de_la_req_ack;

  tranzactie_apb    tranzactii_apb[$];
  req_ack_item tranzactii_req_ack[$];
  
  int reg_a, reg_b, reg_op;
  int expected_results [$], expected_result, op1, op2, opcode,start;

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
        
    
case(tranzactie_venita_de_la_apb.addr)
  

      8'h04: begin
         op1 = tranzactie_venita_de_la_apb.data;
         `uvm_info("SB",$sformatf("OP1=%0d",op1),UVM_LOW)
      end

      8'h08: begin
         op2 = tranzactie_venita_de_la_apb.data;
         `uvm_info("SB",$sformatf("OP2=%0d",op2),UVM_LOW)
        case(opcode)

               3'd0: expected_result = op1 + op2; // suma

               3'd1: expected_result = op1 - op2; // diferenta

               3'd2: expected_result = op1 * op2; // inmultire

               3'd3: begin                       // impartire
                  if(op2 != 0)
                     expected_result = op1 / op2;
                  else
                     expected_result = 8'hFF;
               end

               3'd4: expected_result = op1 & op2; // AND

               3'd5: expected_result = op1 ^ op2; // XOR

               default: expected_result = 0;

            endcase

            `uvm_info(
               "SB",
               $sformatf(
                  "EXPECTED RESULT = %0d",
                  expected_result
               ),
               UVM_LOW
            );
           
           expected_results.push_back(expected_result);

      end

      8'h00: begin
         opcode = tranzactie_venita_de_la_apb.data[2:0];
        `uvm_info("SB",$sformatf("OPCODE=%0d",opcode),UVM_LOW);

      end

   endcase
    tranzactii_apb.push_back(tranzactie_venita_de_la_apb);
  endfunction : write_apb

  function void write_req_ack(input req_ack_item tranzactie_noua_req_ack);  
    `uvm_info("SCOREBOARD", $sformatf("S-a primit de la agentul req_ack tranzactia cu informatia:\n"), UVM_LOW)
     tranzactie_noua_req_ack.afiseaza_informatia_tranzactiei();
    
    $display($sformatf("cand s-au primit date de la apb, enable a fost %d", enable));
    
    tranzactie_venita_de_la_req_ack = tranzactie_noua_req_ack.copy();
    tranzactii_req_ack.push_back(tranzactie_venita_de_la_req_ack);
  endfunction : write_req_ack

   virtual function void check_phase (uvm_phase phase); 
     if (tranzactii_req_ack.size != expected_results.size)  
       `uvm_error(
            "CHECK_PHASE",
            $sformatf(
               "Mismatch size queues expected=%0d actual=%0d",
               expected_results.size,
              tranzactii_req_ack.size
            )
         );
  foreach(tranzactii_req_ack[i]) begin
   
    if(tranzactii_req_ack[i].result != expected_results[i]) begin

         `uvm_error(
            "CHECK_PHASE",
            $sformatf(
               "Mismatch la index %0d: expected=%0d actual=%0d",
               i,
               expected_results[i],
              tranzactii_req_ack[i].result
            )
         );

      end

      else begin

         `uvm_info(
            "CHECK_PHASE",
            $sformatf(
               "Match la index %0d: value=%0d",
               i,
              tranzactii_req_ack[i].result
            ),
            UVM_LOW
         );

      end

   end
       endfunction
endclass
`endif
