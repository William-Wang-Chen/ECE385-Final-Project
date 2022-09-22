//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module lab8( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1,
				 output logic [7:0]  LEDG,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK,      //SDRAM Clock
				 //audio_interface
				 input               AUD_ADCDAT, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,
             output logic        AUD_DACDAT, AUD_XCK, I2C_SCLK, I2C_SDAT,
				 //IR_interface
				 input 					IRDA_RXD
                    );
    
    logic Reset_h, Clk;
	 logic [31:0] keycode_32;
    logic [7:0] keycode;
	 logic [7:0] keycode0;
	 logic [7:0] keycode2;
	 
	 assign keycode0[3:0] = ir_dout[19:16];
	 assign keycode0[7:4] = ir_dout[23:20];
	 
	 always_comb
	 begin
		keycode = 8'h00;
		keycode2 = 8'h00;
		//player1
		if ((keycode_32[31:24] == 8'h1A) || (keycode_32[23:16] == 8'h1A) || (keycode_32[15:8] == 8'h1A) || (keycode_32[7:0] == 8'h1A))
			keycode = 8'h1A;
		if ((keycode_32[31:24] == 8'h04) || (keycode_32[23:16] == 8'h04) || (keycode_32[15:8] == 8'h04) || (keycode_32[7:0] == 8'h04))
			keycode = 8'h04;
		if ((keycode_32[31:24] == 8'h07) || (keycode_32[23:16] == 8'h07) || (keycode_32[15:8] == 8'h07) || (keycode_32[7:0] == 8'h07))
			keycode = 8'h07;
		if ((keycode_32[31:24] == 8'h16) || (keycode_32[23:16] == 8'h16) || (keycode_32[15:8] == 8'h16) || (keycode_32[7:0] == 8'h16))
			keycode = 8'h16;
		if ((keycode_32[31:24] == 8'h2c) || (keycode_32[23:16] == 8'h2c) || (keycode_32[15:8] == 8'h2c) || (keycode_32[7:0] == 8'h2c))
			keycode = 8'h2c;
		//player2
		if ((keycode_32[31:24] == 8'h50) || (keycode_32[23:16] == 8'h50) || (keycode_32[15:8] == 8'h50) || (keycode_32[7:0] == 8'h50))
			keycode2 = 8'h04;
		if ((keycode_32[31:24] == 8'h52) || (keycode_32[23:16] == 8'h52) || (keycode_32[15:8] == 8'h52) || (keycode_32[7:0] == 8'h52))
			keycode2 = 8'h1a;
		if ((keycode_32[31:24] == 8'h4f) || (keycode_32[23:16] == 8'h4f) || (keycode_32[15:8] == 8'h4f) || (keycode_32[7:0] == 8'h4f))
			keycode2 = 8'h07;
		if ((keycode_32[31:24] == 8'h51) || (keycode_32[23:16] == 8'h51) || (keycode_32[15:8] == 8'h51) || (keycode_32[7:0] == 8'h51))
			keycode2 = 8'h16;
		if ((keycode_32[31:24] == 8'h28) || (keycode_32[23:16] == 8'h28) || (keycode_32[15:8] == 8'h28) || (keycode_32[7:0] == 8'h28))
			keycode2 = 8'h2c;
		//IR
		if ((keycode0 == 8'h12) && (keycode_32 == 32'h0000))
			keycode2 = 8'h09;
		end

    
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    
	 logic start;
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
	 logic [9:0] DrawX, DrawY;
	 
	 logic [3:0]player_data_f;
    logic [3:0]player_data_d;
    logic [3:0]player_data_l;
    logic [3:0]player_data_r;
    logic [3:0]player_data_f2;
    logic [3:0]player_data_d2;
    logic [3:0]player_data_l2;
    logic [3:0]player_data_r2;
    logic [18:0]read_address;
    logic [18:0]read_address2;
	 logic [18:0]read_address_shoe;
	 logic [18:0]read_address_shoe2;
	 logic [18:0]read_address_wall1;
    logic [18:0]read_address_wall1_2;
	 logic [18:0]read_address_bomb;
	 logic [18:0]read_address_bomb2;
	 logic [3:0]shoe_data;
	 logic [3:0]box_data;
    logic [3:0]bomb_data;
    logic [3:0]bomb_data2;
	 
    logic is_ball;
	 logic is_wall1;
	 logic is_wall2;
	 logic is_wall3;
	 logic is_wall4;
	 logic is_wall5;
	 logic is_wall6;
	 logic is_wall7;
	 logic is_wall8;
	 logic is_wall9;
	 logic is_wall10;
	 logic is_wall11;
	 logic is_wall12;
	 logic is_shoe1;
	 logic is_bomb;
	 logic is_fire;
	 logic bombstart;
	 logic bomb_exist;
	 logic bomb_exploding;
	 logic bombed_wall1;
	 logic bombed_wall2;
	 logic bombed_wall3;
	 logic bombed_wall4;
	 logic bombed_wall5;
	 logic bombed_wall6;
	 logic bombed_wall7;
	 logic bombed_wall8;
	 logic bombed_wall9;
	 logic bombed_wall10;
	 logic bombed_wall11;
	 logic bombed_wall12;
	 logic bombed_ball;
	 logic shoe_on1;
	 logic leftgraph;
	 logic rightgraph;
	 logic upgraph;
	 logic downgraph;
	 //sss
	 logic is_ball2;
	 logic is_wall1_2;
	 logic is_wall22;
	 logic is_wall32;
	 logic is_wall42;
	 logic is_wall52;
	 logic is_wall62;
	 logic is_wall72;
	 logic is_wall82;
	 logic is_wall92;
	 logic is_wall102;
	 logic is_wall112;
	 logic is_wall122;
	 logic is_shoe12;
	 logic is_bomb2;
	 logic is_fire2;
	 logic bombstart2;
	 logic bomb_exist2;
	 logic bomb_exploding2;
	 logic bombed_wall1_2;
	 logic bombed_wall22;
	 logic bombed_wall32;
	 logic bombed_wall42;
	 logic bombed_wall52;
	 logic bombed_wall62;
	 logic bombed_wall72;
	 logic bombed_wall82;
	 logic bombed_wall92;
	 logic bombed_wall102;
	 logic bombed_wall112;
	 logic bombed_wall122;
	 logic bombed_ball2;
	 logic shoe_on2;
	 logic leftgraph2;
	 logic rightgraph2;
	 logic upgraph2;
	 logic downgraph2;
	 
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     lab8_soc nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode_32),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // TODO: Fill in the connections for the rest of the modules 
    VGA_controller vga_controller_instance(.Clk,
														 .Reset(Reset_h), 
														 .VGA_HS, 
														 .VGA_VS,
														 .VGA_CLK,
														 .VGA_BLANK_N,
														 .VGA_SYNC_N,
														 .DrawX,
														 .DrawY);
    
    // Which signal should be frame_clk?
    ball ball_instance(.Clk,
							  .Reset(Reset_h),
							  .frame_clk(VGA_VS),
							  .DrawX,
							  .DrawY,
							  .keycode,
							  .bomb_exist,
							  .bomb_exploding,
							  .start,
							  .is_ball,
							  .is_wall1,
							  .is_wall2,
							  .is_wall3,
							  .is_wall4,
							  .is_wall5,
							  .is_wall6,
							  .is_wall7,
							  .is_wall8,
							  .is_wall9,
							  .is_wall10,
							  .is_wall11,
							  .is_wall12,
							  .is_bomb,
							  .is_fire,
							  .is_shoe1,
							  .bombstart,
							  .bombed_wall1,
							  .bombed_wall2,
							  .bombed_wall3,
							  .bombed_wall4,
							  .bombed_wall5,
							  .bombed_wall6,
							  .bombed_wall7,
							  .bombed_wall8,
							  .bombed_wall9,
							  .bombed_wall10,
							  .bombed_wall11,
							  .bombed_wall12,
							  .shoe_on1,
							  .leftgraph,
							  .rightgraph,
							  .upgraph,
							  .downgraph,
							  .Bomb_X_Center,
							  .Bomb_Y_Center,
							  .Ball_X_Pos,
							  .Ball_Y_Pos,
							  .bombed_wall1_2,
							  .bombed_wall22,
							  .bombed_wall32,
							  .bombed_wall42,
							  .bombed_wall52,
							  .bombed_wall62,
							  .bombed_wall72,
							  .bombed_wall82,
							  .bombed_wall92,
							  .bombed_wall102,
							  .bombed_wall112,
							  .bombed_wall122,
							  .read_address,
							  .read_address_shoe,
							  .read_address_wall1,
							  .read_address_bomb,
							  .shoe_on2
							  );
	//sss
	ball ball_instance2(.Clk,
							  .Reset(Reset_h),
							  .frame_clk(VGA_VS),
							  .DrawX,
							  .DrawY,
							  .keycode(keycode2),
							  .bomb_exist(bomb_exist2),
							  .bomb_exploding(bomb_exploding2),
							  .start(start2),
							  .is_ball(is_ball2),
							  .is_wall1(is_wall1_2),
							  .is_wall2(is_wall22),
							  .is_wall3(is_wall32),
							  .is_wall4(is_wall42),
							  .is_wall5(is_wall52),
							  .is_wall6(is_wall62),
							  .is_wall7(is_wall72),
							  .is_wall8(is_wall82),
							  .is_wall9(is_wall92),
							  .is_wall10(is_wall102),
							  .is_wall11(is_wall112),
							  .is_wall12(is_wall122),
							  .is_bomb(is_bomb2),
							  .is_fire(is_fire2),
							  .is_shoe1(is_shoe12),
							  .bombstart(bombstart2),
							  .bombed_wall1(bombed_wall1_2),
							  .bombed_wall2(bombed_wall22),
							  .bombed_wall3(bombed_wall32),
							  .bombed_wall4(bombed_wall42),
							  .bombed_wall5(bombed_wall52),
							  .bombed_wall6(bombed_wall62),
							  .bombed_wall7(bombed_wall72),
							  .bombed_wall8(bombed_wall82),
							  .bombed_wall9(bombed_wall92),
							  .bombed_wall10(bombed_wall102),
							  .bombed_wall11(bombed_wall112),
							  .bombed_wall12(bombed_wall122),
							  .shoe_on1(shoe_on2),
							  .leftgraph(leftgraph2),
							  .rightgraph(rightgraph2),
							  .upgraph(upgraph2),
							  .downgraph(downgraph2),
							  .Bomb_X_Center(Bomb_X_Center2),
							  .Bomb_Y_Center(Bomb_Y_Center2),
							  .Ball_X_Pos(Ball_X_Pos2),
							  .Ball_Y_Pos(Ball_Y_Pos2),
							  .bombed_wall1_2(bombed_wall1),
							  .bombed_wall22(bombed_wall2),
							  .bombed_wall32(bombed_wall3),
							  .bombed_wall42(bombed_wall4),
							  .bombed_wall52(bombed_wall5),
							  .bombed_wall62(bombed_wall6),
							  .bombed_wall72(bombed_wall7),
							  .bombed_wall82(bombed_wall8),
							  .bombed_wall92(bombed_wall9),
							  .bombed_wall102(bombed_wall10),
							  .bombed_wall112(bombed_wall11),
							  .bombed_wall122(bombed_wall12),
							  .read_address(read_address2),
							  .read_address_shoe(read_address_shoe2),
							  .read_address_wall1(read_address_wall1_2),
							  .read_address_bomb(read_address_bomb2),
							  .shoe_on2(shoe_on1)
							  );
	
	 bomb_state bombstate(.Clk(Clk), .Reset(Reset_h), .VGA_VS(VGA_VS), .bombstart(bombstart),
								.bomb_exploding(bomb_exploding), .bomb_exist(bomb_exist));
	 //double
	 bomb_state bombstate2(.Clk(Clk), .Reset(Reset_h), .VGA_VS(VGA_VS), .bombstart(bombstart2),
								.bomb_exploding(bomb_exploding2), .bomb_exist(bomb_exist2));
    
    color_mapper color_instance(.start(start2),
										  .is_ball,
										  .is_wall1,
										  .is_wall2,
										  .is_wall3,
										  .is_wall4,
										  .is_wall5,
										  .is_wall6,
										  .is_wall7,
										  .is_wall8,
										  .is_wall9,
										  .is_wall10,
										  .is_wall11,
										  .is_wall12,
										  .is_bomb,
										  .is_fire,
										  .is_shoe1,
										  .bombed_wall1,
										  .bombed_wall2,
										  .bombed_wall3,
										  .bombed_wall4,
										  .bombed_wall5,
										  .bombed_wall6,
										  .bombed_wall7,
										  .bombed_wall8,
										  .bombed_wall9,
										  .bombed_wall10,
										  .bombed_wall11,
										  .bombed_wall12,
										  .bombed_ball,
										  .shoe_on1,
										  .leftgraph,
										  .rightgraph,
										  .upgraph,
										  .downgraph,
										  .DrawX,
										  .DrawY,
										  .VGA_R,
										  .VGA_G,
										  .VGA_B,
										  .is_ball2,
										  .is_bomb2,
										  .is_fire2,
										  .bombed_wall1_2,
										  .bombed_wall22,
										  .bombed_wall32,
										  .bombed_wall42,
										  .bombed_wall52,
										  .bombed_wall62,
										  .bombed_wall72,
										  .bombed_wall82,
										  .bombed_wall92,
										  .bombed_wall102,
										  .bombed_wall112,
										  .bombed_wall122,
										  .bombed_ball2,
										  .shoe_on2,
										  .leftgraph2,
										  .rightgraph2,
										  .upgraph2,
										  .downgraph2,
										  .player_data_f,
											.player_data_d,
											.player_data_l,
											.player_data_r,
											.player_data_f2,
											.player_data_d2,
											.player_data_l2,
											.player_data_r2,
											.shoe_data,
											.box_data,
											.bomb_data,
											.bomb_data2,
											.Clk);
    
	 
   //Music

	logic [15:0] address;
	logic [15:0] music_content;
	logic [15:0] music_content2;
	logic [15:0] music_content0;
	logic [16:0] address2;
	logic			INIT2;
	logic			INIT0;
	logic	INIT, INIT_FINISH, adc_full, data_over;
	logic [31:0] ADCDATA;
	audio_interface music(	
									.LDATA(music_content0),
									.RDATA(music_content0),
									.clk(Clk),
									.Reset(Reset_h), 
									.INIT(INIT0), 									
									.INIT_FINISH(INIT_FINISH), 					
									.adc_full(adc_full), 						
									.data_over(data_over), 						
									.AUD_MCLK(AUD_XCK), 						
									.AUD_BCLK(AUD_BCLK), 						
									.AUD_ADCDAT(AUD_ADCDAT), 					
									.AUD_DACDAT(AUD_DACDAT), 					
									.AUD_DACLRCK(AUD_DACLRCK),
									.AUD_ADCLRCK(AUD_ADCLRCK),
									.I2C_SDAT(I2C_SDAT), 						
									.I2C_SCLK(I2C_SCLK), 						
									.ADCDATA(ADCDATA) 						
									);
	music_state music_state0(.*, .Reset(Reset_h));
	music music0(.*);
	music_state2 music_state2(.*, .Reset(Reset_h));
	music2 music2(.*);
	//IR
	logic	[31:0]		ir_dout;
	IR	IR0(.CLOCK_50(CLOCK_50),
			 .s_rst_n(~Reset_h),
			 .IRDA_RXD(IRDA_RXD),
			 .ir_dout(ir_dout)
			 );
	
    // Display keycode on hex display
    HexDriver hex_inst_0 (keycode0[3:0], HEX0);
    HexDriver hex_inst_1 (keycode0[7:4], HEX1);
	 
	 always_comb
    begin
	   LEDG = 8'b0000;
		case(keycode)
					8'h04: begin
								LEDG = 8'b0001;
							end
					8'h07: begin
								LEDG = 8'b0010;
							end
					8'h1a: begin
								LEDG = 8'b0100;
							end
					8'h16: begin
								LEDG = 8'b1000;
							end
		endcase
    end
    
	 
	 pfront_RAM player_ram0 (.read_address(read_address), .Clk(Clk), .data_Out(player_data_f));
    pdown_RAM  player_ram1 (.read_address(read_address), .Clk(Clk), .data_Out(player_data_d));
    pleft_RAM  player_ram2 (.read_address(read_address), .Clk(Clk), .data_Out(player_data_l));
    pright_RAM  player_ram3 (.read_address(read_address), .Clk(Clk), .data_Out(player_data_r));
  
    p2front_RAM player_ram0_2 (.read_address(read_address2), .Clk(Clk), .data_Out(player_data_f2));
    p2down_RAM  player_ram1_2 (.read_address(read_address2), .Clk(Clk), .data_Out(player_data_d2));
    p2left_RAM  player_ram2_2 (.read_address(read_address2), .Clk(Clk), .data_Out(player_data_l2));
    p2right_RAM  player_ram3_2 (.read_address(read_address2), .Clk(Clk), .data_Out(player_data_r2));
	 //shoe
	 shoe_RAM shoe_ram0 (.read_address(read_address_shoe), .Clk(Clk), .data_Out(shoe_data));
	 //box
	 box_RAM box_ram0 (.read_address(read_address_wall1), .Clk(Clk), .data_Out(box_data));
	 //bomb
    zhadan_RAM bomb_ram0 (.read_address(read_address_bomb), .Clk(Clk), .data_Out(bomb_data));
    zhadan1_RAM bomb_ram1 (.read_address(read_address_bomb2), .Clk(Clk), .data_Out(bomb_data2));
	 
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #1/2:
        What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
             connect to the keyboard? List any two.  Give an answer in your Post-Lab.
    **************************************************************************************/
	 parameter [9:0] Wall_Size = 10'd20;
	 logic [9:0] Bomb_X_Center,Bomb_Y_Center;
	 logic [9:0] Ball_X_Pos,Ball_Y_Pos;
	 logic [9:0] Bomb_X_Center2,Bomb_Y_Center2;
	 logic [9:0] Ball_X_Pos2,Ball_Y_Pos2;
	 int Wall_size;
	 int bombtoball_X11;
	 int bombtoball_Y11;
	 int bombtoball_X12;
	 int bombtoball_Y12;
	 int bombtoball_X21;
	 int bombtoball_Y21;
	 int bombtoball_X22;
	 int bombtoball_Y22;
	 assign bombtoball_X11 = (Bomb_X_Center >= Ball_X_Pos)? Bomb_X_Center - Ball_X_Pos : Ball_X_Pos - Bomb_X_Center;
	 assign bombtoball_Y11 = (Bomb_Y_Center >= Ball_Y_Pos)? Bomb_Y_Center - Ball_Y_Pos : Ball_Y_Pos - Bomb_Y_Center;
	 assign bombtoball_X12 = (Bomb_X_Center >= Ball_X_Pos2)? Bomb_X_Center - Ball_X_Pos2 : Ball_X_Pos2 - Bomb_X_Center;
	 assign bombtoball_Y12 = (Bomb_Y_Center >= Ball_Y_Pos2)? Bomb_Y_Center - Ball_Y_Pos2 : Ball_Y_Pos2 - Bomb_Y_Center;
	 assign bombtoball_X21 = (Bomb_X_Center2 >= Ball_X_Pos)? Bomb_X_Center2 - Ball_X_Pos : Ball_X_Pos - Bomb_X_Center2;
	 assign bombtoball_Y21 = (Bomb_Y_Center2 >= Ball_Y_Pos)? Bomb_Y_Center2 - Ball_Y_Pos : Ball_Y_Pos - Bomb_Y_Center2;
	 assign bombtoball_X22 = (Bomb_X_Center2 >= Ball_X_Pos2)? Bomb_X_Center2 - Ball_X_Pos2 : Ball_X_Pos2 - Bomb_X_Center2;
	 assign bombtoball_Y22 = (Bomb_Y_Center2 >= Ball_Y_Pos2)? Bomb_Y_Center2 - Ball_Y_Pos2 : Ball_Y_Pos2 - Bomb_Y_Center2;
	 assign Wall_size = Wall_Size;
	 
	 always_ff @ (posedge Clk)
    begin
			if(Reset_h)
				bombed_ball = 1'b0;
			if(((bomb_exploding == 1'b1) && (((bombtoball_Y11 <= 4*Wall_size) && (bombtoball_X11 <= Wall_size)) || ((bombtoball_Y11 <= Wall_size) && (bombtoball_X11 <= 4*Wall_size)))) 				||					((bomb_exploding2 == 1'b1) && (((bombtoball_Y21 <= 4*Wall_size) && (bombtoball_X21 <= Wall_size)) || ((bombtoball_Y21 <= Wall_size) && (bombtoball_X21 <= 4*Wall_size)))))
				bombed_ball = 1'b1;
	 end
	 always_ff @ (posedge Clk)
    begin
			if(Reset_h)
				bombed_ball2 = 1'b0;
			if(((bomb_exploding == 1'b1) && (((bombtoball_Y12 <= 4*Wall_size) && (bombtoball_X12 <= Wall_size)) || ((bombtoball_Y12 <= Wall_size) && (bombtoball_X12 <= 4*Wall_size)))) 				||					((bomb_exploding2 == 1'b1) && (((bombtoball_Y22 <= 4*Wall_size) && (bombtoball_X22 <= Wall_size)) || ((bombtoball_Y22 <= Wall_size) && (bombtoball_X22 <= 4*Wall_size)))))
				bombed_ball2 = 1'b1;
	 end
	 
	 //audio_interface
	always_ff @ (posedge Clk)
	begin
		if ((bombed_ball == 1) || (bombed_ball2 == 1))
		begin
			INIT0 <= INIT2;
			music_content0 <= music_content2;
		end
		else
		begin
			INIT0 <= INIT;
			music_content0 <= music_content;
		end
	end

endmodule
