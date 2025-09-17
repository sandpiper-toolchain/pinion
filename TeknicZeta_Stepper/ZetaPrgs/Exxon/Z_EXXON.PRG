;12-18-2010
;Exxon Cart application
;Z axis
;CENTIMETER Scaled


		;***** WAKEUP PROGRAM ******
DELWAKEUP		;delete old wake up
DEFWAKEUP		;begin new definition

DRIVE 0		;** TURN OFF so all parameters accepted

Vars1 = "Z_Axis Exxon _v4" ;convenient way to figure out what port zeta is on
			;v4 uses Continuous Commands and set AD to LHAD on eStops
			;v3 has stop debounce
Vars2 = "Centimeter Scaled"

VAR3 = 0		;Clear instop flag		
VAR4 = 400 ;cm/s/s	;Hard limit and estop decel




		;** COMMUNICATION & PROGRAM EXECUTION SETTINGS
;ERRLVL1		;REQUIRED FOR DAISY CHAIN COM necessary for Daisy-Chain communication
ECHO1			;REQUIRED FOR DAISY CHAIN COM echo commands back to computer 
EOT13,0,0         	;have Zeta return a CR after each transmission
COMEXC1			;1= continuous commands (required for fast Estop in all modes), 0 = execute commands one at a time
COMEXL1			;1 = allow buffered commands to continue when limit is hit
			;   this is required for homing and receiving messages after a limit is hit



		;** MOTOR & DRIVE SETTINGS - PACSCI N31-HRFK-LEK-M2-00  (not fully tested)
			;Note DAREN (Anti-resonance) is ignored if DACTDP (Active Dampening) is active
DAREN1       		;1=on 0=off see p.40 of install guide -- p.55 of software guide
			;  when on vertical axis on main channel resonance trouble above 30mm/s
			;  when off it went 50
DELVIS0                 ; no viscous damping, for speeds under 3rps (seemed worse when in use)
DWAVEF4			; WAVEFORM (seemed best for Z on Exxon  cart)           
DACTDP5			;ACTIVE DAMPING ENABLED helped some but still had some bad speeds
			;ACTIVE DAMPING PARAMETERS - IGNORED IF ACTIVE DAMPING DISABLED
DMTIND4			;INDUCTANCE <5.02 (ACTUAL- 4.9)
DMTSTT4			;STATIC TORQUE 2.34-3.48 (ACTUAL- 2.47)

	;!!!!  ************ Remember Z down is always positive ******************** !!!!
CMDDIR0 		;direction of motor rotation,  Warning; this also effects limit switches
			
DAUTOS1			;reduce power to %50 when idle


		; *** MOTOR AND ENCODER SETTINGS AND SCALING  
ENC 1    		;1 = using encoder to make moves SCLD then refers to Encoder cnts per cm
ENCPOL 0		;encoder polarity ; ************ Remember Z down is always positive ********************
SCALE 1       		;Turn on scaling
DRES 50000       	;micro steps per rev   (DRES should be higher than ERES so it always can step to a particular encoder position)
ERES 4000         	;ERES = Encoder counts per Motor rev 
			;	4000/ 0.4in per rev /25.4*1000 = 393701 counts per m 

			;SCLD Notes; 	SCLD is truncated to an integer
			;		ZETA counter limit is =/-999,999,999 counts scaled any way you like
			;		SCLD limit is 999,999 cnt/unit so meter scaling is max we can could on this axis
			;            	Using METER scaling is best reasonable unit for Zaxis resulting in ~.025mm error over 2000mm
			;		SAYPOS changes to mm	
			;		Choose SCLD value for encoder or motor depending on ENC setting  
			; SCLD = 4000 = 4000ERES *  10 mmPerScaleUnit /10 mmPerMotorRev    				     
SCLD 4000  ;Cnt/CM	;    - ENCODER steps per Unit 
;SCLD 50000 		; or - MOTOR STEPS PER cm

			 
SCLV 50000 		;SCLV,A = 50000 MicroStepsPerUnit = 10mmScaling /  10 mmPerMotorRev * 50000 microstepPerRev 
SCLA 50000 

		;** STALL DETECTION
ESTALL1			;Enable stall detection
ESDB 10			;allow 10 steps of backlash upon direction reversal
ESK1			;kill upon stall detection


		;** LIMITS
