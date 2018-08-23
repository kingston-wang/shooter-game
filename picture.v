module picture(
	input CLOCK_50, reset, start, active,
	output reg ld, writeEn,
	output [7:0] x,
	output [6:0] y
	);
	
	reg [2:0] current_state, next_state;
	reg [14:0] position;
	
	
// CONTROL	
	
// STATE TABLE
	localparam  S_LOAD   = 3'd0,
					S_PLOT   = 3'd1,
					S_UPDATE = 3'd2;
		 
	always@(*) 
		case (current_state)
			S_LOAD:   next_state = (active && start) ? S_PLOT : S_LOAD;			
			S_PLOT:   next_state = (position[14:8] == 7'd120) ? S_UPDATE : S_PLOT;
			S_UPDATE: next_state = S_LOAD;
			default:  next_state = S_LOAD;
		endcase
	
// ENABLE SIGNALS
	always @(*) begin
		writeEn = 1'b0;
		ld = 1'b0;

		case (current_state)
			S_PLOT: writeEn = 1'b1;
			S_UPDATE: ld = 1'b1;
		endcase
	end

// STATE FFs
	always @(posedge CLOCK_50)
		if (reset) current_state <= S_UPDATE;
		else current_state <= next_state;
	
	
// DATAPATH

// ASSIGNS NEXT PIXEL TO PLOT, SEND IT TO THE TOP MODULE
	assign x = position[7:0];
	assign y = position[14:8];	

// POSITION COUNTER
	always @(posedge CLOCK_50)
		if (reset || ~writeEn || (position[14:8] == 7'd120) ) position <= 15'd0;
		else if (writeEn && (position[7:0] == 8'd159) ) position <= position + 8'd97;
		else if (writeEn) position <= position + 1;
		
endmodule
