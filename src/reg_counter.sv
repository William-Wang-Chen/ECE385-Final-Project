module reg_counter(
			input VGA_VS, reset, Load,
		  input [7:0] Din, D,
		  output [7:0] Data_out
);

	logic [7:0] data;
	assign data = Din - 8'b0001;
	always_ff @ (posedge VGA_VS)
   begin
		if(reset)
			Data_out <= D;
		if(Load)
			Data_out <= data;
	 end
	 
endmodule
