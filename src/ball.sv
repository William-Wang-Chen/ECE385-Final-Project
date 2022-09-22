//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------


module  ball ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,       // Current pixel coordinates
					input	[7:0]		  keycode,
					input 		  bomb_exist,
					input			  bomb_exploding,
					output logic  start,
               output logic  is_ball,             // Whether current pixel belongs to ball or background
					output logic  is_bomb,
					output logic  is_wall1,
					output logic  is_wall2,
					output logic  is_wall3,
					output logic  is_wall4,
					output logic  is_wall5,
					output logic  is_wall6,
					output logic  is_wall7,
					output logic  is_wall8,
					output logic  is_wall9,
					output logic  is_wall10,
					output logic  is_wall11,
					output logic  is_wall12,
					output logic  is_fire,
					output logic  is_shoe1,
					output logic  bombstart,
					output logic  bombed_wall1,
					output logic  bombed_wall2,
					output logic  bombed_wall3,
					output logic  bombed_wall4,
					output logic  bombed_wall5,
					output logic  bombed_wall6,
					output logic  bombed_wall7,
					output logic  bombed_wall8,
					output logic  bombed_wall9,
					output logic  bombed_wall10,
					output logic  bombed_wall11,
					output logic  bombed_wall12,
					output logic  shoe_on1,
					output logic  leftgraph,
					output logic  rightgraph,
					output logic  upgraph,
					output logic  downgraph,
					output logic [9:0]		Bomb_X_Center,
					output logic [9:0]		Bomb_Y_Center,
					output logic [9:0] Ball_X_Pos,
					output logic [9:0] Ball_Y_Pos,
					input logic  bombed_wall1_2,
					input logic  bombed_wall22,
					input logic  bombed_wall32,
					input logic  bombed_wall42,
					input logic  bombed_wall52,
					input logic  bombed_wall62,
					input logic  bombed_wall72,
					input logic  bombed_wall82,
					input logic  bombed_wall92,
					input logic  bombed_wall102,
					input logic  bombed_wall112,
					input logic  bombed_wall122,
					output logic [18:0] read_address,
					output logic [18:0] read_address_shoe,
					output logic [18:0] read_address_wall1,
					output logic [18:0] read_address_bomb,
					input logic  shoe_on2
              );
    
    parameter [9:0] Ball_X_Center = 10'd320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center = 10'd240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max = 10'd479;     // Bottommost point on the Y axis
	 logic [9:0] Ball_X_Step, Ball_Y_Step;
    assign Ball_X_Step = (shoe_on1 == 1)? 10'd7 : 10'd5;      // Step size on the X axis
    assign Ball_Y_Step = (shoe_on1 == 1)? 10'd7 : 10'd5;      // Step size on the Y axis
    parameter [9:0] Ball_Size = 10'd20;        // Ball size
	 //wall
	 parameter [9:0] Wall_X_Center1 = 10'd240;
	 parameter [9:0] Wall_X_Center2 = 10'd320;
	 parameter [9:0] Wall_X_Center3 = 10'd400;
	 parameter [9:0] Wall_X_Center4 = 10'd240;
	 parameter [9:0] Wall_X_Center5 = 10'd320;
	 parameter [9:0] Wall_X_Center6 = 10'd400;
	 parameter [9:0] Wall_X_Center7 = 10'd100;
	 parameter [9:0] Wall_X_Center8 = 10'd100;
	 parameter [9:0] Wall_X_Center9 = 10'd100;
	 parameter [9:0] Wall_X_Center10 = 10'd540;
	 parameter [9:0] Wall_X_Center11 = 10'd540;
	 parameter [9:0] Wall_X_Center12 = 10'd540;
	 parameter [9:0] Wall_Y_Center1 = 10'd320;
	 parameter [9:0] Wall_Y_Center2 = 10'd320;
	 parameter [9:0] Wall_Y_Center3 = 10'd320;
	 parameter [9:0] Wall_Y_Center4 = 10'd160;
	 parameter [9:0] Wall_Y_Center5 = 10'd160;
	 parameter [9:0] Wall_Y_Center6 = 10'd160;
	 parameter [9:0] Wall_Y_Center7 = 10'd80;
	 parameter [9:0] Wall_Y_Center8 = 10'd240;
	 parameter [9:0] Wall_Y_Center9 = 10'd400;
	 parameter [9:0] Wall_Y_Center10 = 10'd80;
	 parameter [9:0] Wall_Y_Center11 = 10'd240;
	 parameter [9:0] Wall_Y_Center12 = 10'd400;
	 //shoe
	 parameter [9:0] Shoe_X_Center1 = 10'd240;
	 parameter [9:0] Shoe_Y_Center1 = 10'd320;
	 
	 parameter [9:0] Fire_Size = 10'd20;
	 parameter [9:0] Wall_Size = 10'd20;
	 parameter [9:0] Bomb_Size = 10'd20;
	 parameter [9:0] Shoe_Size = 10'd20;
    
    logic [9:0] Ball_X_Motion, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	 logic is_stop;
	 
    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= 10'd0;
        end
        else
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
        end
    end
    always_ff @ (posedge Clk)
    begin
				if ((keycode == 8'h2c) && (bomb_exist == 0) && (bomb_exploding == 0))
				begin
					bombstart = 1'b1;
					Bomb_X_Center = Ball_X_Pos;
					Bomb_Y_Center = Ball_Y_Pos;
				end		
				else
					bombstart = 1'b0;
	 end
	 
    //////// Do not modify the always_ff blocks. ////////
    assign is_stop = ~((keycode == 8'h04) || (keycode == 8'h07) || (keycode == 8'h1a) || (keycode == 8'h16));
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
        Ball_X_Motion_in = Ball_X_Motion;
        Ball_Y_Motion_in = Ball_Y_Motion;
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin
				case(keycode)
					8'h04: begin//A
								Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
								Ball_Y_Motion_in = 10'h000;
							end
					8'h07: begin//D
								Ball_X_Motion_in = Ball_X_Step;
								Ball_Y_Motion_in = 10'h000;
							end
					8'h1a: begin//W
								Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);
								Ball_X_Motion_in = 10'h000;
							end
					8'h16: begin//S
								Ball_Y_Motion_in = Ball_Y_Step;
								Ball_X_Motion_in = 10'h000;
							end
					default:
						begin
						end
				endcase
            // Be careful when using comparators with "logic" datatype because compiler treats 
            //   both sides of the operator as UNSIGNED numbers.
            // e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
            // If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
            
				if (is_stop)
				begin
					Ball_Y_Motion_in = 10'h000;
					Ball_X_Motion_in = 10'h000;
				end
				//Boundary
				if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max)
				begin
					if(keycode == 8'h16)
						Ball_Y_Motion_in = 10'h000;
				end
            else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size)
				begin
					if(keycode == 8'h1a)
						Ball_Y_Motion_in = 10'h000;
				end
            if( Ball_X_Pos + Ball_Size >= Ball_X_Max)
				begin
					if(keycode == 8'h07)
						Ball_X_Motion_in = 10'h000;
				end
            else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size)
				begin
					if(keycode == 8'h04)
						Ball_X_Motion_in = 10'h000;
				end
				//Wall1
				if((Ball_Y_Pos <= Wall_Y_Center1) && (Ball_Y_Pos >= Wall_Y_Center1 - 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center1 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center1 - 2*Ball_Size) && (bombed_wall1 == 1'b0) && (bombed_wall1_2 == 1'b0))
				begin
					if(keycode == 8'h16)
						Ball_Y_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos >= Wall_Y_Center1) && (Ball_Y_Pos <= Wall_Y_Center1 + 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center1 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center1 - 2*Ball_Size) && (bombed_wall1 == 1'b0) && (bombed_wall1_2 == 1'b0))
				begin
					if(keycode == 8'h1a)
						Ball_Y_Motion_in = 10'h000;
				end
            if((Ball_Y_Pos > Wall_Y_Center1 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center1 + 2*Ball_Size) && (Ball_X_Pos <= Wall_X_Center1) && (Ball_X_Pos >= Wall_X_Center1 - 2*Ball_Size) && (bombed_wall1 == 1'b0) && (bombed_wall1_2 == 1'b0))
				begin
					if(keycode == 8'h07)
						Ball_X_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos > Wall_Y_Center1 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center1 + 2*Ball_Size) && (Ball_X_Pos >= Wall_X_Center1) && (Ball_X_Pos <= Wall_X_Center1 + 2*Ball_Size) && (bombed_wall1 == 1'b0) && (bombed_wall1_2 == 1'b0))
				begin
					if(keycode == 8'h04)
						Ball_X_Motion_in = 10'h000;
				end
				//Wall2
				if((Ball_Y_Pos <= Wall_Y_Center2) && (Ball_Y_Pos >= Wall_Y_Center2 - 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center2 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center2 - 2*Ball_Size) && (bombed_wall2 == 1'b0) && (bombed_wall22 == 1'b0))
				begin
					if(keycode == 8'h16)
						Ball_Y_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos >= Wall_Y_Center2) && (Ball_Y_Pos <= Wall_Y_Center2 + 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center2 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center2 - 2*Ball_Size) && (bombed_wall2 == 1'b0) && (bombed_wall22 == 1'b0))
				begin
					if(keycode == 8'h1a)
						Ball_Y_Motion_in = 10'h000;
				end
            if((Ball_Y_Pos > Wall_Y_Center2 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center2 + 2*Ball_Size) && (Ball_X_Pos <= Wall_X_Center2) && (Ball_X_Pos >= Wall_X_Center2 - 2*Ball_Size) && (bombed_wall2 == 1'b0) && (bombed_wall22 == 1'b0))
				begin
					if(keycode == 8'h07)
						Ball_X_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos > Wall_Y_Center2 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center2 + 2*Ball_Size) && (Ball_X_Pos >= Wall_X_Center2) && (Ball_X_Pos <= Wall_X_Center2 + 2*Ball_Size) && (bombed_wall2 == 1'b0) && (bombed_wall22 == 1'b0))
				begin
					if(keycode == 8'h04)
						Ball_X_Motion_in = 10'h000;
				end
				//Wall3
				if((Ball_Y_Pos <= Wall_Y_Center3) && (Ball_Y_Pos >= Wall_Y_Center3 - 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center3 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center3 - 2*Ball_Size) && (bombed_wall3 == 1'b0) && (bombed_wall32 == 1'b0))
				begin
					if(keycode == 8'h16)
						Ball_Y_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos >= Wall_Y_Center3) && (Ball_Y_Pos <= Wall_Y_Center3 + 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center3 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center3 - 2*Ball_Size) && (bombed_wall3 == 1'b0) && (bombed_wall32 == 1'b0))
				begin
					if(keycode == 8'h1a)
						Ball_Y_Motion_in = 10'h000;
				end
            if((Ball_Y_Pos > Wall_Y_Center3 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center3 + 2*Ball_Size) && (Ball_X_Pos <= Wall_X_Center3) && (Ball_X_Pos >= Wall_X_Center3 - 2*Ball_Size) && (bombed_wall3 == 1'b0) && (bombed_wall32 == 1'b0))
				begin
					if(keycode == 8'h07)
						Ball_X_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos > Wall_Y_Center3 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center3 + 2*Ball_Size) && (Ball_X_Pos >= Wall_X_Center3) && (Ball_X_Pos <= Wall_X_Center3 + 2*Ball_Size) && (bombed_wall3 == 1'b0) && (bombed_wall32 == 1'b0))
				begin
					if(keycode == 8'h04)
						Ball_X_Motion_in = 10'h000;
				end
				//Wall4
				if((Ball_Y_Pos <= Wall_Y_Center4) && (Ball_Y_Pos >= Wall_Y_Center4 - 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center4 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center4 - 2*Ball_Size) && (bombed_wall4 == 1'b0) && (bombed_wall42 == 1'b0))
				begin
					if(keycode == 8'h16)
						Ball_Y_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos >= Wall_Y_Center4) && (Ball_Y_Pos <= Wall_Y_Center4 + 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center4 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center4 - 2*Ball_Size) && (bombed_wall4 == 1'b0) && (bombed_wall42 == 1'b0))
				begin
					if(keycode == 8'h1a)
						Ball_Y_Motion_in = 10'h000;
				end
            if((Ball_Y_Pos > Wall_Y_Center4 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center4 + 2*Ball_Size) && (Ball_X_Pos <= Wall_X_Center4) && (Ball_X_Pos >= Wall_X_Center4 - 2*Ball_Size) && (bombed_wall4 == 1'b0) && (bombed_wall42 == 1'b0))
				begin
					if(keycode == 8'h07)
						Ball_X_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos > Wall_Y_Center4 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center4 + 2*Ball_Size) && (Ball_X_Pos >= Wall_X_Center4) && (Ball_X_Pos <= Wall_X_Center4 + 2*Ball_Size) && (bombed_wall4 == 1'b0) && (bombed_wall42 == 1'b0))
				begin
					if(keycode == 8'h04)
						Ball_X_Motion_in = 10'h000;
				end
				//Wall5
				if((Ball_Y_Pos <= Wall_Y_Center5) && (Ball_Y_Pos >= Wall_Y_Center5 - 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center5 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center5 - 2*Ball_Size) && (bombed_wall5 == 1'b0) && (bombed_wall52 == 1'b0))
				begin
					if(keycode == 8'h16)
						Ball_Y_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos >= Wall_Y_Center5) && (Ball_Y_Pos <= Wall_Y_Center5 + 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center5 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center5 - 2*Ball_Size) && (bombed_wall5 == 1'b0) && (bombed_wall52 == 1'b0))
				begin
					if(keycode == 8'h1a)
						Ball_Y_Motion_in = 10'h000;
				end
            if((Ball_Y_Pos > Wall_Y_Center5 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center5 + 2*Ball_Size) && (Ball_X_Pos <= Wall_X_Center5) && (Ball_X_Pos >= Wall_X_Center5 - 2*Ball_Size) && (bombed_wall5 == 1'b0) && (bombed_wall52 == 1'b0))
				begin
					if(keycode == 8'h07)
						Ball_X_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos > Wall_Y_Center5 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center5 + 2*Ball_Size) && (Ball_X_Pos >= Wall_X_Center5) && (Ball_X_Pos <= Wall_X_Center5 + 2*Ball_Size) && (bombed_wall5 == 1'b0) && (bombed_wall52 == 1'b0))
				begin
					if(keycode == 8'h04)
						Ball_X_Motion_in = 10'h000;
				end
				//Wall6
				if((Ball_Y_Pos <= Wall_Y_Center6) && (Ball_Y_Pos >= Wall_Y_Center6 - 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center6 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center6 - 2*Ball_Size) && (bombed_wall6 == 1'b0) && (bombed_wall62 == 1'b0))
				begin
					if(keycode == 8'h16)
						Ball_Y_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos >= Wall_Y_Center6) && (Ball_Y_Pos <= Wall_Y_Center6 + 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center6 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center6 - 2*Ball_Size) && (bombed_wall6 == 1'b0) && (bombed_wall62 == 1'b0))
				begin
					if(keycode == 8'h1a)
						Ball_Y_Motion_in = 10'h000;
				end
            if((Ball_Y_Pos > Wall_Y_Center6 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center6 + 2*Ball_Size) && (Ball_X_Pos <= Wall_X_Center6) && (Ball_X_Pos >= Wall_X_Center6 - 2*Ball_Size) && (bombed_wall6 == 1'b0) && (bombed_wall62 == 1'b0))
				begin
					if(keycode == 8'h07)
						Ball_X_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos > Wall_Y_Center6 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center6 + 2*Ball_Size) && (Ball_X_Pos >= Wall_X_Center6) && (Ball_X_Pos <= Wall_X_Center6 + 2*Ball_Size) && (bombed_wall6 == 1'b0) && (bombed_wall62 == 1'b0))
				begin
					if(keycode == 8'h04)
						Ball_X_Motion_in = 10'h000;
				end
				//Wall7
				if((Ball_Y_Pos <= Wall_Y_Center7) && (Ball_Y_Pos >= Wall_Y_Center7 - 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center7 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center7 - 2*Ball_Size) && (bombed_wall7 == 1'b0) && (bombed_wall72 == 1'b0))
				begin
					if(keycode == 8'h16)
						Ball_Y_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos >= Wall_Y_Center7) && (Ball_Y_Pos <= Wall_Y_Center7 + 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center7 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center7 - 2*Ball_Size) && (bombed_wall7 == 1'b0) && (bombed_wall72 == 1'b0))
				begin
					if(keycode == 8'h1a)
						Ball_Y_Motion_in = 10'h000;
				end
            if((Ball_Y_Pos > Wall_Y_Center7 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center7 + 2*Ball_Size) && (Ball_X_Pos <= Wall_X_Center7) && (Ball_X_Pos >= Wall_X_Center7 - 2*Ball_Size) && (bombed_wall7 == 1'b0) && (bombed_wall72 == 1'b0))
				begin
					if(keycode == 8'h07)
						Ball_X_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos > Wall_Y_Center7 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center7 + 2*Ball_Size) && (Ball_X_Pos >= Wall_X_Center7) && (Ball_X_Pos <= Wall_X_Center7 + 2*Ball_Size) && (bombed_wall7 == 1'b0) && (bombed_wall72 == 1'b0))
				begin
					if(keycode == 8'h04)
						Ball_X_Motion_in = 10'h000;
				end
				//Wall8
				if((Ball_Y_Pos <= Wall_Y_Center8) && (Ball_Y_Pos >= Wall_Y_Center8 - 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center8 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center8 - 2*Ball_Size) && (bombed_wall8 == 1'b0) && (bombed_wall82 == 1'b0))
				begin
					if(keycode == 8'h16)
						Ball_Y_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos >= Wall_Y_Center8) && (Ball_Y_Pos <= Wall_Y_Center8 + 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center8 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center8 - 2*Ball_Size) && (bombed_wall8 == 1'b0) && (bombed_wall82 == 1'b0))
				begin
					if(keycode == 8'h1a)
						Ball_Y_Motion_in = 10'h000;
				end
            if((Ball_Y_Pos > Wall_Y_Center8 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center8 + 2*Ball_Size) && (Ball_X_Pos <= Wall_X_Center8) && (Ball_X_Pos >= Wall_X_Center8 - 2*Ball_Size) && (bombed_wall8 == 1'b0) && (bombed_wall82 == 1'b0))
				begin
					if(keycode == 8'h07)
						Ball_X_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos > Wall_Y_Center8 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center8 + 2*Ball_Size) && (Ball_X_Pos >= Wall_X_Center8) && (Ball_X_Pos <= Wall_X_Center8 + 2*Ball_Size) && (bombed_wall8 == 1'b0) && (bombed_wall82 == 1'b0))
				begin
					if(keycode == 8'h04)
						Ball_X_Motion_in = 10'h000;
				end
				//Wall9
				if((Ball_Y_Pos <= Wall_Y_Center9) && (Ball_Y_Pos >= Wall_Y_Center9 - 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center9 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center9 - 2*Ball_Size) && (bombed_wall9 == 1'b0) && (bombed_wall92 == 1'b0))
				begin
					if(keycode == 8'h16)
						Ball_Y_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos >= Wall_Y_Center9) && (Ball_Y_Pos <= Wall_Y_Center9 + 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center9 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center9 - 2*Ball_Size) && (bombed_wall9 == 1'b0) && (bombed_wall92 == 1'b0))
				begin
					if(keycode == 8'h1a)
						Ball_Y_Motion_in = 10'h000;
				end
            if((Ball_Y_Pos > Wall_Y_Center9 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center9 + 2*Ball_Size) && (Ball_X_Pos <= Wall_X_Center9) && (Ball_X_Pos >= Wall_X_Center9 - 2*Ball_Size) && (bombed_wall9 == 1'b0) && (bombed_wall92 == 1'b0))
				begin
					if(keycode == 8'h07)
						Ball_X_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos > Wall_Y_Center9 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center9 + 2*Ball_Size) && (Ball_X_Pos >= Wall_X_Center9) && (Ball_X_Pos <= Wall_X_Center9 + 2*Ball_Size) && (bombed_wall9 == 1'b0) && (bombed_wall92 == 1'b0))
				begin
					if(keycode == 8'h04)
						Ball_X_Motion_in = 10'h000;
				end
				//Wall10
				if((Ball_Y_Pos <= Wall_Y_Center10) && (Ball_Y_Pos >= Wall_Y_Center10 - 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center10 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center10 - 2*Ball_Size) && (bombed_wall10 == 1'b0) && (bombed_wall102 == 1'b0))
				begin
					if(keycode == 8'h16)
						Ball_Y_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos >= Wall_Y_Center10) && (Ball_Y_Pos <= Wall_Y_Center10 + 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center10 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center10 - 2*Ball_Size) && (bombed_wall10 == 1'b0) && (bombed_wall102 == 1'b0))
				begin
					if(keycode == 8'h1a)
						Ball_Y_Motion_in = 10'h000;
				end
            if((Ball_Y_Pos > Wall_Y_Center10 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center10 + 2*Ball_Size) && (Ball_X_Pos <= Wall_X_Center10) && (Ball_X_Pos >= Wall_X_Center10 - 2*Ball_Size) && (bombed_wall10 == 1'b0) && (bombed_wall102 == 1'b0))
				begin
					if(keycode == 8'h07)
						Ball_X_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos > Wall_Y_Center10 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center10 + 2*Ball_Size) && (Ball_X_Pos >= Wall_X_Center10) && (Ball_X_Pos <= Wall_X_Center10 + 2*Ball_Size) && (bombed_wall10 == 1'b0) && (bombed_wall102 == 1'b0))
				begin
					if(keycode == 8'h04)
						Ball_X_Motion_in = 10'h000;
				end
				//Wall11
				if((Ball_Y_Pos <= Wall_Y_Center11) && (Ball_Y_Pos >= Wall_Y_Center11 - 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center11 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center11 - 2*Ball_Size) && (bombed_wall11 == 1'b0) && (bombed_wall112 == 1'b0))
				begin
					if(keycode == 8'h16)
						Ball_Y_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos >= Wall_Y_Center11) && (Ball_Y_Pos <= Wall_Y_Center11 + 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center11 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center11 - 2*Ball_Size) && (bombed_wall11 == 1'b0) && (bombed_wall112 == 1'b0))
				begin
					if(keycode == 8'h1a)
						Ball_Y_Motion_in = 10'h000;
				end
            if((Ball_Y_Pos > Wall_Y_Center11 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center11 + 2*Ball_Size) && (Ball_X_Pos <= Wall_X_Center11) && (Ball_X_Pos >= Wall_X_Center11 - 2*Ball_Size) && (bombed_wall11 == 1'b0) && (bombed_wall112 == 1'b0))
				begin
					if(keycode == 8'h07)
						Ball_X_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos > Wall_Y_Center11 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center11 + 2*Ball_Size) && (Ball_X_Pos >= Wall_X_Center11) && (Ball_X_Pos <= Wall_X_Center11 + 2*Ball_Size) && (bombed_wall11 == 1'b0) && (bombed_wall112 == 1'b0))
				begin
					if(keycode == 8'h04)
						Ball_X_Motion_in = 10'h000;
				end
				//Wall12
				if((Ball_Y_Pos <= Wall_Y_Center12) && (Ball_Y_Pos >= Wall_Y_Center12 - 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center12 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center12 - 2*Ball_Size) && (bombed_wall12 == 1'b0) && (bombed_wall122 == 1'b0))
				begin
					if(keycode == 8'h16)
						Ball_Y_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos >= Wall_Y_Center12) && (Ball_Y_Pos <= Wall_Y_Center12 + 2*Ball_Size) && (Ball_X_Pos < Wall_X_Center12 + 2*Ball_Size) && (Ball_X_Pos > Wall_X_Center12 - 2*Ball_Size) && (bombed_wall12 == 1'b0) && (bombed_wall122 == 1'b0))
				begin
					if(keycode == 8'h1a)
						Ball_Y_Motion_in = 10'h000;
				end
            if((Ball_Y_Pos > Wall_Y_Center12 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center12 + 2*Ball_Size) && (Ball_X_Pos <= Wall_X_Center12) && (Ball_X_Pos >= Wall_X_Center12 - 2*Ball_Size) && (bombed_wall12 == 1'b0) && (bombed_wall122 == 1'b0))
				begin
					if(keycode == 8'h07)
						Ball_X_Motion_in = 10'h000;
				end
            else if((Ball_Y_Pos > Wall_Y_Center12 - 2*Ball_Size) && (Ball_Y_Pos < Wall_Y_Center12 + 2*Ball_Size) && (Ball_X_Pos >= Wall_X_Center12) && (Ball_X_Pos <= Wall_X_Center12 + 2*Ball_Size) && (bombed_wall12 == 1'b0) && (bombed_wall122 == 1'b0))
				begin
					if(keycode == 8'h04)
						Ball_X_Motion_in = 10'h000;
				end
				Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion_in;
            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;
            // Update the ball's position with its motion
            
        end
        
        /**************************************************************************************
            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
            Hidden Question #2/2:
               Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
              Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
              What is the difference between writing
                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
              How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
              Give an answer in your Post-Lab.
        **************************************************************************************/
    end
    always_ff @ (posedge Clk)
    begin
			if (Reset)
			begin
				leftgraph = 1'b0;
				rightgraph = 1'b0;
				upgraph = 1'b0;
				downgraph = 1'b0;
			end
			if (keycode == 8'h04)
			//A
			begin
				leftgraph = 1'b1;
				rightgraph = 1'b0;
				upgraph = 1'b0;
				downgraph = 1'b0;
			end
			if (keycode == 8'h07)
			//D
			begin
				leftgraph = 1'b0;
				rightgraph = 1'b1;
				upgraph = 1'b0;
				downgraph = 1'b0;
			end
			if (keycode == 8'h1a)
			//W
			begin
				leftgraph = 1'b0;
				rightgraph = 1'b0;
				upgraph = 1'b1;
				downgraph = 1'b0;
			end
			if (keycode == 8'h16)
			//S
			begin
				leftgraph = 1'b0;
				rightgraph = 1'b0;
				upgraph = 1'b0;
				downgraph = 1'b0;
			end
	 end
	 //startpage
	 always_ff @ (posedge Clk)
    begin
			if (Reset)
				start = 1'b0;
			if (keycode == 8'h09)
				start = 1'b1;
	 end
    // Compute whether the pixel corresponds to ball or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX_Ball, DistY_Ball;
	 int DistX_Bomb, DistY_Bomb;
	 //Wall
	 int DistX_Wall1, DistY_Wall1;
	 int DistX_Wall2, DistY_Wall2;
	 int DistX_Wall3, DistY_Wall3;
	 int DistX_Wall4, DistY_Wall4;
	 int DistX_Wall5, DistY_Wall5;
	 int DistX_Wall6, DistY_Wall6;
	 int DistX_Wall7, DistY_Wall7;
	 int DistX_Wall8, DistY_Wall8;
	 int DistX_Wall9, DistY_Wall9;
	 int DistX_Wall10, DistY_Wall10;
	 int DistX_Wall11, DistY_Wall11;
	 int DistX_Wall12, DistY_Wall12;
	 //Shoe
	 int DistX_Shoe1, DistY_Shoe1;
	 
	 
	 int DistX_Fire, DistY_Fire;
	 int Ball_size;
	 int Bomb_size;
	 int Wall_size;
	 int Fire_size;
	 int Shoe_size;
	 //bomb to wall dist
	 int bombtowall1_X;
	 int bombtowall1_Y;
	 int bombtowall2_X;
	 int bombtowall2_Y;
	 int bombtowall3_X;
	 int bombtowall3_Y;
	 int bombtowall4_X;
	 int bombtowall4_Y;
	 int bombtowall5_X;
	 int bombtowall5_Y;
	 int bombtowall6_X;
	 int bombtowall6_Y;
	 int bombtowall7_X;
	 int bombtowall7_Y;
	 int bombtowall8_X;
	 int bombtowall8_Y;
	 int bombtowall9_X;
	 int bombtowall9_Y;
	 int bombtowall10_X;
	 int bombtowall10_Y;
	 int bombtowall11_X;
	 int bombtowall11_Y;
	 int bombtowall12_X;
	 int bombtowall12_Y;
	 //bomb to ball dist
	 
    assign DistX_Ball = DrawX - Ball_X_Pos;
    assign DistY_Ball = DrawY - Ball_Y_Pos;
	 
    assign DistX_Bomb = DrawX - Bomb_X_Center;
    assign DistY_Bomb = DrawY - Bomb_Y_Center;
	 
	 //Wall
  assign DistX_Wall1 = DrawX - Wall_X_Center1;
  assign DistY_Wall1 = DrawY - Wall_Y_Center1;
  assign DistX_Wall2 = DrawX - Wall_X_Center2;
  assign DistY_Wall2 = DrawY - Wall_Y_Center2;
  assign DistX_Wall3 = DrawX - Wall_X_Center3;
  assign DistY_Wall3 = DrawY - Wall_Y_Center3;
  assign DistX_Wall4 = DrawX - Wall_X_Center4;
  assign DistY_Wall4 = DrawY - Wall_Y_Center4;
  assign DistX_Wall5 = DrawX - Wall_X_Center5;
  assign DistY_Wall5 = DrawY - Wall_Y_Center5;
  assign DistX_Wall6 = DrawX - Wall_X_Center6;
  assign DistY_Wall6 = DrawY - Wall_Y_Center6;
  assign DistX_Wall7 = DrawX - Wall_X_Center7;
  assign DistY_Wall7 = DrawY - Wall_Y_Center7;
  assign DistX_Wall8 = DrawX - Wall_X_Center8;
  assign DistY_Wall8 = DrawY - Wall_Y_Center8;
  assign DistX_Wall9 = DrawX - Wall_X_Center9;
  assign DistY_Wall9 = DrawY - Wall_Y_Center9;
  assign DistX_Wall10 = DrawX - Wall_X_Center10;
  assign DistY_Wall10 = DrawY - Wall_Y_Center10;
  assign DistX_Wall11 = DrawX - Wall_X_Center11;
  assign DistY_Wall11 = DrawY - Wall_Y_Center11;
  assign DistX_Wall12 = DrawX - Wall_X_Center12;
  assign DistY_Wall12 = DrawY - Wall_Y_Center12;
	 //Shoe
	 assign DistX_Shoe1 = DrawX - Shoe_X_Center1;
	 assign DistY_Shoe1 = DrawY - Shoe_Y_Center1;
	 
	 
	 
	 assign DistX_Fire = (DrawX >= Bomb_X_Center)? DrawX - Bomb_X_Center : Bomb_X_Center - DrawX;
	 assign DistY_Fire = (DrawY >= Bomb_Y_Center)? DrawY - Bomb_Y_Center : Bomb_Y_Center - DrawY;
	 assign Ball_size = Ball_Size;
	 assign Bomb_size = Bomb_Size;
	 assign Wall_size = Wall_Size;
	 assign Fire_size = Fire_Size;
	 assign Shoe_size = Shoe_Size;
	 
	 //exploded wall
	 assign bombtowall1_X = (Bomb_X_Center >= Wall_X_Center1)? Bomb_X_Center - Wall_X_Center1 : Wall_X_Center1 - Bomb_X_Center;
	 assign bombtowall1_Y = (Bomb_Y_Center >= Wall_Y_Center1)? Bomb_Y_Center - Wall_Y_Center1 : Wall_Y_Center1 - Bomb_Y_Center;
	 assign bombtowall2_X = (Bomb_X_Center >= Wall_X_Center2)? Bomb_X_Center - Wall_X_Center2 : Wall_X_Center2 - Bomb_X_Center;
	 assign bombtowall2_Y = (Bomb_Y_Center >= Wall_Y_Center2)? Bomb_Y_Center - Wall_Y_Center2 : Wall_Y_Center2 - Bomb_Y_Center;
	 assign bombtowall3_X = (Bomb_X_Center >= Wall_X_Center3)? Bomb_X_Center - Wall_X_Center3 : Wall_X_Center3 - Bomb_X_Center;
	 assign bombtowall3_Y = (Bomb_Y_Center >= Wall_Y_Center3)? Bomb_Y_Center - Wall_Y_Center3 : Wall_Y_Center3 - Bomb_Y_Center;
	 assign bombtowall4_X = (Bomb_X_Center >= Wall_X_Center4)? Bomb_X_Center - Wall_X_Center4 : Wall_X_Center4 - Bomb_X_Center;
	 assign bombtowall4_Y = (Bomb_Y_Center >= Wall_Y_Center4)? Bomb_Y_Center - Wall_Y_Center4 : Wall_Y_Center4 - Bomb_Y_Center;
	 assign bombtowall5_X = (Bomb_X_Center >= Wall_X_Center5)? Bomb_X_Center - Wall_X_Center5 : Wall_X_Center5 - Bomb_X_Center;
	 assign bombtowall5_Y = (Bomb_Y_Center >= Wall_Y_Center5)? Bomb_Y_Center - Wall_Y_Center5 : Wall_Y_Center5 - Bomb_Y_Center;
	 assign bombtowall6_X = (Bomb_X_Center >= Wall_X_Center6)? Bomb_X_Center - Wall_X_Center6 : Wall_X_Center6 - Bomb_X_Center;
	 assign bombtowall6_Y = (Bomb_Y_Center >= Wall_Y_Center6)? Bomb_Y_Center - Wall_Y_Center6 : Wall_Y_Center6 - Bomb_Y_Center;
	 assign bombtowall7_X = (Bomb_X_Center >= Wall_X_Center7)? Bomb_X_Center - Wall_X_Center7 : Wall_X_Center7 - Bomb_X_Center;
	 assign bombtowall7_Y = (Bomb_Y_Center >= Wall_Y_Center7)? Bomb_Y_Center - Wall_Y_Center7 : Wall_Y_Center7 - Bomb_Y_Center;
	 assign bombtowall8_X = (Bomb_X_Center >= Wall_X_Center8)? Bomb_X_Center - Wall_X_Center8 : Wall_X_Center8 - Bomb_X_Center;
	 assign bombtowall8_Y = (Bomb_Y_Center >= Wall_Y_Center8)? Bomb_Y_Center - Wall_Y_Center8 : Wall_Y_Center8 - Bomb_Y_Center;
	 assign bombtowall9_X = (Bomb_X_Center >= Wall_X_Center9)? Bomb_X_Center - Wall_X_Center9 : Wall_X_Center9 - Bomb_X_Center;
	 assign bombtowall9_Y = (Bomb_Y_Center >= Wall_Y_Center9)? Bomb_Y_Center - Wall_Y_Center9 : Wall_Y_Center9 - Bomb_Y_Center;
	 assign bombtowall10_X = (Bomb_X_Center >= Wall_X_Center10)? Bomb_X_Center - Wall_X_Center10 : Wall_X_Center10 - Bomb_X_Center;
	 assign bombtowall10_Y = (Bomb_Y_Center >= Wall_Y_Center10)? Bomb_Y_Center - Wall_Y_Center10 : Wall_Y_Center10 - Bomb_Y_Center;
	 assign bombtowall11_X = (Bomb_X_Center >= Wall_X_Center11)? Bomb_X_Center - Wall_X_Center11 : Wall_X_Center11 - Bomb_X_Center;
	 assign bombtowall11_Y = (Bomb_Y_Center >= Wall_Y_Center11)? Bomb_Y_Center - Wall_Y_Center11 : Wall_Y_Center11 - Bomb_Y_Center;
	 assign bombtowall12_X = (Bomb_X_Center >= Wall_X_Center12)? Bomb_X_Center - Wall_X_Center12 : Wall_X_Center12 - Bomb_X_Center;
	 assign bombtowall12_Y = (Bomb_Y_Center >= Wall_Y_Center12)? Bomb_Y_Center - Wall_Y_Center12 : Wall_Y_Center12 - Bomb_Y_Center;
	 //bombed_wall
    always_ff @ (posedge Clk)
    begin
			if(Reset)
				bombed_wall1 = 1'b0;
			if((bomb_exploding == 1'b1) && (((bombtowall1_Y <= 4*Wall_size) && (bombtowall1_X <= Wall_size)) || ((bombtowall1_Y <= Wall_size) && (bombtowall1_X <= 4*Wall_size))))
				bombed_wall1 = 1'b1;
	 end
	 always_ff @ (posedge Clk)
    begin
			if(Reset)
				bombed_wall2 = 1'b0;
			if((bomb_exploding == 1'b1) && (((bombtowall2_Y <= 4*Wall_size) && (bombtowall2_X <= Wall_size)) || ((bombtowall2_Y <= Wall_size) && (bombtowall2_X <= 4*Wall_size))))
				bombed_wall2 = 1'b1;
	 end
	 always_ff @ (posedge Clk)
    begin
			if(Reset)
				bombed_wall3 = 1'b0;
			if((bomb_exploding == 1'b1) && (((bombtowall3_Y <= 4*Wall_size) && (bombtowall3_X <= Wall_size)) || ((bombtowall3_Y <= Wall_size) && (bombtowall3_X <= 4*Wall_size))))
				bombed_wall3 = 1'b1;
	 end
	 always_ff @ (posedge Clk)
    begin
			if(Reset)
				bombed_wall4 = 1'b0;
			if((bomb_exploding == 1'b1) && (((bombtowall4_Y <= 4*Wall_size) && (bombtowall4_X <= Wall_size)) || ((bombtowall4_Y <= Wall_size) && (bombtowall4_X <= 4*Wall_size))))
				bombed_wall4 = 1'b1;
	 end
	 always_ff @ (posedge Clk)
    begin
			if(Reset)
				bombed_wall5 = 1'b0;
			if((bomb_exploding == 1'b1) && (((bombtowall5_Y <= 4*Wall_size) && (bombtowall5_X <= Wall_size)) || ((bombtowall5_Y <= Wall_size) && (bombtowall5_X <= 4*Wall_size))))
				bombed_wall5 = 1'b1;
	 end
	 always_ff @ (posedge Clk)
    begin
			if(Reset)
				bombed_wall6 = 1'b0;
			if((bomb_exploding == 1'b1) && (((bombtowall6_Y <= 4*Wall_size) && (bombtowall6_X <= Wall_size)) || ((bombtowall6_Y <= Wall_size) && (bombtowall6_X <= 4*Wall_size))))
				bombed_wall6 = 1'b1;
	 end
	 always_ff @ (posedge Clk)
    begin
			if(Reset)
				bombed_wall7 = 1'b0;
			if((bomb_exploding == 1'b1) && (((bombtowall7_Y <= 4*Wall_size) && (bombtowall7_X <= Wall_size)) || ((bombtowall7_Y <= Wall_size) && (bombtowall7_X <= 4*Wall_size))))
				bombed_wall7 = 1'b1;
	 end
	 always_ff @ (posedge Clk)
    begin
			if(Reset)
				bombed_wall8 = 1'b0;
			if((bomb_exploding == 1'b1) && (((bombtowall8_Y <= 4*Wall_size) && (bombtowall8_X <= Wall_size)) || ((bombtowall8_Y <= Wall_size) && (bombtowall8_X <= 4*Wall_size))))
				bombed_wall8 = 1'b1;
	 end
	 always_ff @ (posedge Clk)
    begin
			if(Reset)
				bombed_wall9 = 1'b0;
			if((bomb_exploding == 1'b1) && (((bombtowall9_Y <= 4*Wall_size) && (bombtowall9_X <= Wall_size)) || ((bombtowall9_Y <= Wall_size) && (bombtowall9_X <= 4*Wall_size))))
				bombed_wall9 = 1'b1;
	 end
	 always_ff @ (posedge Clk)
    begin
			if(Reset)
				bombed_wall10 = 1'b0;
			if((bomb_exploding == 1'b1) && (((bombtowall10_Y <= 4*Wall_size) && (bombtowall10_X <= Wall_size)) || ((bombtowall10_Y <= Wall_size) && (bombtowall10_X <= 4*Wall_size))))
				bombed_wall10 = 1'b1;
	 end
	 always_ff @ (posedge Clk)
    begin
			if(Reset)
				bombed_wall11 = 1'b0;
			if((bomb_exploding == 1'b1) && (((bombtowall11_Y <= 4*Wall_size) && (bombtowall11_X <= Wall_size)) || ((bombtowall11_Y <= Wall_size) && (bombtowall11_X <= 4*Wall_size))))
				bombed_wall11 = 1'b1;
	 end
	 always_ff @ (posedge Clk)
    begin
			if(Reset)
				bombed_wall12 = 1'b0;
			if((bomb_exploding == 1'b1) && (((bombtowall12_Y <= 4*Wall_size) && (bombtowall12_X <= Wall_size)) || ((bombtowall12_Y <= Wall_size) && (bombtowall12_X <= 4*Wall_size))))
				bombed_wall12 = 1'b1;
	 end
	 //shoe_on
	 always_ff @ (posedge Clk)
    begin
			if(Reset)
				shoe_on1 = 1'b0;
			if(((bombed_wall1 == 1) || (bombed_wall1_2 == 1)) && ((Ball_X_Pos < Shoe_X_Center1 + Shoe_size) && (Ball_X_Pos > Shoe_X_Center1 - Shoe_size) && (Ball_Y_Pos > Shoe_Y_Center1 - Shoe_size) && (Ball_Y_Pos < Shoe_Y_Center1 + Shoe_size)) && (shoe_on2 == 0))
				shoe_on1 = 1'b1;
	 end
	 always_comb begin
	 //Wall
		  read_address_wall1 = 19'b0;
		  if ( (DistX_Wall1*DistX_Wall1 < Wall_size*Wall_size) && (DistY_Wall1*DistY_Wall1 < Wall_size*Wall_size) )begin
				is_wall1 = 1'b1;
				read_address_wall1 = (DistY_Wall1+Wall_size)*Wall_size*2 + DistX_Wall1+Wall_size;
				end
		  else 
				is_wall1 = 1'b0;
				
		  if ( (DistX_Wall2*DistX_Wall2 < Wall_size*Wall_size) && (DistY_Wall2*DistY_Wall2 < Wall_size*Wall_size) )begin
				is_wall2 = 1'b1;
				read_address_wall1 = (DistY_Wall2+Wall_size)*Wall_size*2 + DistX_Wall2+Wall_size;
				end
		  else
				is_wall2 = 1'b0;
		  if ( (DistX_Wall3*DistX_Wall3 < Wall_size*Wall_size) && (DistY_Wall3*DistY_Wall3 < Wall_size*Wall_size) )begin
				is_wall3 = 1'b1;
				read_address_wall1 = (DistY_Wall3+Wall_size)*Wall_size*2 + DistX_Wall3+Wall_size;
				end
		  else
				is_wall3 = 1'b0;
			if ( (DistX_Wall4*DistX_Wall4 < Wall_size*Wall_size) && (DistY_Wall4*DistY_Wall4 < Wall_size*Wall_size) )begin
				is_wall4 = 1'b1;
				read_address_wall1 = (DistY_Wall4+Wall_size)*Wall_size*2 + DistX_Wall4+Wall_size;
				end
		  else
				is_wall4 = 1'b0;
			if ( (DistX_Wall5*DistX_Wall5 < Wall_size*Wall_size) && (DistY_Wall5*DistY_Wall5 < Wall_size*Wall_size) )begin
				is_wall5 = 1'b1;
				read_address_wall1 = (DistY_Wall5+Wall_size)*Wall_size*2 + DistX_Wall5+Wall_size;
				end
		  else
				is_wall5 = 1'b0;
			if ( (DistX_Wall6*DistX_Wall6 < Wall_size*Wall_size) && (DistY_Wall6*DistY_Wall6 < Wall_size*Wall_size) )begin
				is_wall6 = 1'b1;
				read_address_wall1 = (DistY_Wall6+Wall_size)*Wall_size*2 + DistX_Wall6+Wall_size;
				end
		  else
				is_wall6 = 1'b0;
			if ( (DistX_Wall7*DistX_Wall7 < Wall_size*Wall_size) && (DistY_Wall7*DistY_Wall7 < Wall_size*Wall_size) )begin
				is_wall7 = 1'b1;
				read_address_wall1 = (DistY_Wall7+Wall_size)*Wall_size*2 + DistX_Wall7+Wall_size;
				end
		  else
				is_wall7 = 1'b0;
		
			if ( (DistX_Wall8*DistX_Wall8 < Wall_size*Wall_size) && (DistY_Wall8*DistY_Wall8 < Wall_size*Wall_size) )begin
				is_wall8 = 1'b1;
				read_address_wall1 = (DistY_Wall8+Wall_size)*Wall_size*2 + DistX_Wall8+Wall_size;
				end
		  else
				is_wall8 = 1'b0;
			if ( (DistX_Wall9*DistX_Wall9 < Wall_size*Wall_size) && (DistY_Wall9*DistY_Wall9 < Wall_size*Wall_size) )begin
				is_wall9 = 1'b1;
				read_address_wall1 = (DistY_Wall9+Wall_size)*Wall_size*2 + DistX_Wall9+Wall_size;
				end
		  else
				is_wall9 = 1'b0;
			if ( (DistX_Wall10*DistX_Wall10 < Wall_size*Wall_size) && (DistY_Wall10*DistY_Wall10 < Wall_size*Wall_size) )begin
				is_wall10 = 1'b1;
				read_address_wall1 = (DistY_Wall10+Wall_size)*Wall_size*2 + DistX_Wall10+Wall_size;
				end
		  else
				is_wall10 = 1'b0;
			if ( (DistX_Wall11*DistX_Wall11 < Wall_size*Wall_size) && (DistY_Wall11*DistY_Wall11 < Wall_size*Wall_size) )begin
				is_wall11 = 1'b1;
				read_address_wall1 = (DistY_Wall11+Wall_size)*Wall_size*2 + DistX_Wall11+Wall_size;
				end
		  else
				is_wall11 = 1'b0;
			if ( (DistX_Wall12*DistX_Wall12 < Wall_size*Wall_size) && (DistY_Wall12*DistY_Wall12 < Wall_size*Wall_size) )begin
				is_wall12 = 1'b1;
				read_address_wall1 = (DistY_Wall12+Wall_size)*Wall_size*2 + DistX_Wall12+Wall_size;
				end
		  else
				is_wall12 = 1'b0;
	 //Shoe
			read_address_shoe = 19'b0;
		  if ( (DistX_Shoe1*DistX_Shoe1 < Shoe_size*Shoe_size) && (DistY_Shoe1*DistY_Shoe1 < Shoe_size*Shoe_size) )
		  begin
				is_shoe1 = 1'b1;
				read_address_shoe = (DistY_Shoe1+Shoe_size)*Shoe_size*2 + DistX_Shoe1+Shoe_size;
		  end
		  else
				is_shoe1 = 1'b0;
	 //Ball
        read_address = 19'b0;
        if ( (DistX_Ball*DistX_Ball < Ball_size*Ball_size) && (DistY_Ball*DistY_Ball < Ball_size*Ball_size) )
		  begin
				is_ball = 1'b1;
				read_address = (DistY_Ball+Ball_size)*Ball_size*2 + DistX_Ball+Ball_size;
		  end
        else
            is_ball = 1'b0;
	 //Bomb
        read_address_bomb = 19'b0;
        if ( (DistX_Bomb*DistX_Bomb < Ball_size*Ball_size) && (DistY_Bomb*DistY_Bomb < Ball_size*Ball_size) && (bomb_exist == 1))
			begin
            is_bomb = 1'b1;
				read_address_bomb = (DistY_Bomb+Ball_size)*Ball_size*2 + DistX_Bomb+Ball_size;
			end
        else
            is_bomb = 1'b0;
	 //Fire
		  if ((((DistX_Fire <= 3*Fire_size) && (DistY_Fire <= Fire_size)) || ((DistY_Fire <= 3*Fire_size) && (DistX_Fire <= Fire_size))) && (bomb_exploding == 1))
				is_fire = 1'b1;
		  else
				is_fire = 1'b0;
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
    end
    
endmodule
