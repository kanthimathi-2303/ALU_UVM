/*`include "uvm_macros.svh"
import uvm_pkg::*;
`include "alu_sequence_item.sv"
*/
class alu_sequence extends uvm_sequence #(alu_sequence_item);

  `uvm_object_utils(alu_sequence)

  function new(string name = "alu_sequence");
    super.new(name);
  endfunction

  virtual task body();
    repeat (`NO_OF_TRANS) begin
      req = alu_sequence_item::type_id::create("req");
      wait_for_grant();
      assert(req.randomize()) else
        `uvm_error("ALU_SEQ", "Randomization failed for req");
      send_request(req);
      wait_for_item_done();
    end
  endtask

endclass

class alu_logical_one_sequence extends uvm_sequence #(alu_sequence_item);

  `uvm_object_utils(alu_logical_one_sequence)

  function new(string name = "alu_logical_one_sequence");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info("ALU_SEQ", "Starting alu_logical_one_sequence", UVM_MEDIUM)

    repeat (`NO_OF_TRANS) begin
      `uvm_do_with(req, {
        CMD inside {[6:11]};
        MODE == 0;
				//CE == 1;
        INP_VALID == 3;
      })
    end
    #50;
    `uvm_info("ALU_SEQ", "Finished alu_logical_one_sequence", UVM_MEDIUM)
  endtask

endclass

class alu_arithmetic_one_sequence extends uvm_sequence #(alu_sequence_item);

  `uvm_object_utils(alu_arithmetic_one_sequence)

  function new(string name = "alu_arithmetic_one_sequence");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info("ALU_SEQ", "Starting alu_arithmetic_one_sequence", UVM_MEDIUM)

    repeat(`NO_OF_TRANS) begin
      `uvm_do_with(req, {
        CMD inside {[4:7]};
        MODE == 1;
        INP_VALID == 3;
      })
    end
    #50;
    `uvm_info("ALU_SEQ", "Finished alu_arithmetic_one_sequence", UVM_MEDIUM)
  endtask

  endclass

class alu_logical_two_sequence extends uvm_sequence #(alu_sequence_item);

  `uvm_object_utils(alu_logical_two_sequence)

  function new(string name = "alu_logical_two_sequence");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info("ALU_SEQ", "Starting alu_logical_two_sequence", UVM_MEDIUM)

    repeat(`NO_OF_TRANS) begin
      `uvm_do_with(req, {
        CMD inside {0,1,2,3,4,5,12,13};
        MODE == 0;
        INP_VALID == 3;
      })
    end
    #50;
    `uvm_info("ALU_SEQ", "Finished alu_logical_two_sequence", UVM_MEDIUM)
  endtask

endclass

class alu_arithmetic_two_sequence extends uvm_sequence #(alu_sequence_item);

  `uvm_object_utils(alu_arithmetic_two_sequence)

  function new(string name = "alu_arithmetic_two_sequence");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info("ALU_SEQ", "Starting alu_arithmetic_two_sequence", UVM_MEDIUM)

    repeat(`NO_OF_TRANS) begin
      `uvm_do_with(req, {
        //CMD inside {0,1,2,3,8,9,10};
				CMD == 0;
				MODE == 1;
        INP_VALID == 3;
      })
    end
    #50;
    `uvm_info("ALU_SEQ", "Finished alu_arithmetic_two_sequence", UVM_MEDIUM)
  endtask

endclass

class alu_delay_16_sequence extends uvm_sequence #(alu_sequence_item);

  `uvm_object_utils(alu_delay_16_sequence)

  function new(string name = "alu_delay_16_sequence");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info("ALU_SEQ", "Starting alu_delay_16_sequence", UVM_MEDIUM)

    repeat(`NO_OF_TRANS) begin
      `uvm_do_with(req, {
        CMD inside {[0:13]};
        MODE inside {1,2};
        INP_VALID inside {[1:3]};
      })
    end
    #50;
    `uvm_info("ALU_SEQ", "Finished alu_delay_16_sequence", UVM_MEDIUM)
  endtask

endclass

class alu_regression extends uvm_sequence#(alu_sequence_item);

  alu_logical_one_sequence     log1_seq;
  alu_arithmetic_one_sequence  arith1_seq;
  alu_logical_two_sequence     log2_seq;
  alu_arithmetic_two_sequence  arith2_seq;
  alu_delay_16_sequence        delay_seq;

  `uvm_object_utils(alu_regression)

  function new(string name = "alu_regression");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_name(), "Starting ALU regression sequence", UVM_MEDIUM)

    `uvm_do(log1_seq)
    `uvm_do(arith1_seq)
    `uvm_do(log2_seq)
    `uvm_do(arith2_seq)
    `uvm_do(delay_seq)
    #50;
    `uvm_info(get_name(), "Completed ALU regression sequence", UVM_MEDIUM)
  endtask

endclass
