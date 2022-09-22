module pfront_RAM(
		input [18:0] read_address,
		input Clk,

		output logic [3:0] data_Out);
		
logic [3:0] mem [0:1599];
initial
begin
	 $readmemh("sprite/playerfront.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end
endmodule






module pdown_RAM(
		input [18:0] read_address,
		input Clk,

		output logic [3:0] data_Out);
		
logic [3:0] mem [0:1599];
initial
begin
	 $readmemh("sprite/playerback.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end
endmodule




module pleft_RAM(
		input [18:0] read_address,
		input Clk,

		output logic [3:0] data_Out);
		
logic [3:0] mem [0:1599];
initial
begin
	 $readmemh("sprite/playerleft.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end
endmodule





module pright_RAM(
		input [18:0] read_address,
		input Clk,

		output logic [3:0] data_Out);
		
logic [3:0] mem [0:1599];
initial
begin
	 $readmemh("sprite/playerright.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end
endmodule
