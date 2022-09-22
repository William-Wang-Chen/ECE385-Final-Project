module music (input logic 				Clk,
				  input logic 	[15:0] 	address,   
				  output logic [15:0] 	music_content);

	logic [15:0] music_memory[0:37043];
	initial
	begin
		$readmemh("bombsound.txt", music_memory);
	end
	
	always_ff @ (posedge Clk)
		begin
			music_content <= music_memory[address];
		end
endmodule
