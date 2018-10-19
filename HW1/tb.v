`timescale 1ns/10ps
`define CYCLE      10.00         	 // Modify your clock period here
`define End_CYCLE  100000            // Modify cycle times once your design need more cycle times!
`define PAT1        "./pattern1.dat" // Master1 output data   
`define PAT2        "./pattern2.dat" // Master2 output data
`define EXP        "./golden1.dat"   // Memory stored data (ground truth), is used to verified your designed


module tb;

parameter DWIDTH = 8;

reg clk;
reg rst_n;
reg [DWIDTH-1:0] data1_i;
reg [DWIDTH-1:0] data2_i;
reg valid1_i;
reg valid2_i;
reg gnt_i;

wire [DWIDTH-1:0] data_o;
wire req_o;
wire stop1_o;
wire stop2_o;
wire valid_o;

reg [DWIDTH-1:0] pattern1 [49:0];
reg [DWIDTH-1:0] pattern2 [49:0];
reg [DWIDTH-1:0] golden [99:0];
reg [DWIDTH-1:0] data [99:0];
integer correct, error, i, j, count, k, a, seed;

path   uut(.clk(clk), .rst_n(rst_n), .data1_i(data1_i), .data2_i(data2_i), 
           .valid1_i(valid1_i), .valid2_i(valid2_i), .data_o(data_o), 
           .req_o(req_o), .gnt_i(gnt_i), .stop1_o(stop1_o), .stop2_o(stop2_o), .valid_o(valid_o));

always #(`CYCLE/2) clk = ~clk;

always@(negedge clk)begin
	
	k = {$random(seed)}%10;
	
	if(req_o && (k > 2)) gnt_i <= 1;
	else gnt_i <= 0;
	
	if((i < 50 || j < 51))begin
		if (!stop1_o && (k < 6) && (i < 50)) begin
			data1_i <= pattern1[i];
			valid1_i <= 1;
			i <= i + 1;
		end
		else valid1_i <= 0;
		
		if (!stop2_o && (k < 6) && (j < 50)) begin
			data2_i <= pattern2[j];
			valid2_i <= 1;
			j <= j + 1;
		end
		else valid2_i <= 0;
	end
	
	if (valid_o) begin
		data[count] <= data_o;
		count <= count + 1;
	end
end

initial begin
	$fsdbDumpfile("tb.fsdb");
	$fsdbDumpvars;

	$readmemb(`PAT1, pattern1);
	$readmemb(`PAT2, pattern2);
	$readmemb(`EXP, golden);
	
	clk = 1;
	rst_n = 0;
	data1_i = 0;
	data2_i = 0;
	valid1_i = 0;
	valid2_i = 0;
	gnt_i = 0;
	count = 0;
	correct = 0;
	error = 0;
	i = 0;
	j = 0;
	k = 0;
	seed = 3;
	
	#`CYCLE; rst_n = 1;
	
	wait(count == 99)
    begin
		#50
		for (a=0; a<100; a=a+1) begin
			if (golden[a] == data[a]) begin
				$display("Correct : data =%d, golden=%d",data[a],golden[a]);
				correct = correct + 1;
			end
			else begin
				$display("Error : data =%d, golden=%d",data[a],golden[a]);
				error = error + 1;
			end
		end
		$display("Correct :%d , Error :%d",correct,error);
		$finish;
	end
end

endmodule
