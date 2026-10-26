`timescale 1ns / 1ps

module wptr_handler
#(parameter ptr_width=3)
 (input wclk,
  input wrst_n,
  input w_en,
  input [ptr_width:0] g_rptr_sync,
  output reg [ptr_width:0] b_wptr,
  output reg [ptr_width:0] g_wptr,
  output reg full);
  
  wire [ptr_width:0] b_wptr_next;
  wire [ptr_width:0] g_wptr_next;
  
  //reg wrap_around;
  wire wfull;
  
  assign b_wptr_next = b_wptr + (w_en & !full);
  assign g_wptr_next = b_wptr_next ^ (b_wptr_next>>1);
  
  always @(posedge wclk or negedge wrst_n) begin
  if(!wrst_n) begin
  b_wptr <= 0;
  g_wptr <= 0;
  end else begin
  b_wptr <= b_wptr_next;
  g_wptr <= g_wptr_next;
  end
  end
  
  always @(posedge wclk or negedge wrst_n) begin
  if(!wrst_n) full <= 0;
  else full <= wfull;
  end
  
  assign wfull=(g_wptr_next == {~g_rptr_sync[ptr_width:ptr_width-1],g_rptr_sync[ptr_width-2:0]});
  
endmodule
