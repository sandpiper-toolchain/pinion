;12/08/2008
;Confetti Spreader Drive
;X-AXIS
;Scaled RPS of brush wheel


	;***** WAKEUP PROGRAM ******

DELWAKEUP		;delete old program
DEFWAKEUP		;begin definition of new program

Vars1 = "Confetti Spreader" ;convient way to figure out what port zeta is on
Var1  = 5		;Seconds to spread confetti
Var2  = 2		;Seconds to delay start

DRIVE0		;** TURN OFF so all parameters accepted

		;** COMMUNICATION & PROGRAM EXECUTION SETTINGS
ERRLVL4			;Default = 4 show all errors
			;   No error ERROK or ERRBAD or ?s will be returned
			;   The command is also stripped so instead of *TLM011 you only get *011
			;   Since this makes it harder to parse return having suffixes sent back
			;   from SayPos, GETLIMIT .....
ECHO 0			;REQUIRED FOR DAISY CHAIN COM echo commands back to computer  
EOT13,0,0         	;have Zeta return a CR  after each transmission
COMEXC0			;execute commands one at a time
;COMEXL1			;allow buffered commands to continue when limit is hit
			;   ths is required for homing and receiving messages after a limit is hit

LH 0			;0=no limits

		;** MOTOR & DRIVE SETTINGS
DAREN1        		;1=on 0=off see p.40 of install guide -- p.55 of software guide
DELVIS0			;no viscous damping
DWAVEF4			;Wave form 4 went faster 3rps but wavef 2 was quiter
        
CMDDIR 0		;direction of motor rotation,  Warning; this also effects limit switches
DAUTOS1			;reduce power to %50 when idle

		; *** MOTOR AND ENCODER SETTINGS AND SCALING 
ENC0			;1 = use encoder feedback 
ENCPOL 0		;encoder polarity
			;   Note SCLD is based on Encoder for x axis since ENC1 is set
SCALE1       		;Turn on scaling
DRES25000       	;Microsteps per motor rev 25,000 
				;rollers are approx 3.5" * pi * 25.4= 279.287
				;20t drive gear / 72t driven gear = 3.6 ratio
			;279.287/3.6 = 77.58 mm per motor rev (assuming no slip and exact size of wheel)
				;   (Chris came up with actual move of 77.7605 mm per motor rev.) 						   		
;;ERES3125		;Encoder counts per Motor rev
			;	~78.125mm per motor rev * 40 cnts per encoder mm = 3125
			;	 79,000mm channel length * 40 = 3,160,000 counts which is ok for the encoder's +/- 8,388,603 24 bit limit

			;SCLD Notes; 	SCLD is truncated to an integer
			;		ZETA counter limit is =/-999,999,999 counts scaled any way you like
			;		SCLD limit is 999,999 cnt/unit so 10M scaling is max we can could on this axis
			;            	Using Meter units for X and Y axis results in up to ~1mm error over 80 meters on X (depending on fraction truncated)
			;		Using Meter scaling X axis moves can be up to 99,999.9999 M  (0.1mm res)
			;		SAYPOS changes to mm	
			;		Choose SCLD value for encoder or motor depending on ENC setting  	
   			;Choose SCLD value for encoder or motor depending on ENC setting        
			;40T /54T * 10 to 1 Reducer * scld25000 = 337500
SCLD 337500		;MOTOR STEPS PER REV
SCLV 337500		;Motor steps per Rev (50000 * 15 to 1 gear ratio = 
SCLA 337500		;  "     "  ^2
  




		;*** OUTPUT CONFIGURATION
OUTFEN1			;1 = Enable
OUTFNC1-A		;A = General output
OUTFNC2-A
OUTFNC3-A
OUTFNC4-A
OUT0000			;TURN all 4 off




		;*** SET INITIAL MOVE PARAMETERS 
		   ;(BE SURE YOU ARE IN RIGHT SCALE)
MA 0			;0=make incremental instead of absolute moves
A  10			;Accel
AD 0			;setting decel to 0 causes it to follow accel
V  .5			;velocity
D  1			;distance 0 or forward if in Continuous mode MC=1
MC 1			;1=continuous move 0=specific distance

	


WRITE "Confetti Speader WOKEUP (Drive Disabled)"
END	;*** END OF WAKEUP PROGRAM **

STARTPWAKEUP		;define WAKEUP as power up program


	;******************** Set duration of Confetti Feed **********
DEL SetDur
Def SetDur
Vars2 = "Send Duration"
Var1 = Read2
EOT 0,0,0  :Write "Duration mS = "
EOT 13,0,0 :WRVar 1
End

	;******************** Set Delay of Confetti Feed **********
DEL SetDel
Def SetDel
Vars2 = "Send Delay"
Var2 = Read2
EOT 0,0,0  : Write "Delay mS = "	;no EOT
EOT 13,0,0 : WRVar 2
End

	;******************** Spread Confetti **********
DEL Spread
Def Spread

COMEXC 1		;Continuous commands

Write "Delaying "
TIMST 0			;Reset timer at 0
WHILE (TIM < Var2)	;Delay Start
NWHILE 


Write "Spreading "
TIMST 0			;Begin spreading
GO
WHILE (TIM < Var1)
NWHILE	

Write "Done Spreading"
S			;Stop



COMEXC0
END


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

IF(AS=bxxxxxxxxxxx1)	;if stalled bit 12 will be set
 WRITE "X-STALLED "
ELSE
 IF (AS=bxxxxxxxxxxxxxx1)	;if Hit Positive Hdwr Limit [15th bit from left]
  WRITE "X-HIT_LM+ "
 ELSE
  IF (AS=bxxxxxxxxxxxxxxx1)	;if Hit Negitive Hdwr Limit [16th bit from left]
   WRITE "X-HIT_LM- "
  ELSE	
   WRITE "X-DONE "	;write readable response with YD[CR] at end for computer to parse
  NIF
 NIF
NIF

EOT 13,0,0     		;just a carriage return

END	;end of XG 

		;end of GOHOME definition

;***** Send back name of axis for this zeta (for info only)
DEL SayAxis
DEF SayAxis
WRVARS 1
END

