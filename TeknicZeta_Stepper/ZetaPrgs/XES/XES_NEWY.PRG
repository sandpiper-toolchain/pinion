;12/10/2013
;XES
;Y-AXIS is long axis
;on COM2
;Meter Scaled
;ENC 00

;*** Note Motor related commands are in Gemini setup not here.

;DEL GOTINP
;DEF GOTINP

;Not sending to VB anymore - Zetas do their own jogging
;input for jogging Y and Z as follows
;    Const EStopBit = 1   ;used by VB to get full jog pattern for all axes
;    Const XplusBit = 2
;    Const XnegBit = 3
;    Const YplusBit = 4 ;note 5 skipped
;    Const YnegBit = 6
;    Const ZplusBit = 7
;    Const ZnegBit = 8

;  Input 15 = Brake low air pressure
;  Input 16 = SICK Leak Input
;ONIN x1

;  Write"#Y_Y+JOG"	;# Indicates a Zeta Message. #Y indcates message from X controller
	
;END	

	;***** WAKEUP PROGRAM ******

DELWAKEUP		;delete old program
DEFWAKEUP 		;begin definition of new program

DRIVE00		;** TURN OFF so all parameters accepted

 		;*** VARIABLE SETTING AND/OR USAGE 
Vars1 = "Y_Axis XES_v5" ;convenient way to figure out what port zeta is on
			;v2 includes fix of COMEXC0 in XB/XG
			;v3 has stop debounce
			;v4 leaves COMEXC at 1 for better Estops 
			;v5 fixes in Stop so carriages don't restart after a stop is released

Vars2 = "LONG AXIS Y, ENC00"

VAR2 = 0		;Clear buzzer toggling variable
VAR3 = 0		;clear instop flag

		;** other variable uses
;VAR4 			Hard limit and estop decel
;VAR5 			is used as Temp Loop Counter


		;** COMMUNICATION & PROGRAM EXECUTION SETTINGS
;ERRLVL1			;REQUIRED FOR DAISY CHAIN COM necessary for Daisy-Chain communication
			;   No error ERROK or ERRBAD or ?s will be returned
			;   The command is also stripped so instead of *TLM011 you only get *011
			;   Since this makes it harder to parse return having suffixes sent back
			;   from SayPos, GETLIMIT .....
ECHO1			;REQUIRED FOR DAISY CHAIN COM echo commands back to computer 
EOT13,0,0         	;have Zeta return a CR  after each transmission
COMEXC1			;1=Continuous execution (must loop after a go),    0=execute commands one at a time
COMEXL11		;allow buffered commands to continue when limit is hit
			;   this is required for homing and sending messages after a limit is hit
			;   for apps with brakes ONSTOP error program can turn brake on before deceleration time 
			;	for faster braking
				


		;** MOTOR & DRIVE SETTINGS
DRFLVL 00		;Active low gemini fault level
;DAREN0        		;(overridden with DACTDP) 1=on/0=off see p.40 of install guide -- p.55 of software guide

;DMTSTT4			;(used with DACTDP)	  set at max since motor has more torque than charts
;DACTDP2			;(DACTDP) Note this is set on rotory switch on zeta8's
                        ;         Active Dampening above 3rps.  Table suggests 1 but 2 worked better?? check at ut

;Note Zeta 8 may override with dip switch inductance setting
;DMTIND4			;(used with DACTDP)	  
			;INDUCTANCE 4  <5.02mH  
			;	    3  5.03-10.3mH
			;	    2  10.3-20.07	    
			;K31xxxK-L, 845 oz-in  series = 8.3mH , 
			;K32xxxK-L, 1580 oz-in series = 16.2mh, 
			;K42xxxM-L, 2135 oz-in series = 8.7mH , Parallel = 2.2mh 
				;stand by active
				;SET to 2000~4100 Sys Inertia oz-in series and Step 1 on AD rotary Sw
		


;DELVIS1 ;0		;0 = no viscous damping configure when loaded

;DWAVEF1   	        ;wave form just play with it
			;adjusted pots at resonant speed of 6.5 rps (.65 m/sec with 20t pinion)
CMDDIR0,1 ;opposite per side ;direction of motor rotation,  Warning; this also effects limit switches
;DAUTOS1			;reduce power to %50 when idle

		; *** MOTOR AND ENCODER SETTINGS AND SCALING 
