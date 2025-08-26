/*`include "uvm_macros.svh"
import uvm_pkg::*;
`include "alu_sequence_item.sv"
*/
class alu_active_monitor extends uvm_monitor;
	virtual alu_if vif;
	uvm_analysis_port#(alu_sequence_item)active_mon_port;

	alu_sequence_item alu_seq_item;

	`uvm_component_utils(alu_active_monitor)

	function new(string name = "alu_monitor", uvm_component parent);
		super.new(name,parent);
		alu_seq_item = new();
		active_mon_port = new("active_mon_port",this);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
			`uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
	endfunction

	virtual task run_phase(uvm_phase phase);
		forever begin
			int count = 0;
			int delay;

			repeat(2)@(vif.mon_cb);

			wait(vif.INP_VALID != 0);

			//wait for 2nd operand if needed 
			if(needs_2_op(vif.mon_cb.CMD,vif.mon_cb.MODE) && vif.mon_cb.INP_VALID != 2'b11)begin
				while(vif.mon_cb.INP_VALID != 2'b11 && count < 16)begin
					@(vif.mon_cb);
					count ++;
				end
			end
			
			//delay = get_output_delay(vif.mon_cb.CMD,vif.mon_cb.MODE);

			// Capture inputs
      alu_seq_item.CE        = vif.mon_cb.CE;
      alu_seq_item.INP_VALID = vif.mon_cb.INP_VALID;
      alu_seq_item.MODE      = vif.mon_cb.MODE;
      alu_seq_item.CMD       = vif.mon_cb.CMD;
      alu_seq_item.OPA       = vif.mon_cb.OPA;
      alu_seq_item.OPB       = vif.mon_cb.OPB;
			alu_seq_item.CIN       = vif.mon_cb.CIN;

			`uvm_info(get_type_name(),$sformatf("CE=%0d, IP_VALID=%0d, MODE=%0d, CMD=%0d, OPA=%0d, OPB=%0d, CIN=%0d", alu_seq_item.CE,  alu_seq_item.INP_VALID,  alu_seq_item.MODE, alu_seq_item.CMD,  alu_seq_item.OPA,  alu_seq_item.OPB,  alu_seq_item.CIN),UVM_LOW)

			active_mon_port.write(alu_seq_item);
			
			repeat(2)@(vif.mon_cb);

		end
		//alu_seq_item.print();
	endtask

	//needs 2 operand 16 cycle delay
	function bit needs_2_op(logic [3:0] CMD, logic MODE);
		if(MODE == 1)begin
			return (CMD inside {4'd0, 4'd1, 4'd2, 4'd3, 4'd8, 4'd9, 4'd10});
		end else begin
			return (CMD inside {4'd0, 4'd1, 4'd2, 4'd3, 4'd4, 4'd5, 4'd12, 4'd13});
		end
	endfunction

	//delay based on commands
	function int get_output_delay(logic [3:0] CMD,logic MODE);
		if(CMD inside {4'd9,4'd10} && MODE == 1) begin
			return 3;
		end else begin
			return 2;
		end
	endfunction

endclass

class alu_passive_monitor extends uvm_monitor;
        virtual alu_if vif;
        uvm_analysis_port#(alu_sequence_item)passive_mon_port;

        alu_sequence_item alu_seq_item;

        `uvm_component_utils(alu_passive_monitor)

        function new(string name = "alu_passive_monitor", uvm_component parent);
                super.new(name,parent);
                alu_seq_item = new();
                passive_mon_port = new("passive_mon_port",this);
        endfunction

        function void build_phase(uvm_phase phase);
                super.build_phase(phase);
                if(!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
                        `uvm_fatal("NOVIF",{"virtual interface must be set for: ",get_full_name(),".vif"});
        endfunction

        virtual task run_phase(uvm_phase phase);
                forever begin
                        int count = 0;
                        int delay;

                        repeat(2)@(vif.mon_cb);

                        delay = get_output_delay(vif.mon_cb.CMD,vif.mon_cb.MODE);

                        repeat(delay) @(vif.mon_cb);

                        alu_seq_item.RES   = vif.mon_cb.RES;
                        alu_seq_item.COUT  = vif.mon_cb.COUT;
                        alu_seq_item.OFLOW = vif.mon_cb.OFLOW;
                        alu_seq_item.ERR   = vif.mon_cb.ERR;
                        alu_seq_item.G     = vif.mon_cb.G;
                        alu_seq_item.L     = vif.mon_cb.L;
                        alu_seq_item.E     = vif.mon_cb.E;

                        `uvm_info(get_type_name(), $sformatf("RES=%0d COUT=%0d E=%0d G=%0d L=%0d OFLOW=%0d ERR=%0d", alu_seq_item.RES, alu_seq_item.COUT, alu_seq_item.E, alu_seq_item.G, alu_seq_item.L, alu_seq_item.OFLOW, alu_seq_item.ERR), UVM_LOW)

                        passive_mon_port.write(alu_seq_item);

                        //repeat(1)@(vif.mon_cb);

                end
        endtask

                //delay based on commands
                function int get_output_delay(logic [3:0] CMD,logic MODE);
                        if(CMD inside {4'd9,4'd10} && MODE == 1) begin
                                return 3;
                        end else begin
                                return 2;
                        end
                endfunction

endclass
