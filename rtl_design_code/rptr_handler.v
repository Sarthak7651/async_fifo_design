`timescale 1ns / 1ps

module rptr_handler
#(parameter ptr_width=3)
 (input rclk,
  input rrst_n,
  input r_en,
  input [ptr_width:0] g_wptr_sync,
  output reg [ptr_width:0] b_rptr,
  output reg [ptr_width:0] g_rptr,
  output reg empty);
  
  wire [ptr_width:0] b_rptr_next;
  wire [ptr_width:0] g_rptr_next;
  wire rempty;
  assign b_rptr_next = b_rptr + (r_en & !empty);
  assign g_rptr_next = b_rptr_next ^ (b_rptr_next>>1);
  assign rempty = (g_rptr_next == g_wptr_sync);
  
  always @(posedge rclk or negedge rrst_n) begin
  if(!rrst_n) begin
  b_rptr <= 0;
  g_rptr <= 0;
  end else begin
  b_rptr <= b_rptr_next;
  g_rptr <= g_rptr_next;
  end
  end
  
  always @(posedge rclk or negedge rrst_n) begin
  if(!rrst_n) empty <= 1'b1;
  else empty <= rempty;
  end
      
endmodule
