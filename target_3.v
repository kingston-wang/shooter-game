module target_3(
	input CLOCK_50, reset, start, active,
	output reg done, clear, writeEn,
	output [7:0] x,
	output [6:0] y,
	output reg [23:0] colour,
	input [7:0] x_c, 
	input [6:0] y_c,
	input [7:0] x_set,
	input [6:0] y_set,
	input [2:0] button, 
	output reg [5:0] score
	);
	
	reg pressed, ld, ld_ROM;
	
	reg [2:0] current_state, next_state;
	reg [2:0] current_state_s, next_state_s;
	
	reg [7:0] x_initial;
	reg [6:0] y_initial;
	wire [23:0] x_centre;
	wire [23:0] y_centre;
	
	reg [25:0] move_rate;
	reg [10:0] position, position_ROM;
	
	wire [23:0] colour_ROM;
	reg [23:0] offset;
	

// CONTROL (SAME AS THE ONE IN TARGET_1, TARGET_2 AND RANDOM)
	
// STATE TABLE 
	localparam  S_LOAD   = 3'd0,
					S_PLOT   = 3'd1,
					S_WAIT   = 3'd2,
					S_ERASE  = 3'd3,
					S_DELAY  = 3'd4,
					S_UPDATE = 3'd5;
		 
	always@(*) 
		case (current_state)
			S_LOAD:   next_state = (active) ? S_DELAY : S_LOAD;			
			S_DELAY:  next_state = S_PLOT;
			S_PLOT:   next_state = (position == 11'd1023) ? S_WAIT : S_PLOT;
			S_WAIT:   next_state = (start) ? S_ERASE : S_WAIT;
			S_ERASE:  next_state = (position == 11'd1024) ? S_UPDATE: S_ERASE;
			S_UPDATE: next_state = S_LOAD;
			default:  next_state = S_LOAD;
		endcase
	
// ENABLE SIGNALS
	always @(*) begin
		writeEn = 1'b0;
		clear = 1'b0;
		ld = 1'b0;
		ld_ROM = 1'b0;
		done = 1'b0;

		case (current_state)
			S_DELAY: ld_ROM = 1'b1;
			S_PLOT: writeEn = 1'b1;
			S_WAIT: begin
				done = 1'b1;
				clear = 1'b1;
			end
			S_ERASE: begin
				writeEn = 1'b1;
				clear = 1'b1;
			end
			S_UPDATE: ld = 1'b1;
		endcase
	end

// STATE FFs
	always @(posedge CLOCK_50)
		if (reset) current_state <= S_UPDATE;
		else current_state <= next_state;
	
	
// DATAPATH (UNIQUE FOR TARGET_3)

// UPDATE X, Y POSITION FOR THE UPPER-LEFTMOST PIXEL EVERY 1/60 OF A SECOND
	always @(posedge CLOCK_50)
		if (reset) begin
			x_initial <= 7'd0;
			y_initial <= 6'd0;
		end
		else if (ld) begin
			x_initial <= x_set;
			y_initial <= y_set;
		end

		
// EVERYTHING BELOW IS IN TARGET_1 AND TARGET_2

// ASSIGNS NEXT PIXEL TO PLOT, SEND IT TO THE TOP MODULE
	assign x = x_initial + position[4:0];
	assign y = y_initial + position[9:5];	
	
// POSITION COUNTER
	always @(posedge CLOCK_50)
		if (reset || ~writeEn) position <= 11'd0;
		else if (writeEn) position <= position + 1;

// LOAD COLOUR (PLOT: FROM ROM, ERASE: WHITE)
	always @(posedge CLOCK_50)
		if (reset || clear) colour <= 24'd16777215;
		else if (writeEn || ld) colour <= colour_ROM - offset;
	
// DIMS THE OBJECT WHEN CURSOR IS ON THE TARGET
	assign x_centre = x_initial + 8'd15;
	assign y_centre = y_initial + 7'd15;
	
	always @(posedge CLOCK_50)
		if (reset) offset <= 24'd0;
		else if ( (x_c <= x_centre) && (y_c <= y_centre) && ( (x_centre-x_c)*(x_centre-x_c) + (y_centre-y_c)*(y_centre-y_c) <= 8'd255) ) offset <= 24'b001000000010000000100000;
		else if ( (x_c > x_centre) && (y_c < y_centre) && ( (x_c-x_centre)*(x_c-x_centre) + (y_centre-y_c)*(y_centre-y_c) <= 8'd255) ) offset <= 24'b001000000010000000100000;
		else if ( (x_c < x_centre) && (y_c > y_centre) && ( (x_centre-x_c)*(x_centre-x_c) + (y_c-y_centre)*(y_c-y_centre) <= 8'd255) ) offset <= 24'b001000000010000000100000;
		else if ( (x_c > x_centre) && (y_c > y_centre) && ( (x_c-x_centre)*(x_c-x_centre) + (y_c-y_centre)*(y_c-y_centre) <= 8'd255) ) offset <= 24'b001000000010000000100000;
		else offset <= 24'd0;

// ROM ADDRESS REGISTER
	always @(posedge CLOCK_50)
		if (reset || done) position_ROM <= 11'd0;
		else if (writeEn || ld_ROM) position_ROM <= position_ROM + 1;
	
// ROM FOR TARGET 3 (STORES 32x32 PIXELS, 8-BIT PER COLOUR) 
	object_3 O3(position_ROM, CLOCK_50, colour_ROM);
	
	
// SCORE COUNTER

// INCREMENTS SCORE WHEN: 
// 1. CURSOR IS ON THE TARGET, AND
// 2. BUTTON IS PRESSED AND THEN RELEASED
	always @(posedge CLOCK_50)
		if (reset) score <= 6'd0;
		else if (active && pressed && (x_c <= x + 8'd31) && (x_c >= x) &&  (y_c <= y + 7'd31)  &&  (y_c >= y) )
			score <= score + 1;
	
	localparam  S_WAIT_s  = 3'd0,
					S_PRESSED = 3'd1,
					S_RELEASE = 3'd2;

// STATE TABLE
	always@(*) 
		case (current_state_s)
			S_WAIT_s:  next_state_s = (button[0]) ? S_PRESSED : S_WAIT_s;					
			S_PRESSED: next_state_s = (button[0]) ? S_PRESSED : S_RELEASE;
			S_RELEASE: next_state_s = S_WAIT_s;
			default:   next_state_s = S_WAIT_s;
		endcase

// ENABLE SIGNALS
// PRESSED IS HIGH WHEN BUTTON IS PRESSED AND THEN RELEASED
	always @(*) begin
		pressed = 1'd0;

		case (current_state_s)
			S_RELEASE: pressed = 1'd1;
		endcase
	end

// STAGE FFs
	always @(posedge CLOCK_50)
		if (reset) current_state_s <= S_WAIT_s;
		else current_state_s <= next_state_s;
	
endmodule
