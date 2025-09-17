;07/17/2007
;SAFL Tilting Flume application
;X-AXIS
;on COM1
;Meter Scaled
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
;2 - 1_E1		turn on this axis Listening
;3 - program text	redefine or add a program
;3 - E1			if desired turn all axis listening back on

;1_E0		;** Try to turn off other axes listening
;2_E0

	;***** WAKEUP PROGRAM ******

DELWAKEUP		;delete old program
DEFWAKEUP		;begin definition of new program

Vars1 = "X_Axis TiltBed v2" ;convenient way to figure out what port zeta is on
			;v2 includes fix of COMEXC0 in XB/XG

DRIVE0		;** TURN OFF so all parameters accepted

		;** COMMUNICATION & PROGRAM EXECUTION SETTINGS
;ERRLVL1			;REQUIRED FOR DAISY CHAIN COM necessary for Daisy-Chain communication
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
DAREN0        		;(overridden with DACTDP) 1=on/0=off see p.40 of install guide -- p.55 of software guide
DMTIND3			;(used with DACTDP)	  3 for 5.03~10.3mH 
DMTSTT4			;(used with DACTDP)	  set at max since motor has more torque than charts
;DACTDP2			;(DACTDP) 		  Active Dampening above 3rps.  Table suggests 1 but 2 worked better?? check at ut
DACTDP0			;(DACTDP) 		  Active Dampening above 3rps.  CRE 3-1-09 Seemed less jerky with this setting.

;DELVIS0			;no viscous damping
DELVIS4			;CRE 3-1-09 Seemed less jerky with this setting
DWAVEF1			;Wave form   VERIFIED AS BEST SETTING CRE 6/10/07 for UTFlume
CMDDIR1 		;direction of motor rotation,  Warning; this also effects limit switches
DAUTOS1			;reduce power to %50 when idle

		; *** MOTOR AND ENCODER SETTINGS AND SCALING 
ENC1			;use encoder feedback  (uses encoder to initiate decel)
ENCPOL 0		;encoder polarity
			;   Note SCLD is based on Encoder for x axis since ENC1 is set
SCALE1       		;Turn on scaling
DRES50000   		;Microsteps per motor rev 50000
										   		
ERES4000		;Encoder counts per Motor rev - encoder coupled directly to motor
			
			;SCLD Notes; 	SCLD is truncated to an integer
			;		ZETA counter limit is =/-999,999,999 counts scaled any way you like
			;		SCLD limit is 999,999 cnt/unit so 10M scaling is max we can could on this axis
			;            	Using Meter units for X and Y axis results in up to ~1mm error over 80 meters on X (depending on fraction truncated)
			;		Using Meter scaling X axis moves can be up to 99,999.9999 M  (0.1mm res)
			;		SAYPOS changes to mm	
			;		Choose SCLD value for encoder or motor depending on ENC setting  	
    		        ;Choose SCLD value for encoder or motor depending on ENC setting
   			;Choose SCLD value for encoder or motor depending on ENC setting        
;SCLD 40000 ;Cnt/M	;    - ENCODER STEPS PER M - USE FOR ENCODER FEEDBACK (ENC1)  4000cnts/rev/(.1m/rev)=40000cnts/m
SCLD 39989 ;Cnt/M	;    - ENCODER STEPS PER M - USE FOR ENCODER FEEDBACK (ENC1)  Adjusted for Belt Stretch CRE 3-8-08
;SCLD500000		; or - MOTOR STEPS PER METER   = 50000counts/0.1m (travel distance of 1 motor revolution) (ENC0)      
;SCLV500000       	;Motor steps per sec at 1 meter per sec 
;SCLA500000		;  "     "  ^2
SCLV499867       	;Motor steps per sec at 1 meter per sec Adjusted for Belt Stretch CRE 3-8-08
SCLA499867		;  "     "  ^2                          Adjusted for Belt Stretch CRE 3-8-08
  
		;** STALL DETECTION
ESTALL1			;Enable stall detection
ESDB 10			;allow 10 steps of backlash upon direction reversal
ESK1			;kill upon stall detection


		;** LIMITS