ENC00			;ENC did not accel properly with 2motorX so not using encoder feedback  (uses encoder to initiate decel)
ENCPOL 00		;encoder polarity
			;   Note SCLD is based on motor steps for x axis since ENC00 is set
SCALE1       		;Turn on scaling
DRES 15000,15000	;!!! to match Gemini !!!, Microsteps per motor rev  SET BOTH HERE AND IN GEMINIS
										   		
ERES 4000, 4000		;Encoder counts per Motor rev (integer)
	
			
			;SCLD Notes; 	SCLD is truncated to an integer
			;		ZETA counter limit is =/-999,999,999 counts scaled any way you like
			;		SCLD limit is 999,999 cnt/unit so 10M scaling is max we can could on this axis
			;            	Using Meter units for X and Y axis results in up to ~1mm error over 80 meters on X (depending on fraction truncated)
			;		Using Meter scaling X axis moves can be up to 99,999.9999 M  (0.1mm res)
			;		SAYPOS changes to mm	
			;		Choose SCLD value for encoder or motor depending on ENC setting  	
    		       
   			;Choose SCLD value for encoder or motor depending on ENC setting   


; somehow using ENC11 caused motors to accel at different speeds ?????
;so using motor steps SCLD if enc = 1,1 is  106,666.67 

			;  or - MOTOR STEPS PER METER   = (travel distance of 1 motor revolution) (ENC0)  
SCLD 300000, 300000 	;Motor steps per meter scaling
SCLV 300000, 300000 	;Motor steps per sec at 1 meter per sec  (always in motor steps)
SCLA 300000, 300000 	; SCLV,A = 300000 MicroStepsPerUnit = 1000mm Scaling 
DRFLVL 00 ;to match Gemini


		;** STALL DETECTION
ESTALL11		;Enable stall detection
ESDB 10,10		;allow 10 steps of backlash upon direction reversal
ESK11			;kill upon stall detection

		;** LIMITS
LH 3,3			;BINARY 11 = 3
			;use hardware limits

LHLVL0000		;XES LIMITS ARE FRONT LOOKING NC shorting to ground when not near metal			
			;  The controllers inputs are pulled high. Limits must stop pulling to ground to activate.

VAR4 = 1.5 ;M/s/s	;Hard limit Decel Rate
LHAD(VAR4),(VAR4)  ;M/s/s	;HARD LIMIT DECEL RATE 


		;** POSITION MAINTENANCE
EPM 00			;disable (VB can turn on and off as needed)
			;when EPM = 0 the following settings are ignored
EPMDB 2,2			;DEADBAND IN ENCODER STEPS -- @40 ENCODER STEPS PER MM = +/-0.05MM
EMOVDB 11		;1= don't go to next buffered command until inside deadband
EPMG 100000,100000	;error * gain = velocity ????
EPMV .100,.100		;MAX POSTITION MAINTENANCE VELOCITY 100mm/sec


		;*** HOMING PARAMETERS
HOMV  .100,.100  ;M/Sec	; homing velocity
HOMVF .5,.5		; homing final velocity
HOMA  .500,.500		; Home start accel
HOMAD  0,0		; homing deceleration = accel
HOMZ   1,1		; 1 = use encoder Z-Index to define home position
HOMEDG 1,1		; 0 = positive counting edge of home input
HOMBAC 0,0		; 1 = reverse direction after encountering home
HOMDF  0,0		; 1 = move in positive counting direction (vertically down) to Z-index			
HOMLVL 1,1		; 0 = active low for NO limit OR 1 = active hi, NC
		;Use [HOM 1] command  to home in negative counting direction 


;6200 outputs	;*** OUTPUT CONFIGURATION
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

;XES swap??
;may want to swap xy to match XES designations
INFNC2-1J		;Input #2 defined as jog CW input for 6200 axis #1 
INFNC3-1K		;Input #3 defined as jog CCW input for 6200 axis #1 
INFNC17-2J		;Input #2 defined as jog CW input for 6200 axis #2 
INFNC18-2K		;Input #3 defined as jog CCW input for 6200 axis #2 

;;XES swap??
;input for jogging X x2 Y and Z as follows
; jog X/Y/Z inputs go to both the 6200 as shown here and to the x and Z zetas
; VB now letting Zetas do electrical jogging on thier own but all wires still go to the 6200
;    Const EStopBit = 1   ;& 17 for XES X2 ,used by VB to get full jog pattern for all axes
;    Const XplusBit = 2   ;& 18 for XES
;    Const XnegBit = 3
;    Const YplusBit = 4   ;note to read string first remove dashs 0000_1010_
;    Const YnegBit = 5
;    Const ZplusBit = 6
;    Const ZnegBit = 7
;	Inputs 8 & 9 are the 0 and + buttons on XES jog pendant

