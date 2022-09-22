module p2front_RAM(
		input [18:0] read_address,
		input Clk,

		output logic [3:0] data_Out);
		
logic [3:0] mem [0:1599];
initial
begin
	 $readmemh("sprite/player2front.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end
endmodule






module p2down_RAM(
		input [18:0] read_address,
		input Clk,

		output logic [3:0] data_Out);
		
logic [3:0] mem [0:1599];
initial
begin
	 $readmemh("sprite/player2back.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end
endmodule




module p2left_RAM(
		input [18:0] read_address,
		input Clk,

		output logic [3:0] data_Out);
		
logic [3:0] mem [0:1599];
initial
begin
	 $readmemh("sprite/player2left.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end
endmodule





module p2right_RAM(
		input [18:0] read_address,
		input Clk,

		output logic [3:0] data_Out);
		
logic [3:0] mem [0:1599];
initial
begin
	 $readmemh("sprite/player2right.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end
endmodule
