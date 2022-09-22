module music_state (
							input logic Clk, Reset,
							input logic INIT_FINISH,
							input logic data_over,
							input logic	bomb_exploding,
							input logic	bomb_exploding2,
							output logic INIT,
							output [15:0] address
							);
							

logic [15:0] address_new;
logic [3:0] count_new, count;
							
enum logic [2:0] {IDLE, MUSIC_OFF, MUSIC_ON} curr_state, next_state;

always_ff @ (posedge Clk)
begin
        if (Reset)
		  begin
            curr_state <= IDLE;
				address <= 16'd0;
				count <= 4'b0;
		  end
		  else
		  begin
            curr_state <= next_state;
				address <= address_new;
				count <= count_new;
		  end
end
			
always_comb
   begin
		INIT = 1'b0;
		address_new = address;
		count_new = count;
		next_state  = curr_state;

	unique case(curr_state)
	IDLE:
		begin
		if (INIT_FINISH)
			next_state = MUSIC_OFF;
		end
	MUSIC_OFF:
		begin
		if ((bomb_exploding == 1) || (bomb_exploding2 == 1))
			next_state = MUSIC_ON;
		end
	MUSIC_ON:
		begin
		if ((bomb_exploding == 0) && (bomb_exploding2 == 0))
			next_state = MUSIC_OFF;
		end
		default: ;
			
	endcase	
		

	case(curr_state)
	IDLE: 
		begin 
			INIT = 1'b1;
			address_new = 16'd0;
		end
	MUSIC_OFF: address_new = 16'd0;
	MUSIC_ON:
		begin
			if (count < 4'd11)
				count_new = count + 4'd1;
			else if (count < 4'd11)
				count_new = count;
			else 
				count_new = 4'd0;

			if ((address < 16'd37043) && data_over && (count == 4'd10))
				address_new = address + 16'd1;
			else if (address < 16'd37043)
				address_new = address;
			else
				address_new = 16'd37043;
		end

	default: ;
	endcase	
	end
endmodule