;  Input 15 = Brake low air pressure
;  Input 16 = SICK Leak Input

;INFNC4-L		;Input #4 defined as jog velocity select input 



JOGA  0.025,0.025		;Jog acceleration set to 30 mm/sec/sec
JOGAD 0.4,0.4		;Jog deceleration set to 400 mm/sec/sec
JOGVH 0.5,0.5		;The velocity when the jog velocity select input is high 
JOGVL 0.5,0.5		;The velocity when the jog velocity select input is low 





		
		;*** Stop button branch to ONSTOP Program
		;     ONSTOP must determine which occured

ERRORP ONSTOP		;define error program for all error conditons 

INFNC1-D		;Stop button is input #1 - this will set bit#8 when activated
ERROR.8-1		;enable the error check bit for stop 
COMEXS 0		;0 = AFTER stop clear buffered commands, 1=continue next program cmd when pause is exited

		;*** Stall Detection and program
ERROR.1-1		;Error 1 is stall, when stall error is detected Bit12 is always set.  When ERROR.12-1 is enabled ONSTOP is called.
			;should cause a gosub to onstop

		;*** Drive Fault Detection program
ERROR.4-1


;   **** Other input conventions
;reserving 
;INP 15 for low brake air pressure


;not implemented    ;***Braking Quick Stop at limit switch	
;ERROR.2-1		;Enable the error check bit for Limit Switch activation		
;ONP ONLIMIT 		; Assign the ONLIMIT program as the ON input condition program
;ONINxxxxxxxxxxxxxxx0	; input #16 can be tied to limit switch input
;ONCOND1000 		; Enable only the ONIN function.

		    ;*** Detect X+ Jog 				
; This worked but since only will run if full bit pattern matches it is only useful for one input condition
;  could use this for water detect on Z axis though
;  Instead VB now issues a TIN when interested to get all inputs.
;ONP GOTINP		;Define Sub do if inputs become active
;ONIN x1		;ENABLE X+ jog button to send message
;ONCOND1000 		;Enable only the ONIN functions.


		;*** SET INITIAL MOVE PARAMETERS 
		   ;(BE SURE YOU ARE IN RIGHT SCALE)
MA 00			;make incremental instead of absolute moves
MC 00			;Non-Continuous motion (incase someone set continuous outside VB)
A  0.5,0.5	;Accel  Changed for tilting flume 2-29-08 CRE	
AD 0,0			;setting decel to 0 causes it to follow accel
V  0.2,.2		;velocity - Max V using this accel 
D  0,0			;distance 0

;XES swap?? change if changing xy wiring
;enable this only if jog buttons installed
IF (IN=B000)		;if Stop and Jogs not now active assume ok to enable them
  DRIVE 11
  JOG11
  WRITE "0_Y WOKEUP (Drive and Jog Enabled)"
ELSE
  WRITE "0_Y WOKEUP (Drive Disabled)"
  Write "Stop or Y Jog Switch Stuck!!!"
  JOG 00
  DRIVE 00
NIF

END	;*** END OF WAKEUP PROGRAM **

STARTPWAKEUP		;define WAKEUP as power up program






;	********* YLIM [L] ********

;	Return format compatible with daisy chain
;	*xxxal [x=limit states, l denotes a limit response, a = axis]
;  NOTE;
;  if not done in this compact, single return method it is possible that
;  another axes could send something between a description and the value.
;  Use of lower case will not return a lower case letter unless it is the 
;  final controller on chain

DEL YLIM 
DEF YLIM 

			;         PNH (Positive, Negative, Home)
			;RETURNS *111 WHERE 
			;         1xx = NOT AT POSITIVE LIMIT (xDOWNSTREAM,zBOTTOM, or yMAX)
			;         x1x = NOT AT NEGATIVE LIMIT (xUPSTREAM,zTOP or yMIN)
			;         xx1 = HOME NOT ACTIVE (if connected)


EOT 89,76,13		;YL [CR]
TLIM			;TRANSFER LIMIT STATUS 
EOT13,0,0		;Send CRLF


END	;end YLIM 


 
;	*********** SAYPOS [P] ************
;	Always make to return a MM Float
;	Return format compatible with daisy chain
;	*xxx.xxxap [*xxx.x = position, a = axis, p denotes a Position response]


