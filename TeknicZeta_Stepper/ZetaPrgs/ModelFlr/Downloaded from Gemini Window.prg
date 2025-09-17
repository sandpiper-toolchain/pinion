;Uploaded from device address 0
;Gemini GT Stepper Drive Setup

;Motor Setup
DMTR 101		;Motor ID (ES22B-XXXXX Series Wiring)
DMTSTT 100.0		;Motor Static Torque (oz-in)
DMTIC 1.07		;Continuous Current (Amps-RMS)
DMTIND 20.8		;Motor Inductance (mH)
DMTRES 9.40		;Motor Winding Resistance (Ohm)
DMTJ 20.120		;Motor Rotor Inertia (kg*m*m*10e-6)
DPOLE 50		;Number of Motor Pole Pairs
DIGNA 9.000		;Current Loop Gain A
DIGNB 0.806		;Current Loop Gain B
DIGNC 3.220		;Current Loop Gain C
DIGND 0.980		;Current Loop Gain D

;Drive Setup
DMODE 6		;Drive Control Mode
DRES 24000		;Drive Resolution (counts/rev)
ORES 0		;Encoder Output Resolution (counts/rev)
DAUTOS 90.00		;Auto Current Standby (% reduction of motor current)
DMVLIM 50.000000	;Velocity Limit (rev/sec)
DMVSCL 50.000000	;Velocity Scaling (rev/sec)

;Load Setup
LJRAT 0.0		;Load-to-Rotor Inertia Ratio

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
OUTLVL 0100000	;Output Active Level

;Analog Monitor Setup
DMONAV 0		;Analog Monitor A Variable
DMONAS 100		;Analog Monitor A Scaling (% of full scale output)
DMONBV 0		;Analog Monitor B Variable
DMONBS 100		;Analog Monitor B Scaling (% of full scale output)

;Motor Matching
DPHOFA 0.000	;Phase A Current Offset
DPHOFB 0.000	;Phase B Current Offset
DPHBAL 100.0	;Phase Balance
DWAVEF -4.00	;Waveform (% of 3rd harmonic)

;Electronic Damping
DACTDP 4		;Active Damping Level
DDAMPA 0		;Damping During Acceleration Enable
DELVIS 0		;Electronic Viscosity Level
DABSD 0		;ABS Damping Enable
