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

import CleareCore_funcs 

class state_machine():
    def __init__(self,axis:CleareCore_funcs.clearcore_motion,daq:CleareCore_funcs.clearcore_daq): 
        self.state = 0
        self.previous_state = 0
        self.axis = axis
        self.daq = daq
        self.jog_speed = 5 # mm/s
        self.data = []

        self.state_desc = {0:"Disabled",1:"Standy (Motor Enabled)",2:"Homing",2.1:"Homing: Move to Limit",2.2:"Homing: Backing off",2.3:"Homing: Reapproach Limit",2.4:"Homing: Resetting Zero",3:"Moving to absolute position",4.1:"Jogging-Negative",4.2:"Jogging-Positive",5.1:"Scanning: Collecting Data",5.2:"Scanning: Traveling"}

    def check_state(self): 
        self.axis.poll_status()
        # print(f"Steps Active? {bool(self.axis.StepsActive)}")
        if self.state == 0 and bool(self.axis.Enabled): # motor disabled
            self.axis.disable()
        elif self.state == 1 and not bool(self.axis.Enabled):  # motor enabled, but not moving
            self.axis.enable()
            self.axis.stop_motion()
            # self.daq.read_data()
        elif self.state == 2.1 and not bool(self.axis.InNegativeLimit) and self.previous_state != 2.1: # GUI sets state to 2 to initiate homing sequence
            self.axis.jog(-5)
            # print("starting move to limit switch")
        elif self.state == 2.1 and bool(self.axis.InNegativeLimit) and not bool(self.axis.StepsActive): # If we've made it to the negative limit switch.
            self.state = 2.2
            self.axis.clear_faults()
            self.axis.set_velocity(10)
            self.axis.relative_move(10)
            # self.axis.poll_status()
            
        elif self.state == 2.2 and not bool(self.axis.StepsActive): # if finished backing off the limit switch
            self.axis.jog(-self.jog_speed/2) # reapproach the limit switch at half the initial speed.
            self.state = 2.3
        elif self.state == 2.3 and bool(self.axis.InNegativeLimit): # If we've made it to the negative limit switch.
            self.state = 2.4
            self.axis.clear_faults()
            self.axis.set_absoulute_position(0)
            self.axis.poll_status()
            self.state = 1
            self.axis.set_velocity(self.axis.travel_vel)
        elif self.state == 4.1 and self.previous_state != 4.1:
            self.axis.jog(self.jog_speed*-1)
        elif self.state == 4.2 and self.previous_state != 4.2:
            self.axis.jog(self.jog_speed)
        elif self.state == 3 and self.previous_state != 3: 
            self.axis.move_to_absolute_position(self.axis.target)
            # self.daq.com.flush()
            self.daq.data = [] # clear the logged data array at the beginning of each positional move
            # self.daq.read_data()
        elif self.state == 3 and bool(self.axis.StepsActive):
            # self.daq.read_data()
            pass
        elif self.state == 3 and not bool(self.axis.StepsActive): # the move is done. 
            self.state = 1

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


if __name__ == '__main__':
    import time
    x_axis = CleareCore_funcs.clearcore('COM11',9600,'m')
    x_axis.clear_faults()
    x_axis.enable()

    statemachine = state_machine(x_axis)

    statemachine.enter_neg_jog()

    for i in range(10):
        statemachine.check_state()
        time.sleep(1)

    statemachine.enter_standby()





