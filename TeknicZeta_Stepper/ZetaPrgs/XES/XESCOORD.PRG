;12/10/2013
;XES application
;Short X axis to match 1/4 basin coord of XES



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

Vars1 = "X_Axis XES v5" ;convenient way to figure out what port zeta is on
			;v2 includes fix of COMEXC0 in YG 
			;v3 has stop debounce
			;v4 comexe = 1 and ONSTOP defined inorder to get fast estops when using stop buttons
			;v5 fixes in Stop so carriages don't restart after a stop is released
Vars2 = "Meter Scaled"
VAR3 = 0		;Clear instop flag

		;** other variable uses
;VAR4 			Hard limit and estop decel


		;** COMMUNICATION & PROGRAM EXECUTION SETTINGS
;ERRLVL1		;REQUIRED FOR DAISY CHAIN COM necessary for Daisy-Chain communication
			;   No error ERROK or ERRBAD or ?s will be returned
			;   The command is also stripped so instead of *TLM011 you only get *011
			;   Since this makes it harder to parse return having suffixes sent back
			;   from SayPos, GETLIMIT .....
ECHO1			;REQUIRED FOR DAISY CHAIN COM echo commands back to computer 
EOT13,0,0         	;have Zeta return a CR  after each transmission
COMEXC1			;continuously execute commands even during moves
COMEXL1			;allow buffered commands to continue when limit is hit
			;   this is required for homing and receiving messages after a limit is hit

		;** MOTOR & DRIVE SETTINGS
		;	Settings for Y worked ok to V=1.5M/s and A=1.2 M/s/s
DAREN1        		;(overridden with DACTDP) 1=on/0=off see p.40 of install guide -- p.55 of software guide

DMTIND3			;(used with DACTDP)	  3 for 5.03~10.3mH 
DMTSTT4			;(used with DACTDP)	  set at max since motor has more torque than charts
DACTDP2 ;3			;(DACTDP) 		  Active Dampening above 3rps.  Table suggests 1 but 3 worked better			

