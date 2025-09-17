;4/28/06
;Main Channel Cart application
;X-AXIS
;Meter Scaled

;--- Due to limitations of ZETA math, and entry limits I decided not to scale to real world coords
;	Unless your applications drive is both short and based on your desired unit, such as Velmex 2mm pitch 
;	and it needs no calibration such as with belts the best solution is to do the math in the computer 
;	and then send step/count commands to the zeta.  The only way to send the zeta 99345623451 steps is to
;	either have scaling off or set to 1.  Setting to 1 allows velocity /accel to be in step/cnts as well 
; 	as distance.  The basic problems are due to Zeta's fixed point instead of true floating point distance entry'
;	the fact that you must enter integer SCLD... and upper limits of move entries.



	;***** WAKEUP PROGRAM ******

DELWAKEUP		;delete old program
DEFWAKEUP		;begin definition of new program

Vars1 = "X_Axis UCB v2" ;convient way to figure out what port zeta is on
			;v2 includes fix of COMEXC0 in XB/XG		

DRIVE0		;** TURN OFF so all parameters accepted

		;** COMMUNICATION & PROGRAM EXECUTION SETTINGS
ERRLVL1			;REQUIRED FOR DAISY CHAIN COM necessary for Daisy-Chain communication
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
DACTDP2			;(DACTDP) 		  Active Dampening above 3rps.  Table suggests 1 but 2 worked better?? check at ut
DELVIS0			;no viscous damping
DWAVEF1			;Wave form   VERIFIED AS BEST SETTING CRE 6/10/07 for UTFlume
CMDDIR0 		;direction of motor rotation,  Warning; this also effects limit switches
DAUTOS1			;reduce power to %50 when idle


		; *** MOTOR AND ENCODER SETTINGS AND SCALING 
ENC 0			;1 = use encoder feedback  (uses encoder to initiate decel)
ENCPOL 0		;encoder polarity
			;   Note SCLD is based on Encoder for x axis since ENC1 is set
SCALE1       		;Turn on scaling
DRES25000       	;Microsteps per motor rev 25,000
				;rollers are approx 3.5" * pi * 25.4= 279.287
				;20t drive gear / 72t driven gear = 3.6 ratio
				;279.287/3.6 = 77.58 mm per motor rev (assuming no slip and exact size of wheel)
				;   (Chris came up with actual move of 77.7605 mm per motor rev.) 						   		
ERES 39998 ;4000 		;Encoder counts per Motor rev - encoder coupled directly to motor
			;	'1000 lpr X quad ???? not connected so not verified ??? on UCB_RFS
			;	 

			;SCLD Notes; 	SCLD is truncated to an integer
			;		ZETA counter limit is =/-999,999,999 counts scaled any way you like
			;		SCLD limit is 999,999 cnt/unit so 10M scaling is max we can could on this axis
			;            	Using Meter units for X and Y axis results in up to ~1mm error over 80 meters on X (depending on fraction truncated)
			;		Using Meter scaling X axis moves can be up to 99,999.9999 M  (0.1mm res)
			;		SAYPOS changes to mm	
			;		Choose SCLD value for encoder or motor depending on ENC setting  	
   		;Choose SCLD value for encoder or motor depending on ENC setting        
;SCLD 40000 ;Cnt/M	;    - (ENC1) ENCODER COUNTS PER M - USE FOR ENCODER FEEDBACK 
SCLD 499980 ;500000		; or - (ENC0) MOTOR STEPS PER METER     (20T * 10mm for AT10) = 0.2M/rev PerPulleyRev 
						     	     ; / 4-1 reducer = 0.050M PerMotorRev; 
							     ;  
						             ; and 25000 MotorStepsPerRev / PerMotorRev = 50000 MotorStepPerMeter