LH 3			;use hardware limits	
LHLVL01			;Z Limits on Exxon cart are wired opposite top and bottom
LHAD (VAR4)  		;cm/s/s	;HARD LIMIT DECEL RATE


		;*** HOMING PARAMETERS
HOMV  1.50  ;cm/sec	; homing velocity
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



		;*** INPUT and JOG CONFIGURATION

INFEN1			;Enable Input Functions 
INDEB1,20		;set Debounce for all Inputs to 20 ms (4 is default)

INFNC2-1J		;Input #2 defined as jog CW input for axis #1 
INFNC3-1K		;Input #3 defined as jog CCW input for axis #1 
INFNC4-L		;Input #4 defined as jog velocity select input 

JOGA  1.0		;Jog acceleration  cm/sec/sec
JOGAD 10		;Jog deceleration  cm/sec/sec
JOGVH 3			;The velocity when the jog velocity select input is high 
JOGVL 2			;The velocity when the jog velocity select input is low 

;IF( IN=BX00)		;Enable jog if switches off now 
;  JOG 1
;ELSE
;  JOG 0			;Enable jog mode 
;NIF



		;*** OUTPUT CONFIGURATION
			;Note Definining an output 1 as the IN-Motion output made output 1 commands change the state of output wire 2 ETC.
			;	so to avoid confusion I made 8 the IN-MOTION output
