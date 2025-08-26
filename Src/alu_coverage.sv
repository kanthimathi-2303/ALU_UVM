/*`include "uvm_macros.svh"
import uvm_pkg::*;
`include "alu_sequence_item.sv"
*/
`uvm_analysis_imp_decl(_active_mon_cg)
`uvm_analysis_imp_decl(_passive_mon_cg)

class alu_coverage extends uvm_component;

  `uvm_component_utils(alu_coverage)

  uvm_analysis_imp_active_mon_cg #(alu_sequence_item, alu_coverage) active_mon;
  uvm_analysis_imp_passive_mon_cg #(alu_sequence_item, alu_coverage) passive_mon;

  alu_sequence_item active_mon1, passive_mon1;

  real active_mon_cov, passive_mon_cov;
 
  covergroup input_cov;
    OPA : coverpoint active_mon1.OPA {
      bins opa_range[] = {[0 : (1<<`DATA_WIDTH)-1]};
    }
    OPB : coverpoint active_mon1.OPB {
      bins opb_range[] = {[0 : (1<<`DATA_WIDTH)-1]};
    }
    CIN : coverpoint active_mon1.CIN { bins cin_vals[] = {0,1}; }
    CE  : coverpoint active_mon1.CE  { bins ce_vals[]  = {0,1}; }
    MODE: coverpoint active_mon1.MODE{ bins mode_vals[]= {0,1}; }
    INP_VALID : coverpoint active_mon1.INP_VALID {
      bins ip_valid[] = {2'b00, 2'b01, 2'b10, 2'b11};
    }
    CMD : coverpoint active_mon1.CMD {
      bins command[] = {[0 : 13]};
    }

    MODExINP_VALID : cross MODE, INP_VALID;
    MODExCMD       : cross MODE, CMD;
    CMDxINP_VALID  : cross CMD, INP_VALID;
  endgroup : input_cov

  covergroup output_cov;
    RES   : coverpoint passive_mon1.RES   { bins res_range[] = {[0 : `DATA_WIDTH-1]}; }
    COUT  : coverpoint passive_mon1.COUT  { bins cout_vals[]  = {0,1}; }
    OFLOW : coverpoint passive_mon1.OFLOW { bins oflow_vals[] = {0,1}; }
    ERR   : coverpoint passive_mon1.ERR   { bins err_vals[]   = {0,1}; }
    G     : coverpoint passive_mon1.G     { bins g_vals[]     = {0,1}; }
    E     : coverpoint passive_mon1.E     { bins e_vals[]     = {0,1}; }
    L     : coverpoint passive_mon1.L     { bins l_vals[]     = {0,1}; }
  endgroup : output_cov

  function new(string name, uvm_component parent);
    super.new(name, parent);
	  active_mon= new("active_mon", this);
    passive_mon = new("passive_mon", this);
    input_cov = new();
    output_cov = new();
  endfunction

  function void write_passive_mon_cg(alu_sequence_item t);
    passive_mon1 = t;
    output_cov.sample();
  endfunction

  function void write_active_mon_cg(alu_sequence_item t);
    active_mon1 = t;
    input_cov.sample();
  endfunction
  

function void extract_phase(uvm_phase phase);
  super.extract_phase(phase);
  passive_mon_cov = input_cov.get_coverage();
  active_mon_cov = output_cov.get_coverage();
endfunction

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info(get_type_name, $sformatf("[DRIVER] Coverage ------> %0.2f%%,", passive_mon_cov), UVM_MEDIUM);
    `uvm_info(get_type_name, $sformatf("[MONITOR] Coverage ------> %0.2f%%,", active_mon_cov), UVM_MEDIUM);
  endfunction
endclass 
