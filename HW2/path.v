`timescale 1ns/10ps

module path(clk, rst_n, data1_i, data2_i, valid1_i, valid2_i, data_o, req_o, gnt_i, stop1_o, stop2_o, valid_o);

parameter DWIDTH = 8;
parameter FDEPTH = 5;
input clk;
input rst_n;
input [DWIDTH-1:0] data1_i;
input [DWIDTH-1:0] data2_i;
input valid1_i;
input valid2_i;
input gnt_i;
output req_o;
output reg stop1_o;
output reg stop2_o;
output reg [DWIDTH-1:0] data_o;
output reg valid_o;


wire [DWIDTH-1:0] fifo_o;
wire full, empty, valid_i, almost_full;
wire bypass;
wire read_i;
wire write_i;
wire [DWIDTH-1:0] data_i;

reg n_req_o;
reg n_stop1_o;
reg n_stop2_o;
reg [DWIDTH-1:0] n_data_o;
reg n_valid_o; 

reg [3:0]count;
reg [3:0]n_count;
reg switch,n_switch;

reg [DWIDTH-1:0]n_data_i;
//reg n_write_i;

assign valid_i = valid1_i || valid2_i;
assign bypass = empty && gnt_i && valid_i;
assign data_i = n_data_i;
assign read_i = !empty && gnt_i;
assign write_i = !bypass && ((!switch && valid1_i && !stop1_o) || (switch && valid2_i && !stop2_o));
assign req_o = !empty || bypass;

always@(*) begin
	//n_stop1_o = stop1_o;
	//n_stop2_o = stop2_o;
	n_data_o =  data_o;
	n_valid_o = valid_o;
	n_count = count;
	n_switch = switch;
	
	if(full && !read_i) begin
		stop1_o = 1;
		stop2_o = 1;
	end
	else begin
		if(switch)begin
			stop1_o = 1;
			stop2_o = 0;
		end
		else begin
			stop1_o = 0;
			stop2_o = 1;
		end
	end
	
	if(!switch && valid1_i && !stop1_o)begin
		n_data_i = data1_i;
		
		if(count == 9)begin
			n_count = 0;
			n_switch = 1;
		end
		else begin
			n_count = count + 1;
			n_switch = 0;
		end
	end
	else if(switch && valid2_i && !stop2_o)begin
		n_data_i = data2_i;
		
		if(count == 9)begin
			n_count = 0;
			n_switch = 0;
		end
		else begin
			n_count = count + 1;
			n_switch = 1;
		end
	end
	else begin
		n_data_i = 0;
		n_count = count;
		n_switch = switch;
	end
	
	/*if(full && read_i) begin
		if(!switch) begin n_stop1_o = 0;n_stop2_o = 1; end
		else begin n_stop1_o = 1;n_stop2_o = 0;end
	end
	else if(full && !read_i) begin
		n_stop1_o = 1;
		n_stop2_o = 1;
	end
	else if(!full)begin
		if(stop1_o && stop2_o)begin
			if(!switch) begin n_stop1_o = 0;n_stop2_o = 1; end
			else begin n_stop1_o = 1;n_stop2_o = 0;end
		end
		else if(!switch && valid1_i && !stop1_o && count == 9)begin
			n_stop1_o = 1;
			n_stop2_o = 0;
		end
		else if(switch && valid2_i && !stop2_o && count == 9)begin
			n_stop1_o = 0;
			n_stop2_o = 1;
		end
	end
	else begin
		n_stop1_o = stop1_o;
		n_stop2_o = stop2_o;
	end*/
	
	
	
	if(bypass)begin
		n_data_o =  n_data_i;
		n_valid_o = 1;
	end
	else if(read_i)begin
		n_data_o = fifo_o;
		n_valid_o = 1;
	end
	else begin
		n_data_o = data_o;
		n_valid_o = 0;
	end
end

always@(posedge clk, negedge rst_n)	begin
    if (!rst_n) begin
		//stop1_o <= 0;
		//stop2_o <= 1;
		data_o <= 0;
		valid_o <= 0;
		count <= 0;
		switch <= 0;
	end else begin
		//stop1_o <= n_stop1_o;
		///stop2_o <= n_stop2_o;
		data_o <=  n_data_o;
		valid_o <= n_valid_o;
		count <= n_count;
		switch <= n_switch;
	end
end

fifo fifo_inst (.data_i(data_i), .write_i(write_i), .read_i(read_i),
                .full_o(full), .empty_o(empty),
                .data_o(fifo_o), .clk(clk), .rst_n(rst_n));

endmodule