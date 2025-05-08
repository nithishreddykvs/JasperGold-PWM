`timescale 1ns / 1ps

module pwm (
    input clk,          // 50MHz clock input
    input rst,          // Reset signal
    input [2:0] sw,     // 3 switches for duty cycle control
    output reg pwm_out  // PWM output signal
);

    reg [3:0] counter;  // 4-bit counter for PWM timing (0 to 9)
    reg [3:0] duty_cycle; // 4-bit duty cycle register (0 to 8, representing 10% to 80%)

    // Duty cycle control logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            duty_cycle <= 0; // Reset duty cycle to 10% (default)
        end else begin
            // Set duty cycle based on switch combinations
            case (sw)
                3'b000: duty_cycle <= 1; // 10% duty cycle
                3'b001: duty_cycle <= 2; // 20% duty cycle
                3'b010: duty_cycle <= 3; // 30% duty cycle
                3'b011: duty_cycle <= 4; // 40% duty cycle
                3'b100: duty_cycle <= 5; // 50% duty cycle
                3'b101: duty_cycle <= 6; // 60% duty cycle
                3'b110: duty_cycle <= 7; // 70% duty cycle
                3'b111: duty_cycle <= 8; // 80% duty cycle
                default: duty_cycle <= 1; // Default to 10% if invalid input
            endcase
        end
    end

    // Counter logic for PWM signal generation
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            counter <= 0;
        end else begin
            if (counter == 9) begin
                counter <= 0; // Reset counter after reaching 9
            end else begin
                counter <= counter + 1; // Increment counter
            end
        end
    end

    // PWM signal generation logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pwm_out <= 0;
        end else begin
            if (counter < duty_cycle) begin
                pwm_out <= 1; // Set PWM output HIGH
            end else begin
                pwm_out <= 0; // Set PWM output LOW
            end
        end
    end


	// Reset initializes all registers properly
	property p_reset_initialization;
	    @(posedge clk) rst |-> (counter == 0 && duty_cycle == 0 && pwm_out == 0);
	endproperty
	a_reset_initialization: assert property(p_reset_initialization);

	// No unknowns during operation
	property p_no_unknowns;
	    @(posedge clk) !$isunknown({counter, duty_cycle, pwm_out});
	endproperty
	a_no_unknowns: assert property(p_no_unknowns);

	
	// Counter increments correctly
	property p_counter_increment;
	    @(posedge clk) disable iff(rst)
	    (counter < 9) |=> (counter == $past(counter) + 1);
	endproperty
	a_counter_increment: assert property(p_counter_increment);

	// Counter wraps around correctly
	property p_counter_wrap;
	    @(posedge clk) disable iff(rst)
	    (counter == 9) |=> (counter == 0);
	endproperty
	a_counter_wrap: assert property(p_counter_wrap);


	// Duty cycle updates correctly based on switches
	property p_duty_cycle_update;
	    @(posedge clk) disable iff(rst)
	    (sw == 3'b000) |=> (duty_cycle == 1);
	endproperty
	a_duty_cycle_update_10: assert property(p_duty_cycle_update);

	property p_duty_cycle_update_20;
	    @(posedge clk) disable iff(rst)
	    (sw == 3'b001) |=> (duty_cycle == 2);
	endproperty
	a_duty_cycle_update_20: assert property(p_duty_cycle_update_20);

	property p_duty_cycle_update_30;
	    @(posedge clk) disable iff(rst)
	    (sw == 3'b010) |=> (duty_cycle == 3);
	endproperty
	a_duty_cycle_update_30: assert property(p_duty_cycle_update_30);

	property p_duty_cycle_update_40;
	    @(posedge clk) disable iff(rst)
	    (sw == 3'b011) |=> (duty_cycle == 4);
	endproperty
	a_duty_cycle_update_40: assert property(p_duty_cycle_update_40);

	
	property p_duty_cycle_update_50;
	    @(posedge clk) disable iff(rst)
	    (sw == 3'b100) |=> (duty_cycle == 5);
	endproperty
	a_duty_cycle_update_50: assert property(p_duty_cycle_update_50);

	property p_duty_cycle_update_60;
	    @(posedge clk) disable iff(rst)
	    (sw == 3'b101) |=> (duty_cycle == 6);
	endproperty
	a_duty_cycle_update_60: assert property(p_duty_cycle_update_60);

	property p_duty_cycle_update_70;
	    @(posedge clk) disable iff(rst)
	    (sw == 3'b110) |=> (duty_cycle == 7);
	endproperty
	a_duty_cycle_update_70: assert property(p_duty_cycle_update_70);

	// Similar properties for all switch combinations
	property p_duty_cycle_update_80;
	    @(posedge clk) disable iff(rst)
	    (sw == 3'b111) |=> (duty_cycle == 8);
	endproperty
	a_duty_cycle_update_80: assert property(p_duty_cycle_update_80);

	// PWM high assertion - more robust version
	property p_pwm_high_correct;
	    @(posedge clk) disable iff(rst)
	    !rst && (counter < duty_cycle) |-> ##[0:1] pwm_out;
	endproperty
	a_pwm_high_correct: assert property(p_pwm_high_correct);

	// PWM low assertion - more robust version
	property p_pwm_low_correct;
	    @(posedge clk) disable iff(rst)
	    !rst && (counter >= duty_cycle) |-> ##[0:1] !pwm_out;
	endproperty
	a_pwm_low_correct: assert property(p_pwm_low_correct);


	// Handle duty_cycle = 0 case (should always be low)
	property p_pwm_duty_zero;
	    @(posedge clk) disable iff(rst)
	    (duty_cycle == 0) |-> !pwm_out;
	endproperty
	a_pwm_duty_zero: assert property(p_pwm_duty_zero);

	// Handle duty_cycle = 9 case (should be high for all counts except maybe 9)
	property p_pwm_duty_max;
	    @(posedge clk) disable iff(rst)
	    (duty_cycle == 9) && (counter < 9) |-> pwm_out;
	endproperty
	a_pwm_duty_max: assert property(p_pwm_duty_max);

	
	// Verify complete PWM cycle behavior
	property p_pwm_full_cycle;
	    @(posedge clk) disable iff(rst)
	    (counter == 0 && pwm_out) ##1 (counter == duty_cycle-1)[->1] |=> 
	    (!pwm_out) until (counter == 9);
	endproperty
	a_pwm_full_cycle: assert property(p_pwm_full_cycle);


	// Cover all duty cycle settings
	cover property (@(posedge clk) sw == 3'b000 && duty_cycle == 1);
	cover property (@(posedge clk) sw == 3'b111 && duty_cycle == 8);

	// Cover PWM output transitions
	cover property (@(posedge clk) $rose(pwm_out));
	cover property (@(posedge clk) $fell(pwm_out));

	// Cover full counter cycle
	cover property (@(posedge clk) counter == 0 ##1 counter == 9);
	// Duty cycle never exceeds maximum value (8)
	property p_duty_cycle_max;
	    @(posedge clk) disable iff(rst)
	    (duty_cycle <= 8);
	endproperty
	a_duty_cycle_max: assert property(p_duty_cycle_max);

	// Counter never exceeds maximum value (9)
	property p_counter_max;
	    @(posedge clk) disable iff(rst)
	    (counter <= 9);
	endproperty
	a_counter_max: assert property(p_counter_max);

	


endmodule
