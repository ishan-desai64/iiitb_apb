

module apb_testbench;

  reg  core_clk;
  reg  sys_reset;

  reg [7:0]  addr;
  reg [31:0] data;
  reg        data_valid;
  reg        data_dir;
  reg [31:0] wait_cycle;
  wire [31:0] read_out_data;
  wire        transaction_done;
   
   
  wire apb_ready;
  wire apb_selx;
  wire apb_en;
  wire apb_write;
  wire [7:0]apb_addr;
  wire [31:0]apb_rdata;
  wire [31:0]apb_wdata;
 
  // Initial block for generating the clock
  initial
  begin
    core_clk = 0;

    while(1)
    begin
       #5 core_clk = ~core_clk;
    end
  end

  // Initial block for asserting & de-asserting the reset
  initial
  begin
    sys_reset = 1;
    #50
    sys_reset = 0;
  end

   apb_master master(
      // System interface
      .addr(addr),
 .data_valid(data_valid),
      .data (data),
      .data_dir (data_dir),
      .transaction_done(transaction_done),
      .read_out_data(read_out_data),
      // APB interface signals
     .apb_clk(core_clk),
      .apb_reset(sys_reset),
      .apb_write(apb_write),
      .apb_selx(apb_selx),
      .apb_en(apb_en),
      .apb_wdata(apb_wdata),
      .apb_rdata(apb_rdata),
      .apb_ready(apb_ready),
     .apb_addr(apb_addr)
           );
   apb_slave slave(
       .apb_clk(core_clk),
       .apb_reset(sys_reset),
       .apb_addr(apb_addr),
       .apb_write(apb_write),
       .apb_en(apb_en),
       .apb_wdata(apb_wdata),
  .apb_rdata(apb_rdata),
       .apb_selx(apb_selx),
     .apb_ready(apb_ready),
     .wait_cycle(wait_cycle)
    );


  // initial block to end the simulation
  initial
  begin
    #500;
    $finish;
  end
 
   
 
   // Test the transaction
   initial
   begin  
 `ifdef TEST1_WR_RD
     @(negedge sys_reset);
     data = 10;
     addr = 4;
     data_dir=1;
     data_valid=1;
     @(posedge transaction_done);
     data_valid=0;

     data = 12;
     addr = 5;
     data_dir=1;
     data_valid=1;
     @(posedge transaction_done);
     data_valid=0;

     data = 12;
     addr = 4;
     data_dir=0;
     data_valid=1;
     @(posedge transaction_done);
     data_valid=0;
   
     
     data = 12;
     addr = 5;
     data_dir=0;
     data_valid=1;
     @(posedge transaction_done);
     data_valid=0;
`endif
     
`ifdef TEST2_SLV_ERR_WR
     data = 12;
     addr = 100;
     data_dir=0;
     data_valid=1;
     @(posedge transaction_done);
     data_valid=0;  
`endif

`ifdef TEST3_SLV_ERR_RD
     data = 12;
     addr = 100;
     data_dir=1;
     data_valid=1;
     @(posedge transaction_done);
     data_valid=0;  
`endif
     
`ifdef TEST4_TIMEOUT
     #15
     data = 12;
     addr = 1;
     data_dir=1;
     data_valid=1;
     @(posedge transaction_done);
     data_valid=0;
`endif
     

   end
  initial
  begin
    #500;
    $finish;
  end
  initial
   begin
       $dumpfile("dump.vcd");
     $dumpvars(0,apb_testbench);
   end

 
endmodule
