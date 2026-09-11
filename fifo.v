`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.09.2026 23:52:41
// Design Name: 
// Module Name: fifo
// Project Name: Dual Clock FIFO
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo(clk_r,clk_w,rst,buf_in,buf_out,wr_en,rd_en,buf_empty,buf_full,fifo_counter

    );
    input rst,clk_r,clk_w,wr_en,rd_en;
    input [7:0] buf_in;             // data being written
    output reg [7:0] buf_out;       // data being read
    output reg buf_empty,buf_full;  // 1 bit each flags to indicate if buffer is empty or full
    output reg [6:0] fifo_counter;  // 7 bit counter to show no. of elements currently stored
    
    reg [5:0] rd_ptr;               // 6 bit read pointer
    reg [5:0] wr_ptr;               // 6 bit write pointer
    reg [7:0] buf_mem [63:0];       // 64 bit memory to store 8 bit data in each cell
    
    always@ ( fifo_counter) begin          // checks flags
        buf_empty=(fifo_counter==0);
        buf_full=(fifo_counter==64);
        end
        
    always@(posedge clk_w or posedge rst) begin // manages fifo counter for reset clock and write operation
    if(rst)
        fifo_counter<=0;
        
    else if (!buf_full && wr_en)
        fifo_counter <= fifo_counter +1;
    else
        fifo_counter<=fifo_counter;
    end
    
    always@(posedge clk_r) begin             // manages fifo counter for read operation
        if(!buf_empty && rd_en)
            fifo_counter<=fifo_counter-1;
        else 
            fifo_counter<=fifo_counter;  
    end 
    
    always@(posedge clk_r or posedge rst) begin    // to fetch or read data from FIFO
        if(rst)
            buf_out=0;
        else begin
            if(!buf_empty && rd_en)
                buf_out<=buf_mem[rd_ptr];
        else 
            buf_out<=buf_out;
        end
     end
     
     always@(posedge clk_w) begin       // to write data in FIFO
        if(!buf_full && wr_en)
            buf_mem[wr_ptr]<=buf_in;
        else 
            buf_mem[wr_ptr]<=buf_mem[wr_ptr];
     end
     
     
     always@(posedge clk_w or posedge rst) begin      // to manage the write pointer
     if(rst)
        wr_ptr<=0;
     else if (!buf_full && wr_en)
        wr_ptr<=wr_ptr+1;
     else 
     wr_ptr<=wr_ptr;
    
    end
    
    always@(posedge clk_r or posedge rst) begin      // to manage the read pointer
     if(rst)
        rd_ptr<=0;
     else if (!buf_empty && rd_en)
        rd_ptr<=rd_ptr+1;
     else 
     rd_ptr<=rd_ptr;
    
    end
    
        
    
    
    
    
    
    
endmodule
