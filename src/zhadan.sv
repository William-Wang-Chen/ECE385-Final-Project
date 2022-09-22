module zhadan_RAM(
		input [18:0] read_address,
		input Clk,

		output logic [3:0] data_Out);
		
logic [3:0] mem [0:1599];
initial
begin
	 $readmemh("sprite/zhadan.txt", mem);
end


always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address];
end
endmodule
