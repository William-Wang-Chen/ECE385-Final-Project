//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input					start,
							  input              is_ball,            // Whether current pixel belongs to ball 
                                                              //   or background (computed in ball.sv)
							  input					is_wall1,
							  input					is_wall2,
							  input					is_wall3,
							  input					is_wall4,
							  input					is_wall5,
							  input					is_wall6,
							  input					is_wall7,
							  input					is_wall8,
							  input					is_wall9,
							  input					is_wall10,
							  input					is_wall11,
							  input					is_wall12,
							  input					is_bomb,
							  input					is_fire,
							  input					is_shoe1,
							  input					bombed_wall1,
							  input					bombed_wall2,
							  input					bombed_wall3,
							  input					bombed_wall4,
							  input					bombed_wall5,
							  input					bombed_wall6,
							  input					bombed_wall7,
							  input					bombed_wall8,
							  input					bombed_wall9,
							  input					bombed_wall10,
							  input					bombed_wall11,
							  input					bombed_wall12,
							  input					bombed_ball,
							  input					shoe_on1,
							  input					leftgraph,
							  input					rightgraph,
							  input					upgraph,
							  input					downgraph,
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
                       output logic [7:0] VGA_R, VGA_G, VGA_B, // VGA RGB output
							  //double
							  input              is_ball2,
							  input					is_bomb2,
							  input					is_fire2,
							  input					bombed_wall1_2,
							  input					bombed_wall22,
							  input					bombed_wall32,
							  input					bombed_wall42,
							  input					bombed_wall52,
							  input					bombed_wall62,
							  input					bombed_wall72,
							  input					bombed_wall82,
							  input					bombed_wall92,
							  input					bombed_wall102,
							  input					bombed_wall112,
							  input					bombed_wall122,
							  input					bombed_ball2,
							  input					shoe_on2,
							  input					leftgraph2,
							  input					rightgraph2,
							  input					upgraph2,
							  input					downgraph2,
							  
							  input logic [3:0]	player_data_f,
							  input logic [3:0]  player_data_d,
							  input logic [3:0]  player_data_l,
							  input logic [3:0]  player_data_r,
							  input logic [3:0]	player_data_f2,
							  input logic [3:0]  player_data_d2,
							  input logic [3:0]  player_data_l2,
							  input logic [3:0]  player_data_r2,
							  input logic [3:0]  shoe_data,
							  input logic [3:0]  box_data,
							  input logic [3:0]  bomb_data,
							  input logic [3:0]  bomb_data2,
							  input   Clk
							  
                     );
    
    logic [7:0] Red, Green, Blue;
	 
	 //logic [23:0] player_color;
	 logic [23:0] player_palette [0:15];
	 logic [23:0] player2_palette [0:15];
	 logic [23:0] start_palette   [0:15];
	 logic [23:0] die_palette   [0:15];
	 logic [23:0] shoe_palette   [0:15];
	 logic [23:0] background_palette   [0:15];
	 logic [23:0] box_palette [0:15];
	 logic [23:0] bomb_palette [0:15];
	 logic [23:0] bomb_palette2 [0:15];
	 
