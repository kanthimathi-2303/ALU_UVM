/*`include "uvm_macros.svh"
import uvm_pkg::*;
`include "alu_driver.sv"
`include "alu_monitor.sv"
`include "alu_sequencer.sv"
*/
class alu_active_agent extends uvm_agent;
	alu_driver drv;
	alu_sequencer seqr;
	alu_active_monitor active_mon;

	`uvm_component_utils(alu_active_agent)

	function new(string name = "alu_active_agent", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(get_is_active() == UVM_ACTIVE)begin
			drv = alu_driver::type_id::create("drv",this);
			seqr = alu_sequencer::type_id::create("seqr",this);
		end

		active_mon = alu_active_monitor::type_id::create("active_mon",this);

	endfunction

	function void connect_phase(uvm_phase phase);
		if(get_is_active() == UVM_ACTIVE) begin
			drv.seq_item_port.connect(seqr.seq_item_export);
		end
	endfunction
endclass

class alu_passive_agent extends uvm_agent;
	alu_driver drv;
	alu_sequencer seqr;
	alu_passive_monitor passive_mon;

	`uvm_component_utils(alu_passive_agent)

	function new(string name = "alu_passive_agent", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(get_is_active() == UVM_PASSIVE)begin
			passive_mon = alu_passive_monitor::type_id::create("passive_mon",this);
		end
	endfunction

endclass
