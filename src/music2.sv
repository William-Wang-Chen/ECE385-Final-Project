module music2 (input logic 				Clk,
				  input logic 	[16:0] 	address2,   
				  output logic [15:0] 	music_content2);

	logic [15:0] music_memory[0:89494];
	initial
	begin
		$readmemh("yaobaiyang.txt", music_memory);
	end
	
	always_ff @ (posedge Clk)
		begin
			music_content2 <= music_memory[address2];
		end
endmodule