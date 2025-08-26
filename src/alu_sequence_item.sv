`include "defines.sv"
`include "uvm_macros.svh"
import uvm_pkg::*;

class alu_sequence_item extends uvm_sequence_item;
	//input signals
	rand bit [`DATA_WIDTH-1:0] OPA,OPB;
	rand bit [1:0] INP_VALID;
	randc bit [3:0] CMD;
	rand bit CE,CIN,MODE;

	//output signals
	bit [`DATA_WIDTH:0] RES;
	bit ERR,OFLOW,COUT,G,L,E;

	`uvm_object_utils_begin(alu_sequence_item)
		`uvm_field_int(OPA,UVM_ALL_ON)
		`uvm_field_int(OPB,UVM_ALL_ON)
		`uvm_field_int(INP_VALID,UVM_ALL_ON)
		`uvm_field_int(CMD,UVM_ALL_ON)
		`uvm_field_int(CE,UVM_ALL_ON)
		`uvm_field_int(CIN,UVM_ALL_ON)
		`uvm_field_int(MODE,UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name = "alu_sequence_item");
		super.new(name);
	endfunction

	//constraints
	constraint ce{ CE dist {0 := 2, 1 := 10};}
	constraint cin_needed { if (!(CMD inside {4'b0010, 4'b0011}) || MODE == 0) CIN == 0;}
	/*constraint cmd_mode{
			if(MODE == 1) CMD inside{[0:10]};
			else CMD inside{[0:13]};}
	constraint ip_valid { INP_VALID inside{[0:3]};}*/
	
endclass
