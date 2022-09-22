module start_RAM(
		input Clk,
		input [9:0] DrawX, DrawY,

		output logic [3:0] data_Out);
		
logic [3:0] mem [0:76799];
logic [18:0] read_address_start;
int half;
		
initial
begin
	 $readmemh("sprite/start.txt", mem);
end

assign half = 10'd320;
assign read_address_start = DrawY/2*half + DrawX/2;

always_ff @ (posedge Clk) begin
	data_Out<= mem[read_address_start];
end
endmodule
