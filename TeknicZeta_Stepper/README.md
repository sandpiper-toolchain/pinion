# Teknic Motor Replacements for Parker Zetas
Existing system layout: 
                                                                                    
                                                                                
                                        ┌──────────┐          ┌────────────┐    
                                        │Zeta      │          │  Stepper   │    
                                ┌───────┼Motor     ┼─────────►│  Motor     │    
                                │ RS232 │Controller│◄────┐    └────────────┘    
      ┌────────────────┐        │       └──────────┘     │     ┌───────────┐    
      │                │◄───────┘       ┌────────────┐   └─────┼ Quadrature│    
      │       PC       │                │USB Encoder │    ┌────┼ Encoder   │    
      │  Visual Basic  │◄───────────────┼Interface   │◄───┘    └───────────┘    
      │                │     USB        └────────────┘                          
      └────────────────┘                                                        
                                                                                
                                                                                
New System with Teknic Clearcore
                                                                                          
                                                    Step &                                
                                      ┌──────────┐  Direct. ┌──────────┐  ┌────────────┐  
                                      │ Teknic   │  Pulses  │ Stepper  │  │  Stepper   │  
                              ┌───────│ ClearCore┼─────────►│ Driver   ┼─►│  Motor     │  
                              │ RS232 │          │          └──────────┘  └────────────┘  
    ┌────────────────┐        │       └──────────┘                        ┌───────────┐   
    │                │◄───────┘       ┌────────────┐                      │ Quadrature│   
    │       PC       │                │USB Encoder │◄─────────────────────┼ Encoder   │   
    │  Visual Basic  │◄───────────────│Interface   │                      └───────────┘   
    │                │     USB        └────────────┘                                      
    └────────────────┘                                                                    
                                                                                        


## Teknic Zeta programming in Arduino IDE
I couldn't get any of the examples to compile at first.  I had to copy all the header files in `C:\Users\milli079\AppData\Local\Arduino15\packages\arduino\tools\CMSIS\4.5.0\CMSIS\Include` 

to 

`C:\Users\milli079\AppData\Local\Arduino15\packages\ClearCore\hardware\sam\1.7.0\variants\clearcore\Third Party\SAME53\CMSIS\Device\Include`  

Then it would compile.