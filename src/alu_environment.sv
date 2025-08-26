/*`include "uvm_macros.svh"
import uvm_pkg::*;
`include "alu_agent.sv"
`include "alu_scoreboard.sv"
`include "alu_coverage.sv"
*/
class alu_environment extends uvm_env;
  alu_active_agent      active_agt;
	alu_passive_agent			passive_agt; 
  alu_scoreboard 				scb;
  alu_coverage 					fcov;
  
  `uvm_component_utils(alu_environment)
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    active_agt = alu_active_agent::type_id::create("active_agt", this);
    passive_agt = alu_passive_agent::type_id::create("passive_agt", this);

		set_config_int("active_agt","is_active",UVM_ACTIVE);
		set_config_int("passive_agt","is_active",UVM_PASSIVE);

    scb = alu_scoreboard::type_id::create("scb", this);
    fcov = alu_coverage::type_id::create("fcov", this);
  endfunction
  
  function void connect_phase(uvm_phase phase);
    active_agt.active_mon.active_mon_port.connect(scb.active_scb_port);
    active_agt.active_mon.active_mon_port.connect(fcov.active_mon);
    passive_agt.passive_mon.passive_mon_port.connect(fcov.passive_mon);
    passive_agt.passive_mon.passive_mon_port.connect(scb.passive_scb_port);
  endfunction

endclass
