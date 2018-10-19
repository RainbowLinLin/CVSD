`timescale 1ns/10ps

module fifo (data_i, write_i, read_i, full_o, empty_o, data_o, clk, rst_n);
parameter DWIDTH = 8, FDEPTH = 5;

input wire [DWIDTH-1:0] data_i;
input wire write_i, read_i;
output full_o, empty_o;
output reg [DWIDTH-1:0] data_o;
input wire clk, rst_n;


reg [2:0]j, n_j;
reg [DWIDTH-1:0] n_data;
reg [DWIDTH-1:0] mem [FDEPTH-1:0];
reg [DWIDTH-1:0] n_mem [FDEPTH-1:0];

assign empty_o = j == 0 ? 1 : 0;
assign full_o = j >= (FDEPTH) ? 1 : 0;

// should consider the condition of (write_i && read_i), (write_i), (read_i) 
always@(*) begin
	n_j = j;
	//n_data = data_o;
	data_o = 0;
	n_mem[0] = mem[0];
	n_mem[1] = mem[1];
	n_mem[2] = mem[2];
	n_mem[3] = mem[3];
	n_mem[4] = mem[4];
	
	if(write_i && read_i)begin
		data_o = mem[0];
		case(j)
			1:begin
				n_mem[0] = data_i;
				n_mem[1] = 0;
				n_mem[2] = 0;
				n_mem[3] = 0;
				n_mem[4] = 0;
			end
			2:begin
				n_mem[0] = mem[1];
				n_mem[1] = data_i;
				n_mem[2] = 0;
				n_mem[3] = 0;
				n_mem[4] = 0;
			end
			3:begin
				n_mem[0] = mem[1];
				n_mem[1] = mem[2];
				n_mem[2] = data_i;
				n_mem[3] = 0;
				n_mem[4] = 0;
			end
			4:begin
				n_mem[0] = mem[1];
				n_mem[1] = mem[2];
				n_mem[2] = mem[3];
				n_mem[3] = data_i;
				n_mem[4] = 0;
			end
			5:begin
				n_mem[0] = mem[1];
				n_mem[1] = mem[2];
				n_mem[2] = mem[3];
				n_mem[3] = mem[4];
				n_mem[4] = data_i;
			end
		endcase
		n_j = j;
	end
	else if(!write_i && read_i)begin
		data_o = mem[0];
		n_mem[0] = mem[1];
		n_mem[1] = mem[2];
		n_mem[2] = mem[3];
		n_mem[3] = mem[4];
		n_mem[4] = 0;
		n_j = j - 1;
	end
	else if(write_i && !read_i)begin
		data_o = 0;
		n_mem[j] = data_i;
		n_j = j + 1;
	end
	 
end

always @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
		//data_o <= 0;
		j <= 0;
		mem[0] <= 0;
		mem[1] <= 0;
		mem[2] <= 0;
		mem[3] <= 0;
		mem[4] <= 0;
	end
	else begin
		//data_o <= n_data;
		j <= n_j;
		mem[0] <= n_mem[0];
		mem[1] <= n_mem[1];
		mem[2] <= n_mem[2];
		mem[3] <= n_mem[3];
		mem[4] <= n_mem[4];
	end
end

endmodule
