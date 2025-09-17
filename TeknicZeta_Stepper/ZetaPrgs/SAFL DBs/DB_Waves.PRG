WRITE"Delta Basin Wakeup"

DEL WAKEUP
DEF WAKEUP

; echo
ECHO1

;DWAVEF3 found to be best for PacSci N31 motors
DWAVEF4

;reduce motor current by 50% when stopped
DAUTOS1

; move distances based on motor steps
ENC0

; set scaling parameters
SCALE1
DRES10000
;ERES4000 ; direct connection of encoder to motor  NO ENCODER

; 10000 steps/motor pulley rev * 60/15 (pulley teeth ratio) = 40000 steps/drive shaft rev

SCLD40000
SCLV40000	;rev/sec
SCLA40000

;Continuous Motion
MC1

;Continuous Command Execution
COMEXC1

; no limits 
LH0

;enable stall detect
;ESTALL1

; default acceleration
A1
AD1

D1	;distance ignored due to MC1
V1	;rev/sec

; disable drive
DRIVE0

;*** Wave Control Zeta *****
Vars1 = "Wave Control"


END ;end of wakeup

STARTPWAKEUP		;define WAKEUP program to run at power up


;*****
DEL SayAxis
DEF SayAxis
WRVARS 1
END
;*******

WAKEUP


