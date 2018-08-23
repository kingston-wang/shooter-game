module random(
	input CLOCK_50, reset, start, active,
	output reg done, clear, writeEn,
	output [7:0] x,
	output [6:0] y,
	output reg [23:0] colour,
	input [7:0] x_in, 
	input [6:0] y_in,
	input [14:0] random_input
	);
	
	reg pressed, ld, ld_ROM;
	reg [7:0] x_initial;
	reg [6:0] y_initial;
	reg [2:0] current_state, next_state;
	reg [25:0] move_rate;
	reg [6:0] position, position_ROM;
	reg [1:0] horizontal, vertical;
	wire [23:0] colour_ROM;
	
// CONTROL (SAME AS THE ONE IN TARGET_1, TARGET_2 AND TARGET_3)
			
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
			S_PLOT:   next_state = (position == 7'd63) ? S_WAIT : S_PLOT;
			S_WAIT:   next_state = (start) ? S_ERASE : S_WAIT;
			S_ERASE:  next_state = (position == 7'd64) ? S_UPDATE : S_ERASE;
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
	
	
// DATAPATH (SIMILAR TO THAT OF TARGET_2, BUT WITH SOME MINOR DIFFERENCES)

// DETERMINE DIRECTION OF MOVEMENT RANDOMLY
// NOTE: RANDOM INPUT IS DIFFERENT FOR EVERY RANDOM OBJECT
	reg [14:0] random;	
	always @(posedge CLOCK_50)
		if (reset) random <= random_input;
		else random <= {random[13:0], random[14] ^ random[1]};

// COUNTS 1/5 OF A SECOND
	reg [23:0] rate;
	always @(posedge CLOCK_50)
		if (reset || (|rate == 0) ) rate <= 24'd9999999;
		else rate <= rate - 1;

// UPDATES DIRECTION OF MOVEMENT EVERY 1/5 OF A SECOND
	always @(posedge CLOCK_50)
		if (reset || ( (random[1:0] == 2'd0) && (|rate == 0) ) ) horizontal = 2'd1;
		else if ( (random[1:0] == 2'd1) && (|rate == 0) ) horizontal = 2'd0;
		else if (|rate == 0) horizontal = 2'd2;
	 
	always @(posedge CLOCK_50)
		if (reset || ( (random[3:2] == 2'd0) && (|rate == 0) ) ) vertical = 2'd1;
		else if ( (random[3:2] == 2'd1) && (|rate == 0) ) vertical = 2'd0;
		else if (|rate == 0) vertical = 2'd2;
	
// UPDATE X, Y POSITION FOR THE UPPER-LEFTMOST PIXEL EVERY 1/60 OF A SECOND
	always @(posedge CLOCK_50)
		if (reset) x_initial <= x_in;
		else if (ld && (horizontal == 2'd1) ) x_initial <= x_initial + 2;
		else if (ld && (horizontal == 2'd0) ) x_initial <= x_initial - 2;
	 
	always @(posedge CLOCK_50)
		if (reset) y_initial <= y_in;
		else if (ld && (vertical == 2'd1) ) y_initial <= y_initial + 2;
		else if (ld && (vertical == 2'd0) ) y_initial <= y_initial - 2;	
	
// ASSIGNS NEXT PIXEL TO PLOT, SEND IT TO THE TOP MODULE
	assign x = x_initial + position[2:0];
	assign y = y_initial + position[5:3];
	
// POSITION COUNTER
	always @(posedge CLOCK_50)
		if (reset || ~writeEn) position <= 7'd0;
		else if (writeEn) position <= position + 1;
		
// LOAD COLOUR (PLOT: FROM ROM, ERASE: WHITE)
	always @(posedge CLOCK_50)
		if (reset || clear) colour <= 24'd16777215;
		else if (writeEn || ld) colour <= colour_ROM;

// ASSIGNS COLOUR OF THE OBJECT TO BLACK
// COULD REPLACE THIS LINE WITH A ROM (STORES 8x8 PIXELS, 8-BIT PER COLOUR) 
	assign colour_ROM = 24'd1;
	
endmodule
