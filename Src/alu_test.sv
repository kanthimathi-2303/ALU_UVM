/*import uvm_pkg::*;
`include "alu_environment.sv"
`include "alu_sequence.sv"
*/
class alu_base extends uvm_test;
	`uvm_component_utils(alu_base)

	alu_environment env;
	function new(string name = "alu_base",uvm_component parent );
		super.new(name,parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = alu_environment::type_id::create("env",this);
	endfunction

	virtual function void end_of_elaboration_phase(uvm_phase phase);
		super.end_of_elaboration_phase(phase);
		uvm_top.print_topology();
	endfunction

endclass

class logical_one_test extends alu_base;
	`uvm_component_utils(logical_one_test)

	function new(string name = "logical_one_test",uvm_component parent = null);
		super.new(name,parent);
	endfunction

	virtual task run_phase(uvm_phase phase);
		alu_logical_one_sequence seq; 
		phase.raise_objection(this);
		seq = alu_logical_one_sequence::type_id::create("seq");
		seq.start(env.active_agt.seqr);

		phase.drop_objection(this);
	endtask
endclass

class arithmetic_one_test extends alu_base;
		`uvm_component_utils(arithmetic_one_test)

		function new(string name = "arithmetic_one_test",uvm_component parent = null);
					super.new(name,parent);
				endfunction

					virtual task run_phase(uvm_phase phase);
								alu_arithmetic_one_sequence seq;
								phase.raise_objection(this);
								
								seq = alu_arithmetic_one_sequence::type_id::create("seq");
								seq.start(env.active_agt.seqr);

								phase.drop_objection(this);
							endtask
endclass

class logical_two_test extends alu_base;
	  `uvm_component_utils(logical_two_test)

	  function new(string name = "logical_two_test",uvm_component parent = null);
					super.new(name,parent);
				endfunction

					virtual task run_phase(uvm_phase phase);
								alu_logical_two_sequence seq;
								phase.raise_objection(this);
								
								seq = alu_logical_two_sequence::type_id::create("seq");
								seq.start(env.active_agt.seqr);

								phase.drop_objection(this);
							endtask
endclass

class arithmetic_two_test extends alu_base;
		`uvm_component_utils(arithmetic_two_test)

		function new(string name = "arithmetic_two_test",uvm_component parent = null);
					super.new(name,parent);
				endfunction

					virtual task run_phase(uvm_phase phase);
								alu_arithmetic_two_sequence seq;
								phase.raise_objection(this);
								
								seq = alu_arithmetic_two_sequence::type_id::create("seq");
								seq.start(env.active_agt.seqr);

								phase.drop_objection(this);
							endtask
endclass


class delay_16_test extends alu_base;
		`uvm_component_utils(delay_16_test)

		function new(string name = "alu_delay_16_test",uvm_component parent = null);
					super.new(name,parent);
				endfunction

					virtual task run_phase(uvm_phase phase);
								alu_delay_16_sequence seq;
								phase.raise_objection(this);
								
								seq = alu_delay_16_sequence::type_id::create("seq");
								seq.start(env.active_agt.seqr);

								phase.drop_objection(this);
							endtask
endclass

class alu_regression_test extends alu_base;

	  `uvm_component_utils(alu_regression_test)

	  function new(string name = "alu_regression_test", uvm_component parent = null);
			    super.new(name, parent);
			  endfunction

				  virtual task run_phase(uvm_phase phase);
						    alu_regression   seq;
						    phase.raise_objection(this);

						    seq =  alu_regression::type_id::create("seq");
						    seq.start(env.active_agt.seqr);

						    phase.drop_objection(this);
						  endtask

endclass
