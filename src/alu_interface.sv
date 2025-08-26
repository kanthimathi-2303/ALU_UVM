`include "defines.sv"

interface alu_if(input bit clk, input bit rst);
	// input signals
	logic CE, MODE;
	logic [`DATA_WIDTH-1:0] OPA, OPB;
	logic [1:0] INP_VALID;
	logic [3:0] CMD;
	logic CIN;

	// output signals
	wire ERR, OFLOW, COUT, G, L, E;
	wire [`DATA_WIDTH+1:0] RES;

	// driver clocking block
	clocking drv_cb @(posedge clk);
		output CE, MODE, OPA, OPB, INP_VALID, CMD, CIN;
		input rst;
	endclocking

	// monitor clocking block
	clocking mon_cb @(posedge clk);
		input CE, MODE, OPA, OPB, INP_VALID, CMD, CIN;
		input ERR, OFLOW, COUT, G, L, E, RES;
	endclocking

	/*// reference model clocking block
	clocking ref_cb @(posedge clk);
	input CE, MODE, OPA, OPB, INP_VALID, CMD, CIN, rst;
	endclocking*/

	// modports
	modport DRV(clocking drv_cb, input rst,INP_VALID);
	modport MON(clocking mon_cb);
			//modport REF_SB(clocking ref_cb, input rst,INP_VALID);   
/*
			//Assertions
			//checking signals valid when ce is high
			property valid_ip;
				@(posedge clk) 
				disable iff(rst) CE |=> not($isunknown({OPA, OPB, CIN, MODE, CMD, INP_VALID}));
			endproperty

			assert property(valid_ip)
			$info("Valid Inputs Pass ");
			else 
				$error("Valid Inputs Fail ");

			//check reset condition
			property valid_reset;
				@(posedge clk) rst |=> ##[1:5] (RES === 9'bzzzzzzzz && ERR === 1'bz && E === 1'bz && G === 1'bz && L === 1'bz 
													 && COUT === 1'bz && OFLOW === 1'bz);
			endproperty

			assert property(valid_reset)
			$info("RST assertion Pass ");
			else
				$error("RST assertion Fail");

			//16 cycle wait and error condition
			property wait_err;
				@(posedge clk) 
				disable iff(rst)(CE && (INP_VALID == 1 || INP_VALID == 2)) |-> (INP_VALID == 3)[*16] |=> ERR;
			endproperty

			assert property(wait_err)
			$info("16 cycle wait condition Pass");
			else 
				$error("16 cycle wait condition Fail");

			//rotate operation error condition
			property rotate_err;
				@(posedge clk)
				disable iff(rst)(CE && INP_VALID == 3 && MODE == 0 && (CMD == 12 || CMD == 13) && OPB[7:4] > 0) |=> ERR;
			endproperty

			assert property(rotate_err)
			$info("Rotate Error Condition Pass");
			else
				$error("Rotate Error Condition Fail");
*/
endinterface


