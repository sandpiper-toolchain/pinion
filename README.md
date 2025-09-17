<p align="center">
<img src="PinionProject_Icon.png" alt="drawing" width="200"/>
</p>

# Project Pinion 
Project Pinion began with the objective of finding a replacement for the Stepper Motor controllers used on all SAFL/NCED data carriages. SAFL/NCED carriages use Parker Zeta CompuMotors (6104 and 6108 typically) to power and control the stepper motors that move the carriages. Parker has long since discontinued the Zeta line leaving SAFL staff to purchase replacements from eBay. Project Pinion was intended to develop a drop-in replacement for the Zetas that could power the steppers and receive/parse the same serial commands that the NCED carts use to tell the Zetas where to go. Zetas have become the most frequently failed component on carts, so a replacement would go a long way to extend the life of the existing fleet of carts. 

The secondary objective was to evaluate the ClearCore controller from Teknic Inc. for use a component or the main controller of a second generation data carriage system. The ClearCore controller has many attractive features: 
- Open Source programming in the Arduino IDE
- Active support from Teknic Inc.
- The ability to control any brand stepper motor or Teknic's "Stepper Killer" servo motors
- Built in digital and analog inputs
- Digital outputs that can be used to control relays etc
- Ability to control up to 4 motors
- 2 built in serial ports, a USB port that mounts as a serial port and an Ethernet port.

## TeknicZeta_Stepper
This folder contains files for the development of a ClearCore controller that can emulate a Zeta in controlling a single stepper on an existing SAFL/NCED Cart. The Arduino program files are located in the directory: `\pinion\TeknicZeta_Stepper\TeknicZeta`.

## Pinion UI
To evaluate the ClearCore controller for use in a second generation data carriage a demo UI was developed using the Python tkinter package. This GUI is located in the directory: `\pinion\Pinion_Demo_UI`.


## Installation Notes:
### Notes on programming in the Arduino IDE
Maybe this issue is specific to my installation of the Arduino IDE, but I couldn't get any of the examples to compile at first.  I had to copy all the header files in `C:\Users\milli079\AppData\Local\Arduino15\packages\arduino\tools\CMSIS\4.5.0\CMSIS\Include` 

to 

`C:\Users\milli079\AppData\Local\Arduino15\packages\ClearCore\hardware\sam\1.7.0\variants\clearcore\Third Party\SAME53\CMSIS\Device\Include`  

Then it would compile.