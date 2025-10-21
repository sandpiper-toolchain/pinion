'''
State Machine for Pinion controller

States :
0   : Disabled
1   : Standby (Motor Enabled)
2   : Homing 
    2.1 : Moving to negative limit switch
    2.2 : Backing off Limit Switch
    2.3 : approaching again, slowly
    2.4 : Stopped at Home, resetting position to Zero. 
3   : Moving to Absolute Position
4.1 : Jogging -> Negative
4.2 : Jogging -> Positive
5.1 : Scanning: Collecting Data
5.2 : Scanning: Traveling


'''
import time
import ClearCore_MQTT
import SAFL_tkinter_toolbox as safl

class state_machine():
    def __init__(self,axis:ClearCore_MQTT.ClearCoreMQTT_motion,axis_limits): 
        self.state = 0 #Initialize state at 0 (Disabled)
        self.previous_state = 0 # Initialize previous state at 0
        self.axis = axis # add axis as a part of the statemachine object so it can be accessed later in the statemachine class
        # self.daq = daq # add daq to the statemachine object
        # self.jog_speed = 5 # mm/s Set the default jog speed
        self.axis_limits = axis_limits # add the limit settings to the statemachine object.

        # Create a dictionary of the states and their descriptions that can be used by the GUI to tell the user what state we're in
        self.state_desc = {0:"Disabled",1:"Standy (Motor Enabled)",2:"Homing",2.1:"Homing: Move to Limit",2.2:"Homing: Backing off",2.3:"Homing: Reapproach Limit",2.4:"Homing: Resetting Zero",3:"Moving to absolute position",4.1:"Jogging-Negative",4.2:"Jogging-Positive",5.1:"Scanning: Collecting Data",5.2:"Scanning: Traveling"}

    # define a function that will check the current state and execute commands appropriate for the state that we're in
    def check_state(self):
        if not self.axis.status_array: 
            time.sleep(0.5)
            print("Waiting for MQTT broker to send data packet.")

        # STATE 0: Disabled
        if self.state == 0 and bool(self.axis.status_array['Enabled']): # motor disabled
            self.axis.disable()
        # STATE 1: Standby (Motor Enabled)
        elif self.state == 1 and not bool(self.axis.status_array['Enabled']):  # STATE 1: motor enabled, but not moving
            self.axis.enable()
            self.axis.stop_motion()
        # STATE 2.1: Homing: Moving to the negative limit switch
        elif self.state == 2.1 and not bool(self.axis.status_array['InNegativeLimit']) and self.previous_state != 2.1: # GUI sets state to 2 to initiate homing sequence
            self.axis.jog(-self.axis.jog_vel)
        # STATE 2.2: Homing: Backing off the limit switch
        elif self.state == 2.1 and bool(self.axis.status_array['InNegativeLimit']) and not bool(self.axis.status_array['StepsActive']): # If we've made it to the negative limit switch.
            print("At Limit.  Moving 10 mm off limit")
            self.state = 2.2
            self.axis.clear_faults()
            self.axis.set_velocity(10)
            self.axis.relative_move(10)
            # time.sleep(0.5)
        # STATE 2.3: Homing: Reapproach the limit switch even slower 
        elif self.state == 2.2 and not bool(self.axis.status_array['StepsActive']): # if finished backing off the limit switch
            self.axis.jog(-self.axis.jog_vel/2) # reapproach the limit switch at half the initial speed.
            self.state = 2.3
        #STATE 2.4: Reset position to 0 and transition back to state=1 Standby
        elif self.state == 2.3 and bool(self.axis.status_array['InNegativeLimit']): # If we've made it to the negative limit switch.
            self.state = 2.4
            self.axis.clear_faults()
            self.axis.set_absolute_position(0)
            self.state = 1
            self.axis.set_velocity(self.axis.travel_vel)
        # STATE 3:
        elif self.state == 3 and self.previous_state != 3:
            if self.axis.target >= self.axis_limits[0] and self.axis.target <= self.axis_limits[1]:
                self.axis.move_to_absolute_position(self.axis.target)
                self.data_array = [] # clear the logged data array at the beginning of each positional move
            else: 
                safl.popup_warning("Commanded Move is outisde software limits",f'Commanded Move is outside of software limits: {self.axis_limits[0]}mm \u2192 {self.axis_limits[1]}mm')
                print(f'Commanded move is outside of set limits: {self.axis_limits[0]}mm \u2192 {self.axis_limits[1]}mm')
        elif self.state == 3 and bool(self.axis.status_array['StepsActive']):
            pass
        elif self.state == 3 and not bool(self.axis.status_array['StepsActive']): # the move is done. 
            self.state = 1
        #STATE 4.1: Jog negative
        elif self.state == 4.1 and self.previous_state != 4.1:
            self.axis.jog(self.axis.jog_vel*-1)
        # STATE 4.2: Jog positive
        elif self.state == 4.2 and self.previous_state != 4.2:
            self.axis.jog(self.axis.jog_vel)

    # Define Functions that can be called programmatically or by GUI Buttons to change states
    def enter_neg_jog(self):
        self.state = 4.1
    def enter_pos_jog(self):
        self.state = 4.2
    def enter_standby(self):
        self.axis.stop_motion()
        self.state = 1
    def update_jog_speed(self,jog_speed):
        self.jog_speed=jog_speed
    def start_homing_seq(self):
        self.state = 2.1
    def start_position_move(self,target):
        self.axis.target = target
        self.state = 3


# For testing.  Only runs if this is the main program that was called.  Not if it was called by another Python script
if __name__ == '__main__':
    import time
    broker = "160.94.187.233"
    port = 1883
    x_axis = ClearCore_MQTT.ClearCoreMQTT_motion(broker,port,'m')
    x_axis.clear_faults()
    x_axis.enable()

    statemachine = state_machine(x_axis,[80,700])

    # statemachine.enter_neg_jog()

    for i in range(10):
        statemachine.check_state()
        time.sleep(1)

    statemachine.enter_standby()