OUTFEN1			;1 = Enable	;A = General
OUTFNC1-A		; Define as programmable output - Strobe 
OUTFNC2-A		; Define as programmable output - Bell
OUTFNC3-A		; Define as programmable output - Z power down
OUTFNC4-A		; Define as programmable output - anything else
OUTFNC5-A		; Define as programmable output - anything else
OUTFNC6-A		; Define as programmable output - anything else
OUTFNC7-A		; Define as programmable output - wired so it can be used to programically release brake.
OUTFNC8-B		; Define as IN-MOTION output    - Automatic Brake Release (may be also connected to Out.7 (WIRE OR'd) 			;  
OUT00000000		;TURN all 8 off


		;*** STOP button CONFIGURATION
			;Y and Z just stop and clear any buffered commands - X takes care of informing DAQ
INFNC1-D		;Stop button is input #1
ERROR.8-1		;enable the error check bit for stop
ERRORP ONSTOP		;define error program ,no need only X responds
COMEXS 0		;0 = AFTER stop clear buffered commands, 1=continue next program cmd when pause is exited




		;*** SET INITIAL MOVE PARAMETERS
		;(BE SURE YOU ARE IN RIGHT SCALE)
MA 0  			;make incremental instead of absolute moves	
MC 0			;Non-Continuous motion (incase someone set continuous outside VB)
A 2.0	;cm/s/s		;Accel
AD 0.0  		;setting decel to 0 causes it to follow accel
V 1.0   ;cm/s		;velocity
D 0.0  			;don't move till programmed

;IF (IN = B000)
;  DRIVE 1
;  WRITE "2_Z WOKEUP (Drive and Jog Enabled)"
;ELSE
  Write"2_Z Woke Up (Drive is Disabled)"
;NIF

END		;************************ END OF WAKEUP PROGRAM *********************************

STARTPWAKEUP		;define WAKEUP program to run at power up




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
			;LEFT     1   = NOT AT POSITIVE LIMIT (DOWNSTREAM,BOTTOM, or L/R MAX)
			;MID       1  = NOT AT NEGATIVE LIMIT (UPSTREAM,TOP or L/R ORIGIN)
			;RIGHT      1 = HOME NOT ACTIVE

EOT 90,76,13		;ZL[CR]
TLIM			;TRANSFER LIMIT STATUS 
EOT13,0,0		;Send CRLF

END	;end ZLIM 




;	*********** SAYPOS [P] ************

;	Always make to return a MM Float
;	Return format compatible with daisy chain
;	*xxx.xxxap [*xxx.x = position, a = axis, p denotes a Position response]


DEL SAYPOS
DEF SAYPOS


EOT 90,80,13		;set end of transmision characters to ZP[CR] 
VAR1 = PE*10		;PE is scaled to CM  VAR1 to CM scaled encoder position
			;VAR1 scaled to MM 
WR VAR1			;TRANSFER scaled and offset MM Position  (will not include probe offsets)
EOT 13,0,0		;Reset end of transmision characters to CRLF
	
END  ;end SAYPOS



;***** Send back name of axis for this zeta (for info only)
DEL SayAxis
DEF SayAxis
  WRVARS 1
  WRVARS 2
END



;	************ ZG *************
;		     GO
	;as a way to avoid bad communications use G_ commands instead of 
	;sending a set of commands to do the same thing
	; (even if another the addressing portion of this command 
	;  is trashed other controllers will not have this program)

DEL ZG
DEF ZG
DRIVE 1
PSET 0			;Because we are using ENC1, relative moves must be preceeded by PSET 0.  
			;  Otherwise manual (disengaged motor) will set a position err.
			;  This results in the drive making the new relative (Dxxx) move to Dxxx + position it 
			;  thought it should be at.

VAR3 = 0		;CLEAR	INSTOP MODE FLAG
ERROR.8-1		;Reset Stop interupt here because sometimes multiple stop hits can leave unset
COMEXC1			;continuous execution so stops can be had LHAD decel rate

GO			;Start Move			
WAIT(MOV=b0)		;Wait til move is done
			;NOTE if stop button hit none of whats after this loop will run 

D 0			;reset distance to 0 for safety
EOT 90,68,13		;set end of transmision characters to ZD[CR]  for computer to parse

IF(AS=bxxxxxxxxxxx1)	;if stalled bit 12 will be set
 WRITE "Z-STALLED "
ELSE
 IF (AS=bxxxxxxxxxxxxxx1)	;if Hit Positive Hdwr Limit [15th bit from left]
  WRITE "Z-HIT_LM+ "
 ELSE
  IF (AS=bxxxxxxxxxxxxxxx1)	;if Hit Negitive Hdwr Limit [16th bit from left]
   WRITE "Z-HIT_LM- "
  ELSE	
   WRITE "Z-DONE "	;write readable response with ZD[CR] at end for computer to parse
  NIF
 NIF
NIF

EOT 13,0,0     		;just a carriage return

END	;end of ZG 




DEL ONSTOP
DEF ONSTOP			; ******** Begin definition of Error program 

	;On first entry after stop is pressed routine turns off strobe/bell, sets decel to max and issues a stop
	;on second entry which occurs immediately after the S cmd routine 
	;	turns off error bit, 
	;	waits for decel to finish
	;	waits for Stop to be released
	;	rearms stop bit
	;NOTE ** Setting Decel to LHAD (VAR4) will only work when using ZG because in that subroutine Zeta is in
	;	icontinuous command mode, else this program only runs after Zeta finishes move

   IF (VAR3 <> 0) 
	ERROR.8-0		;turn off/clear this interrupt on second entry
	JUMP STOPED		;if stop is released then it was hit again before motors stopped so skip the first part
   ELSE 
	VAR3 = 1	
   NIF 

   ;Notes:	
   ;at this point only stop buttons trigger this program 
   ;Otherwise to see what caused branch to this routine test ER (IF (ER.8=b1) 
   ;ERROR.8-0	;turn off/clear this interrupt if you don't want to come back in. (turn back on when exiting)
   ;if an S is issued within a Error Stop routine program buffer will be wiped and not return
		
   
   IF (MOV<>b0)		;if moving set to max decel and issue a stop cmd
      AD (VAR4)		;? this will not return until stop is complete ???
      S                 ;****** NOTE Actual Decel to Stop already started electrically by zeta
   NIF			;   this AD change only is useful in continuous command mode

$STOPED
   VAR3 = 2
   WAIT(MOV=b0)  
   OUT.7-0	;set brake just in case
   AD  0	;sets decel back same as A
   D 0

   EOT 90,68,13		;set end of transmision characters to ZD[CR]  for computer to parse
   WRITE "Z-Stopped "
   EOT 13,0,0     		;just a carriage return
   
   T 0.25			;debounce DELAY
   WHILE (IN.1 = B1) 		; Wait for STOP input #1 to CLEAR
   NWHILE
   T 0.25			;debounce

   ERROR.8-1			;reactivate this stop interupt		
   VAR3 = 0

END	

