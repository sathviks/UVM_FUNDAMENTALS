// Code your design here
`timescale 1ns / 1ps

module alu( 
           input clock,reset,
           input [7:0] a,b,  // ALU 8-bit Inputs                 
           input [3:0] ALU_Sel,// ALU Selection
           output reg [8:0] ALU_Out // ALU 9-bit Output with carry
    );
  reg [8:0] ALU_Result;
  
  always @(posedge clock or posedge reset) begin
    if(reset) begin
      ALU_Out  <= 8'd0;
    
    end
    else begin
      ALU_Out <= ALU_Result;
    end
  end
  always @(*)
    begin
        case(ALU_Sel)
        4'b0000: // Addition
           ALU_Result =a+b; 
        4'b0001: // Subtraction
           ALU_Result =a-b;
        4'b0010: // Multiplication
           ALU_Result =a* b;
        4'b0011: // Division
           ALU_Result = a/b;
        4'b0100: // Logical shift left
           ALU_Result = a<<1;
         4'b0101: // Logical shift right
           ALU_Result = a>>1;
          4'b1000: //  Logical and 
           ALU_Result =a & b;
          4'b1001: //  Logical or
           ALU_Result =a| b;
          4'b1010: //  Logical xor 
           ALU_Result =a^ b;
          4'b1011: //  Logical nor
           ALU_Result = ~(a | b);
          4'b1100: // Logical nand 
           ALU_Result = ~(a & b);
          4'b1101: // Logical xnor
           ALU_Result = ~(a ^ b);
          4'b1110: // Greater comparison
           ALU_Result = (a>b)?8'd1:8'd0 ;
          4'b1111: // Equal comparison   
            ALU_Result = (a==b)?8'd1:8'd0 ;
          default: ALU_Result =a+b; 
        endcase
    end
endmodule
