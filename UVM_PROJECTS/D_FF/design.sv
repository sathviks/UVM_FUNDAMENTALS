module dff
  (
    input clk, rst, din, ////din - data input, rst - active high synchronus
    output reg dout ////dout - data output
  );
  
  always@(posedge clk)
    begin
      if(rst == 1'b1) 
        dout <= 1'b0;
      else
        dout <= din;
    end
  
endmodule