LH 3			;use hardware limits
;LHLVL00			;X LIMITS ARE ACTIVE HIGH (TTL low volt except when activated
			;  note depending on whether sinking or sourcing limits can be 
			;  considered NO or NC and still be Active High
			;  The controllers inputs are pulled high. Limits must pull to ground to activate.
LHAD 2.0 ;M/s/s		;HARD LIMIT DECEL RATE changed for tilting flume 2-29-08 CRE


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
OUTFEN1			;1 = Enable	;A = General
OUTFNC1-A		; output Strobe
OUTFNC2-A		; Bell
OUTFNC3-A
OUTFNC4-A
OUT0000			;TURN all 4 off




		;*** INPUT and JOG CONFIGURATION

INFEN1			;Enable Input Functions 

INFNC2-1J		;Input #2 defined as jog CW input for axis #1 
INFNC3-1K		;Input #3 defined as jog CCW input for axis #1 
INFNC4-L		;Input #4 defined as jog velocity select input 

JOGA  0.1		;Jog acceleration set to 100 mm/sec/sec
JOGAD 0.5		;Jog deceleration set to 500 mm/sec/sec
JOGVH 1.0		;The velocity when the jog velocity select input is high 
JOGVL 0.5		;The velocity when the jog velocity select input is low 

IF( IN=BX00)		;Enable jog if switches off now 
  JOG 1
ELSE
  JOG 0			;Enable jog mode 
NIF




		;*** Stop button 

INFNC1-D		;Stop button is input #1
ERROR.8-1		;enable the error check bit for stop
ERRORP ONSTOP		;define error program
COMEXS 0		;0 = AFTER stop clear buffered commands, 1=continue next program cmd when pause is exited



		;*** SET INITIAL MOVE PARAMETERS 
		   ;(BE SURE YOU ARE IN RIGHT SCALE)
MA 0			;make incremental instead of absolute moves
A  0.5	;Accel  Changed for tilting flume 2-29-08 CRE	
AD 0			;setting decel to 0 causes it to follow accel
V  0.200		;velocity - Max V using this accel is 0.8 m/s
D  0			;distance 0

	

IF (IN=B000)		;if Stop and Jogs not now active assume ok to enable them
  DRIVE 1
  WRITE "0_X WOKEUP (Drive and Jog Enabled)"
ELSE
  WRITE "0_X WOKEUP (Drive Disabled)"
NIF

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

DEL XG
DEF XG

COMEXC0			;normal execution (just in case it was not reset some how in XB) Debugging Axis in motion error

PSET 0			;Because we are using ENC1, relative moves must be preceeded by PSET 0.  
			;  Otherwise manual (disengaged motor) motors or slight dislocations between moves will set a position err.
			;  This results in the drive making the new relative (Dxxx) move to Dxxx + position it 
			;  thought it should be at.

GO			;Do Move
D 0			;reset distance to 0 for safety

EOT 88,68,13		;set end of transmision characters to XD[CR] for computer to parse

IF(AS=bxxxxxxxxxxx1)	;if stalled bit 12 will be set
 WRITE "X-STALLED "
ELSE
 IF (AS=bxxxxxxxxxxxxxx1)	;if Hit Positive Hdwr Limit [15th bit from left]
  WRITE "X-HIT_LM+ "
 ELSE
  IF (AS=bxxxxxxxxxxxxxxx1)	;if Hit Negitive Hdwr Limit [16th bit from left]
   WRITE "X-HIT_LM- "
  ELSE	
   if (MOV<>b0)
     WRITE "X-Done Before Move Done"
   ELSE
   	WRITE "X-DONE "	;write readable response with YD[CR] at end for computer to parse
   NIF
  NIF
 NIF
NIF


EOT 13,0,0     		;just a carriage return

END	;end of XG 



;	************ XB [D] ************* (GO while ringing bell)
;
DEL XB
DEF XB

PSET 0			;see above 


COMEXC1			;continuous execution required to ring bell
VAR2 = 0		;toggling variable
Out.1-1			;Turn on Strobe

GO			;Start Move



		;Bell  (door bell style) 
OUT.2-1			;Ring Bell
  ;T.5			;energize solonoid for 1/2 sec (MainChan bell needs just a whack)
  ;OUT.2-0		;Bell solonoid off
T.5			;When starting energize solonoid for 1/2 sec 

REPEAT
 IF(VAR2=0)		;then time to ring bell
  TIMST0		;Reset and start timer
  VAR2=1
  OUT.2-1		;Ring Bell
  T.33			;energize bell 
  OUT.2-0		;Bell off  
 ELSE			;Time between bell rings
  VAR2=0
  WAIT(MOV=b0 OR TIM > 3000) ;Wait til move is done or 3 seconds
 NIF
UNTIL(MOV=b0)		;loop till move is done

D 0			;reset distance to 0 for safety
OUT.1-0			;Turn off strobe
OUT.2-0			;Bell off
COMEXC0			;normal execution



EOT 88,68,13		;set end of transmision characters to XD[CR] for computer to parse

IF(AS=bxxxxxxxxxxx1)	;if stalled bit 12 will be set
 WRITE "X-STALLED "
ELSE
 IF (AS=bxxxxxxxxxxxxxx1)	;if Hit Positive Hdwr Limit [15th bit from left]
  WRITE "X-HIT_LM+ "
 ELSE
  IF (AS=bxxxxxxxxxxxxxxx1)	;if Hit Negitive Hdwr Limit [16th bit from left]
   WRITE "X-HIT_LM- "
  ELSE	
   WRITE "X-DONE "		;write readable response with YD[CR] at end for computer to parse
  NIF
 NIF
NIF

EOT 13,0,0     		;just a carriage return

END	;end of XB


DEL ONSTOP
DEF ONSTOP			; Begin definition of program onjump
  ERROR.8-0			;turn off
  WRITE "RED_StopHit "
  OUT.2-0			;Bell off  
  OUT.1-0			;Strobe off  
  WHILE (IN.1 = B1) 		; Wait for STOP input #1 to CLEAR
  NWHILE
  WRITE "StopReleased "
  ERROR.8-1
END



;***** Send back name of axis for this zeta (for info only)
DEL SayAxis
DEF SayAxis
WRVARS 1
END
	

;DEF onjump ; Begin definition of program onjump
;VAR1=VAR1+1 ; Increment variable 1
;END ; End definition of program onjump
;VAR1=0 ; Initialize variable 1
;ONIN1 ; When input 1 becomes active, branch to the ON program
;ONP onjump ; Assign the onjump program as the ON program
;ONCOND1000 ; Enable only the ONIN function. Disable		