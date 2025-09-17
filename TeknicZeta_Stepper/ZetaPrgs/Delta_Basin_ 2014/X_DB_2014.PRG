;08/10//2010
;UT Wonsuck Flume application (derived from Exxon)
;X-AXIS
;on COM1
;Meter Scaled



	;***** WAKEUP PROGRAM ******

DELWAKEUP		;delete old program
DEFWAKEUP		;begin definition of new program

DRIVE0		;** TURN OFF so all parameters accepted

 		;*** VARIABLE SETTING AND/OR USAGE 
Vars1 = "X_Axis DB_2014_v4" ;convenient way to figure out what port zeta is on
			;v2 includes fix of COMEXC0 in XB/XG
			;v3 has stop debounce
			;v4 leaves COMEXC at 1 for better Estops 
Vars2 = "Meter Scaled"

VAR2 = 0		;Clear buzzer toggling variable
VAR3 = 0		;clear instop flag

		;** other variable uses
;VAR4 			Hard limit and estop decel



		;** COMMUNICATION & PROGRAM E			XECUTION SETTINGS
;ERRLVL1			;REQUIRED FOR DAISY CHAIN COM necessary for Daisy-Chain communication
			;   No error ERROK or ERRBAD or ?s will be returned
			;   The command is also stripped so instead of *TLM011 you only get *011
			;   Since this makes it harder to parse return having suffixes sent back
			;   from SayPos, GETLIMIT .....
ECHO1			;REQUIRED FOR DAISY CHAIN COM echo commands back to computer 
EOT13,0,0         	;have Zeta return a CR  after each transmission
COMEXC1			;1=Continuous execution (must loop after a go),    0=execute commands one at a time
COMEXL1			;allow buffered commands to continue when limit is hit
			;   this is required for homing and sending messages after a limit is hit
			;   for apps with brakes ONSTOP error program can turn brake on before deceleration time 
			;	for faster braking
				


		;** MOTOR & DRIVE SETTINGS
DAREN0        		;(overridden with DACTDP) 1=on/0=off see p.40 of install guide -- p.55 of software guide
	;Note Zeta 8 may override with dip switch inductance setting
DMTIND3			;(used with DACTDP)	  3 for 5.03~10.3mH 
DMTSTT4			;(used with DACTDP)	  set at max since motor has more torque than charts
DACTDP2			;(DACTDP) Note this is set on rotory switch on zeta8's
                        ;         Active Dampening above 3rps.  Table suggests 1 but 2 worked better?? check at ut

DELVIS1 ;0		;0 = no viscous dampingx

DWAVEF4   	        ;wave form just play with it
			;adjusted pots at resonant speed of 6.5 rps (.65 m/sec with 20t pinion)
CMDDIR0 		;direction of motor rotation,  Warning; this also effects limit switches
DAUTOS1			;reduce power to %50 when idle

		; *** MOTOR AND ENCODER SETTINGS AND SCALING 
ENC1			;use encoder feedback  (uses encoder to initiate decel)
ENCPOL 0		;encoder polarity
			;   Note SCLD is based on Encoder for x axis since ENC1 is set
SCALE1       		;Turn on scaling
DRES 20000		;Microsteps per motor rev 
										   		
ERES 5004			;Encoder counts per Motor rev (integer) (quad for Zetas)
			
			;SCLD Notes; 	SCLD is truncated to an integer
			;		ZETA counter limit is =/-999,999,999 counts scaled any way you like
			;		SCLD limit is 999,999 cnt/unit so 10M scaling is max we can could on this axis
			;            	Using Meter units for X and Y axis results in up to ~1mm error over 80 meters on X (depending on fraction truncated)
			;		Using Meter scaling X axis moves can be up to 99,999.9999 M  (0.1mm res)
			;		SAYPOS changes to mm	
			;		Choose SCLD value for encoder or motor depending on ENC setting  	
    		       
   			;Choose SCLD value for encoder or motor depending on ENC setting  
			;Without belt stretch      
SCLD 96000		;Cnt/M	;      - ENCODER STEPS PER M - USE FOR ENCODER FEEDBACK (ENC1)  
;SCLD 384000		;   or - MOTOR STEPS PER METER   = (travel distance of 1 motor revolution) (ENC0)      
SCLV 383693		;Motor steps per sec at 1 meter per sec 
SCLA 383693		;  "     "  ^2


		;** STALL DETECTION
ESTALL1			;Enable stall detection
ESDB 10			;allow 10 steps of backlash upon direction reversal
ESK1			;kill upon stall detection


		;** LIMITS
