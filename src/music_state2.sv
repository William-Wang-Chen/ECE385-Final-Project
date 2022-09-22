module music_state2 (
							input logic Clk, Reset,
							input logic INIT_FINISH,
							input logic data_over,
							input logic	bombed_ball,
							input logic	bombed_ball2,
							output logic INIT2,
							output [16:0] address2
							);
							

logic [16:0] address2_new;
logic [3:0] count_new, count;
							
enum logic [2:0] {IDLE, MUSIC_OFF, MUSIC_ON} curr_state, next_state;

always_ff @ (posedge Clk)
begin
        if (Reset)
		  begin
            curr_state <= IDLE;
				address2 <= 17'd0;
				count <= 4'b0;
		  end
		  else
		  begin
            curr_state <= next_state;
				address2 <= address2_new;
				count <= count_new;
		  end
end
			
always_comb
   begin
		INIT2 = 1'b0;
		address2_new = address2;
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
		if ((bombed_ball == 1) || (bombed_ball2 == 1))
			next_state = MUSIC_ON;
		end
	MUSIC_ON:
		begin
		if (Reset)
			next_state = IDLE;
		end
		default: ;
			
	endcase	
		

	case(curr_state)
	IDLE: 
		begin 
			INIT2 = 1'b1;
			address2_new = 17'd0;
		end
	MUSIC_OFF: address2_new = 17'd0;
	MUSIC_ON:
		begin
			if (count < 4'd8)
				count_new = count + 4'd1;
			else if (count < 4'd8)
				count_new = count;
			else 
				count_new = 4'd0;

			if ((address2 < 17'd89494) && data_over && (count == 4'd7))
				address2_new = address2 + 17'd1;
			else if (address2 < 17'd89494)
				address2_new = address2;
			else
				address2_new = 17'd89494;
		end

	default: ;
	endcase	
	end
endmodule
