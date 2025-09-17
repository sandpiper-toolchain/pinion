;6-21-10
;Brazil Cart application
;Y axis



;--- Due to limitations of ZETA math, and entry limits it may be better not to scale to real world coords
;	Unless your application's drive is both short and based on your desired unit, such as Velmex 2mm pitch 
;	and it needs no calibration as when belts are used, the best solution is to do the math in the computer 
;	and then send step/count commands to the zeta.  The only way to send the zeta 99345623451 steps is to
;	either have scaling off or set to 1.  Setting to 1 allows velocity /accel to be in step/cnts as well 
; 	as distance.  The basic problems are due to Zeta's fixed point instead of true floating point distance entry'
;	the fact that you must enter integer SCLD... and upper limits of move entries.



	;***** WAKEUP PROGRAM ******

DELWAKEUP		;delete old program
DEFWAKEUP		;begin definition of new program

DRIVE0		;** TURN OFF so all parameters accepted

Vars1 = "Y_Axis Brazil v3" ;convenient way to figure out what port zeta is on
			;v2 includes fix of COMEXC0 in YB/YG (though only really needed for x when doing XB
			;v3 has stop debounce
Vars2 = "Meter Scaled"

		;** COMMUNICATION & PROGRAM EXECUTION SETTINGS
;ERRLVL1		;REQUIRED FOR DAISY CHAIN COM necessary for Daisy-Chain communication
			;   No error ERROK or ERRBAD or ?s will be returned
			;   The command is also stripped so instead of *TLM011 you only get *011
			;   Since this makes it harder to parse return having suffixes sent back
			;   from SayPos, GETLIMIT .....
ECHO1			;REQUIRED FOR DAISY CHAIN COM echo commands back to computer 
EOT13,0,0         	;have Zeta return a CR  after each transmission
COMEXC0			;execute commands one at a time
COMEXL1			;allow buffered commands to continue when limit is hit
			;   this is required for homing and receiving messages after a limit is hit

		;** MOTOR & DRIVE SETTINGS
		;	Settings for Y worked ok to V=1.5M/s and A=1.2 M/s/s
DAREN1        		;(overridden with DACTDP) 1=on/0=off see p.40 of install guide -- p.55 of software guide

DMTIND3			;(used with DACTDP)	  3 for 5.03~10.3mH 
DMTSTT4			;(used with DACTDP)	  set at max since motor has more torque than charts
DACTDP3			;(DACTDP) 		  Active Dampening above 3rps.  Table suggests 1 but 3 worked better			

DELVIS0			;no viscous damping
DWAVEF3			; WAVEFORM (seemed best for Z Tilt bed)
CMDDIR1 		;direction of motor rotation,  Warning; this also effects limit switches and must work with ENCPOL
DAUTOS1			;reduce power to %50 when idle

		; *** MOTOR AND ENCODER SETTINGS AND SCALING 
ENC1			;use encoder feedback  (uses encoder to initiate decel)
ENCPOL0			;encoder polarity - 
			;   Note SCLD is based on Encoder for x axis since ENC1 is set
SCALE1       		;Turn on scaling
DRES 10000       	;micro steps per rev   (DRES should be higher than ERES so it always can step to a particular encoder position)
ERES 4000         	;ERES = Encoder counts per Motor rev 
			;	4000/ 3to1 pulley ratio 

			;SCLD Notes; 	SCLD is truncated to an integer
			;		ZETA counter limit is =/-999,999,999 counts scaled any way you like
			;		SCLD limit is 999,999 cnt/unit so meter scaling is max we can could on this axis
			;            	Using METER scaling is best reasonable unit for Zaxis resulting in ~.025mm error over 2000mm
			;		SAYPOS changes to mm	
			;		Choose SCLD value for encoder or motor depending on ENC setting  				     
;SCLD 160000  ;Cnt/M	;    - ENCODER steps per M (UnCalibrated)
;		
;SCLD 400000 		; or - MOTOR STEPS PER M (UnCalibrated)
SCLD 159944		; 	(Calibrated / 1.00035)
;SCLV&A Nominal 400000
SCLV 399860        	;      Velocity and Accel are always scaled in motor units (Calibrated jim 6/2//2010 399860.049)
SCLA 399860
 
		;** STALL DETECTION
ESTALL1			;Enable stall detection
ESDB 10			;allow 10 steps of backlash upon direction reversal
ESK1			;1=kill upon stall detection (had to deactivate because linear encoder sometime resulted in bad stall detect)


		;** LIMITS
LH 3			;use hardware limits
LHLVL11			;LIMIT switch polarity (LHLVL00 for microswitchs on Velmexs)
			;  note depending on whether sinking or sourcing limits can be 
			;  considered NO or NC and still be Active High
			;  If AUX_P is connected to 5V limits must pull to ground to activate.  Limits must pull to ground to activate.  NPN limits should be used
			;  If AUX_P is connected to 0V limits must source 5V to activate. PNP limits should be used
LHAD 3 ;M/s/s		;HARD LIMIT DECEL RATE


		;** POSTION MAINTENANCE 
EPM 0			;0 = disabled (vb can turn on and off as needed)
			;when EPM = 0 the following settings are ignored
EPMDB 5			;DEADBAND IN ENCODER STEPS -- @100 ENCODER STEPS PER MM setting to 10 = +/-0.05MM
EMOVDB 1		;1= don't go to next buffered command until inside deadband
EPMG 10000 ;was 100000		;error * gain = velocity ????
EPMV .0022		;MAX POSTITION MAINTENANCE VELOCITY 2.5mm/sec


		;*** HOMING PARAMETERS (not used in current VB code)
HOMV  .050  ;M/Sec	; homing velocity
HOMVF .005		; homing final velocity
HOMA  .500		; Home start accel
HOMAD  0		; homing deceleration = accel
HOMZ   1		; 1 = use encoder Z-Index to define home position
HOMEDG 1		; 0 = positive counting edge of home input
HOMBAC 0		; 1 = reverse direction after encountering home
HOMDF  0		; 1 = move in positive counting direction (vertically down) to Z-index			
HOMLVL 1		; 0 = active low for NO limit OR 1 = active hi, NC
		;Use [HOM 1] command  to home in negative counting direction 


		;*** OUTPUT CONFIGURATION
OUTFEN1			;1 = Enable
OUTFNC1-A		;A = General output
OUTFNC2-A
OUTFNC3-A
OUTFNC4-A
OUT0000			;TURN all 4 off


		;*** INPUT and JOG CONFIGURATION

INFEN1			;Enable Input Functions
INDEB1,20		;set Debounce for all Inputs to 20 ms (4 is default)
 

INFNC2-1J		;Input #2 defined as jog CW input for axis #1 
INFNC3-1K		;Input #3 defined as jog CCW input for axis #1 
INFNC4-L		;Input #4 defined as jog velocity select input 

JOGA  0.01		;Jog acceleration  m/sec/sec
JOGAD 0.5		;Jog deceleration  m/sec/sec
JOGVH .15		;The velocity when the jog velocity select input is high 
JOGVL .05		;The velocity when the jog velocity select input is low 

;IF( IN=BX00)		;Enable jog if switches off now 
;  JOG 1
;ELSE
  JOG 0			;Disable Enable jog mode 
;NIF






		;*** Stop button CONFIGURATION

INFNC1-D		;Stop button is input #1	;<< this does the stop
COMEXS 0		;0 = AFTER stop clear buffered commands, 1=continue next program cmd when pause is exited
 
;Y and Z just stop and clear any buffered commands - X takes care of informing DAQ
;ERROR.8-1		;enable the error check bit for stop
;ERRORP ONSTOP		;define error program


		;*** SET INITIAL MOVE PARAMETERS 
		   ;(BE SURE YOU ARE IN RIGHT SCALE)
MA 0			;0= make incremental instead of absolute moves
MC 0			;Non-Continuous motion			
A  0.5 ;m/s/s		;Accel
AD 0			;setting decel to 0 causes it to follow accel
V  0.1 ;m/s		;velocity - Max V 
D  0			;distance 0

	
;IF(IN = B000)		;assume ok to turn on if stop and jog inputs are off
;  WRITE "0_Y WOKEUP (Drive and Jog Enabled)"
;  DRIVE 1
;ELSE
;  WRITE "0_Y WOKEUP (Drive Disabled)"
;NIF

WRITE "0_Y WOKEUP (Drive Disabled)"

END	;*** END OF WAKEUP PROGRAM **

STARTPWAKEUP		;define WAKEUP as power up program



;	********* YLIM [L] ********

;	Return format compatible with daisy chain
;	*xxxal [x=limit states, l denotes a limit response, a = axis]

;  NOTE;
;  when daisy chaining if not done in this compact, single return method it is possible that
;  another axes could send something between a description and the value.
;  also use of lower case xyz allows easy parsing of Zeta returns since
;  the Zeta never uses lower case on its own

DEL YLIM 
DEF YLIM 

			;RETURNS *111 WHERE 
			;LEFT     1   = NOT AT POSITIVE LIMIT (DOWNSTREAM,BOTTOM, or L/R MAX)
			;MID       1  = NOT AT NEGATIVE LIMIT (UPSTREAM,TOP or L/R ORIGIN)
			;RIGHT      1 = HOME NOT ACTIVE

EOT 89,76,13		;YL[CR]
TLIM			;TRANSFER LIMIT STATUS 
EOT 13,0,0     		;just a carriage return

END	;end LM_Y





;	************ YG *************
;		     GO
	;as a way to avoid bad communications use G_ commands instead of 
	;sending a set of commands to do the same thing
	; (even if another the addressing portion of this command 
	;  is trashed other controllers will not have this program)

DEL YG
DEF YG
COMEXC0			;normal execution (V2 change - COMEXC0 normally already set but Just in case YB interupted
DRIVE 1			;now auto activating drive 

PSET 0			;Because we are using ENC1, relative moves must be preceeded by PSET 0.  
			;  Otherwise manual (disengaged motor) will set a position err.
			;  This results in the drive making the new relative (Dxxx) move to Dxxx + position it 
			;  thought it should be at.

GO			;Do Move
D 0			;reset distance to 0 for safety
EOT 89,68,13		;set end of transmision characters to YD[CR] to indicate motion stopped


IF(AS=bxxxxxxxxxxx1)	;if stalled [12th bit from left]
 WRITE "Y-STALLED "
ELSE
 IF (AS=bxxxxxxxxxxxxxx1)	;if Hit Positive Hdwr Limit [15th bit from left]
  WRITE "Y-HIT_LM+ "
 ELSE
  IF (AS=bxxxxxxxxxxxxxxx1)	;if Hit Negitive Hdwr Limit [16th bit from left]
   WRITE "Y-HIT_LM- "
  ELSE	
   WRITE "Y-DONE "	;write readable response with YD[CR] at end for computer to parse
  NIF
 NIF
NIF
 
EOT 13,0,0     		;just a carriage return

END	;end of YG 



;	*********** SAYPOS [P] ************

;	Always make to return a MM Float
;	Return format compatible with daisy chain
;	*xxx.xxxap [*xxx.x = position, a = axis, p denotes a Position response]



DEL SAYPOS
DEF SAYPOS
;set end of transmision characters to Y P [CR]

EOT 89,80,13
;VAR1 = PE*1000          ;PE is Meter scaled encoder position       			
			
;WR VAR1                ;TRANSFER scaled and offset MM Position  (will not include probe offsets)
TPE	
EOT 13,0,0		;Reset end of transmision characters to CRLF
			

END  	;end SAYPOS



;***** Send back name of axis for this zeta (for info only)
DEL SayAxis
DEF SayAxis
WRVARS 1
WRVARS 2

END