DEL SAYPOS
DEF SAYPOS


EOT 89,80,13		;set end of transmision characters to YP[CR]  
;VAR1 = 1PM*1000		;PM = Meter Zeta scaled motor position				
;WR VAR1			;TRANSFER scaled and offset MM Position  (will not include probe offsets)
TPM		;motor units
EOT 13,0,0		;Reset end of transmision characters to CRLF
			

END  	;end SAYPOS



;	************ YG [D] (XES LONG AXIS) *************
;		     GO
	;as a way to avoid bad communications use G_ commands instead of 
	;sending a set of commands to do the same thing
	; (even if another the addressing portion of this command 
	;  is trashed other controllers will not have this program)

DEL YG ;obsolete now Zetas XB figures out whether to warn
DEF YG

JUMP YB

END	;end of YG 



;	************ YB [D] ************* (GO while ringing bell)
;
DEL YB		;This routine now decides on its own whether to ring bell
DEF YB

IF (1as.13 <> b0 OR 2as.13 <> b0)	;0 means drive enabled 		'3/25/14	
  DRIVE 11		;now auto activating drives
  WRITE "Enabling DOUBLE Y-Drive"	
  T .5			;It takes a bit to get geminis enabled.  else stall can occur
NIF

LH 0,0			;Cycle limits on and off so we don't get invalid conditions error
LH 3,3			;  and reset last stop bits

;two motor carriages can't use ENC because for some reason they 
;would not move in lock step.  They went out of parallel by 2-3mm but finished at correct spot.
;
;ENC 00			;instead of PSET 0 trying turning ENC off then on
;ENC 11	
			;Because we are using ENC1, relative moves must be preceeded by PSET 0 or ENC 00.  
			;  Otherwise manual (disengaged motor) will set a position err.
			;  This results in the drive making the new relative (Dxxx) move to Dxxx + position it 
			;  thought it should be at.

VAR3 = 0		;CLEAR	INSTOP MODE FLAG
ERROR.8-1		;Reset here because sometimes multiple stop hits can leave unset
ERROR.1-1		;turn on stall error bit (ONLY required for two axis drives)
ERROR.4-1		;turn on drive fault error bit

COMEXC1			;1=Continuous execution (must loop after a go)

;IF (IN.15=b1)		;IF LOW AIR PRESSURE (if no air brake make sure pulled false)
; JUMP MVDONE
;NIF

IF (IN.1 = B1)
 ; WRITE "Cant go" 	;debug
  JUMP MVDONE		;for some reason if stop is stuck it can get deactivated so don't even send
NIF
;write "TIN Stop ="	;debug
;TIN.1

;;ESK00	;Turn off and monitor here
GO			;Start Move

VAR2 = 0		;toggling variable
Out.1-1			;Turn on Strobe if it exists


			;if going over 1 meter
IF (D>=1 OR D<=-1 )	;adjust times for start warning as desired
 OUT.2-1		;beep
 T.25			
 OUT.2-0		;off
 T.3			;
 OUT.2-1		;beep
 T.25			;
 OUT.2-0  		;off
NIF	

REPEAT
 IF(D>=1 OR D<=-1)	;ring bell if going over 1 meter

  IF(VAR2=0)		;then time to ring bell/buzzer
   TIMST0		;Reset and start timer
   VAR2=1
   OUT.2-1		;Energize bell/buzzer						
   T.25			;buzzing peizo
;  T.33		        ;or 1/3 sec for door bell style
   OUT.2-0		;Bell off 
 
  ELSE			;Time between bell rings
   VAR2=0
   REPEAT
     IF (IN.15=b1)		;IF LOW AIR PRESSURE		MUST TEST HERE AND BELOW IN CASE NOT RINGING		
       JUMP MVDONE
     NIF
   UNTIL (MOV=b00 OR TIM > 3000) ;Wait til move is done or 3 seconds
	;UNTIL (MOV=b0 OR TIM > 3000) ;Wait til move is done or 3 seconds
  NIF

 NIF ;end if ringing bell

; IF (IN.15=b1)		;IF LOW AIR PRESSURE			
;    JUMP MVDONE
; NIF

UNTIL(MOV=b0)		;loop till move is done


$MVDONE
D 0,0			;reset distance to 0 for safety
OUT.1-0			;Turn off strobe
OUT.2-0			;Bell off



EOT 89,68,13		;set end of transmision characters YD[CR] for computer to parse

