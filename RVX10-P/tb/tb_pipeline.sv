// This is your new main testbench file.
// It's almost identical to the 'testbench' module from your old file,
// but it instantiates your new 'top' module.

module testbench();

  logic        clk;
  logic        reset;

  logic [31:0] WriteData, DataAdr;
  logic        MemWrite;

  // instantiate device to be tested (which now includes the memories)
  top dut(clk, reset, WriteData, DataAdr, MemWrite);
  
  // initialize test
  initial
    begin
      reset <= 1; # 22; reset <= 0;
      
      // Add a timeout in case the pipeline fails
      #2000; // 2000 time units
      $display("Simulation failed (Timeout)");
      $stop;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 5; clk <= 0; # 5; // 10ns clock cycle
    end

  // check results - This logic is UNCHANGED from your original testbench.
  always @(negedge clk)
    begin
      if (!reset && MemWrite) begin // Only check after reset
        if(DataAdr === 100 & WriteData === 25) begin
          $display("Simulation succeeded");
          $stop;
        end else if (DataAdr !== 96) begin
          // This fails if it writes to any address other than 96 (first write)
          // or 100 (final write).
          $display("Simulation failed: Wrote %d to adr %d", WriteData, DataAdr);
          $stop;
        end
      end
    end
endmodule

