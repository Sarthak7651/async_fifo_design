`timescale 1ns / 1ps

module fifo_mem
#(parameter depth=8,
  parameter data_width=8,
  parameter ptr_width=$clog2(depth))
 (input wclk,
  input w_en,
  
  input rclk,
  input r_en,
  
  input [ptr_width:0] b_wptr,
  input [ptr_width:0] b_rptr,
  
  input [data_width-1:0] data_in,
  input full,
  input empty,
  
  output reg [data_width-1:0] data_out);
  
  reg [data_width-1:0] fifo [0:depth-1];
  
  always @(posedge wclk) begin
  if(w_en & !full) begin
  fifo[b_wptr[ptr_width-1:0]] <= data_in;
  end
  end
  
  always @(posedge rclk) begin
  if(r_en & !empty) begin
  data_out <= fifo[b_rptr[ptr_width-1:0]];
  end
  end
   
endmodule
