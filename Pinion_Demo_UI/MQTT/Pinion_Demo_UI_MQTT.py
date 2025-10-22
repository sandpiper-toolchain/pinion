import SAFL_tkinter_toolbox as safl
import datetime
import ClearCore_MQTT
import Pinion_StateMachine_MQTT
import matplotlib.animation as animation

System_Name = "2D Scanner"

# Initialize and Configure the GUI.  Read in the config.json that contains com port IDs, scale factors, software limits, etc.
gui = safl.gui('Project Pinion Demo GUI',icon='./pinion_feather_gear.ico')
gui.add_tabs(['Main','Diagnostics'])
gui.add_frame(gui.tabs['Main'],'Status')
gui.add_frame(gui.tabs['Main'],'Plots')

# Initialize Motor Controllers and State Machine.
x_axis = ClearCore_MQTT.ClearCoreMQTT_motion("192.168.1.100",1883,gui.configs["Keyence Scale"],System_Name=System_Name)
# daq    = CleareCore_funcs.clearcore_daq(gui.configs['DAQ Com Port'],115200)
statemachine = Pinion_StateMachine_MQTT.state_machine(x_axis,gui.configs['x limits'])

python_loop_time = safl.timestamp_looptime(gui.frames['Status']) # Display for the current timestamp and the duration of the last loop through the program
state_display = safl.value_display(gui.frames['Status'],"Current State") # Display the current state of the statemachine
stop_button = safl.one_button(gui.frames['Status'],'STOP',statemachine.enter_standby,background_color = 'red') # Button to stop motion (put the statemachine into standby mode)
clear_faults_button = safl.one_button(gui.frames['Status'],'Clear Motor Errors',x_axis.clear_faults)# Button to clear errors on the motor
homing_button = safl.one_button(gui.frames['Status'],"Home Axis",statemachine.start_homing_seq) # Button to initiate homing
x_jog_buttons = safl.jog_buttons(gui.frames['Status'],'Jog X',statemachine.start_position_move,statemachine.enter_neg_jog,statemachine.enter_pos_jog,statemachine.enter_standby) # Jogging interface
plots = safl.xy_plot(gui.frames['Plots'],'Topography','mm','mm',['Keyence']) # live updating data plots


# Enable the drive:
statemachine.enter_standby()

# Define the GUI exit routine (commands to be executed when closing the GUI)
def gui_exit():
    x_axis.stop_motion() # Stops any motion that is currently ongoing
    gui.window.destroy() # closes the GUI window
gui.window.protocol("WM_DELETE_WINDOW", gui_exit) # tell the GUI to use gui_exit() when closing the GUI window


def main():
    python_loop_time.update(datetime.datetime.now()) # compute the latest loop interval and update the data display

    if statemachine.state != statemachine.previous_state: # check if state has changed since last loop or if in homing mode.
        state_display.update(statemachine.state_desc[statemachine.state])
        statemachine.check_state() # is the state has changed since the last loop run the state machine
    statemachine.previous_state = statemachine.state # update the previous_state

    # if statemachine.state not in [0,1]: # the state is one where the axis is moving
    statemachine.check_state() # if there is motion, check the state and execute commands required by that state.
    x_jog_buttons.update_current_pos(x_axis.status_array["CurrentPosition"]) # Update the value display for the current position

    
    gui.window.after(200,main) # Rerun main() again after xxx milliseconds

# Define the function that will be rerun automatically on an interval by the plot animation. This runs separately and independantly from main()
def update_plotting(i):
        if x_axis.data_array:
            plots.refresh_plot(x_axis.data)# If there is data in the data_array, refresh the plot
ani1= animation.FuncAnimation(plots.figure,update_plotting,interval=100,save_count=1) # This function handles the plot animation.  It runs update_plotting() in the specified interval

main() # Initial call to main() to start it running.

# Start the GUI
gui.window.mainloop()