DELVIS0			;no viscous damping
DWAVEF 4		; WAVEFORM (seemed best for Y XES
CMDDIR0 		;direction of motor rotation,  Warning; this also effects limit switches and must work with ENCPOL
DAUTOS1			;reduce power to %50 when idle

		; *** MOTOR AND ENCODER SETTINGS AND SCALING 
ENC1			;use encoder feedback  (uses encoder to initiate decel)
ENCPOL0			;encoder polarity - 
			;   Note SCLD is based on Encoder for x axis since ENC1 is set
SCALE1       		;Turn on scaling
DRES 20000       	;micro steps per rev   (DRES should be higher than ERES so it always can step to a particular encoder position)
ERES 4000         	;ERES = Encoder counts per Motor rev 
			;	

			;SCLD Notes; 	SCLD is truncated to an integer
			;		ZETA counter limit is =/-999,999,999 counts scaled any way you like
			;		SCLD limit is 999,999 cnt/unit so meter scaling is max we can could on this axis
			;            	Using METER scaling is best reasonable unit for Zaxis resulting in ~.025mm error over 2000mm
			;		SAYPOS changes to mm	
			;		Choose SCLD value for encoder or motor depending on ENC setting  
			;Encoder on Drive SCLD  = 160000 EncoderCntPerUnit = 4000ERES *  1000 mmPerScaleUnit /25mmPerMotorRev 
				     
SCLD  160000 	;Cnt/M	;    - ENCODER steps per M (UnCalibrated)
		; 	(UnCalibrated / x = calibrated  xxxx
 		; or - MOTOR STEPS PER M (UnCalibrated) SCLD  800000 
		; SCLV,A = 800000 MicroStepsPerUnit = 1000mmScaling /  25 mmPerMotorRev * 20000 microstepPerRev  
SCLV 800000 		;Velocity and Accel are always scaled in motor units (Calibrated jim 6/2//2010
SCLA 800000

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
VAR4 = 3		;var4 used here and in E-Stops
LHAD (VAR4)  ;M/s/s	;HARD LIMIT DECEL RATE


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
 

INFNC2-1K		;Input #2 defined as jog CWw input for axis #1 
INFNC3-1J		;Input #3 defined as jog CW input for axis #1 
INFNC4-L		;Input #4 defined as jog velocity select input 

JOGA  0.03		;Jog acceleration  m/sec/sec
JOGAD 0.5		;Jog deceleration  m/sec/sec
JOGVH .5		;(not used) The velocity when the jog velocity select input is high 
JOGVL .5		;The velocity when the jog velocity select input is low 
 


		;*** Stop button CONFIGURATION

INFNC1-D		;Stop button is input #1	;<< this does the stop
COMEXS 0		;0 = AFTER stop clear buffered commands, 1=continue next program cmd when pause is exited
 
;Y and Z just stop and clear any buffered commands - X takes care of informing DAQ
ERROR.8-1		;enable the error check bit for stop
ERRORP ONSTOP		;define error program


		;*** SET INITIAL MOVE PARAMETERS 
		   ;(BE SURE YOU ARE IN RIGHT SCALE)
MA 0			;0= make incremental instead of absolute moves
MC 0			;Non-Continuous motion ie goes to a target or distance			
A  0.5 ;m/s/s		;Accel
AD 0			;setting decel to 0 causes it to follow accel
V  0.1 ;m/s		;velocity - Max V 
D  0			;distance 0

	
IF(IN = B000)		;assume ok to turn on if stop and jog inputs are off
  WRITE "0_Y WOKEUP (Drive and Jog Enabled)"
  DRIVE 1
  JOG 1
ELSE
  Drive 0
  JOG 0
  WRITE "0_Y WOKEUP (Drive Disabled)"
  Write "Stop or Y Jog Switch Stuck!!!"
   
NIF


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

IF (as.13 <> b0)	;0 means drive enabled 		'3/25/14	
  DRIVE 11		;auto activating drives
  WRITE "Enabling Y-Drive"	
  T .5			;It takes a bit to get geminis enabled.  else stall can occur
NIF

LH 0			;Cycle limits on and off so we don't get invalid conditions error
LH 3			;  and resets last stop bits
			
ENC 0			;cycling ENC because otherwise manual (disengaged motor) will set a position err.			 
ENC 1			;  This results in the drive making the new relative (Dxxx) move to Dxxx + position it 
			;  thought it should be at.

VAR3 = 0		;CLEAR	INSTOP MODE FLAG
ERROR.8-1		;Reset Stop interrupt here because sometimes multiple stop hits can leave unset

GO			;Start Move
WAIT(MOV=b0)		;Wait til move is done
			;NOTE if stop button hit none of what's after this loop will run 

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



DEL ONSTOP
DEF ONSTOP			; ******** Begin definition of Error program 

	;On first entry after stop is pressed routine turns off strobe/bell
	;       sets decel to max and issues a stop
        ;       NOTE ** Setting Decel to LHAD (VAR4) only works if comexc = 1, else this code runs after Zeta finishes move	
	;on second entry which occurs immediately after the S cmd routine 
	;	turns off error bit, 
	;	waits for decel to finish
	;	waits for Stop to be released
	;	rearms stop bit
	

   IF (VAR3 <> 0) ;ie not first entry
	;WRITE "Y-OnStop 2nd entry "	; (debug message)
	ERROR.8-0		;turn off/clear this interrupt on second entry
	JUMP STOPPED		;if stop is released then it was hit again before motors stopped so skip the first part
   ELSE 
	;WRITE "Y-OnStop 1st entry " ; (debug message)
	VAR3 = 1	
   NIF 

   ;Notes	
   ;at this point only stop buttons trigger this program 
   ;Otherwise to see what caused branch to this routine test ER (IF (ER.8=b1) 
   ;ERROR.8-0	;turn off/clear this interrupt if you don't want to come back in. (turn back on when exiting)
   ;if an S is issued within a Error Stop routine program buffer will be wiped and not return
		
   		 ;****** NOTE Actual Decel to Stop already started electrically by zeta
   IF (MOV<>b0)		;if moving set to max decel and issue a stop cmd
      AD (VAR4)		; set decl to max
      S                 ; this will not return until stop is complete ???
      WRITE "Y Came Back after S issued" ;debug do not expect this to run	
   NIF			;   this AD change only is useful in continuous command mode
   
	
$STOPPED
   VAR3 = 2
   WAIT(MOV=b0)  
   OUT.7-0	;set brake just in case
   AD  0	;sets decel back same as A
   D 0

   EOT 89,68,13		;set end of transmision characters to YD[CR]  for computer to parse
   WRITE "Y-Stopped "
   EOT 13,0,0     		;just a carriage return
   
   IF (IN.2 = b1 or IN.3 = b1)
     JOG 0
   NIF	

   T 0.25			;debounce DELAY
   WHILE (IN.1 = B1) 		;Wait for STOP input #1 to CLEAR
   NWHILE
   T 0.25			;debounce

   ERROR.8-1			;reactivate this stop interupt		
   VAR3 = 0

   WRITE "Y-Stop Clear "	; (debug message)
   S				;issuing an Stop here just to clear any buffered commands, othewise motion could start after stop release.  Halt did not work 3/26/2014
   WRITE "Y-Returned after Stop??"	 ;should not run
END ;end ONSTOP





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





