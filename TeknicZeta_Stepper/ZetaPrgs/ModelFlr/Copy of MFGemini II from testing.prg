;Gemini GT Stepper Drive Setup

;Motor Setup
;DMTR 34		;Motor ID (RE42B-XXP10 Parallel/Series Winding)

DMTR 1
DMTSTT 3935.0		;Motor Static Torque (oz-in)
DMTJ 1090.000 	;Motor Rotor Inertia (kg*m*m*10e-6)
DPOLE 50		;Number of Motor Pole Pairs

;************for k42xxxL winding Parallel winding
;DMTIC 5 ;8.1		;Continuous Current (Amps-RMS)
;DMTIND 6		;Motor Inductance (mH)
;DMTRES 0.38		;Motor Winding Resistance (Ohm)

;.65m/s	
;DIGNA 6		;Current Loop Gain A
;DIGNB 0.5376		;Current Loop Gain B
;DIGNC 2.1468		;Current Loop Gain C
;DIGND 0.980		;Current Loop Gain D


;.45m/s
;DIGNA 3		;Current Loop Gain A
;DIGNB 0.2688		;Current Loop Gain B
;DIGNC 1.0734 		;Current Loop Gain C
;DIGND 0.980		;Current Loop Gain D


;Caused singing
;DIGNA 9		;Current Loop Gain A
;DIGNB 0.8064		;Current Loop Gain B
;DIGNC 3.2202		;Current Loop Gain C
;DIGND 0.980		;Current Loop Gain D

;**************** Series Winding
DMTIC 4		;Continuous Current (Amps-RMS)
DMTIND 23.9		;Motor Inductance (mH)
DMTRES 1.51		;Motor Winding Resistance (Ohm)

;1.5x suggested was bad
;1x
DIGNA 11.95		;Current Loop Gain A
DIGNB 1.0707		;Current Loop Gain B
DIGNC 4.2757		;Current Loop Gain C
DIGND 0.980		;Current Loop Gain D


;Drive Setup
DMODE 6		;Drive Control Mode
DRES 25000		;Drive Resolution (counts/rev)
ORES 200		;Encoder Output Resolution (counts/rev)
DAUTOS 50.00		;Auto Current Standby (% reduction of motor current)
DMVLIM 50.000000	;Velocity Limit (rev/sec)
DMVSCL 50.000000	;Velocity Scaling (rev/sec)

;Load Setup
LJRAT 15.0		;Load-to-Rotor Inertia Ratio

;Fault Setup
FLTSTP 1		;Fault on Startup Indexer Pulses Enable
FLTDSB 1		;Fault on Drive Disable Enable
ESK 1			;Fault on Stall Enable
DSTALL 0		;Stall Detect Sensitivity

;Digital Input Setup
INLVL 11000000	;Input Active Level
INDEB 50		;Input Debounce Time (milliseconds)
INUFD 0		;Input User Fault Delay Time (milliseconds)
LH 0			;Hardware EOT Limits Enable

;Digital Output Setup
OUTBD 0		;Output Brake Delay Time (milliseconds)
OUTLVL 0000000	;Output Active Level

;Analog Monitor Setup
DMONAV 0		;Analog Monitor A Variable
DMONAS 100		;Analog Monitor A Scaling (% of full scale output)
DMONBV 0		;Analog Monitor B Variable
DMONBS 100		;Analog Monitor B Scaling (% of full scale output)

;Motor Matching
DPHOFA 0.000	;Phase A Current Offset
DPHOFB 0.000	;Phase B Current Offset
DPHBAL 100.0	;Phase Balance
DWAVEF  0 ; 0 was quiter -4.00 	;Waveform (% of 3rd harmonic)

;Electronic Damping
DACTDP 4		;Active Damping Level
DDAMPA 0		;Damping During Acceleration Enable
DELVIS 0		;Electronic Viscosity Level
DABSD 0		;ABS Damping Enable
