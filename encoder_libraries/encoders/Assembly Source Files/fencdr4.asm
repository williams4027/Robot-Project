* icb file: "fencdr4.asm"

* handy board shaft encoders
* simple (non-quadrature) encoder 
*   with hysteresis on counting transitions
* samples at 1000 Hz. rate

* operates off of system interrupt

*  Fred Martin
*  22 Apr 1996

* 6811 registers
BASE	EQU	$1000
ADCTL	EQU	$1030	; A/D Control/status Register
ADR1	EQU	$1031	; A/D Result Register 1
TOC4INT	EQU	$E2	; Timer Output Compare 4

ANLGPORT EQU	4

* zero-page global variables
system_time_hi	EQU	$12
system_time_lo	EQU	$14

	ORG	MAIN_START

* low and high thresholds for counting pulses
variable_encoder4_low_threshold:		FDB	50
variable_encoder4_high_threshold:		FDB	200

* tick and velocity counts
variable_encoder4_counts:			FDB	0
variable_encoder4_velocity:			FDB	0

* internal variables
encoder_state:					FCB	0
last_counts:					FDB	0


* install module into 1 kHz IC system interrupt on TOC4
subroutine_initialize_module:
	LDX	#$BF00			; pointer to interrupt base
* install ourselves onto system interrupt
* get current vector; poke such that when we finish, we go there 
	LDD	TOC4INT,X		; SystemInt on TOC4
	STD	interrupt_code_exit+1

* install ourself as new vector
	LDD	#interrupt_code_start
	STD	TOC4INT,X

* reset encoder variables
	LDD	#0
	STAA	encoder_state
	STD	variable_encoder4_counts
	STD	variable_encoder4_velocity
	STD	last_counts

	RTS


* encoder interrupt code:
*	check for transition every time
* 	calculate velocities every 64th time called (about 16 Hertz)
interrupt_code_start:
	LDX	#BASE

* get analog reading
	LDAA	#ANLGPORT
	STAA	ADCTL,X
	BRCLR	ADCTL,X $80 *
	LDAA	ADR1,X

	TST	encoder_state
* if zero, look for rising edge
	BNE	test_falling
	CMPA	variable_encoder4_high_threshold+1
	BLO	encdr_done
* got it! increment
got_click:
	LDY	variable_encoder4_counts
	INY
	STY	variable_encoder4_counts
	LDAA	encoder_state
	EORA	#$FF
	STAA	encoder_state

	BRA	encdr_done
test_falling:
	CMPA	variable_encoder4_low_threshold+1
	BLO	got_click

encdr_done:
* calc velocities every 64 calls
	LDAA	system_time_lo+1	; lowest byte
	ANDA	#%001111111
	BNE	interrupt_code_exit

* velocities are ticks since last interrupt
	LDD	variable_encoder4_counts
	SUBD	last_counts
	STD	variable_encoder4_velocity
	LDD	variable_encoder4_counts
	STD	last_counts

interrupt_code_exit:
	JMP	$0000		/* this value poked in by init routine */

