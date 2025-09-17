;12/23/2009
;Texas Basin ocean control application
;MM Scaled



DEL WAKEUP
DEF WAKEUP


ECHO1			;Echo on - must turn off in VBA for Delta Basin Control to run properly
DRIVE0			;disable drive - must be disabled to change polarities etc

		** MOTOR & DRIVE SETTINGS
DWAVEF3			;DWAVEF3 found to be best for PacSci N31 motors
			;may need to adjust for Slo-Syn motor

DAUTOS1			;reduce motor current by 50% when stopped



;		; ** Encoder and Motor Scaling Parameters
;	ENC 0			;move distances based on; 0=motor steps 1=Encoder
;	SCALE1			;Turn on scaling
;	DRES50000		;micro steps per rev   (DRES should be higher than ERES so motor always can step to a particular encoder position)			
			;  when set to 50,000;  
			;	velocity is limited to about 80mm/sec when set to 50,000
			;	position range of zeta = 2,147,483,648 (Hex 80000000) =42949.67296 mm

;*** Delta Basin I *****
	;	Vars1 = "Basin I Ocean Ctl"
	;	ENCPOL 0		;encoder polarity (0 = default)
	;	ERES4000 		;Quadrature Encoder counts per Motor rev (400*4)
					; Note; when ENC=0 value returned with TPE not scaled but instead raw counts; 
	;	SCLD 78740		;(enc=0) Motor 50000 steps/rev * 4(pulley ratio) * 10 rev/in(screw) / 25.4 mm/in = 78740
	;	;SCLD 6299		;(enc=1) Encoder 4000 cnt/rev * 4(pulley ratio) * 10 rev/in(screw) / 25.4 mm/in  =6299.2125    

	;	SCLV78740		;motor steps per sec
	;	SCLA78740		;motor steps /Sec/Sec
	

;*** Delta Basin II *****
	;	Vars1 = "Basin II Ocean Ctl"

	;	ENCPOL 1		;encoder polarity (0 = default)
	;	ERES1600 		;Quadrature Encoder counts per Motor rev (400*4)
					; Note; when ENC=0 value returned with TPE not scaled but instead raw counts
					;       
	;	SCLD25000 		;(enc=0) Motor  50000(DRES) steps/rev / 2mmPerRev = 25000 steps per mm			;   
	;	;SCLD 800		;(enc=1) Encoder  1600 (DRES) Cnts/rev / 2mmPerRev = 800 cnts/rev
					;  either in motor steps or encoder counts depending on state of ENC

	;	SCLV25000 		;motor steps per mm/sec
	;	SCLA25000 		;motor steps /Sec/Sec
	
;*** Tulane Delta Basin *****
	;Vars1 = "Tulane Ocean Ctl"

	;ENCPOL 0			;encoder polarity (0 = default)
	;ERES4000 			;Quadrature Encoder counts per Motor rev (1000*4)
					; Note; when ENC=0 value returned with TPE not scaled but instead raw counts
					;       
	;SCLD25000 			;(enc=0) Motor  50000(DRES) steps/rev / 2mmPerRev = 25000 steps per mm			;   
	;;SCLD 2000			;(enc=1) Encoder  4000 (DRES) Cnts/rev / 2mmPerRev = 2000 cnts/rev
					;  either in motor steps or encoder counts depending on state of ENC

	;SCLV25000 			;motor steps per mm/sec
	;SCLA25000 			;motor steps /Sec/Sec
	
;*** Texas Delta Basin *****
Vars1 = "UT Table"

ENC 1			;move distances based on; 0=motor steps 1=Encoder
SCALE1			;Turn on scaling
DRES 5000		;micro steps per rev   (DRES should be higher than ERES so motor always can step to a particular encoder position)			
			;  when set to 50,000;  
			;	velocity is limited to about 80mm/sec when set to 50,000
			;	position range of zeta = 2,147,483,648 (Hex 80000000) =42949.67296 mm


daren 1
dactdp 3

ENCPOL 0		;encoder polarity (0 = default)
ERES4000 		;Quadrature Encoder counts per Motor rev (1000*4)
			; Note; when ENC=0 value returned with TPE not scaled but instead raw counts

;IF (ENC=0)		;       
;   SCLD 295276  	;(enc=0) Motor  5000(DRES) steps/rev of reducer output			;  
;ELSE
   SCLD 236220 		;(enc=1) Encoder  following 
;NIF			;  either in motor steps or encoder counts depending on state of ENC

SCLV 295276  		;motor steps per mm/sec
SCLA 295276  		;motor steps /Sec/Sec
	
		;** LIMITS
LH 3			;use hardware limits (default = 3 = On)	
LHLVL00			;Z Limits are normally closed Default = 0 = voltage active Hi
LHAD 5 ;mm/s/s 	;HARD LIMIT DECEL RATE


		;** STALL DETECTION
ESTALL1			;enable stall detect
ESDB 10			;allow 10 steps of backlash upon direction reversal
ESK1			;kill upon stall detection


		;*** SET INITIAL MOVE PARAMETERS		
MA 0  			;0 = make incremental instead of absolute moves	
A  .25	;mm/s/s		;Accel
AD 0			;setting decel to 0 causes it to follow accel
V  .25	;mm/s		;velocity
D  0		

WRVARS 1
Write "Zeta Woke Up (Drive is Disabled)"


END ;end of wakeup

STARTPWAKEUP		;define WAKEUP program to run at power up

;***** Set up to test motors encoder scaled D1 rotates 1 rev, Enc Counts 4000
DEL SclOne
DEF SclOne
Drive 1
SCLV 5000
SCLA 5000
SCLD 4000
V10
D1
A5
END


;*****
DEL SayAxis
DEF SayAxis
WRVARS 1
END
;*******


