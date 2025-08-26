/*`include "uvm_macros.svh"
import uvm_pkg::*;
`include "alu_sequence_item.sv"
*/

`uvm_analysis_imp_decl(_active_mon_scb)
`uvm_analysis_imp_decl(_passive_mon_scb)

class alu_scoreboard extends uvm_scoreboard;
	alu_sequence_item pkt_o[$]; //monitor outputs
	alu_sequence_item pkt_i[$]; //monitor inputs 

	`uvm_component_utils(alu_scoreboard)
	
	virtual alu_if vif;

	uvm_analysis_imp_active_mon_scb#(alu_sequence_item,alu_scoreboard) active_scb_port;
	uvm_analysis_imp_passive_mon_scb#(alu_sequence_item,alu_scoreboard) passive_scb_port;

	function new(string name = "alu_scoreboard",uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		active_scb_port = new("active_scb_port",this);
		passive_scb_port = new("passive_scb_port",this);

		if (!uvm_config_db#(virtual alu_if)::get(this, "", "vif", vif))
			`uvm_fatal("NO_VIF",{"virtual intrface must be set for:",get_full_name(),".vif"});
	endfunction

	virtual function void write_passive_mon_scb(alu_sequence_item pkt1);
		$display("scoreboard received :: passive packet ");
		pkt_o.push_back(pkt1);
	endfunction
	
	virtual function void write_active_mon_scb(alu_sequence_item pkt2);
		$display("scoreboard received :: active packet ");
		pkt_i.push_back(pkt2);
	endfunction

	virtual task run_phase(uvm_phase phase);
  alu_sequence_item p1, p2;

  phase.raise_objection(this);

  for (int i = 0; i < `NO_OF_TRANS; i++) begin
    wait (pkt_i.size() > 0 && pkt_o.size() > 0);

    p1 = pkt_i.pop_front();
    p2 = pkt_o.pop_front();

    if (p1 == null || p2 == null) begin
      `uvm_fatal("SCB_NULL", $sformatf("Null packet: p1=%p p2=%p", p1, p2))
    end

		`uvm_info(get_type_name(),
			$sformatf("DUT INPUTS @ SCB => CE=%0d, MODE=%0d, INP_VALID=%0d, CMD=%0d, OPA=%0d, OPB=%0d, CIN=%0d",
				p1.CE, p1.MODE, p1.INP_VALID, p1.CMD, p1.OPA, p1.OPB, p1.CIN),
			UVM_LOW)

		`uvm_info(get_type_name(),
			$sformatf("DUT OUTPUT @ SCB => RES=%0d, COUT=%0b, E=%0b, G=%0b, L=%0b, OFLOW=%0b, ERR=%0b",
				p2.RES, p2.COUT, p2.E, p2.G, p2.L, p2.OFLOW, p2.ERR),
			UVM_LOW)

		compare_results(p1, p2);
	end

		if (pkt_i.size() != 0 || pkt_o.size() != 0) begin
			`uvm_warning("SCB_LEFTOVER",
				$sformatf("Leftover items after loop: inputs=%0d outputs=%0d",
					pkt_i.size(), pkt_o.size()))
		end

		phase.drop_objection(this);
	endtask


	task compare_results(alu_sequence_item pi,alu_sequence_item po);
		bit [`DATA_WIDTH:0] exp_res;
		bit exp_cout, exp_e, exp_g, exp_l, exp_oflow, exp_err;

		calculate_expected_results(
			vif.rst,
			pi.CE,
			pi.MODE,
			pi.CIN,
			pi.INP_VALID,
			pi.CMD,
			pi.OPA,
			pi.OPB,
			exp_res,
			exp_cout,
			exp_e,
			exp_g,
			exp_l,
			exp_oflow,
			exp_err
		);
		`uvm_info(get_type_name(), $sformatf("EXPECTED OUTPUT => RES=%0d, COUT=%0b, E=%0b, G=%0b, L=%0b, OFLOW=%0b, ERR=%0b", exp_res, exp_cout, exp_e, exp_g, exp_l, exp_oflow, exp_err), UVM_LOW)

		`uvm_info(get_type_name(),"Reference model without delay",UVM_HIGH)
		if (po.RES === exp_res) begin
			`uvm_info(get_type_name(), $sformatf("PASS: RES matched => %0d", po.RES), UVM_LOW)
		end else begin
			`uvm_error(get_type_name(), $sformatf("FAIL: Expected RES=%0d Got RES=%0d", exp_res, po.RES))
		end

		if (po.COUT === exp_cout) begin
			`uvm_info(get_type_name(), $sformatf("PASS: COUT matched => %0b", po.COUT), UVM_LOW)
		end else begin
			`uvm_error(get_type_name(), $sformatf("FAIL: Expected COUT=%0b Got COUT=%0b", exp_cout, po.COUT))
		end

		if (po.E === exp_e) begin
			`uvm_info(get_type_name(), $sformatf("PASS: E matched => %0b", po.E), UVM_LOW)
		end else begin
			`uvm_error(get_type_name(), $sformatf("FAIL: Expected E=%0b Got E=%0b", exp_e, po.E))
		end

		if (po.G === exp_g) begin
			`uvm_info(get_type_name(), $sformatf("PASS: G matched => %0b", po.G), UVM_LOW)
		end else begin
			`uvm_error(get_type_name(), $sformatf("FAIL: Expected G=%0b Got G=%0b", exp_g, po.G))
		end

		if (po.L === exp_l) begin
			`uvm_info(get_type_name(), $sformatf("PASS: L matched => %0b", po.L), UVM_LOW)
		end else begin
			`uvm_error(get_type_name(), $sformatf("FAIL: Expected L=%0b Got L=%0b", exp_l, po.L))
		end

		if (po.OFLOW === exp_oflow) begin
			`uvm_info(get_type_name(), $sformatf("PASS: OFLOW matched => %0b", po.OFLOW), UVM_LOW)
		end else begin
			`uvm_error(get_type_name(), $sformatf("FAIL: Expected OFLOW=%0b Got OFLOW=%0b", exp_oflow, po.OFLOW))
		end

		if (po.ERR === exp_err) begin
			`uvm_info(get_type_name(), $sformatf("PASS: ERR matched => %0b", po.ERR), UVM_LOW)
		end else begin
			`uvm_error(get_type_name(), $sformatf("FAIL: Expected ERR=%0b Got ERR=%0b", exp_err, po.ERR))
		end

		/*if ((po.RES    === exp_res) &&
			(po.COUT   === exp_cout) &&
			(po.E      === exp_e) &&
			(po.G      === exp_g) &&
			(po.L      === exp_l) &&
			(po.OFLOW  === exp_oflow) &&
			(po.ERR    === exp_err)) begin
				`uvm_info(get_type_name(), "PASS: Outputs match", UVM_LOW)
			end
		else begin
			`uvm_error(get_type_name(),$sformatf("FAIL: Expected RES=%0h Got RES=%0h", exp_res, po.RES))
		end*/
	endtask

	task calculate_expected_results;
		input rst, ce, mode, cin;
		input [1:0] ip_v;
		input [3:0] cmd;
		input [`DATA_WIDTH-1:0] opa, opb;
		output reg [`DATA_WIDTH+1:0] expected_res;
		output reg expected_cout;
		output reg expected_e;
		output reg expected_g;
		output reg expected_l;
		output reg expected_overflow;
		output reg expected_error;

		integer rot_amt;

		begin
			expected_res = 0;
			expected_cout = 0;
			{expected_e, expected_g, expected_l} = 3'b000;
			expected_overflow = 0;
			expected_error = 0;

			if (rst) begin
				expected_res = 0;
				expected_cout = 0;
				{expected_e, expected_g, expected_l} = 3'b000;
				expected_overflow = 0;
				expected_error = 0;
			end
			else if (ce) begin
				rot_amt = opb[$clog2(`DATA_WIDTH)-1:0];

				case (ip_v)
					2'b00: expected_error = 1;

					2'b01: begin
						if (mode) begin
							case (cmd)
								4'd4: begin expected_res = opa + 1; expected_error = (opa == {`DATA_WIDTH{1'b1}}); end // INC_A
								4'd5: begin expected_res = opa - 1; expected_error = (opa == {`DATA_WIDTH{1'b0}}); end // DEC_A
								default: expected_error = 1;
							endcase
						end else begin
							case (cmd)
								4'd6: expected_res = {{`DATA_WIDTH{1'b0}}, ~opa};      // NOT_A
								4'd8: expected_res = {{`DATA_WIDTH{1'b0}}, opa >> 1};  // SHR1_A
								4'd9: expected_res = {{`DATA_WIDTH{1'b0}}, opa << 1};  // SHL1_A
								default: expected_error = 1;
							endcase
						end
					end

					2'b10: begin
						if (mode) begin
							case (cmd)
								4'd6: begin expected_res = opb + 1; expected_error = (opb == {`DATA_WIDTH{1'b1}}); end // INC_B
								4'd7: begin expected_res = opb - 1; expected_error = (opb == {`DATA_WIDTH{1'b0}}); end // DEC_B
								default: expected_error = 1;
							endcase
						end else begin
							case (cmd)
								4'd7: expected_res = {{`DATA_WIDTH{1'b0}}, ~opb};      // NOT_B
								4'd10: expected_res = {{`DATA_WIDTH{1'b0}}, opb >> 1}; // SHR1_B
								4'd11: expected_res = {{`DATA_WIDTH{1'b0}}, opb << 1}; // SHL1_B
								default: expected_error = 1;
							endcase
						end
					end

					2'b11: begin
						if (mode) begin
							case (cmd)
								4'd0: begin expected_res = opa + opb; expected_cout = expected_res[`DATA_WIDTH]; end // ADD
								4'd1: begin expected_res = opa - opb; expected_overflow = (opa < opb); end           // SUB
								4'd2: begin expected_res = opa + opb + cin; expected_cout = expected_res[`DATA_WIDTH]; end // ADD_CIN
								4'd3: begin expected_res = opa - opb - cin; expected_overflow = (opa < (opb + cin)); end   // SUB_CIN
								4'd4: begin expected_res = opa + 1; expected_error = (opa == {`DATA_WIDTH{1'b1}}); end     // INC_A
								4'd5: begin expected_res = opa - 1; expected_error = (opa == {`DATA_WIDTH{1'b0}}); end     // DEC_A
								4'd6: begin expected_res = opb + 1; expected_error = (opb == {`DATA_WIDTH{1'b1}}); end     // INC_B
								4'd7: begin expected_res = opb - 1; expected_error = (opb == {`DATA_WIDTH{1'b0}}); end     // DEC_B
								4'd8: begin // CMP
									if (opa == opb) {expected_e, expected_g, expected_l} = 3'b100;
									else if (opa > opb) {expected_e, expected_g, expected_l} = 3'b010;
									else {expected_e, expected_g, expected_l} = 3'b001;
								end
								4'd9:  expected_res = (opa + 1) * (opb + 1); // MULT (increment both then multiply)
								4'd10: expected_res = (opa << 1) * opb;      // SH1_MULT
								default: expected_error = 1;
							endcase
						end else begin
							case (cmd)
								4'd0: expected_res = {{`DATA_WIDTH{1'b0}}, opa & opb};   // AND
								4'd1: expected_res = {{`DATA_WIDTH{1'b0}}, ~(opa & opb)};// NAND
								4'd2: expected_res = {{`DATA_WIDTH{1'b0}}, opa | opb};   // OR
								4'd3: expected_res = {{`DATA_WIDTH{1'b0}}, ~(opa | opb)};// NOR
								4'd4: expected_res = {{`DATA_WIDTH{1'b0}}, opa ^ opb};   // XOR
								4'd5: expected_res = {{`DATA_WIDTH{1'b0}}, ~(opa ^ opb)};// XNOR
								4'd6: expected_res = {{`DATA_WIDTH{1'b0}}, ~opa};        // NOT_A
								4'd7: expected_res = {{`DATA_WIDTH{1'b0}}, ~opb};        // NOT_B
								4'd8: expected_res = {{`DATA_WIDTH{1'b0}}, opa >> 1};    // SHR1_A
								4'd9: expected_res = {{`DATA_WIDTH{1'b0}}, opa << 1};    // SHL1_A
								4'd10: expected_res = {{`DATA_WIDTH{1'b0}}, opb >> 1};   // SHR1_B
								4'd11: expected_res = {{`DATA_WIDTH{1'b0}}, opb << 1};   // SHL1_B
								4'd12: begin // ROL_A_B
									expected_error = |opb[`DATA_WIDTH-1:$clog2(`DATA_WIDTH)];
									expected_res = {{`DATA_WIDTH{1'b0}}, (rot_amt == 0) ? opa : (opa << rot_amt) | (opa >> (`DATA_WIDTH - rot_amt))};
								end
								4'd13: begin // ROR_A_B
									expected_error = |opb[`DATA_WIDTH-1:$clog2(`DATA_WIDTH)];
									expected_res = {{`DATA_WIDTH{1'b0}}, (rot_amt == 0) ? opa : (opa >> rot_amt) | (opa << (`DATA_WIDTH - rot_amt))};
								end
								default: expected_error = 1;
							endcase
						end
					end

					default: expected_error = 1;
				endcase
			end
			else begin
				expected_error = 1;
			end
		end

	endtask
endclass
