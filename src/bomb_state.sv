module bomb_state( input Clk, Reset, VGA_VS,
						input bombstart,
						output bomb_exploding,
						output bomb_exist);

	enum logic [2:0] {IDLE, UNEXPLODED, EXPLODE} curr_state, next_state;

	logic LD_counter1, LD_counter2, reset;
	logic [7:0] counter1, counter2;


   always_ff @ (posedge Clk)
    begin
        if (Reset)
            curr_state <= IDLE;
			else
            curr_state <= next_state;
    end


	always_comb
   begin
     	LD_counter1 = 1'b0;
		LD_counter2 = 1'b0;
		reset = 1'b0;
		bomb_exploding = 1'b0;
		bomb_exist = 1'b0;
		next_state  = curr_state;

	unique case(curr_state)
   IDLE:
		begin
		if (bombstart)
		   next_state = UNEXPLODED;
		end
	UNEXPLODED:
		begin
		if(counter1 == 8'h00)
		   next_state = EXPLODE;
		end
	EXPLODE:
		begin
		if(counter2 == 8'h00)
			begin
				next_state = IDLE;
			end
		end
		default: ;
			
	endcase	
		

	case(curr_state)
	IDLE: 
		begin 
			reset = 1'b1;
			bomb_exploding = 1'b0;
			bomb_exist = 1'b0;
		end
	UNEXPLODED:
		begin
			LD_counter1 = 1'b1;
			bomb_exist = 1'b1;
		end
	EXPLODE:
		begin
			LD_counter2 = 1'b1;
			bomb_exploding = 1'b1;
			bomb_exist = 1'b0;
		end
	default: ;
	endcase	
	end
	
	reg_counter exist_reg(.*, .Load(LD_counter1), .Din(counter1), .D(8'h30), .Data_out(counter1));
	reg_counter explode_reg(.*, .Load(LD_counter2), .Din(counter2), .D(8'h19), .Data_out(counter2));

endmodule
