/*`include "uvm_macros.svh"
import uvm_pkg::*;
`include "alu_sequence_item.sv"
*/
class alu_driver extends uvm_driver#(alu_sequence_item);
	virtual alu_if vif;

	`uvm_component_utils(alu_driver)

	function new(string name,uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(virtual alu_if)::get(this,"","vif",vif))
			`uvm_fatal("NO_VIF",{"virtual intrface must be set for:",get_full_name(),".vif"});
	endfunction

	virtual task run_phase(uvm_phase phase);
		forever begin
			seq_item_port.get_next_item(req);
			drive(req);
			seq_item_port.item_done();
		end
	endtask

  function bit needs_2_op(logic [3:0] CMD, logic MODE);
    if (MODE == 1)
      return (CMD inside {4'd0,4'd1,4'd2,4'd3,4'd8,4'd9,4'd10});
    else
      return (CMD inside {4'd0,4'd1,4'd2,4'd3,4'd4,4'd5,4'd12,4'd13});
  endfunction

	function int get_output_delay(logic [3:0] CMD,logic MODE);
		if(CMD inside {4'd9,4'd10} && MODE == 1) return 4;
		else return 3;
	endfunction

	// Drive a single transaction to the DUT
  virtual task drive(alu_sequence_item req);
    int delay, c;
    c = 0;
    delay = get_output_delay(vif.CMD, vif.MODE);

    repeat(1)@(vif.drv_cb); // Wait for a clock edge

		`uvm_info(get_type_name(),$sformatf("CE=%0d, MODE=%0d, INP_VALID=%0d, CMD=%0d, OPA=%0d, OPB=%0d, CIN=%0d", req.CE, req.MODE, req.INP_VALID, req.CMD, req.OPA, req.OPB, req.CIN),UVM_LOW)
			
		//req.print();

    if (vif.rst == 0) begin
      // Drive fields
      vif.drv_cb.CE        <= req.CE;
      vif.drv_cb.MODE      <= req.MODE;
      vif.drv_cb.CMD       <= req.CMD;
      vif.drv_cb.CIN       <= req.CIN;
      vif.drv_cb.OPA       <= req.OPA;
      vif.drv_cb.OPB       <= req.OPB;
      vif.drv_cb.INP_VALID <= req.INP_VALID;

      // Ensure INP_VALID is correct for dual operand ops
      if (needs_2_op(req.CMD, req.MODE) && req.INP_VALID != 2'b11) begin
        req.CMD.rand_mode(0);
        req.CE.rand_mode(0);
        req.MODE.rand_mode(0);

        while (req.INP_VALID != 2'b11 && c < 16) begin
          @(vif.drv_cb);
          c++;
          if (!req.randomize()) begin
            `uvm_error("ALU_DRV", "Randomization failed")
          end
          vif.drv_cb.OPA       <= req.OPA;
          vif.drv_cb.OPB       <= req.OPB;
          vif.drv_cb.INP_VALID <= req.INP_VALID;
          vif.drv_cb.CIN       <= req.CIN;
					`uvm_info(get_type_name(),$sformatf("Retry [%0d]: CE=%0d, MODE=%0d, INP_VALID=%0d, CMD=%0d, OPA=%0d, OPB=%0d, CIN=%0d",c, req.CE, req.MODE, req.INP_VALID, req.CMD, req.OPA, req.OPB, req.CIN),UVM_LOW)
				end

        if (req.INP_VALID != 2'b11) begin
          `uvm_error("ALU_DRV", "INP_VALID did not become 2'b11 within 16 cycles")
        end
      end

      //@(vif.drv_cb); // latch values
      repeat(delay) @(vif.drv_cb);

    end
    else begin
      // During reset
      vif.drv_cb.CE        <= 0;
      vif.drv_cb.OPA       <= 0;
      vif.drv_cb.OPB       <= 0;
      vif.drv_cb.INP_VALID <= 0;
      vif.drv_cb.CMD       <= 0;
      vif.drv_cb.CIN       <= 0;
      vif.drv_cb.MODE      <= 0;

      `uvm_info("ALU_DRV", "DUT is in reset", UVM_NONE)
      //@(vif.drv_cb);
    end
  endtask

endclass 
