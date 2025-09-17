;10/16/06
;Delta Basin Topo System application
;X-AXIS
;on COM3
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
DAREN1        		;1=on 0=off see p.40 of install guide -- p.55 of software guide
DELVIS0			;no viscous damping
DWAVEF1			;Wave form        
;CMDDIR 0		;direction of motor rotation,  Warning; this also effects limit switches
DAUTOS1			;reduce power to %50 when idle

		; *** MOTOR AND ENCODER SETTINGS AND SCALING 
ENC1			;use encoder feedback  (uses encoder to initiate decel)
ENCPOL 1		;encoder polarity  Note-  Changed from 1 to 0 for Liam's setup
			;   Note SCLD is based on Encoder for x axis since ENC1 is set
SCALE1       		;Turn on scaling
DRES20000       	;Microsteps per motor rev 25,000 (was 50000 on MainChanel)
				;rollers are approx 3.5" * pi * 25.4= 279.287
				;20t drive gear / 72t driven gear = 3.6 ratio
				;279.287/3.6 = 77.58 mm per motor rev (assuming no slip and exact size of wheel)
				;   (Chris came up with actual move of 77.7605 mm per motor rev.) 						   		
ERES4000		;Encoder counts per Motor rev - encoder coupled directly to motor
			;	~78.125mm per motor rev * 40 cnts per encoder mm = 3125
			;	 79,000mm channel length * 40 = 3,160,000 counts which is ok for the encoder's +/- 8,388,603 24 bit limit

			;SCLD Notes; 	SCLD is truncated to an integer
			;		ZETA counter limit is =/-999,999,999 counts scaled any way you like
			;		SCLD limit is 999,999 cnt/unit so 10M scaling is max we can could on this axis
			;            	Using Meter units for X and Y axis results in up to ~1mm error over 80 meters on X (depending on fraction truncated)
			;		Using Meter scaling X axis moves can be up to 99,999.9999 M  (0.1mm res)
			;		SAYPOS changes to mm	
			;		Choose SCLD value for encoder or motor depending on ENC setting  	
;SCLD 133333 (theory) ;Cnt/M	;- ENCODER steps per mm  4000*4/120mm per drive gear rev = 133.3333333cnts per mm (note 4 to 1 motor to encoder gear ratio)
SCLD 133225 		;This is the actual calibrated value including belt stretch (calibrated by Chris 10/16/06)
;SCLD 666500 (theory)	; OR - MOTOR STEPS PER Meter 20,000 StepsPerRev*4/0.12m Per motor rev (note 4 to 1 motor to encoder gear ratio)
SCLV 666125 		;Motor Steps Per Meter Per Sec 166666.666666666667 per Meter
SCLA 666125 		;Motor Accel Steps change per Meter/s/s

			; (SCLV and SCLA can not be set above 999,999)


		;** STALL DETECTION
ESTALL1			;Enable stall detection
ESDB 10			;allow 10 steps of backlash upon direction reversal
ESK1			;kill upon stall detection


		;** LIMITS
LH 3			;use hardware limits
LHLVL11			;Y LIMITS ARE ACTIVE HIGH (PNP-NC) [LHLVL<Axis 1 CW><Axis 1 CCW>]
LHAD 10 ;M/s/s		;HARD LIMIT DECEL RATE


		;*** HOMING PARAMETERS
HOMV  .100  ;M/Sec	; homing velocity
HOMVF .5		; homing final velocity
HOMA  .500		; Home start accel
HOMAD  0		; homing deceleration = accel
HOMZ   1		; 1 = use encoder Z-Index to define home position
HOMEDG 1		; 0 = positive counting edge of home input
HOMBAC 0		; 1 = reverse direction after encountering home
HOMDF  0		; 1 = move in positive counting direction (vertically down) to Z-index			
HOMLVL 0		; 0 = active low for NO limit OR 1 = active hi, NC
		;Use [HOM 1] command  to home in negative counting direction 


		;*** OUTPUT CONFIGURATION
OUTFEN1			;1 = Enable
OUTFNC1-A		;A = General output
OUTFNC2-A
OUTFNC3-A
OUTFNC4-A
OUT0000			;TURN all 4 off



		;*** SET INITIAL MOVE PARAMETERS 
		   ;(BE SURE YOU ARE IN RIGHT SCALE)
MA 0			;make incremental instead of absolute moves
A  2		;Accel
AD 0			;setting decel to 0 causes it to follow accel
V  0.200		;velocity - Max V using this accel is 0.8 m/s
D  0			;distance 0

	


WRITE "0_X WOKEUP (Drive Disabled)"
END	;*** END OF WAKEUP PROGRAM **

STARTPWAKEUP		;define WAKEUP as power up program



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

PSET 0			;Because we are using ENC1, relative moves must be preceeded by PSET 0.  
			;  Otherwise manual (disengaged motor) will set a position err.
			;  This results in the drive making the new relative (Dxxx) move to Dxxx + position it 
			;  thought it should be at.

GO			;Do Move
D 0			;reset distance to 0 for safety
EOT 88,68,13		;set end of transmision characters to XD[CR] 
WRITE "0_X-DONE "	;write readable response with XD[CR] at end for computer to parse
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
WRITE "0_X-DONE "	;write readable response with XD[CR] at end for computer to parse
EOT 13,0,0     		;just a carriage return

END	;end of XB

		