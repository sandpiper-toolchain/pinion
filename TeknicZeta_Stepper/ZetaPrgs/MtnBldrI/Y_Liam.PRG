;1/4/2006
;Mountain Builder Topo System application
;Y axis
;on COMM4
;Meter Scaled
;Daisy Chain Version - worked as of 4/28/06  BUT----Always was suceptable to other contollers stepping on commands

;--- Due to limitations of ZETA math, and entry limits scaling to real world coords has to be done with care.
;	Unless your application's drive length is both short and based on your desired unit, such as Velmex 2mm pitch 
;	and it needs no calibration such as with belts the best solution may be to do the math in the computer 
;	and then send step/count commands to the zeta.  The only way to send the zeta 99345623451 steps is to
;	either have scaling off or set to 1.  Setting to 1 allows velocity/accel to be in step/cnts as well 
; 	as distance.  The basic problems are due to Zeta's fixed point instead of true floating point distance entry'
;	the fact that you must enter integer SCLD... and upper limits of move entries.  However if you can get desired
;	resolution/accuracy with integer SCLD and still travel the whole basin go for it. 

;	Jim


;Note, only indented commented out command lines were removed from Daisy chain application for delta basin use
;	(if not indented they were comments in daisy chain app as well

; NOTE for Daisy chain program loading first use terminal to activate only this axis
;1 - E0			shut off all listening
;2 - 1_E1		turn on this axis Listening
;3 - program text	redefine or add a program
;3 - E1			if desired turn all axis listening back on

	;0_E0		;** Try to turn off other axes listening
	;2_E0


;1_ERASE		;*** Erase all programs ***


		;***** WAKEUP PROGRAM ******
DELWAKEUP		;delete old wake up
DEFWAKEUP		;begin new definition

DRIVE0		;** TURN OFF so all parameters accepted

		;** COMMUNICATION & PROGRAM EXECUTION SETTINGS
	;ERRLVL1	;REQUIRED FOR DAISY CHAIN COM necessary for Daisy-Chain communication
ECHO1			;REQUIRED FOR DAISY CHAIN COM echo commands back to computer 
EOT 13,0,0     		;just a carriage return
COMEXC0			;0 = execute commands one at a time
COMEXL1			;1 = allow buffered commands to continue when limit is hit
			;   this is required for homing and receiving messages after a limit is hit

		;** MOTOR & DRIVE SETTINGS - PACSCI E31NLFA-LNW
DAREN1        		; 1=on 0=off see p.40 of install guide -- p.55 of software guide
DELVIS0               	; 0 = no viscous damping
DWAVEF1			; WAVEFORM             
DACTDP0			;ACTIVE DAMPING DISABLED
			;ACTIVE DAMPING PARAMETERS - IGNORED IF ACTIVE DAMPING DISABLED
;DMTIND4		;INDUCTANCE <5.02 (ACTUAL- 4.9)
;DMTSTT4		;STATIC TORQUE 2.34-3.48 (ACTUAL- 2.47)
;CMDDIR 0		;(default is 0)direction of motor rotation,  Warning; this also effects limit switches
DAUTOS1			;reduce power to %50 when idle



		; *** MOTOR AND ENCODER SETTINGS AND SCALING  
ENC 1    		;1 = using encoder to make moves SCLD then refers to Encoder cnts per mm
ENCPOL 1		;encoder polarity  Note-  Changed from 1 to 0 for Liam's setup
SCALE1       		;Turn on scaling
DRES20000      		;5,000 micro steps per motor rev   
			;	could not use 50,000 because that caused SCLV and SCLA to be beyond Zeta limits
ERES4000  		;Encoder counts per Motor rev - encoder directly coupled to motor
			
			;SCLD Notes; 	SCLD is truncated to an integer
			;		ZETA counter limit is =/-999,999,999 counts scaled any way you like
			;		SCLD limit is 999,999 cnt/unit so 10M scaling is max we can could on this axis
			;            	Using DecaMeter units for X and Y axis results in upto ~.3mm error over 180meters on X
			;		SAYPOS changes to mm	
			;		Choose SCLD value for encoder or motor depending on ENC setting  	

;SCLD 133333 ;Cnt/M	;    - ENCODER steps per mm  4000*4/120mm per drive gear rev = 133.3333333cnts per mm (note 4 to 1 motor to encoder gear ratio)
SCLD 133300		;This is the actual calibrated value including belt stretch (calibrated by Chris 10/16/06)
;SCLD 666500		; OR - MOTOR STEPS PER Meter 20,000 StepsPerRev*4/0.12m Per motor rev (note 4 to 1 motor to encoder gear ratio)
SCLV 666500		;Motor Steps Per Meter Per Sec 166666.666666666667 per Meter
SCLA 666500		;Motor Accel Steps change per Meter/s/s

			; (SCLV and SCLA can not be set above 999,999)

		;** STALL DETECTION
ESTALL1			;Enable stall detection
ESDB 10			;allow 10 steps of backlash upon direction reversal
ESK1			;kill upon stall detection


		;** LIMITS
LH 3			;use hardware limits
LHLVL11			;Y LIMITS ARE ACTIVE HIGH (PNP-NC) [LHLVL<Axis 1 CW><Axis 1 CCW>]
LHAD 10 	;M/s/s	;HARD LIMIT DECEL RATE


		;*** HOMING PARAMETERS
		
HOMV  .100  ;M/sec	; homing velocity
HOMVF .5		; homing final velocity
HOMA  .500		; Home start accel
HOMAD  0		; homing deceleration
HOMZ   1		; 1 = use encoder Z-Index to define home position
HOMEDG 1		; 0 = positive counting edge of home input
HOMBAC 0		; 1 = reverse direction after encountering home
HOMDF  0		; 1 = move in positive counting direction (vertically down) to Z-index			
HOMLVL 0		; 0 = active low for NO limit OR 1 = active hi, NC
		;Use [HOM 1] command  to home in negative counting direction 



		;*** SET INITIAL MOVE PARAMETERS
		   ; (BE SURE YOU ARE IN RIGHT SCALE)
MA   0			;make incremental instead of absolute moves	
A    2  		;Accel
AD   0			;setting decel to 0 causes it to follow accel
V    0.200		;velocity - Max V using this accel is 2.0 m/s



Write"1_Y Woke Up (Drive Disabled)"
END		;***** END OF WAKEUP PROGRAM *****

STARTPWAKEUP		;define WAKEUP program to run at power up








;	********* YLIM [L] ********

;	Return format compatible with daisy chain
;	*xxxal [x=limit states, l denotes a limit response, a = axis]

;  NOTE;
;  if not done in this compact, single return method it is possible that
;  another axes could send something between a description and the value.
;  also use of lower case xyz allows easy parsing of Zeta returns since
;  the Zeta never uses lower case on its own

DEL YLIM 
DEF YLIM 

			;RETURNS *111 WHERE 
			;LEFT  1 = NOT AT POSITIVE LIMIT (DOWNSTREAM,BOTTOM, or L/R MAX)
			;MID   1 = NOT AT NEGATIVE LIMIT (UPSTREAM,TOP or L/R ORIGIN)
			;RIGHT 1 = HOME NOT ACTIVE

EOT 89,76,13		;YL[CR]
TLIM			;TRANSFER LIMIT STATUS 
EOT 13,0,0     		;just a carriage return

END	;end LM_Y



;	*********** SAYPOS [P] ************
; Note, since now doing PSET 0 before YG this will only return last move
;	Always make to return a MM Float
;	Return format compatible with daisy chain
;	*xxx.xxxap [*xxx.x = position, a = axis, p denotes a Position response]


DEL SAYPOS
DEF SAYPOS

EOT 89,80,13		;set end of transmision characters to YP[CR]  
VAR1 = PE*1000		;PE = Meter scaled encoder position				
WR VAR1			;TRANSFER scaled and offset MM Position  (will not include probe offsets)
EOT 13,0,0     		;just a carriage return

END  ;end SAYPOS



;	************ YG *************
;		     GO
	;as a way to avoid bad daisy communications use [X,Y,Z]G commands instead of 
	;sending a normal set of commands to do the same thing
	; (even if the addressing portion of this command 
	;  is trashed, at least other controllers will not have this program)

DEL YG
DEF YG

PSET 0			;Because we are using ENC1, relative moves must be preceeded by PSET 0.  
			;  Otherwise manual (disengaged motor) will set a position err.
			;  This results in the drive making the new relative (Dxxx) move to Dxxx + position it 
			;  thought it should be at.


GO			;Do Move
D 0			;reset distance to 0 for safety
EOT 89,68,13		;set end of transmision characters to YD[CR] 
WRITE "Y-DONE "		;write readable response with YD[CR] at end for computer to parse
EOT 13,0,0     		;just a carriage return

END	;end of YG 