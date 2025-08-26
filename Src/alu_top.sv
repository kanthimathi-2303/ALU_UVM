`include "uvm_macros.svh"
//`include "alu_pkg.sv"
`include "alu_interface.sv"
`include "alu_design.sv"
`include "defines.sv"
`include "alu_sequence_item.sv"
`include "alu_sequence.sv"
`include "alu_sequencer.sv"
`include "alu_driver.sv"
`include "alu_monitor.sv"
`include "alu_agent.sv"
`include "alu_scoreboard.sv"
`include "alu_coverage.sv"
`include "alu_environment.sv"
`include "alu_test.sv"

module top;
	import uvm_pkg::*;
	//import alu_pkg::*;

	bit clk;
	bit rst;

	always #5 clk = ~clk;

	initial begin
		//rst = 1;
		//#10 rst = 0;
	end

	alu_if intf(clk,rst);

	alu_design DUV (
		    .OPA(intf.OPA),
		    .OPB(intf.OPB),
				.INP_VALID(intf.INP_VALID),
				.CE(intf.CE),
				.MODE(intf.MODE),
				.CIN(intf.CIN),
		    .CMD(intf.CMD),
		    .RES(intf.RES),
		    .COUT(intf.COUT),
		    .OFLOW(intf.OFLOW),
				.G(intf.G),
				.E(intf.E),
				.L(intf.L),
				.ERR(intf.ERR),
		    .CLK(clk),
		    .RST(rst)
		  );

			initial begin
				uvm_config_db#(virtual alu_if)::set(uvm_root::get(),"*","vif",intf);
				$dumpfile("dump.vcd");
				$dumpvars;
			end

			initial begin
				run_test("logical_one_test");
				#100;
				$finish;
			end
endmodule
