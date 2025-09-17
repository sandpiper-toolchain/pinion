# Project Pinion 
Project Pinion began with the objective of finding a replacement for the Stepper Motor controllers used on all SAFL/NCED data carriages. SAFL/NCED carriages used Parker Zeta CompuMotors (6104 and 6108 typically) to power and controll the stepper motors that move the carriages. Parker has long since discontinued the Zeta line leaving SAFL staff to purchase replacements from eBay. Project Pinion was intended to develop a drop-in replacement for the Zetas that could power the steppers and receive/parse the same serial commands that the NCED carts use to tell the Zetas where to go. Zetas have become the most frequently failed component on carts, so a replacement would go a long way to extend the life of the existing fleet of carts. 


## Teknic Zeta programming in Arduino IDE
I couldn't get any of the examples to compile at first.  I had to copy all the header files in `C:\Users\milli079\AppData\Local\Arduino15\packages\arduino\tools\CMSIS\4.5.0\CMSIS\Include` 

to 

`C:\Users\milli079\AppData\Local\Arduino15\packages\ClearCore\hardware\sam\1.7.0\variants\clearcore\Third Party\SAME53\CMSIS\Device\Include`  

Then it would compile.