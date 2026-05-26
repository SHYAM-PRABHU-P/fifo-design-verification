module FIFO(input  w_en,
            input  r_en,
            input rst,clk,
            input [7:0] w_d,
            output logic [7:0] r_d,
           output full,emt);
  
  logic [3:0]w_ad=0,r_ad=0;
  logic [4:0] cn=0;
  logic [7:0] fifo [15:0];
  
  always @(posedge clk) begin;
    if(rst) begin
      w_ad<=0;
      r_ad<=0;
      cn<=0;
    end
    
    else if(w_en && !full) begin
      fifo[w_ad]<=w_d;
      w_ad<=w_ad+1;
      cn<=cn+1;
      
    end
    
    else if(r_en && !emt) begin
      r_d<=fifo[r_ad];
      r_ad<=r_ad+1;
      cn<=cn-1;
    end
    	
    
  end
  assign emt = (cn==5'd0) ? 1'b1 : 1'b0;
  assign full = (cn==5'd16) ? 1'b1 : 1'b0;
  
endmodule

interface f_in;
  
  logic  w_en;
  logic  r_en;
  logic rst,clk;
  logic [7:0] w_d;
  logic [7:0] r_d;
  logic full,emt;
  
endinterface
