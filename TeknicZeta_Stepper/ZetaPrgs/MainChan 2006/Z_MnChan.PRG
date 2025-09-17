;4/28/06
;Main Channel Cart application
;Z axis
;CENTEMITER Scaled
;Daisy Chain Version - worked as of 4/28/06     BUT----
;--- Due to limitations of ZETA math, and entry limits I decided not to scale to real world coords
;	Unless your applications drive is both short and based on your desired unit, such as Velmex 2mm pitch 
;	and it needs no calibration such as with belts the best solution is to do the math in the computer 
;	and then send step/count commands to the zeta.  The only way to send the zeta 99345623451 steps is to
;	either have scaling off or set to 1.  Setting to 1 allows velocity /accel to be in step/cnts as well 
; 	as distance.  The basic problems are due to Zeta's fixed point instead of true floating point distance entry'
;	the fact that you must enter integer SCLD... and upper limits of move entries.



; NOTE for Daisy chain program loading first use terminal to activate only this axis
;1 - E0			shut off all listening
;2 - 2_E1		turn on this axis Listening
;3 - program text	redefine or add a program
;3 - E1			if desired turn all axis listening back on

0_E0		;** Try to turn off other axes listening
1_E0


		;***** WAKEUP PROGRAM ******
DELWAKEUP		;delete old wake up
DEFWAKEUP		;begin new definition

DRIVE 0		;** TURN OFF so all parameters accepted

		;** COMMUNICATION & PROGRAM EXECUTION SETTINGS
ERRLVL1			;REQUIRED FOR DAISY CHAIN COM necessary for Daisy-Chain communication
ECHO1			;REQUIRED FOR DAISY CHAIN COM echo commands back to computer 
EOT13,0,0         	;have Zeta return a CR after each transmission
COMEXC0			;0 = execute commands one at a time
COMEXL1			;1 = allow buffered commands to continue when limit is hit
			;   this is required for homing and receiving messages after a limit is hit



		;** MOTOR & DRIVE SETTINGS - PACSCI N31-HRFK-LEK-M2-00  (not fully tested)
			;Note DAREN (Anti-resonance) is ignored if DACTDP (Active Dampening) is active
DAREN0       		;1=on 0=off see p.40 of install guide -- p.55 of software guide
			;  when on vertical axis on main channel resonance trouble above 30mm/s
			;  when off it went 50
DELVIS0                 ; no viscous damping, for speeds under 3rps (seemed worse when in use)
DWAVEF3			; WAVEFORM (seemed best for Z)           
DACTDP5			;ACTIVE DAMPING ENABLED helped some but still had some bad speeds
			;ACTIVE DAMPING PARAMETERS - IGNORED IF ACTIVE DAMPING DISABLED
DMTIND4			;INDUCTANCE <5.02 (ACTUAL- 4.9)
DMTSTT4			;STATIC TORQUE 2.34-3.48 (ACTUAL- 2.47)
CMDDIR 1		;direction of motor rotation,  Warning; this also effects limit switches
DAUTOS1			;reduce power to %50 when idle


		; *** MOTOR AND ENCODER SETTINGS AND SCALING  
ENC 1    		;1 = using encoder to make moves SCLD then refers to Encoder cnts per mm
ENCPOL 0		;encoder polarity
SCALE 1       		;Turn on scaling
DRES 50000       	;50,000 micro steps per rev   (DRES should be higher than ERES so it always can step to a particular encoder position)
ERES 4000         	;ERES = Encoder counts per Motor rev 
			;	4000/ 0.1in per rev /25.4 = 1574.80314 counts per mm 

			;SCLD Notes; 	SCLD is truncated to an integer
			;		ZETA counter limit is =/-999,999,999 counts scaled any way you like
			;		SCLD limit is 999,999 cnt/unit so decimeter scaling is max we can could on this axis
			;            	Using CM scaling is best reasonable unit for Zaxis resulting in ~.025mm error over 2000mm
			;		SAYPOS changes to mm	
			;		Choose SCLD value for encoder or motor depending on ENC setting  				     
