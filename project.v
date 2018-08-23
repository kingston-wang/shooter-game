module project(
		input CLOCK_50,
		input [9:0] SW,
		input [3:0] KEY,
		output [9:0] LEDR,
		inout	PS2_CLK, PS2_DAT,
		output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N,
		output [7:0] VGA_R, VGA_G, VGA_B, 
		output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
	);
	
	reg [7:0] x;
	reg [6:0] y;
	reg [23:0] colour;
	reg writeEn;
	
// INSTANTIATES VGA ADAPTER
	vga_adapter VGA(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 8;
		defparam VGA.BACKGROUND_IMAGE = "background_5.mif";

// LEFTMOST LEDs DISPLAY LEFT / MIDDLE / RIGHT BUTTONS
	assign LEDR = {button[0], button[1], button[2], active_b1, active_b2, active_b3, active_b4, active_t1, active_t2, active_t3};
	
// LEFTMOST HEX DISPLAYS: COUNTDOWN TIMER
// RIGHTMOST HEX DISPLAYS: SCORE
	hex_decoder H0(score[3:0], HEX0);
	hex_decoder H1(score[7:4], HEX1);
	hex_decoder H2(4'd0, HEX2);
	hex_decoder H3(4'd0, HEX3);
	hex_decoder H4(half_minute[26:23], HEX4);
	hex_decoder H5(half_minute[30:27], HEX5);
	
// A BUNCH OF WIRES AND REGS
	wire [7:0] x_mouse, x_b, x_c, x_t1, x_t2, x_t3, x_r1, x_r2, x_r3, x_r4, x_r5, x_r6, x_r7, x_r8, x_r9, x_r10;
	wire [6:0] y_mouse, y_b, y_c, y_t1, y_t2, y_t3, y_r1, y_r2, y_r3, y_r4, y_r5, y_r6, y_r7, y_r8, y_r9, y_r10;
	
	wire [23:0] colour_t1, colour_t2, colour_t3, colour_r1, colour_r2, colour_r3, colour_r4, colour_r5, colour_r6, colour_r7, colour_r8, colour_r9, colour_r10;
	wire writeEn_b, writeEn_c, writeEn_t1, writeEn_t2, writeEn_t3, writeEn_r1, writeEn_r2, writeEn_r3, writeEn_r4, writeEn_r5, writeEn_r6, writeEn_r7, writeEn_r8, writeEn_r9, writeEn_r10;
	
	wire [2:0] button;
	
	reg reset_mouse, active_c, active_b, active_b1, active_b2, active_b3, active_b4, active_t1, active_t2, active_t3, active_r1, active_r2, active_r3, active_r4, active_r5, active_r6, active_r7, active_r8, active_r9, active_r10;
	reg start_b, start_c, start_t1, start_t2, start_t3, start_r1, start_r2, start_r3, start_r4, start_r5, start_r6, start_r7, start_r8, start_r9, start_r10;
	wire done_b, done_c, done_t1, done_t2, done_t3, done_r1, done_r2, done_r3, done_r4, done_r5, done_r6, done_r7, done_r8, done_r9, done_r10;
	wire clear_c, clear_t1, clear_t2, clear_t3, clear_r1, clear_r2, clear_r3, clear_r4, clear_r5, clear_r6, clear_r7, clear_r8, clear_r9, clear_r10;
	
	
// INSTANTIATES ALL DRAWING MODULES
	
	mouse M1(CLOCK_50, reset_mouse, PS2_CLK, PS2_DAT, x_mouse, y_mouse, button[1], button[2], button[0]);
	display D1(CLOCK_50, reset_mouse, writeEn_c, x_mouse, y_mouse, x_c, y_c, start_c, done_c, clear_c);
	
	target_1 T1(CLOCK_50, ~KEY[0], start_t1, active_t1, done_t1, clear_t1, writeEn_t1, x_t1, y_t1, colour_t1, x_c, y_c, button, score_t1);
	target_2 T2(CLOCK_50, ~KEY[0], start_t2, active_t2, done_t2, clear_t2, writeEn_t2, x_t2, y_t2, colour_t2, x_c, y_c, button, score_t2);
	target_3 T3(CLOCK_50, ~KEY[0], start_t3, active_t3, done_t3, clear_t3, writeEn_t3, x_t3, y_t3, colour_t3, x_c, y_c, 8'd63, 7'd43, button, score_t3);
	
	random R1(CLOCK_50, ~KEY[0], start_r1, active_r1, done_r1, clear_r1, writeEn_r1, x_r1, y_r1, colour_r1, 8'd25, 7'd40, 15'd3000);
	random R2(CLOCK_50, ~KEY[0], start_r2, active_r2, done_r2, clear_r2, writeEn_r2, x_r2, y_r2, colour_r2, 8'd50, 7'd40, 15'd6000);
	random R3(CLOCK_50, ~KEY[0], start_r3, active_r3, done_r3, clear_r3, writeEn_r3, x_r3, y_r3, colour_r3, 8'd75, 7'd40, 15'd9000);
	random R4(CLOCK_50, ~KEY[0], start_r4, active_r4, done_r4, clear_r4, writeEn_r4, x_r4, y_r4, colour_r4, 8'd100, 7'd40, 15'd12000);
	random R5(CLOCK_50, ~KEY[0], start_r5, active_r5, done_r5, clear_r5, writeEn_r5, x_r5, y_r5, colour_r5, 8'd125, 7'd40, 15'd15000);
	random R6(CLOCK_50, ~KEY[0], start_r6, active_r6, done_r6, clear_r6, writeEn_r6, x_r6, y_r6, colour_r6, 8'd25, 7'd80, 15'd18000);
	random R7(CLOCK_50, ~KEY[0], start_r7, active_r7, done_r7, clear_r7, writeEn_r7, x_r7, y_r7, colour_r7, 8'd50, 7'd80, 15'd21000);
	random R8(CLOCK_50, ~KEY[0], start_r8, active_r8, done_r8, clear_r8, writeEn_r8, x_r8, y_r8, colour_r8, 8'd75, 7'd80, 15'd24000);
	random R9(CLOCK_50, ~KEY[0], start_r9, active_r9, done_r9, clear_r9, writeEn_r9, x_r9, y_r9, colour_r9, 8'd100, 7'd80, 15'd27000);
	random R10(CLOCK_50, ~KEY[0], start_r10, active_r10, done_r10, clear_r10, writeEn_r10, x_r10, y_r10, colour_r10, 8'd125, 7'd80, 15'd30000);
	
	picture P1(CLOCK_50, ~KEY[0], start_b, active_b, done_b, writeEn_b, x_b, y_b);
	
	
// COUNTERS

// COUNTS 1/60 OF A SECOND
// USED BY DISPLAY CONTROLLER TO UPDATE THE SCREEN
	reg [19:0] frame_rate;
	always @(posedge CLOCK_50)
		if (~KEY[0] || (|frame_rate == 0) ) frame_rate <= 20'd833333;
		else frame_rate <= frame_rate - 1;

// COUNTS 1/2 OF A SECOND
// USED BY RANDOM OBJECT COLOUR RANDOMIZER
	reg [5:0] frame_counter;
	always @(posedge CLOCK_50)
		if (~KEY[0] || (|frame_counter == 0) ) frame_counter <= 6'd29;
		else if (|frame_rate == 0) frame_counter <= frame_counter - 1;
	
	
// SCOREKEEPER
	wire [5:0] score_t1, score_t2, score_t3;
	reg [7:0] score;
	
	always @(posedge CLOCK_50)
		if (~KEY[0]) score <= 8'd0;
		else score <= score_t1 + score_t2 + score_t3;
	
	
//	SPECIAL BACKGROUNDS

// RECTANGULAR FRAME IN INTERMEDIATE SCREENS
	
	reg [23:0] offset_1;
	reg [7:0] x_offset_1A, x_offset_1B, x_offset_1C, x_offset_1D, x_offset_1E, x_offset_1F;
	reg [6:0] y_offset_1A, y_offset_1B, y_offset_1C, y_offset_1D, y_offset_1E, y_offset_1F;
	
	always @(posedge CLOCK_50)
		if (~KEY[0] || ~writeEn_b) offset_1 <= 24'd0;
		
		else if (writeEn_b && (x_memIn >= x_offset_1A && x_memIn <= x_offset_1B) && (y_memIn == y_offset_1A || y_memIn == y_offset_1B) )
			offset_1 <= 24'd16700000;
		else if (writeEn_b && (x_memIn == x_offset_1A || x_memIn == x_offset_1B) && (y_memIn >= y_offset_1A && y_memIn <= y_offset_1B) )
			offset_1 <= 24'd16700000;
		
		else if (writeEn_b && (x_memIn >= x_offset_1C && x_memIn <= x_offset_1D) && (y_memIn == y_offset_1C || y_memIn == y_offset_1D) )
			offset_1 <= 24'd16700000;
		else if (writeEn_b && (x_memIn == x_offset_1C || x_memIn == x_offset_1D) && (y_memIn >= y_offset_1C && y_memIn <= y_offset_1D) )
			offset_1 <= 24'd16700000;
		
		else if (writeEn_b && (x_memIn >= x_offset_1E && x_memIn <= x_offset_1F) && (y_memIn == y_offset_1E || y_memIn == y_offset_1F) )
			offset_1 <= 24'd16700000;
		else if (writeEn_b && (x_memIn == x_offset_1E || x_memIn == x_offset_1F) && (y_memIn >= y_offset_1E && y_memIn <= y_offset_1F) )
			offset_1 <= 24'd16700000;
		
		else offset_1 <= 24'd0;
	
	always @(posedge CLOCK_50)
		if (~KEY[0]) begin
			x_offset_1E <= 8'd50;
			x_offset_1F <= 8'd108;
			y_offset_1E <= 7'd50;
			y_offset_1F <= 7'd68;
		end
		else if (|x_offset_1E == 0) begin
			x_offset_1E <= 8'd54;
			x_offset_1F <= 8'd104;
			y_offset_1E <= 7'd54;
			y_offset_1F <= 7'd64;
		end
		else if (|frame_rate == 0) begin
			x_offset_1E <= x_offset_1E - 1;
			x_offset_1F <= x_offset_1F + 1;
			y_offset_1E <= y_offset_1E - 1;
			y_offset_1F <= y_offset_1F + 1;
		end
	
	always @(posedge CLOCK_50)
		if (~KEY[0]) begin
			x_offset_1C <= 8'd52;
			x_offset_1D <= 8'd106;
			y_offset_1C <= 7'd52;
			y_offset_1D <= 7'd66;
		end
		else if (|x_offset_1C == 0) begin
			x_offset_1C <= 8'd54;
			x_offset_1D <= 8'd104;
			y_offset_1C <= 7'd54;
			y_offset_1D <= 7'd64;
		end
		else if (|frame_rate == 0) begin
			x_offset_1C <= x_offset_1C - 1;
			x_offset_1D <= x_offset_1D + 1;
			y_offset_1C <= y_offset_1C - 1;
			y_offset_1D <= y_offset_1D + 1;
		end
	
	always @(posedge CLOCK_50)
		if (~KEY[0] || (|x_offset_1A == 0)) begin
			x_offset_1A <= 8'd54;
			x_offset_1B <= 8'd104;
			y_offset_1A <= 7'd54;
			y_offset_1B <= 7'd64;
		end
		else if (|frame_rate == 0) begin
			x_offset_1A <= x_offset_1A - 1;
			x_offset_1B <= x_offset_1B + 1;
			y_offset_1A <= y_offset_1A - 1;
			y_offset_1B <= y_offset_1B + 1;
		end

		
// CIRCULAR FRAME IN INTERMEDIATE SCREENS
// NOT IMPLEMENTED

//	reg [23:0] offset_2;
//	reg [7:0] radius;
//	
//	wire [7:0] x_centre;
//	wire [6:0] y_centre;
//	
//	assign x_centre = 8'd79;
//	assign y_centre = 7'd59;
//	
//	always @(posedge CLOCK_50)
//		if (~KEY[0] || ~writeEn_b) offset_2 <= 24'd0;
//		else if (writeEn_b && (x_memIn < x_centre) && (y_memIn < y_centre) && ( (x_memIn > x_centre - radius) && (y_memIn > y_centre - radius) ) 
//		&& ( (x_centre-x_memIn)*(x_centre-x_memIn) + (y_centre-y_memIn)*(y_centre-y_memIn) >= (radius - 1) * (radius - 1) ) && ( (x_centre-x_memIn)*(x_centre-x_memIn) + (y_centre-y_memIn)*(y_centre-y_memIn) <= (radius + 1) * (radius + 1) ) )
//			offset_2 <= 24'd16000000;
//		else if (writeEn_b && (x_memIn > x_centre) && (y_memIn < y_centre) && ( (x_memIn < x_centre + radius) && (y_memIn > y_centre - radius) ) 
//		&& ( (x_memIn-x_centre)*(x_memIn-x_centre) + (y_centre-y_memIn)*(y_centre-y_memIn) >= (radius - 1) * (radius - 1) ) && ( (x_memIn-x_centre)*(x_memIn-x_centre) + (y_centre-y_memIn)*(y_centre-y_memIn) <= (radius + 1) * (radius + 1) ) )
//			offset_2 <= 24'd16000000;
//		else if (writeEn_b && (x_memIn < x_centre) && (y_memIn > y_centre) && ( (x_memIn > x_centre - radius) && (y_memIn < y_centre + radius) ) 
//		&& ( (x_centre-x_memIn)*(x_centre-x_memIn) + (y_memIn-y_centre)*(y_memIn-y_centre) >= (radius - 1) * (radius - 1) ) && ( (x_centre-x_memIn)*(x_centre-x_memIn) + (y_memIn-y_centre)*(y_memIn-y_centre) <= (radius + 1) * (radius + 1) ) )
//			offset_2 <= 24'd16000000;
//		else if (writeEn_b && (x_memIn > x_centre) && (y_memIn > y_centre) && ( (x_memIn < x_centre + radius) && (y_memIn < y_centre + radius) ) 
//		&& ( (x_memIn-x_centre)*(x_memIn-x_centre) + (y_memIn-y_centre)*(y_memIn-y_centre) >= (radius - 1) * (radius - 1) ) && ( (x_memIn-x_centre)*(x_memIn-x_centre) + (y_memIn-y_centre)*(y_memIn-y_centre) <= (radius + 1) * (radius + 1) ) )
//			offset_2 <= 24'd16000000;
//		else offset_2 <= 24'd0;
//	
//	always @(posedge CLOCK_50)
//		if (~KEY[0] || (radius == 8'd79) ) radius <= 8'd0;
//		else if (|frame_rate == 0) radius <= radius + 1;

	
// DISPLAY A PALETTE OF COLOURS
// NOT IMPLEMENTED
	
//	reg [23:0] offset_1;	
//	always @(posedge CLOCK_50)
//		if (~KEY[0] || ~writeEn_b) offset_1 <= 24'b000000000000000000000000;
//		else if (writeEn_b) offset_1 <= offset_1 + 24'd10;
//		
//	reg [23:0] offset_2;	
//	always @(posedge CLOCK_50)
//		if (~KEY[0] || ~writeEn_b) offset_2 <= 24'b000000000000000011111111;
//		else if (writeEn_b) offset_2 <= offset_2 + 24'd10;
//		
//	reg [23:0] offset_3;	
//	always @(posedge CLOCK_50)
//		if (~KEY[0] || ~writeEn_b) offset_3 <= 24'b000000001111111111111111;
//		else if (writeEn_b) offset_3 <= offset_3 + 24'd10;
//		
//	reg [23:0] offset_4;	
//	always @(posedge CLOCK_50)
//		if (~KEY[0] || ~writeEn_b) offset_4 <= 24'b111111111111111111111111;
//		else if (writeEn_b) offset_4 <= offset_4 + 24'd10;
	

// BACKGROUND ROM
	
	reg [7:0] x_memIn, x_memOut;
	reg [6:0] y_memIn, y_memOut;
	reg writeEn_memIn, writeEn_memOut;
	
	wire [23:0] colour_1, colour_2, colour_3, colour_4;
	reg [23:0] colour_ROM;

// CHOOSE WHICH ROM TO USE FOR BACKGROUND
// COLOUR_ROM USED FOR UPDATING BACKGROUND OR ERASING OBJECT
// OFFSET COMES FROM RECTANGULAR FRAME ABOVE
	always @(*)
		if (~KEY[0]) colour_ROM = 24'd0;
		else if (active_b1) colour_ROM = colour_1 + offset_1;
		else if (active_b2) colour_ROM = colour_2 + offset_1;
		else if (active_b3) colour_ROM = colour_3 + offset_1;
		else if (active_b4) colour_ROM = colour_4 + offset_1;
		else colour_ROM = 24'd0;
	
// DELAY X, Y, WRITE SIGNALS TO MEET ROM TIMING REQUIREMENTS
	always @(posedge CLOCK_50)
		if (~KEY[0]) begin
			x_memOut <= 8'd0;
			y_memOut <= 7'd0;
			writeEn_memOut <= 1'b0;
		end
		else begin
			x_memOut <= x_memIn;
			y_memOut <= y_memIn;
			writeEn_memOut <= writeEn_memIn;
		end
	
// ADDRESS FOR ACCESSING ROM
	wire [14:0] address;
	assign address = (8'd160 * y_memIn) + x_memIn;
	
// ROM FOR EACH BACKGROUND (STORES 160x120 PIXELS, 8-BIT PER COLOUR) 
	background_1 B1(address, CLOCK_50, colour_1);
	background_2 B2(address, CLOCK_50, colour_2);
	background_3 B3(address, CLOCK_50, colour_3);
	background_4 B4(address, CLOCK_50, colour_4);
	
	
// GAME CONTROLLER	 
	
// COUNTDOWN TIMER THAT COUNTS 30 SECONDS
// GOVERNS THE DURATION OF EACH STATE
	reg [30:0] half_minute;
	always @(posedge CLOCK_50)
		if (~KEY[0] || (|half_minute == 0) ) half_minute <= 31'd1499999999;
		else if (active_t1 || active_t2 || active_t3) half_minute <= half_minute - 1;	 
	
// STATE TABLE
	reg [3:0] current_state, next_state;
	localparam  S_MOUSE_RESET   = 4'd0,
					S_GAME_START    = 4'd1,
					S_INSTRUCTION_1 = 4'd2,
					S_PLOT_1        = 4'd3,
					S_INSTRUCTION_2 = 4'd4,
					S_PLOT_2        = 4'd5,
					S_INSTRUCTION_3 = 4'd6,
					S_PLOT_3        = 4'd7,
					S_GAME_END      = 4'd8;
					
	always@(*) 
		case (current_state)
		
			S_MOUSE_RESET:   next_state = (~KEY[1]) ? S_GAME_START : S_MOUSE_RESET;
					
			S_GAME_START:    next_state = (~KEY[1]) ? S_INSTRUCTION_1 : S_GAME_START;
			
			S_INSTRUCTION_1: next_state = (button[0]) ? S_PLOT_1 : S_INSTRUCTION_1;
			S_PLOT_1:        next_state = (half_minute <= 31'd749999999) ? S_INSTRUCTION_2 : S_PLOT_1;
			// STAGE 1 LASTS 15 SEC
			
			S_INSTRUCTION_2: next_state = (button[0]) ? S_PLOT_2 : S_INSTRUCTION_2;
			S_PLOT_2:        next_state = (half_minute <= 31'd249999999) ? S_INSTRUCTION_3 : S_PLOT_2;
			// STAGE 2 LASTS 10 SEC
			
			S_INSTRUCTION_3: next_state = (button[0]) ? S_PLOT_3 : S_INSTRUCTION_3;
			S_PLOT_3:        next_state = (half_minute >= 31'd249999999) ? S_GAME_END : S_PLOT_3;
			// STAGE 3 LASTS 5 SEC
			
			S_GAME_END:      next_state = (~KEY[1]) ? S_GAME_START : S_GAME_END;
			
			default: next_state = S_MOUSE_RESET;
		endcase
		
// ENABLE SIGNALS
	always @(*) begin

		reset_mouse = 1'b0;
		
		// IF ACTIVE CORRESPONDING TO AN OBJECT IS HIGH, 
		// THE OBJECT IS ALLOWED TO BE DRAWN
		active_c  = 1'b1;
		active_b  = 1'b0;
		active_b1 = 1'b0;
		active_b2 = 1'b0;
		active_b3 = 1'b0;
		active_b4 = 1'b0;
		
		active_t1 = 1'b0;
		active_t2 = 1'b0;
		active_t3 = 1'b0;
		
		active_r1 = 1'b0;
		active_r2 = 1'b0;
		active_r3 = 1'b0;
		active_r4 = 1'b0;
		active_r5 = 1'b0;
		active_r6 = 1'b0;
		active_r7 = 1'b0;
		active_r8 = 1'b0;
		active_r9 = 1'b0;
		active_r10 = 1'b0;

		case (current_state)
		
			S_MOUSE_RESET: begin
				active_c = 1'b0;
				reset_mouse = ~KEY[0];
			end
			
			S_INSTRUCTION_1: begin
				active_b1 = 1'b1;
				active_b  = 1'b1;
			end
			S_INSTRUCTION_2: begin
				active_b2 = 1'b1;
				active_b  = 1'b1;
			end
			S_INSTRUCTION_3: begin
				active_b3 = 1'b1;
				active_b  = 1'b1;
			end
			
			S_GAME_END: begin
				active_b4 = 1'b1;
				active_b  = 1'b1;
			end
			
			S_PLOT_1: begin
				active_t1 = 1'b1;
				active_b1 = 1'b1;
				active_r1 = 1'b1;
				active_r2 = 1'b1;
				active_r3 = 1'b1;
				active_r4 = 1'b1;
				active_r5 = 1'b1;
				active_r6 = 1'b1;
				active_r7 = 1'b1;
				active_r8 = 1'b1;
				active_r9 = 1'b1;
				active_r10 = 1'b1;
			end
			S_PLOT_2: begin
				active_t2 = 1'b1;
				active_b2 = 1'b1;
				active_r1 = 1'b1;
				active_r2 = 1'b1;
				active_r3 = 1'b1;
				active_r4 = 1'b1;
				active_r5 = 1'b1;
				active_r6 = 1'b1;
				active_r7 = 1'b1;
				active_r8 = 1'b1;
				active_r9 = 1'b1;
				active_r10 = 1'b1;
				
			end
			S_PLOT_3: begin
				active_t3 = 1'b1;
				active_b3 = 1'b1;
				active_r1 = 1'b1;
				active_r2 = 1'b1;
				active_r3 = 1'b1;
				active_r4 = 1'b1;
				active_r5 = 1'b1;
				active_r6 = 1'b1;
				active_r7 = 1'b1;
				active_r8 = 1'b1;
				active_r9 = 1'b1;
				active_r10 = 1'b1;
			end
			
		endcase
	end

// STATE FFs
	always @(posedge CLOCK_50)
		if (~KEY[0]) current_state <= S_MOUSE_RESET;
		else current_state <= next_state;
			
	
//	DISPLAY CONTROLLER
	
// STATE TABLE
	reg [4:0] current_state_1, next_state_1;
	
	localparam  S_START             = 5'd0,
					
					S_BACKGROUND_PLOT   = 5'd1,
					S_BACKGROUND_WAIT   = 5'd2,
					
					S_TARGET_PLOT_1     = 5'd3,
					S_TARGET_WAIT_1     = 5'd4,
					S_TARGET_PLOT_2     = 5'd5,
					S_TARGET_WAIT_2     = 5'd6,
					S_TARGET_PLOT_3     = 5'd7,
					S_TARGET_WAIT_3     = 5'd8,
					
					S_RANDOM_PLOT_1     = 5'd9,
					S_RANDOM_WAIT_1     = 5'd10,
					S_RANDOM_PLOT_2     = 5'd11,
					S_RANDOM_WAIT_2     = 5'd12,
					S_RANDOM_PLOT_3     = 5'd13,
					S_RANDOM_WAIT_3     = 5'd14,
					S_RANDOM_PLOT_4     = 5'd15,
					S_RANDOM_WAIT_4     = 5'd16,
					S_RANDOM_PLOT_5     = 5'd17,
					S_RANDOM_WAIT_5     = 5'd18,
					S_RANDOM_PLOT_6     = 5'd19,
					S_RANDOM_WAIT_6     = 5'd20,
					S_RANDOM_PLOT_7     = 5'd21,
					S_RANDOM_WAIT_7     = 5'd22,
					S_RANDOM_PLOT_8     = 5'd23,
					S_RANDOM_WAIT_8     = 5'd24,
					S_RANDOM_PLOT_9     = 5'd25,
					S_RANDOM_WAIT_9     = 5'd26,
					S_RANDOM_PLOT_10    = 5'd27,
					S_RANDOM_WAIT_10    = 5'd28,
					
					S_CURSOR_PLOT       = 5'd29,
					S_CURSOR_WAIT       = 5'd30,
					
					S_WAIT              = 5'd31;
					
	always @(*)
		 case (current_state_1)
				
				// DON'T START DRAWING UNTIL THE MOUSE IS WORKING
				S_START: next_state_1 = (active_t1 || active_t2 || active_t3 || active_b || active_c) ? S_BACKGROUND_PLOT : S_START;
				
				S_BACKGROUND_PLOT: next_state_1 = S_BACKGROUND_WAIT;
				
				// MOVE TO THE NEXT STATE IF :
				// 1. THE OBJECT HAS FINISHED DRAWING, OR
				// 2. THE OBJECT SHOULD NOT BE DRAWN
				S_BACKGROUND_WAIT: next_state_1 = (done_b || ~active_b) ? S_TARGET_PLOT_1 : S_BACKGROUND_WAIT;
				
				S_TARGET_PLOT_1: next_state_1 = S_TARGET_WAIT_1; 
				S_TARGET_WAIT_1: next_state_1 = (done_t1 || ~active_t1) ? S_TARGET_PLOT_2 : S_TARGET_WAIT_1;
				
				S_TARGET_PLOT_2: next_state_1 = S_TARGET_WAIT_2; 
				S_TARGET_WAIT_2: next_state_1 = (done_t2 || ~active_t2) ? S_TARGET_PLOT_3 : S_TARGET_WAIT_2;
				
				S_TARGET_PLOT_3: next_state_1 = S_TARGET_WAIT_3; 
				S_TARGET_WAIT_3: next_state_1 = (done_t3 || ~active_t3) ? S_RANDOM_PLOT_1 : S_TARGET_WAIT_3;
				
				S_RANDOM_PLOT_1: next_state_1 = S_RANDOM_WAIT_1; 
				S_RANDOM_WAIT_1: next_state_1 = (done_r1 || ~active_r1) ? S_RANDOM_PLOT_2 : S_RANDOM_WAIT_1;
				
				S_RANDOM_PLOT_2: next_state_1 = S_RANDOM_WAIT_2; 
				S_RANDOM_WAIT_2: next_state_1 = (done_r2 || ~active_r2) ? S_RANDOM_PLOT_3 : S_RANDOM_WAIT_2;
				
				S_RANDOM_PLOT_3: next_state_1 = S_RANDOM_WAIT_3; 
				S_RANDOM_WAIT_3: next_state_1 = (done_r3 || ~active_r3) ? S_RANDOM_PLOT_4 : S_RANDOM_WAIT_3;
				
				S_RANDOM_PLOT_4: next_state_1 = S_RANDOM_WAIT_4; 
				S_RANDOM_WAIT_4: next_state_1 = (done_r4 || ~active_r4) ? S_RANDOM_PLOT_5 : S_RANDOM_WAIT_4;
				
				S_RANDOM_PLOT_5: next_state_1 = S_RANDOM_WAIT_5; 
				S_RANDOM_WAIT_5: next_state_1 = (done_r5 || ~active_r5) ? S_RANDOM_PLOT_6 : S_RANDOM_WAIT_5;
				
				S_RANDOM_PLOT_6: next_state_1 = S_RANDOM_WAIT_6; 
				S_RANDOM_WAIT_6: next_state_1 = (done_r6 || ~active_r6) ? S_RANDOM_PLOT_7 : S_RANDOM_WAIT_6;
				
				S_RANDOM_PLOT_7: next_state_1 = S_RANDOM_WAIT_7; 
				S_RANDOM_WAIT_7: next_state_1 = (done_r7 || ~active_r7) ? S_RANDOM_PLOT_8 : S_RANDOM_WAIT_7;
				
				S_RANDOM_PLOT_8: next_state_1 = S_RANDOM_WAIT_8; 
				S_RANDOM_WAIT_8: next_state_1 = (done_r8 || ~active_r8) ? S_RANDOM_PLOT_9 : S_RANDOM_WAIT_8;
				
				S_RANDOM_PLOT_9: next_state_1 = S_RANDOM_WAIT_9; 
				S_RANDOM_WAIT_9: next_state_1 = (done_r9 || ~active_r9) ? S_RANDOM_PLOT_10 : S_RANDOM_WAIT_9;
					
				S_RANDOM_PLOT_10: next_state_1 = S_RANDOM_WAIT_10; 
				S_RANDOM_WAIT_10: next_state_1 = (done_r10 || ~active_r10) ? S_CURSOR_PLOT : S_RANDOM_WAIT_10;
				
				S_CURSOR_PLOT: next_state_1 = S_CURSOR_WAIT; 
				S_CURSOR_WAIT: next_state_1 = (done_c) ? S_WAIT : S_CURSOR_WAIT;
				
				// REPEAT EVERYTHING ABOVE EVERY 1/60 OF A SECOND
				S_WAIT: next_state_1 = (|frame_rate == 0) ? S_START : S_WAIT;
				
				default: next_state_1 = S_START;
		 endcase
	
// ENABLE SIGNALS
	always @(*) begin
		 
		 // IF START CORRESPONDING TO AN OBJECT IS HIGH, 
		 // START DRAWING THAT OBJECT
		 start_b  = 1'b0;
		 start_c  = 1'b0;
		 start_t1 = 1'b0;
		 start_t2 = 1'b0;
		 start_t3 = 1'b0;
		 
		 start_r1 = 1'b0;
		 start_r2 = 1'b0;
		 start_r3 = 1'b0;
		 start_r4 = 1'b0;
		 start_r5 = 1'b0;
		 start_r6 = 1'b0;
		 start_r7 = 1'b0;
		 start_r8 = 1'b0;
		 start_r9 = 1'b0;
		 start_r10 = 1'b0;
		 
		 x = 8'd0;
		 y = 7'd0;
		 
		 x_memIn = 8'd0;
		 y_memIn = 7'd0;
		 
		 colour = 24'd0;
		 
		 writeEn_memIn = 1'b0;
		 writeEn = 1'b0;
		
		 case (current_state_1)  
			  
			  // BACKGROUND
			  S_BACKGROUND_PLOT: start_b = 1'b1;
			  S_BACKGROUND_WAIT: begin
					x_memIn = x_b;
					y_memIn = y_b;
					x = x_memOut;
					y = y_memOut;
					colour = colour_ROM;
					writeEn_memIn = writeEn_b;
					writeEn = writeEn_memOut;
			  end
				
			  // TARGET #1
			  S_TARGET_PLOT_1: start_t1 = 1'b1;
			  S_TARGET_WAIT_1: begin
					
					if (clear_t1) begin
						x_memIn = x_t1;
						y_memIn = y_t1;
						x = x_memOut;
						y = y_memOut;
						colour = colour_ROM;
						writeEn_memIn = writeEn_t1;
						writeEn = writeEn_memOut;
					end
					else begin
						x = x_t1;
						y = y_t1;
						colour = colour_t1;
						
						// TRANSPARENT PIXELS STORED AS BLACK IN THE ROM
						if (colour_t1 == 24'd0) writeEn = 1'b0;
						else writeEn = writeEn_t1;
					end
			  end
			  
			  // TARGET #2
			  S_TARGET_PLOT_2: start_t2 = 1'b1;
			  S_TARGET_WAIT_2: begin
					
					if (clear_t2) begin
						x_memIn = x_t2;
						y_memIn = y_t2;
						x = x_memOut;
						y = y_memOut;
						colour = colour_ROM;
						writeEn_memIn = writeEn_t2;
						writeEn = writeEn_memOut;
					end
					else begin
						x = x_t2;
						y = y_t2;
						colour = colour_t2;
						if (colour_t2 == 24'd0) writeEn = 1'b0;
						else writeEn = writeEn_t2;
					end
			  end
			  
			  // TARGET #3
			  S_TARGET_PLOT_3: start_t3 = 1'b1;
			  S_TARGET_WAIT_3: begin
					
					if (clear_t3) begin
						x_memIn = x_t3;
						y_memIn = y_t3;
						x = x_memOut;
						y = y_memOut;
						colour = colour_ROM;
						writeEn_memIn = writeEn_t3;
						writeEn = writeEn_memOut;
					end
					else begin
						x = x_t3;
						y = y_t3;
						colour = colour_t3;
						if (colour_t3 == 24'd0) writeEn = 1'b0;
						else writeEn = writeEn_t3;
					end
			  end
			  
			  // RANDOM OBJECT #1
			  S_RANDOM_PLOT_1: start_r1 = 1'b1;
			  S_RANDOM_WAIT_1: begin
					
					if (clear_r1) begin
						x_memIn = x_r1;
						y_memIn = y_r1;
						x = x_memOut;
						y = y_memOut;
						colour = colour_ROM;
						writeEn_memIn = writeEn_r1;
						writeEn = writeEn_memOut;
					end
					else begin
						x = x_r1;
						y = y_r1;
						colour = colour_r1 - random_r1;
						if (colour_r1 == 24'd0) writeEn = 1'b0;
						else writeEn = writeEn_r1;
					end
			  end
			  
			  // RANDOM OBJECT #2
			  S_RANDOM_PLOT_2: start_r2 = 1'b1;
			  S_RANDOM_WAIT_2: begin
					
					if (clear_r2) begin
						x_memIn = x_r2;
						y_memIn = y_r2;
						x = x_memOut;
						y = y_memOut;
						colour = colour_ROM;
						writeEn_memIn = writeEn_r2;
						writeEn = writeEn_memOut;
					end
					else begin
						x = x_r2;
						y = y_r2;
						colour = colour_r2 - random_r2;
						if (colour_r2 == 24'd0) writeEn = 1'b0;
						else writeEn = writeEn_r2;
					end
			  end
			  
			  // RANDOM OBJECT #3
			  S_RANDOM_PLOT_3: start_r3 = 1'b1;
			  S_RANDOM_WAIT_3: begin
					
					if (clear_r3) begin
						x_memIn = x_r3;
						y_memIn = y_r3;
						x = x_memOut;
						y = y_memOut;
						colour = colour_ROM;
						writeEn_memIn = writeEn_r3;
						writeEn = writeEn_memOut;
					end
					else begin
						x = x_r3;
						y = y_r3;
						colour = colour_r3 - random_r3;
						if (colour_r3 == 24'd0) writeEn = 1'b0;
						else writeEn = writeEn_r3;
					end
			  end
			  
			  // RANDOM OBJECT #4
			  S_RANDOM_PLOT_4: start_r4 = 1'b1;
			  S_RANDOM_WAIT_4: begin
					
					if (clear_r4) begin
						x_memIn = x_r4;
						y_memIn = y_r4;
						x = x_memOut;
						y = y_memOut;
						colour = colour_ROM;
						writeEn_memIn = writeEn_r4;
						writeEn = writeEn_memOut;
					end
					else begin
						x = x_r4;
						y = y_r4;
						colour = colour_r4 - random_r4;
						if (colour_r4 == 24'd0) writeEn = 1'b0;
						else writeEn = writeEn_r4;
					end
			  end
			  
			  // RANDOM OBJECT #5
			  S_RANDOM_PLOT_5: start_r5 = 1'b1;
			  S_RANDOM_WAIT_5: begin
					
					if (clear_r5) begin
						x_memIn = x_r5;
						y_memIn = y_r5;
						x = x_memOut;
						y = y_memOut;
						colour = colour_ROM;
						writeEn_memIn = writeEn_r5;
						writeEn = writeEn_memOut;
					end
					else begin
						x = x_r5;
						y = y_r5;
						colour = colour_r5 - random_r5;
						if (colour_r5 == 24'd0) writeEn = 1'b0;
						else writeEn = writeEn_r5;
					end
			  end
			  
			  // RANDOM OBJECT #6
			  S_RANDOM_PLOT_6: start_r6 = 1'b1;
			  S_RANDOM_WAIT_6: begin
					
					if (clear_r6) begin
						x_memIn = x_r6;
						y_memIn = y_r6;
						x = x_memOut;
						y = y_memOut;
						colour = colour_ROM;
						writeEn_memIn = writeEn_r6;
						writeEn = writeEn_memOut;
					end
					else begin
						x = x_r6;
						y = y_r6;
						colour = colour_r6 - random_r6;
						if (colour_r6 == 24'd0) writeEn = 1'b0;
						else writeEn = writeEn_r6;
					end
			  end
			  
			  // RANDOM OBJECT #7
			  S_RANDOM_PLOT_7: start_r7 = 1'b1;
			  S_RANDOM_WAIT_7: begin
					
					if (clear_r7) begin
						x_memIn = x_r7;
						y_memIn = y_r7;
						x = x_memOut;
						y = y_memOut;
						colour = colour_ROM;
						writeEn_memIn = writeEn_r7;
						writeEn = writeEn_memOut;
					end
					else begin
						x = x_r7;
						y = y_r7;
						colour = colour_r7 - random_r7;
						if (colour_r7 == 24'd0) writeEn = 1'b0;
						else writeEn = writeEn_r7;
					end
			  end
			  
			  // RANDOM OBJECT #8
			  S_RANDOM_PLOT_8: start_r8 = 1'b1;
			  S_RANDOM_WAIT_8: begin
					
					if (clear_r8) begin
						x_memIn = x_r8;
						y_memIn = y_r8;
						x = x_memOut;
						y = y_memOut;
						colour = colour_ROM;
						writeEn_memIn = writeEn_r8;
						writeEn = writeEn_memOut;
					end
					else begin
						x = x_r8;
						y = y_r8;
						colour = colour_r8 - random_r8;
						if (colour_r8 == 24'd0) writeEn = 1'b0;
						else writeEn = writeEn_r8;
					end
			  end
			  
			  // RANDOM OBJECT #9
			  S_RANDOM_PLOT_9: start_r9 = 1'b1;
			  S_RANDOM_WAIT_9: begin
					
					if (clear_r9) begin
						x_memIn = x_r9;
						y_memIn = y_r9;
						x = x_memOut;
						y = y_memOut;
						colour = colour_ROM;
						writeEn_memIn = writeEn_r9;
						writeEn = writeEn_memOut;
					end
					else begin
						x = x_r9;
						y = y_r9;
						colour = colour_r9 - random_r9;
						if (colour_r9 == 24'd0) writeEn = 1'b0;
						else writeEn = writeEn_r9;
					end
			  end
			  
			  // RANDOM OBJECT #10
			  S_RANDOM_PLOT_10: start_r10 = 1'b1;
			  S_RANDOM_WAIT_10: begin
					
					if (clear_r10) begin
						x_memIn = x_r10;
						y_memIn = y_r10;
						x = x_memOut;
						y = y_memOut;
						colour = colour_ROM;
						writeEn_memIn = writeEn_r10;
						writeEn = writeEn_memOut;
					end
					else begin
						x = x_r10;
						y = y_r10;
						colour = colour_r10 - random_r10;
						if (colour_r10 == 24'd0) writeEn = 1'b0;
						else writeEn = writeEn_r10;
					end
			  end
			  
			  // CURSOR
			  S_CURSOR_PLOT: start_c = 1'b1;
			  S_CURSOR_WAIT: begin
					
					if (clear_c) begin
						x_memIn = x_c;
						y_memIn = y_c;
						x = x_memOut;
						y = y_memOut;
						colour = colour_ROM;
						writeEn_memIn = writeEn_c;
						writeEn = writeEn_memOut;
					end
					else begin
						x = x_c;
						y = y_c;
						colour = mouse_counter;
						writeEn = writeEn_c;
					end
			  end
		 endcase
	end
	
// STATE FFs
	always @(posedge CLOCK_50)
		if (~KEY[0]) current_state_1 <= S_START;
		else current_state_1 <= next_state_1; 

		
// CURSOR AND RANDOM OBJECT COLOUR RANDOMIZER
	reg [23:0] mouse_counter, random_r1, random_r2, random_r3, random_r4, random_r5, random_r6, random_r7, random_r8, random_r9, random_r10;	
	always @(posedge CLOCK_50)
		if (~KEY[0]) begin
			mouse_counter <= 24'd0;
			random_r1 <= 24'd1500000;
			random_r2 <= 24'd3000000;
			random_r3 <= 24'd4500000;
			random_r4 <= 24'd6000000;
			random_r5 <= 24'd7500000;
			random_r6 <= 24'd9000000;
			random_r7 <= 24'd10500000;
			random_r8 <= 24'd12000000;
			random_r9 <= 24'd13500000;
			random_r10 <= 24'd15000000;
		end
		else if (|frame_counter == 0) begin
			mouse_counter <= mouse_counter + 24'd500;
			random_r1 <= {random_r1[22:0], random_r1[23] ^ random_r1[1]};
			random_r2 <= {random_r2[22:0], random_r2[23] ^ random_r2[1]};
			random_r3 <= {random_r3[22:0], random_r3[23] ^ random_r3[1]};
			random_r4 <= {random_r4[22:0], random_r4[23] ^ random_r4[1]};
			random_r5 <= {random_r5[22:0], random_r5[23] ^ random_r5[1]};
			random_r6 <= {random_r6[22:0], random_r6[23] ^ random_r6[1]};
			random_r7 <= {random_r7[22:0], random_r7[23] ^ random_r7[1]};
			random_r8 <= {random_r8[22:0], random_r8[23] ^ random_r8[1]};
			random_r9 <= {random_r9[22:0], random_r9[23] ^ random_r9[1]};
			random_r10 <= {random_r10[22:0], random_r10[23] ^ random_r10[1]};
		end
	
endmodule