SCLV 499980 		;Motor steps per sec at 1 meter per sec (alway in motor step - not encoder
SCLA 499980 		;  "     "  ^2
 
		;** STALL DETECTION
ESTALL0			;Enable stall detection (must be using encoder)
ESDB 100		;allow 100 steps of backlash upon direction reversal
ESK1			;kill upon stall detection


		;** LIMITS
LH 3			;use hardware limits
LHLVL00			;0 = X LIMITS ARE ACTIVE HIGH (TTL low volt except when activated
;LHLVL11		;1 =     NPN N.O. ACTIVE LOW
			;  note depending on whether sinking or sourcing limits can be 
			;  considered NO or NC and still be Active High
			;  The controllers inputs are pulled high. Limits must pull to ground to activate.
LHAD 2.250 ;M/s/s	;HARD LIMIT DECEL RATE


		;** POSTION MAINTENANCE
EPM 0			;disable (vb can turn on and off as needed)
		   ;NOTE when EPM = 0 the following settings are ignored
EPMDB 2			;DEADBAND IN ENCODER STEPS -- @40 ENCODER STEPS PER MM = +/-0.05MM
EMOVDB 1		;1= don't go to next buffered command until inside deadband
EPMG 100000		;error * gain = velocity ????
EPMV .100		;MAX POSTITION MAINTENANCE VELOCITY 100mm/sec


		;*** HOMING PARAMETERS
;HOMV  .100  ;M/Sec	; homing velocity
;HOMVF .5		; homing final velocity
;HOMA  .500		; Home start accel
;HOMAD  0		; homing deceleration = accel
;HOMZ   1		; 1 = use encoder Z-Index to define home position
;HOMEDG 1		; 0 = positive counting edge of home input
;HOMBAC 0		; 1 = reverse direction after encountering home
;HOMDF  0		; 1 = move in positive counting direction (vertically down) to Z-index			
;HOMLVL 1		; 0 = active low for NO limit OR 1 = active hi, NC
		;Use [HOM 1] command  to home in negative counting direction 


		;*** OUTPUT CONFIGURATION
OUTFEN1			;1 = Enable
OUTFNC1-A		;A = General output
OUTFNC2-A
OUTFNC3-A
OUTFNC4-A
OUT0000
;OUT0010			;TURN all 4 off EXCEPT 3 if used to power Z axis for ADV


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

		;Define input Logic to voltage levels
INLVL 00000001  	;Stop button reverse logic

		;*** Stop button 
;
INFNC8-D		;Define input #8 as Stop (D=EStop)
ERROR.8-1		;enable the error check bit for stop
ERRORP ONSTOP		;define error program			!!! add program similar to Tiltbed if using
COMEXS 0		;0 = AFTER stop clear buffered commands, 1=continue next program cmd when pause is exited

		;*** Green Resume button
ONP GRNBUT
ONIN XXXXXX0		;Enable bit #7 I/O line to gosub grnbut
ONCOND 1000		;First bit is ONIN enable bit


		;*** SET INITIAL MOVE PARAMETERS 
		   ;(BE SURE YOU ARE IN RIGHT SCALE)
MA 0			;make incremental instead of absolute moves
A  0.300		;Accel
AD 0			;setting decel to 0 causes it to follow accel
V  0.200		;velocity
D  0			;distance 0

	


WRITE "0_X WOKEUP (Drive Disabled)"
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

			;         PNH
			;RETURNS *111 WHERE 
			;LEFT  1 = NOT AT POSITIVE LIMIT (DOWNSTREAM,BOTTOM, or L/R MAX)
			;MID   1 = NOT AT NEGATIVE LIMIT (UPSTREAM,TOP or L/R ORIGIN)
			;RIGHT 1 = HOME NOT ACTIVE


EOT 88,76,13		;XL [CR]
TLIM			;TRANSFER LIMIT STATUS 
EOT13,0,0		;Send CRLF


END	;end XLIM 


 
;	*********** SAYPOS [P] ************
; Note, since now doing PSET 0 before XG/B this will only return last move

;	Always make to return a MM Float
;	Return format compatible with daisy chain
;	*xxx.xxxap [*xxx.x = position, a = axis, p denotes a Position response]


DEL SAYPOS
DEF SAYPOS


EOT 88,80,13		;set end of transmision characters to x p [CR]  
;VAR1 = PE*1000		;PE = Meter Zeta scaled encoder position
VAR1 = PM*1000	        ;PM = Scaled motor position				
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
COMEXC0			;normal execution (repeated here in case XB interupted with !S or stop button

PSET 0			;Because we are using ENC1, relative moves must be preceeded by PSET 0.  
			;  Otherwise manual (disengaged motor) will set a position err.
			;  This results in the drive making the new relative (Dxxx) move to Dxxx + position it 
			;  thought it should be at.

GO			;Do Move
D 0			;reset distance to 0 for safety
EOT 88,68,13		;set end of transmision characters to XD[CR] 

IF(AS=bxxxxxxxxxxx1)	;if stalled bit 12 will be set
 WRITE "X-STALLED "
ELSE
 IF (AS=bxxxxxxxxxxxxxx1)	;if Hit Positive Hdwr Limit [15th bit from left]
  WRITE "X-HIT_LM+ "
 ELSE
  IF (AS=bxxxxxxxxxxxxxxx1)	;if Hit Negitive Hdwr Limit [16th bit from left]
   WRITE "X-HIT_LM- "
  ELSE	
   WRITE "X-DONE "	;write readable response with XD[CR] at end for computer to parse
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
COMEXC1			;continuous execution
GO			;Start Move

VAR2 = 0		;toggling variable
Out.1-1			;Turn on Strobe

		;SanFran Bell for Chris
OUT.2-1			;Ring Bell
T.05			;energize solonoid for 1/10 sec
OUT.2-0			;Bell solonoid off
T.2			;Pause 2/10 sec

REPEAT
 IF(VAR2=0)		;then time to ring bell
  TIMST0		;Reset and start timer
  VAR2=1
  OUT.2-1		;Ring Bell
  T.1			;energize solonoid for 1/10 sec
  OUT.2-0		;Bell solonoid off
 ELSE			;Time between bell rings
  VAR2=0
  WAIT(MOV=b0 OR TIM > 4000) ;Wait til move is done or 4 seconds
 NIF
UNTIL(MOV=b0)		;loop till move is done

D 0			;reset distance to 0 for safety
OUT.1-0			;Turn off strobe
OUT.2-0			;Bell off
COMEXC0			;normal execution
EOT 88,68,13		;set end of transmision characters to XD[CR] 

			;Now Check for possible stall
IF(AS=bxxxxxxxxxxx1)	;if stalled bit 12 will be set
 WRITE "X-STALLED "
ELSE
 IF (AS=bxxxxxxxxxxxxxx1)	;if Hit Positive Hdwr Limit [15th bit from left]
  WRITE "X-HIT_LM+ "
 ELSE
  IF (AS=bxxxxxxxxxxxxxxx1)	;if Hit Negitive Hdwr Limit [16th bit from left]
   WRITE "X-HIT_LM- "
  ELSE	
   WRITE "X-DONE "	;write readable response with XD[CR] at end for computer to parse
  NIF
 NIF
NIF 


EOT 13,0,0     		;just a carriage return

END	;end of XB

		;** Define Stop Program

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



		;** Define Resume Program
DEL GRNBUT
DEF GRNBUT
  WRITE "GREEN"
END  

;***** Send back name of axis for this zeta (for info only)
DEL SayAxis
DEF SayAxis
  WRVARS 1
END

;