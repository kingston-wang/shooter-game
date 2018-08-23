module mouse(
	input CLOCK_50, reset,
	inout PS2_CLK, PS2_DAT,
	output reg [7:0] x,
	output reg [6:0] y,
	output reg m_button, r_button, l_button
	);
	
	wire ps2_key_pressed;
	wire [7:0] ps2_key_data;
	
	reg [7:0] x_movement, y_movement;
	reg x_sign, y_sign;

// COUNTER THAT COUNTS 0~3
// CYCLES FOR EACH DATA TRANSMISSION FROM THE PS2 CONTROLLER
// EFFECTLY A STATE TABLE
	reg [2:0] counter;
	always @(posedge CLOCK_50)
		 if (reset || (counter == 3'd3)) counter <= 3'd0;
		 else if (ps2_key_pressed) counter <= counter + 1;

// FIRST BYTE OF DATA: LOAD X, Y SIGN AND BUTTON STATE
	always @(posedge CLOCK_50)
		 if (reset) begin
				l_button <= 1'b0;
				r_button <= 1'b0;
				m_button <= 1'b0;
				x_sign <= 1'b0;
				y_sign <= 1'b0;
		 end
		 else if (ps2_key_pressed && (counter == 3'd0)) begin
				l_button <= ps2_key_data[0];
				r_button <= ps2_key_data[1];
				m_button <= ps2_key_data[2];
				x_sign <= ps2_key_data[4];
				y_sign <= ps2_key_data[5];
		 end

// SECOND BYTE OF DATA: LOAD RELATIVE CHANGE IN X
	always @(posedge CLOCK_50)
		 if (reset) x_movement <= 8'd0;
		 else if (ps2_key_pressed && (counter == 3'd1)) x_movement <= ps2_key_data;

// THIRD BYTE OF DATA: LOAD RELATIVE CHANGE IN Y
	always @(posedge CLOCK_50)
		 if (reset) y_movement <= 8'd0;
		 else if (ps2_key_pressed && (counter == 3'd2)) y_movement <= ps2_key_data;

// UPDATE X, Y POSITION FOR THE CURSOR AFTER EACH TRANSMISSION
	always @(posedge CLOCK_50)
		 if (reset) begin
				x <= 8'd0;
				y <= 7'd0;
		 end
		 else if ((counter == 3'd3) && (8'd160 < x + {x_sign, x_movement[6:0]}) && (x == 8'd0)) begin
				x <= 8'd0;
				y <= y - {y_sign, y_movement[5:0]};
		 end
		 else if ((counter == 3'd3) && (7'd120 < y - {y_sign, y_movement[5:0]}) && (y == 7'd0)) begin
				x <= x - {x_sign, x_movement[6:0]};
				y <= 7'd0;
		 end
		 else if ((counter == 3'd3) && (8'd160 < x + {x_sign, x_movement[6:0]})) begin
				x <= 8'd159;
				y <= y - {y_sign, y_movement[5:0]};
		 end
		 else if ((counter == 3'd3) && (7'd120 < y - {y_sign, y_movement[5:0]})) begin
				x <= x - {x_sign, x_movement[6:0]};
				y <= 7'd119;
		 end
		 else if (counter == 3'd3) begin
				x <= x +	{x_sign, x_movement[6:0]};
				y <= y - {y_sign, y_movement[5:0]};
		 end

// INSTANTIATES PS2 CONTROLLER
	PS2_Controller #(1) PS2 (
		.CLOCK_50 (CLOCK_50),
		.reset	 (reset),
		.PS2_CLK	 (PS2_CLK),
		.PS2_DAT	 (PS2_DAT),
		.received_data		(ps2_key_data),
		.received_data_en	(ps2_key_pressed)
	);
endmodule

module display (
	 input CLOCK_50, reset,
	 output reg writeEn,
	 input [7:0] x,  
	 input [6:0] y, 
	 output reg [7:0] x_VGA,  
	 output reg [6:0] y_VGA, 
	 input start,
	 output reg done, clear
	);

	reg ld;
	reg [2:0] current_state, next_state;

	
// CONTROL	
	
// STATE TABLE	
	localparam  S_UPDATE = 3'd0,
					S_WAIT   = 3'd1,
					S_ERASE  = 3'd2,
					S_PLOT   = 3'd3,
					S_DELAY  = 3'd4;
		 
	always @(*)
		 case (current_state)
			  S_UPDATE: next_state = S_PLOT;
			  S_PLOT: next_state = S_WAIT;
			  S_WAIT: next_state = (start) ? S_ERASE : S_WAIT;
			  S_ERASE: next_state = S_DELAY;
			  S_DELAY: next_state = S_UPDATE;
			  default: next_state = S_UPDATE;
		 endcase
		 
// ENABLE SIGNALS
	always @(*) begin
		 ld = 1'b0;
		 writeEn = 1'b0;
		 clear = 1'b0;
		 done = 1'b0;

		 case (current_state)
			  S_UPDATE: ld = 1'b1;
			  S_PLOT: writeEn = 1'b1;
			  S_WAIT: begin
					done = 1'b1;
					clear = 1'b1;
			  end
			  S_ERASE: begin
					writeEn = 1'b1;
					clear = 1'b1;
			  end
			  S_DELAY: begin
					writeEn = 1'b1;
					clear = 1'b1;
			  end
		 endcase
	end

// STATE FFs
	always @(posedge CLOCK_50)
		 if (reset) current_state <= S_UPDATE;
		 else current_state <= next_state;

		 
// DATAPATH

// ASSIGNS NEXT PIXEL TO PLOT, SEND IT TO THE TOP MODULE
	always @(posedge CLOCK_50)
		 if (reset) begin
			  x_VGA <= 8'd0;
			  y_VGA <= 7'd0;
		 end
		 else if (ld) begin
			  x_VGA <= x;
			  y_VGA <= y;
		 end
	
endmodule