IF (IN.1 = B1)
 WRITE "STOP ACTIVE"	

ELSE
 IF(IN.15=b1)
  WRITE "LOW BRAKE AIR PRESSURE "
; can get here if low pressure occurs before or after move starts
  EOT 13,0,0     		;just a carriage return (sent here because will not return from stop
  S				;stop -- will not return here -- cmd buffer cleared
  WRITE "RETURNED FROM STOP"	;THIS WILL NOT RUN because COMEXS = 0 so stop does not return

 ELSE  ;Check for Stall
  IF(1AS=bxxxxxxxxxxx1 OR 2AS=bxxxxxxxxxxx1)	;if stalled bit 12 will be set	
   IF (1AS=bxxxxxxxxxxx1) 	
    WRITE "Y1-STALLED "
   ELSE
    IF (2AS=bxxxxxxxxxxx1)
     WRITE "Y2-STALLED "	
    NIF
   NIF

  ELSE ;Check limits
   IF (1AS=bxxxxxxxxxxxxxx1)	;if Hit Positive Hdwr Limit [15th bit from left]
    WRITE "Y-HIT_LM+ "
   ELSE
    IF (1AS=bxxxxxxxxxxxxxxx1)	;if Hit Negitive Hdwr Limit [16th bit from left]
     WRITE "Y-HIT_LM- "
    ELSE	
     WRITE "Y-DONE "		;write readable response with XD[CR] at end for computer to parse
    NIF
   NIF
  NIF
 NIF
NIF

EOT 13,0,0     		;just a carriage return

END	;end of YB




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
;    WAIT(MOV=b00) 		;Wait til decel is done
;    WRITE "Stopped "
;
;    OUTFNC1-B			;Reset to InMotion output for warning light or brake/clutch
;    
;END
;**********




DEL ONSTOP
DEF ONSTOP			;Begin definition of Error program 

   ; stop buttons, stalls and drive faults trigger this program 
   ;test such as ER (IF (ER.8=b1) to see what caused branch to this routine
;;;;;;ERROR.8-0	;turn off/clear this interrupt if you don't want to come back in. (turn back on when exiting)
     ;but if an S is issued here program buffer will be wiped and not return
   
  ;WRITE "ONSTP ER =
  ;TER
  ;WRITE "Moving = " 
  ;VARB1 = MOV
  ;WRVARB1
 
  IF(ER=b1)			;**** STALLED
         	
     ;WRITE "Killing DRIVE"	;Ideally when one drive stalled the other could just be turned off but 
				;Drive 0 can not be issued until motors stop.  So now motion is killed first and then immediately drives 
				;are turned off.  Result is a jerk and then freewheeling to stop.  -- Better than full power racking.
     K11
     WAIT(MOV=b00)	
     DRIVE 00
     ERROR.1-0	;turn off stall error bit
     
     IF (1AS=bxxxxxxxxxxx1 and 2AS=bxxxxxxxxxxx1) 	
    	VARS3 = "Both Y-STALLED "
     ELSE
        IF (1AS=bxxxxxxxxxxx1)
          VARS3 = "Y1-STALLED "
	ELSE
          IF (2AS=bxxxxxxxxxxx1)
            VARS3 = "Y2-STALLED "	
          NIF
        NIF
     NIF
	
    OUT.1-0			;Strobe off  
    OUT.2-0			;Bell off  
 
     ERROR.1-1	;turn on bit (bits cleared)
     WRVARS 3  ;VB will issue a stop command so may not complete here.


    ; TPE  ;debug stuff
    ; TPE
    ; TPE
    ; TAS
    ; DRIVE
    ; T1
    ; TPE
    ; T1
    ; TPE
    ; T1
    ; TPE
    ; T1
    ; D0,0	;clear error bits
    ; DRIVE 11
    ; GO
     	
     JUMP STOPDONE
  NIF

				;***** Drive Fault ***
  IF (ER .4= b1) 
     ERROR.4-0			;turn off drive Fault error bit	to avoid reentry
 
     IF (MOV <> b00) 
	S
	OUT.1-0			;Strobe off  
   	OUT.2-0			;Bell off 
     NIF

     JOG 00
     DRIVE 00
     IF (1AS.14	= b1)	
	WRITE "Y-DRIVE 1 FAULTED - DRIVES DISABLED"
     NIF
     IF (2as.14 = b1 )
	WRITE "Y-DRIVE 2 FAULTED - DRIVES DISABLED"
     NIF

     JUMP STOPDONE 	
  NIF	

; ELSE its a stop button ****	

	;On first entry after stop is pressed routine turns of strobe/bell, 
	;sets decel to max and issues a stop.  Note to take effect continuous execution has to be set COMEXC = 1
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



		
			;NOTE Actual Decel to Stop already started electrically by zeta
   WRITE "RED_StopHit " ;VB is looking for this string
   
   IF (MOV<>b00)	;if moving set to max decel and issue a stop cmd
      AD  (VAR4), (VAR4);this will not return until stop is complete
      S                 ;Note to take effect continuous execution has to be set COMEXC = 1
      WRITE "Y came back after S Issued" ;should not come back debug 	
   NIF			; Actual Decel already started electrically by stop switch ???	
  
$STOPPED
   VAR3 = 2
   WAIT(MOV=b0)  
   OUT.7-0	;set brake just in case -- but since inmotion output on 8 will be active until decel complete this only helps if decel stall occurs
   AD  0,0	;sets decel back same as Accel
   ;D 0,0	;moved below incase VB do an XB cmd while in stop loop - somehow it can be buffered

   EOT 89,68,13			;YD   
   WRITE "Y-Stopped "
   EOT 13,0,0     		;just a carriage return

   IF (IN.2 = b1 or IN.3 = b1)
     JOG 00			;in case button is stuck
   NIF	

  ; T 1		;be sure all are stopped
  ; DRIVE 0	;Now letting VB do it if it wants to.  Take motors off line if desired to allow moving manually away from stop
   
   T 0.25			;debounce DELAY
   VAR5 = 0			;CLEAR Resend Stop Msg counter

   WHILE (IN.1 = B1) 		; Wait for STOP input #1 to CLEAR
      T 0.25
      if(VAR5 >= 8) 		;resend msg ~every 2 seconds
          WRITE "STOP STUCK " 	  
	  VAR5 = 0	
      else
	Var5= Var5 +1
      NIF
   NWHILE
	
   D 0,0			;reset distance to 0 for safety

   WRITE "Y-Stop Clear"   
   T 0.25			;debounce

   ERROR.8-1	;
   VAR3 = 0	;should this be after  $STOPDONE

$STOPDONE
  ERROR.8-1	
  ERROR.1-1		;turn on stall bit
  ERROR.4-1		;turn on drive fault bit

 ; write "halting"
 ; HALT		;3/25/2014 if new go command is sent from VB while in stop loop it gets buffered - use halt to set completely idle
 ;write "halted"  ;note this did not run but the XG command DID

  S	;issuing an Stop here just to clear any buffered commands, othewise motion could start after stop release.  Halt did not work 3/26/2014
  write "Y-Returned after Stop??"	 ;should not run
END	






;****************** Follow did not work smoothly so not using

;DEL xFollow
;def xFollow
; K 01
; T.5
; FOLMAS0,0   ;exit Follow mode	
; FOLEN00 	
; MA 00      ;make incremental moves not absolute
; MC 00
; ENC 11
; SCALE1  
; write "Exited Follow"		
;END

;*****************************
;DEL Follow
;def Follow
; K01
; T.5	
; FOLMAS0,0    ;so other params accepted
; Drive 00
; ;Scale 0     ;no scale	
;Write "1"
; MC 01        ;must be continuous for Following
; ENC10
; ;DRES 20000  ;if encoder is 4000 cpr and ratio is 1 to 1 there should be a 5 to 1 ratio	
; ;SCLMAS 4000 ;Master scale factor is 4000 steps/rev  
; ;SCLD 4000   ; irrelavent if no scaling  - Slave scale factor is 4000 steps/rev ?????
;Write "2"
; FOLMAS 0,+14    ;Axis 1 normal axis 2 Command move is the master for axis 2 
; FOLMD0,0      ;Assign Following acceleration distance to 0 master revs (i.e., instantaneous) 
;Write "3"
; FOLRN1,1      ;Set slave-to-master Following ratio numerator to 1 
;Write "4"
; FOLRD1,1      ;Set slave-to-master Following ratio denominator to 1 ratio set to 1 to 1 
;Write "5"   
; FOLEN01      ;Enable Following on axis f#1 
; ;D-          ;Set direction to opposite direction of the master 
; Drive 11
;Write "6"
; GO 01        ;Begin folowing master. If the master is not moving, slave will remain at rest until master moves, at which time the slave will track 
; Write "Following"
;END