SCLD 15748  ;Cnt/CM	;    - ENCODER steps per CM (4000/ 0.1" per rev /2.54 = 15,748.031496062992125984251968504 counts per cm )			
;SCLD 196850   		; or - MOTOR STEPS PER MM (=50000/(0.1*2.54)) = 19,6850.3937007874015748031496063   
SCLV 196850        	
SCLA 196850

		;** STALL DETECTION
ESTALL1			;Enable stall detection
ESDB 10			;allow 10 steps of backlash upon direction reversal
ESK1			;kill upon stall detection


		;** LIMITS
LH 3			;use hardware limits	
LHLVL00			;Z Limits are normally closed (voltage active Hi)
LHAD 200.0  ;cm/s/s	;HARD LIMIT DECEL RATE


		;*** HOMING PARAMETERS
HOMV  3.00  ;cm/sec	; homing velocity
HOMVF 0.05		; homing final velocity
HOMA  50		; Home start accel
HOMAD 0			; homing deceleration = accel
HOMZ   1		; 1 = use encoder Z-Index to define home position
HOMEDG 1		; 0 = positive counting edge of home input
HOMBAC 0		; 1 = reverse direction after encountering home
HOMDF  0		; 1 = move in positive counting direction (vertically down) to Z-index			
HOMLVL 1		; 0 = active low for NO limit OR 1 = active hi, NC
			; (velmex microswiches are wired NC)
	;Use [HOM 1] command to home in negative counting direction (up for z axis)



		;*** SET INITIAL MOVE PARAMETERS
		;(BE SURE YOU ARE IN RIGHT SCALE)
MA 0  		;make incremental instead of absolute moves	
A  2	;cm/s/s		;Accel
AD 0			;setting decel to 0 causes it to follow accel
V  3	;cm/s		;velocity
D  0			;don't move till programmed


Write"2_Z Woke Up (Drive is Disabled)"
END		;***** END OF WAKEUP PROGRAM *****

STARTPWAKEUP		;define WAKEUP program to run at power up



;	********** GOHOME ************
;!!!! does not work consistantly presumably because MainChannel
;      does not have a home limit

		;routine assumes limit switch is wired to home input
;DEL GOHOME
;DEF GOHOME
;HOM1		
;T 0.5			;settle 1/2 sec
;HOM1			;second home is a kluge to fix inconsistent problem that happens 
			;when homing fast and or when already near limit
;WRITE "2_Z Homed"
;END			;end of GOHOME definition






;	********* ZLIM [L] ********

;	Return format compatible with daisy chain
;	*xxxal [x=limit states, l denotes a limit response, a = axis]
;  NOTE;
;  if not done in this compact, single return method it is possible that
;  another axes could send something between a description and the value.
;  also use of lower case xyz allows easy parsing of Zeta returns since
;  the Zeta never uses lower case on its own

DEL ZLIM 
DEF ZLIM 


			;RETURNS *111 WHERE 
			;LEFT  1 = NOT AT POSITIVE LIMIT (DOWNSTREAM,BOTTOM, or L/R MAX)
			;MID   1 = NOT AT NEGATIVE LIMIT (UPSTREAM,TOP or L/R ORIGIN)
			;RIGHT 1 = HOME NOT ACTIVE

EOT 90,76,13		;ZL[CR]
TLIM			;TRANSFER LIMIT STATUS 
EOT13,0,0		;Send CRLF

END		;end ZLIM 




;	*********** SAYPOS [P] ************

;	Always make to return a MM Float
;	Return format compatible with daisy chain
;	*xxx.xxxap [*xxx.x = position, a = axis, p denotes a Position response]


DEL SAYPOS
DEF SAYPOS

	;The old routine got raw encoder count
	; and then scaled it. [PE] can be scalee but only when ENC1 is active.
	; In addition it is possible to use PSET to add offsets to 
	; encoder position in mm BUT ONLY when ENC=1 
	;VAR1=1CNT		;get encoder count NOTE-
	;VAR5=VAR1/1574.8031496	;4000/ 0.1" per rev /25.4 = 1574.8031496 counts per mm 

	;EOT0,0,0		;don't send crlf after "YPOS ="
	;WRITE "2_YPOS = "
	;EOT13,10,0	

	;WRVAR5			;send position		

	;ok code for use when not in daisy chain
	;VAR1 = PE		;set VAR1 to scaled encoder position
	;EOT0,0,0		;don't send crlf after "ZPOS ="
	;WRITE "2_ZPOS = "
	;EOT13,10,0
	;WR VAR1			;transfer ZETA scaled & offsettable encoder position in mm


EOT 90,80,13		;set end of transmision characters to ZP[CR] 
VAR1 = PE*10		;PE is scaled to CM  VAR1 to CM scaled encoder position
			;VAR1 scaled to MM 
WR VAR1			;TRANSFER scaled and offset MM Position  (will not include probe offsets)
EOT 13,0,0		;Reset end of transmision characters to CRLF
	

END  ;end SAYPOS



;	************ ZG *************
;		     GO
	;as a way to avoid bad communications use G_ commands instead of 
	;sending a set of commands to do the same thing
	; (even if another the addressing portion of this command 
	;  is trashed other controllers will not have this program)

DEL ZG
DEF ZG

PSET 0			;Because we are using ENC1, relative moves must be preceeded by PSET 0.  
			;  Otherwise manual (disengaged motor) will set a position err.
			;  This results in the drive making the new relative (Dxxx) move to Dxxx + position it 
			;  thought it should be at.

GO			;Do Move
D 0			;reset distance to 0 for safety
EOT 90,68,13		;set end of transmision characters to ZD[CR] 
WRITE "Z-DONE "		;write readable response with ZD[CR] at end for computer to parse
EOT 13,0,0     		;just a carriage return

END	;end of ZG 