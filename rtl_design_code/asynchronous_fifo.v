`timescale 1ns / 1ps

module asynchronous_fifo
#(parameter depth = 8,
  parameter data_width = 8)
 (input  wclk, wrst_n,
  input  rclk, rrst_n,
  input  w_en, r_en,
  input  [data_width-1:0] data_in,
  output [data_width-1:0] data_out,
  output full, empty);

  localparam ptr_width = $clog2(depth);

  wire [ptr_width:0] g_wptr_sync, g_rptr_sync;
  wire [ptr_width:0] b_wptr, b_rptr;
  wire [ptr_width:0] g_wptr, g_rptr;

  // write pointer -> read clock domain
  synchronizer #(.width(ptr_width+1)) sync_wptr (
    .clk(rclk), .rst_n(rrst_n), .d_in(g_wptr), .d_out(g_wptr_sync));

  // read pointer -> write clock domain
  synchronizer #(.width(ptr_width+1)) sync_rptr (
    .clk(wclk), .rst_n(wrst_n), .d_in(g_rptr), .d_out(g_rptr_sync));

  wptr_handler #(.ptr_width(ptr_width)) wptr_h (
    .wclk(wclk), .wrst_n(wrst_n), .w_en(w_en),
    .g_rptr_sync(g_rptr_sync),
    .b_wptr(b_wptr), .g_wptr(g_wptr), .full(full));

  rptr_handler #(.ptr_width(ptr_width)) rptr_h (
    .rclk(rclk), .rrst_n(rrst_n), .r_en(r_en),
    .g_wptr_sync(g_wptr_sync),
    .b_rptr(b_rptr), .g_rptr(g_rptr), .empty(empty));

  fifo_mem #(.depth(depth), .data_width(data_width), .ptr_width(ptr_width)) fifom (
    .wclk(wclk), .w_en(w_en), .rclk(rclk), .r_en(r_en),
    .b_wptr(b_wptr), .b_rptr(b_rptr),
    .data_in(data_in), .full(full), .empty(empty), .data_out(data_out));

endmodule