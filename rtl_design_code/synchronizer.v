`timescale 1ns / 1ps

module synchronizer
#(parameter width=3)
 (input clk,
  input rst_n,
  input [width-1:0] d_in,
  output reg [width-1:0] d_out);
  
  reg [width-1:0] q1;
  
  always @(posedge clk) begin
  if(!rst_n) begin
  q1 <= {width{1'b0}};
  d_out <= {width{1'b0}};
  end else begin
  q1 <= d_in;
  d_out <= q1;
  end
  end
endmodule