LH 3			;use hardware limits
LHLVL00			;X LIMITS ARE ACTIVE HIGH (TTL low volt except when activated
			;  note depending on whether sinking or sourcing limits can be 
			;  considered NO or NC and still be Active High
			;  The controllers inputs are pulled high. Limits must pull to ground to activate.

VAR4 = 1.25 ;M/s/s	;Hard limit Decel Rate
LHAD(VAR4) ;M/s/s	;HARD LIMIT DECEL RATE changed for tilting flume 2-29-08 CRE


		;** POSTION MAINTENANCE
EPM 0			;disable (VB can turn on and off as needed)
			;when EPM = 0 the following settings are ignored
EPMDB 2			;DEADBAND IN ENCODER STEPS -- @40 ENCODER STEPS PER MM = +/-0.05MM
EMOVDB 1		;1= don't go to next buffered command until inside deadband
EPMG 100000		;error * gain = velocity ????
EPMV .100		;MAX POSTITION MAINTENANCE VELOCITY 100mm/sec


		;*** HOMING PARAMETERS
HOMV  .100  ;M/Sec	; homing velocity
HOMVF .5		; homing final velocity
HOMA  .500		; Home start accel
HOMAD  0		; homing deceleration = accel
HOMZ   1		; 1 = use encoder Z-Index to define home position
HOMEDG 1		; 0 = positive counting edge of home input
HOMBAC 0		; 1 = reverse direction after encountering home
HOMDF  0		; 1 = move in positive counting direction (vertically down) to Z-index			
HOMLVL 1		; 0 = active low for NO limit OR 1 = active hi, NC
		;Use [HOM 1] command  to home in negative counting direction 


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
OUTFNC7-A		; Define as programmable output - Used to keep brake released while drives enabled and slope is low
OUTFNC8-B		; Define as IN-MOTION output    - Automatic Brake Release (may be also connected to Out.7 (WIRE OR'd) to avoid 
			;   noise when slope is low --
OUT00000000		;TURN all 8 off




		;*** INPUT and JOG CONFIGURATION


INFEN1			;Enable Input Functions 
INDEB1,20		;set Debounce for all Inputs to 20 ms (4 is default)

INFNC2-1J		;Input #2 defined as jog CW input for axis #1 
INFNC3-1K		;Input #3 defined as jog CCW input for axis #1 
INFNC4-L		;Input #4 defined as jog velocity select input 

JOGA  0.1		;Jog acceleration set to 100 mm/sec/sec
JOGAD 0.5		;Jog deceleration set to 500 mm/sec/sec
JOGVH 1.0		;The velocity when the jog velocity select input is high 
JOGVL 0.5		;The velocity when the jog velocity select input is low 


;enable this only if jog buttons installed
;IF( IN=BX00)		;Enable jog if switches off now 
;  JOG 1
;ELSE
  JOG 0			;Disable jog mode 
;NIF


		
		;*** Stop button branch to ONSTOP Program
		;     ONSTOP must determine which occured

ERRORP ONSTOP		;define error program for all error conditons 

INFNC1-D		;Stop button is input #1
ERROR.8-1		;enable the error check bit for stop 
COMEXS 0		;0 = AFTER stop clear buffered commands, 1=continue next program cmd when pause is exited



;   **** Other input conventions
;reserving 
;INP 15 for low brake air pressure


;not implemented    ;***Braking Quick Stop at limit switch	
;ERROR.2-1		;Enable the error check bit for Limit Switch activation		
;ONP ONLIMIT 		; Assign the ONLIMIT program as the ON input condition program
;ONINxxxxxxxxxxxxxxx0	; input #16 can be tied to limit switch input
;ONCOND1000 		; Enable only the ONIN function.



		;*** SET INITIAL MOVE PARAMETERS 
		   ;(BE SURE YOU ARE IN RIGHT SCALE)
MA 0			;make incremental instead of absolute moves
MC 0			;Non-Continuous motion (incase someone set continuous outside VB)
A  0.35	;Accel  changed for DB 4-25-2014	
AD 0			;setting decel to 0 causes it to follow accel
V  0.200		;velocity - Max V using this accel is 0.8 m/s
D  0			;distance 0

	

;IF (IN=B000)		;if Stop and Jogs not now active assume ok to enable them
;  DRIVE 1
;  WRITE "0_X WOKEUP (Drive and Jog Enabled)"
;ELSE
  WRITE "0_X WOKEUP (Drive Disabled)"
;NIF

END	;*** END OF WAKEUP PROGRAM **

STARTPWAKEUP		;define WAKEUP as power up program





;	********** GOHOME ************
;!!!! does not work consistantly presumably because MainChannel
;      does not have a home limit

		;routine assumes limit switch is wired to home input
;DEL GOHOME
;DEF GOHOME
;V.200
;A.300
;D -99
;GO
;HOM1					
;WRITE "1_X Homed"
;END			;end of GOHOME definition



;	********* XLIM [L] ********

;	Return format compatible with daisy chain
;	*xxxal [x=limit states, l denotes a limit response, a = axis]
;  NOTE;
;  if not done in this compact, single return method it is possible that
;  another axes could send something between a description and the value.
;  Use of lower case will not return a lower case letter unless it is the 
;  final controller on chain

DEL XLIM 
DEF XLIM 

			;         PNH (Positive, Negative, Home)
			;RETURNS *111 WHERE 
			;         1xx = NOT AT POSITIVE LIMIT (xDOWNSTREAM,zBOTTOM, or yMAX)
			;         x1x = NOT AT NEGATIVE LIMIT (xUPSTREAM,zTOP or yMIN)
			;         xx1 = HOME NOT ACTIVE (if connected)


EOT 88,76,13		;XL [CR]
TLIM			;TRANSFER LIMIT STATUS 
EOT13,0,0		;Send CRLF


END	;end XLIM 


 
;	*********** SAYPOS [P] ************
; Note, since now doing PSET 0 before XG this will only return last move

;	Always make to return a MM Float
;	Return format compatible with daisy chain
;	*xxx.xxxap [*xxx.x = position, a = axis, p denotes a Position response]


DEL SAYPOS
DEF SAYPOS


EOT 88,80,13		;set end of transmision characters to x p [CR]  
VAR1 = PE*1000		;PE = Meter Zeta scaled encoder position				
WR VAR1			;TRANSFER scaled and offset MM Position  (will not include probe offsets)
EOT 13,0,0		;Reset end of transmision characters to CRLF
			

END  	;end SAYPOS



;	************ XG [D] *************
;		     
	;as a way to avoid bad communications use G_ commands instead of 
	;sending a set of commands to do the same thing
	; (even if another the addressing portion of this command 
	;  is trashed other controllers will not have this program)

DEL XG ;obsolete now Zetas XB figures out whether to warn
DEF XG

JUMP XB


END	;end of XG 



;	************ XB [D] ************* (GO while ringing bell)
;
DEL XB		;This routine now decides on its own whether to ring bell
DEF XB

DRIVE 1			;now auto activating drive 	
PSET 0			;Because we are using ENC1, relative moves must be preceeded by PSET 0.  
			;  Otherwise manual (disengaged motor) will set a position err.
			;  This results in the drive making the new relative (Dxxx) move to Dxxx + position it 
			;  thought it should be at.

VAR3 = 0		;CLEAR	INSTOP MODE FLAG
ERROR.8-1		;Reset here because sometimes multiple stop hits can leave unset
COMEXC1			;1=Continuous execution (must loop after a go)

IF (IN.15=b1)		;IF LOW AIR PRESSURE (if no air brake make sure pulled false)
 JUMP MVDONE
NIF



GO			;Start Move

VAR2 = 0		;toggling variable
Out.1-1			;Turn on Strobe if it exists


			;if going over 1 meter
IF (D>=1 OR D<=-1 )	;adjust times for start warning as desired
 OUT.2-1		;beep
 T.1			
 OUT.2-0		;off
 T.3			;
 OUT.2-1		;beep
 T.1			;
 OUT.2-0  		;off
NIF	

REPEAT
 IF(D>=1 OR D<=-1)	;ring bell if going over 1 meter

  IF(VAR2=0)		;then time to ring bell/buzzer
   TIMST0		;Reset and start timer
   VAR2=1
   OUT.2-1		;Energize bell/buzzer						
   T.1			;buzzing peizo
;  T.33		        ;or 1/3 sec for door bell style
   OUT.2-0		;Bell off 
 
  ELSE			;Time between bell rings
   VAR2=0
   REPEAT
     IF (IN.15=b1)		;IF LOW AIR PRESSURE		MUST TEST HERE AND BELOW IN CASE NOT RINGING		
       JUMP MVDONE
     NIF
   UNTIL (MOV=b0 OR TIM > 3000) ;Wait til move is done or 3 seconds
  NIF

 NIF ;end if ringing bell

 IF (IN.15=b1)		;IF LOW AIR PRESSURE			
    JUMP MVDONE
 NIF

UNTIL(MOV=b0)		;loop till move is done


$MVDONE
D 0			;reset distance to 0 for safety
OUT.1-0			;Turn off strobe
OUT.2-0			;Bell off



EOT 88,68,13		;set end of transmision characters to XD[CR] for computer to parse

IF(IN.15=b1)
 WRITE "LOW BRAKE AIR PRESSURE "
 EOT 13,0,0     		;just a carriage return
 S				;stop -- will not return here -- cmd buffer cleared
 WRITE "RETURNED FROM STOP"	;THIS WILL NOT RUN AND COMEXC WILL REMAIN AT 1
ELSE
 IF(AS=bxxxxxxxxxxx1)	;if stalled bit 12 will be set
  WRITE "X-STALLED "
 ELSE
  IF (AS=bxxxxxxxxxxxxxx1)	;if Hit Positive Hdwr Limit [15th bit from left]
   WRITE "X-HIT_LM+ "
  ELSE
   IF (AS=bxxxxxxxxxxxxxxx1)	;if Hit Negitive Hdwr Limit [16th bit from left]
    WRITE "X-HIT_LM- "
   ELSE	
    WRITE "X-DONE "		;write readable response with XD[CR] at end for computer to parse
   NIF
  NIF
 NIF
NIF

;COMEXC0		leaving continuous now	;normal execution
EOT 13,0,0     		;just a carriage return

END	;end of XB




;***** Send back name of axis for this zeta (for info only)
DEL SayAxis
DEF SayAxis
WRVARS 1
WRVARS 2
END

;***********

;DEL ONLIMIT	;NOT USING 
;DEF ONLIMIT
;
; 
;    OUTFNC8-A			;Change Brake output to normal output and turn off
;    OUT.1-0
;    WRITE "HardLimit BrakeEngaged "	
;    WAIT(MOV=b0) 		;Wait til decel is done
;    WRITE "Stopped "
;
;    OUTFNC1-B			;Reset to InMotion output for warning light or brake/clutch
;    
;END
;**********




DEL ONSTOP
DEF ONSTOP			;Begin definition of Error program 

	;On first entry after stop is pressed routine turns of strobe/bell, sets decel to max and issues a stop
	;on second entry which occurs immediately after the S cmd routine 
	;	turns off error bit, 
	;	waits for decel to finish
	;	waits for Stop to be released
	;	rearms stop bit

   IF (VAR3 <> 0) 
	;WRITE "ReStopped "	;for debugging 
	ERROR.8-0		;turn off/clear this interrupt on second entry
	JUMP STOPPED		;if stop is released then hit again before motors stop skip the first part
   ELSE 
	VAR3 = 1	
   NIF 

   OUT.1-0			;Strobe off  
   OUT.2-0			;Bell off  


   ;at this point only stop buttons trigger this program 
   ;Otherwise test ER (IF (ER.8=b1) to see what caused branch to this routine
;;;;;;ERROR.8-0	;turn off/clear this interrupt if you don't want to come back in. (turn back on when exiting)
     ;but if an S is issued here program buffer will be wiped and not return
		
			;NOTE Actual Decel to Stop already started electrically by zeta
   WRITE "RED_StopHit "
   
   IF (MOV<>b0)		;if moving set to max decel and issue a stop cmd
      AD  (VAR4)	;this will not return until stop is complete
      S                 ;Note to take effect continuous execution had to be set
   NIF			;     Actual Decel already started electrically by stop switch	
 
$STOPPED
   VAR3 = 2
   WAIT(MOV=b0)  
   OUT.7-0	;set brake just in case -- but since inmotion output on 8 will be active until decel complete this only helps if decel stall occurs
   AD  0	;sets back same as A
   D 0

   EOT 88,68,13			;XD   
   WRITE "X-Stopped "
   EOT 13,0,0     		;just a carriage return
   
   T 0.25			;debounce DELAY
   WHILE (IN.1 = B1) 		; Wait for STOP input #1 to CLEAR
   NWHILE
   WRITE "StopReleased "   
   T 0.25			;debounce

   ERROR.8-1	;
   VAR3 = 0

END	

;DEF onjump ; Begin definition of program onjump
;VAR1=VAR1+1 ; Increment variable 1
;END ; End definition of program onjump
;VAR1=0 ; Initialize variable 1
;ONIN1 ; When input 1 becomes active, branch to the ON program
;ONP onjump ; Assign the onjump program as the ON program
;ONCOND1000 ; Enable only the ONIN function. Disable	

;could not get this to work - seems like unlike for stop button, hard limits do not
; activate ErrorProgram until decel is complete.
; 
;    IF (ER.8=b1)	;electrical stop button pressed (this seems to clear it reenters)
;      VAR4 = 1	;last Stop Reason
      
      ;ERROR.8-0	;turn off/clear this interrupt if you don't want to come backin
      
;    else
;	IF (ER.2=b1)
;	  VAR4 = 2	;last Stop Reason
;	  OUTFNC8-A			;Change Brake output to normal output and turn off
;    	  OUT.8-0			;turn off both brake release outputs	
;	  OUT.7-0
;	  WRITE "HardLimit BrakeEngaged "
;	  LH 0			;clear error condition so it won't reenter	
;          			
;	NIF
;   NIF	

;   ERROR.8-1	;restore ONSTOP call
;   LH 3	;restore hard limits

;   OUTFNC8-B		  ; Define back as IN-MOTION output

;  ERROR.8-1	;turn off/clear this interrupt if you don't want to come backin