//	 logic [18:0] read_address_start;
	 logic [3:0] start_data;
	 logic [3:0] die1_data;
	 logic [3:0] die2_data;
	 logic [3:0] background_data;
	 logic		pink_1;
	 logic		pink_2;
	 logic		pink_3;
	 logic		pink_4;
	 logic		pink2_1;
	 logic		pink2_2;
	 logic		pink2_3;
	 logic		pink2_4;
	 logic		pink_shoe;
	 logic		black_1;
	 logic		black_2;
	 
	 
	 

											 
	 assign player_palette =    '{24'hff00ff, 24'hffc6c6, 24'he50000, 24'hf40000, 
											 24'h000000, 24'hffffff, 24'h5f341e, 24'h814527, 
											 24'h318d95, 24'h00e9ff, 24'hffa5a5, 24'hffdada, 
											 24'h424242, 24'h303030, 24'ha70d00, 24'hc66b42};
											 
	 assign player2_palette = 		'{24'hff00ff, 24'h6b6b6b, 24'ha3a3a3, 24'hffffff, 
											 24'h8c4a29, 24'hed9a6b, 24'h5f341e, 24'hffcaac, 
											 24'h454545, 24'h505050, 24'hffb286, 24'hababab, 
											 24'h434343, 24'hdedede, 24'h535353, 24'h767676};
											 
	 assign start_palette = 		'{24'h3851ad,24'h5b6ccc,24'h6c7fde,24'hf75f53, 
											 24'hdd382c,24'ha46530,24'hc4544f,24'h801913, 
											 24'he39081,24'hf4d7c1,24'hf64f49,24'h5f110d,
											 24'h936a6a,24'h360e31,24'ha17d67,24'hb18d43};
											 
											 
	 assign die_palette = 		 '{24'hba2d2f,24'h7b2d32,24'h5a262b,24'h2d262c, 
											 24'hc00000,24'h44131b,24'h1b222c,24'h171d1d, 
											 24'h181317,24'h1a242d,24'h0f0f11,24'h131720,
											 24'h6c282a,24'h11191d,24'h1e212b,24'he131a};
											 
	 assign shoe_palette = 		 '{24'hff00ff,24'hffffff,24'h424242,24'h6b6b6b,
											 24'hd6d6d6,24'h949494,24'hb50000,24'hff4a4a, 
											 24'hff6300,24'hff9400,24'hfff7e7,24'h000000,
											 24'h635a63,24'hd67b18,24'hcec6ce,24'hd67b18};
											 
	 assign background_palette =  '{24'h3e4049,24'h30333a,24'h3a2a4f,24'h15192a,
											 24'h1f1724,24'h261a28,24'h322638,24'h3a2d3e,
											 24'h8ea8b3,24'h2f2231,24'h251829,24'h2f3036,
											 24'h332437,24'h312331,24'h373743,24'h3c303e};
											 
	 assign box_palette =  		'{24'hce8600,24'h845100,24'h633c00,24'h5a3400,
											 24'hf7b639,24'hffbe42,24'had7108,24'hc68e18,
											 24'h9c6500,24'hbd8618,24'hd69621,24'hffcb63,
											 24'hffd373,24'h6b4500,24'h8c5900,24'h946500};
											 
	 assign bomb_palette =  	'{24'h000000,24'h278dbd,24'h16c8ff,24'h0057c1,
											24'h1891f5,24'h57f9ff,24'h6ffeff,24'heffffc,
											24'h008bf0,24'h019dfa,24'h0088f6,24'h0bbaff,
											24'h6bd3ee,24'h01c6fc,24'h0179e8,24'h12a3e4};
											 
	 assign bomb_palette2 =  	'{24'h000000,24'h081018,24'hffffff,24'h10285a,
											24'h294163,24'h29456b,24'h9ca6bd,24'hc6d3de,
											24'hdee3e7,24'h637994,24'h182439,24'h298ac6,
											24'h101429,24'h101c39,24'hd6f3ff,24'heff3ff};

    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
	 
	 start_RAM   startpage_ram (.DrawX, .DrawY, .Clk(Clk), .data_Out(start_data));
	 die1_RAM   die1page_ram (.DrawX, .DrawY, .Clk(Clk), .data_Out(die1_data));
	 die2_RAM   die2page_ram (.DrawX, .DrawY, .Clk(Clk), .data_Out(die2_data));
	 background_RAM background_ram0 (.DrawX, .DrawY, .Clk(Clk), .data_Out(background_data));
	 
	 always_comb
	 begin
	 if ((player_palette[player_data_l][23:16] == 8'hff) && (player_palette[player_data_l][15:8] == 8'h00) && (player_palette[player_data_l][7:0] == 8'hff))
		pink_1 = 1'b1;
	 else
		pink_1 = 1'b0;
	 if ((player_palette[player_data_r][23:16] == 8'hff) && (player_palette[player_data_r][15:8] == 8'h00) && (player_palette[player_data_r][7:0] == 8'hff))
		pink_2 = 1'b1;
	 else
		pink_2 = 1'b0;
	 if ((player_palette[player_data_d][23:16] == 8'hff) && (player_palette[player_data_d][15:8] == 8'h00) && (player_palette[player_data_d][7:0] == 8'hff))
		pink_3 = 1'b1;
	 else
		pink_3 = 1'b0;
	 if ((player_palette[player_data_f][23:16] == 8'hff) && (player_palette[player_data_f][15:8] == 8'h00) && (player_palette[player_data_f][7:0] == 8'hff))
		pink_4 = 1'b1;
	 else
		pink_4 = 1'b0;
	 //player2
	 if ((player2_palette[player_data_l2][23:16] == 8'hff) && (player2_palette[player_data_l2][15:8] == 8'h00) && (player2_palette[player_data_l2][7:0] == 8'hff))
		pink2_1 = 1'b1;
	 else
		pink2_1 = 1'b0;
	 if ((player2_palette[player_data_r2][23:16] == 8'hff) && (player2_palette[player_data_r2][15:8] == 8'h00) && (player2_palette[player_data_r2][7:0] == 8'hff))
		pink2_2 = 1'b1;
	 else
		pink2_2 = 1'b0;
	 if ((player2_palette[player_data_d2][23:16] == 8'hff) && (player2_palette[player_data_d2][15:8] == 8'h00) && (player2_palette[player_data_d2][7:0] == 8'hff))
		pink2_3 = 1'b1;
	 else
		pink2_3 = 1'b0;
	 if ((player2_palette[player_data_f2][23:16] == 8'hff) && (player2_palette[player_data_f2][15:8] == 8'h00) && (player2_palette[player_data_f2][7:0] == 8'hff))
		pink2_4 = 1'b1;
	 else
		pink2_4 = 1'b0;
	 if ((shoe_palette[shoe_data][23:16] == 8'hff) && (shoe_palette[shoe_data][15:8] == 8'h00) && (shoe_palette[shoe_data][7:0] == 8'hff))
		pink_shoe = 1'b1;
	 else
		pink_shoe = 1'b0;
	 end
	 
	 //bomb
	 always_comb
	 begin
	 if ((bomb_palette[bomb_data][23:16] == 8'h00) && (bomb_palette[bomb_data][15:8] == 8'h00) && (bomb_palette[bomb_data][7:0] == 8'h00))
		black_1 = 1'b1;
	 else
		black_1 = 1'b0;
	 if ((bomb_palette2[bomb_data2][23:16] == 8'h00) && (bomb_palette2[bomb_data2][15:8] == 8'h00) && (bomb_palette2[bomb_data2][7:0] == 8'h00))
		black_2 = 1'b1;
	 else
		black_2 = 1'b0;
	 end
	 

    // Assign color based on is_ball signal
    always_comb
    begin
		  if (start == 1'b0)
		  begin
		  Red = start_palette[start_data][23:16];
		  Green = start_palette[start_data][15:8];
		  Blue = start_palette[start_data][7:0];
		  end
		  else if ((bombed_ball == 1) && (bombed_ball2 == 0))
		  begin
		  Red = die_palette[die1_data][23:16];
		  Green = die_palette[die1_data][15:8];
		  Blue = die_palette[die1_data][7:0];
		  end
		  else if (bombed_ball2 == 1)
		  begin
		  Red = die_palette[die2_data][23:16];
		  Green = die_palette[die2_data][15:8];
		  Blue = die_palette[die2_data][7:0];
		  end
		  else if ((is_fire == 1'b1) || (is_fire2 == 1'b1))
		  begin
				Red=8'hff;
				Green=8'h00;
				Blue=8'h00;
		  end
		  else if (is_ball == 1'b1)
        begin
				begin
				if (bombed_ball == 1'b1)
				begin
				//background
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					if (leftgraph == 1'b1)
					begin
						if (pink_1 == 1)
						begin
							Red = background_palette[background_data][23:16];
							Green = background_palette[background_data][15:8];
							Blue = background_palette[background_data][7:0];
						end
						else
						begin
					//Blue ball
							Red = player_palette[player_data_l][23:16];
							Green = player_palette[player_data_l][15:8];
							Blue = player_palette[player_data_l][7:0];
						end
					end
					else if (rightgraph == 1'b1)
					begin
						if (pink_2 == 1)
						begin
							Red = background_palette[background_data][23:16];
							Green = background_palette[background_data][15:8];
							Blue = background_palette[background_data][7:0];
						end
						else
						begin
						//Brown
							Red = player_palette[player_data_r][23:16];
							Green = player_palette[player_data_r][15:8];
							Blue = player_palette[player_data_r][7:0];
						end
					end
					else if (upgraph == 1'b1)
					begin
						if (pink_3 == 1)
						begin
							Red = background_palette[background_data][23:16];
							Green = background_palette[background_data][15:8];
							Blue = background_palette[background_data][7:0];
						end
						else
						begin
						//purple
							Red = player_palette[player_data_d][23:16];
							Green = player_palette[player_data_d][15:8];
							Blue = player_palette[player_data_d][7:0];
						end
					end
					else
					begin
						if (pink_4 == 1)
						begin
							Red = background_palette[background_data][23:16];
							Green = background_palette[background_data][15:8];
							Blue = background_palette[background_data][7:0];
						end
						else
						begin
					// White ball
							Red = player_palette[player_data_f][23:16];
							Green = player_palette[player_data_f][15:8];
							Blue = player_palette[player_data_f][7:0];
						end
					end
				end
				end
			end

		  //sss
        else if (is_ball2 == 1'b1)
        begin
				if (bombed_ball2 == 1'b1)
				begin
				//background
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					if (leftgraph2 == 1'b1)
					begin
						if (pink2_1 == 1)
						begin
							Red = background_palette[background_data][23:16];
							Green = background_palette[background_data][15:8];
							Blue = background_palette[background_data][7:0];
						end
						else
						begin
						//Blue ball
							Red = player2_palette[player_data_l2][23:16];
							Green = player2_palette[player_data_l2][15:8];
							Blue = player2_palette[player_data_l2][7:0];
						end
					end
					else if (rightgraph2 == 1'b1)
					begin
						if (pink2_2 == 1)
						begin
							Red = background_palette[background_data][23:16];
							Green = background_palette[background_data][15:8];
							Blue = background_palette[background_data][7:0];
						end
						else
						begin
						//Brown
							Red = player2_palette[player_data_r2][23:16];
							Green = player2_palette[player_data_r2][15:8];
							Blue = player2_palette[player_data_r2][7:0];
						end
					end
					else if (upgraph2 == 1'b1)
					begin
					if (pink2_3 == 1)
						begin
							Red = background_palette[background_data][23:16];
							Green = background_palette[background_data][15:8];
							Blue = background_palette[background_data][7:0];
						end
						else
						begin
						//purple
							Red = player2_palette[player_data_d2][23:16];
							Green = player2_palette[player_data_d2][15:8];
							Blue = player2_palette[player_data_d2][7:0];
						end
					end
					else
					begin
						if (pink2_4 == 1)
						begin
							Red = background_palette[background_data][23:16];
							Green = background_palette[background_data][15:8];
							Blue = background_palette[background_data][7:0];
						end
						else
						begin
						// White ball
							Red = player2_palette[player_data_f2][23:16];
							Green = player2_palette[player_data_f2][15:8];
							Blue = player2_palette[player_data_f2][7:0];
						end
					end
				end
			end
		  else if (is_bomb == 1'b1)
		  begin
				if (black_1 == 1)
				begin
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					//Black bomb
					Red = bomb_palette[bomb_data][23:16];
					Green = bomb_palette[bomb_data][15:8];
					Blue = bomb_palette[bomb_data][7:0];
				end
		  end
		  else if (is_bomb2 == 1'b1)
		  begin
				if (black_2 == 1)
				begin
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					//bomb2
					Red = bomb_palette2[bomb_data2][23:16];
					Green = bomb_palette2[bomb_data2][15:8];
					Blue = bomb_palette2[bomb_data2][7:0];
				end
		  end
		  else if (is_wall1 == 1'b1)
		  begin
				if ((bombed_wall1 == 1'b1) || (bombed_wall1_2 == 1))
				begin
					if ((shoe_on1 == 0) && (shoe_on2 == 0) && (is_shoe1 == 1))
					begin
						if (pink_shoe == 1)
						begin
							Red = background_palette[background_data][23:16];
							Green = background_palette[background_data][15:8];
							Blue = background_palette[background_data][7:0];
						end
						else
						begin
						//shoe
							Red = shoe_palette[shoe_data][23:16];
							Green = shoe_palette[shoe_data][15:8];
							Blue = shoe_palette[shoe_data][7:0];
						end
					end
					else
					begin
					//background
						Red = background_palette[background_data][23:16];
						Green = background_palette[background_data][15:8];
						Blue = background_palette[background_data][7:0];
					end
				end
				else
				begin
					// orange wall
					Red = box_palette[box_data][23:16];
					Green = box_palette[box_data][15:8];
					Blue = box_palette[box_data][7:0];
				end
		  end
		  else if (is_wall2 == 1'b1)
		  begin
				if ((bombed_wall2 == 1'b1) || (bombed_wall22 == 1))
				begin
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					// orange wall
					Red = box_palette[box_data][23:16];
					Green = box_palette[box_data][15:8];
					Blue = box_palette[box_data][7:0];
				end
		  end
		  else if (is_wall3 == 1'b1)
		  begin
				if ((bombed_wall3 == 1'b1) || (bombed_wall32 == 1))
				begin
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					// orange wall
					Red = box_palette[box_data][23:16];
					Green = box_palette[box_data][15:8];
					Blue = box_palette[box_data][7:0];
				end
		  end
		  else if (is_wall4 == 1'b1)
		  begin
				if ((bombed_wall4 == 1'b1) || (bombed_wall42 == 1))
				begin
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					// orange wall
					Red = box_palette[box_data][23:16];
					Green = box_palette[box_data][15:8];
					Blue = box_palette[box_data][7:0];
				end
		  end
		  else if (is_wall5 == 1'b1)
		  begin
				if ((bombed_wall5 == 1'b1) || (bombed_wall52 == 1))
				begin
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					// orange wall
					Red = box_palette[box_data][23:16];
					Green = box_palette[box_data][15:8];
					Blue = box_palette[box_data][7:0];
				end
		  end
		  else if (is_wall6 == 1'b1)
		  begin
				if ((bombed_wall6 == 1'b1) || (bombed_wall62 == 1))
				begin
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					// orange wall
					Red = box_palette[box_data][23:16];
					Green = box_palette[box_data][15:8];
					Blue = box_palette[box_data][7:0];
				end
		  end
		  else if (is_wall7 == 1'b1)
		  begin
				if ((bombed_wall7 == 1'b1) || (bombed_wall72 == 1))
				begin
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					// orange wall
					Red = box_palette[box_data][23:16];
					Green = box_palette[box_data][15:8];
					Blue = box_palette[box_data][7:0];
				end
		  end
		  else if (is_wall8 == 1'b1)
		  begin
				if ((bombed_wall8 == 1'b1) || (bombed_wall82 == 1))
				begin
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					// orange wall
					Red = box_palette[box_data][23:16];
					Green = box_palette[box_data][15:8];
					Blue = box_palette[box_data][7:0];
				end
		  end
		  else if (is_wall9 == 1'b1)
		  begin
				if ((bombed_wall9 == 1'b1) || (bombed_wall92 == 1))
				begin
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					// orange wall
					Red = box_palette[box_data][23:16];
					Green = box_palette[box_data][15:8];
					Blue = box_palette[box_data][7:0];
				end
		  end
		  else if (is_wall10 == 1'b1)
		  begin
				if ((bombed_wall10 == 1'b1) || (bombed_wall102 == 1))
				begin
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					// orange wall
					Red = box_palette[box_data][23:16];
					Green = box_palette[box_data][15:8];
					Blue = box_palette[box_data][7:0];
				end
		  end
		  else if (is_wall11 == 1'b1)
		  begin
				if ((bombed_wall11 == 1'b1) || (bombed_wall112 == 1))
				begin
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					// orange wall
					Red = box_palette[box_data][23:16];
					Green = box_palette[box_data][15:8];
					Blue = box_palette[box_data][7:0];
				end
		  end
		  else if (is_wall12 == 1'b1)
		  begin
				if ((bombed_wall12 == 1'b1) || (bombed_wall122 == 1))
				begin
					Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
				end
				else
				begin
					// orange wall
					Red = box_palette[box_data][23:16];
					Green = box_palette[box_data][15:8];
					Blue = box_palette[box_data][7:0];
				end
		  end
        else 
        begin
            // Pink Background
            Red = background_palette[background_data][23:16];
					Green = background_palette[background_data][15:8];
					Blue = background_palette[background_data][7:0];
        end
    end 
    
endmodule
