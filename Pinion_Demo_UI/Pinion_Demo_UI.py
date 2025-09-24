import SAFL_tkinter_toolbox as safl
import datetime
import CleareCore_funcs
import Pinion_StateMachine
import matplotlib.animation as animation

# Initialize and Configure the GUI
gui = safl.gui('SandPiper Demo GUI')
gui.add_tabs(['Main','Diagnostics'])
gui.add_frame(gui.tabs['Main'],'Status')
gui.add_frame(gui.tabs['Main'],'Plots')

# Initialize Motor Controllers: 
x_axis = CleareCore_funcs.clearcore_motion('COM11',9600,'m')
daq    = CleareCore_funcs.clearcore_daq('COM6',9600)
statemachine = Pinion_StateMachine.state_machine(x_axis,daq)

python_loop_time = safl.timestamp_looptime(gui.frames['Status'])
state_display = safl.value_display(gui.frames['Status'],"Current State")
clear_faults_button = safl.one_button(gui.frames['Status'],'Clear Motor Errors',x_axis.clear_faults)
homing_button = safl.one_button(gui.frames['Status'],"Home Axis",statemachine.start_homing_seq)
x_jog_buttons = safl.jog_buttons(gui.frames['Status'],'Jog X',statemachine.start_position_move,statemachine.enter_neg_jog,statemachine.enter_pos_jog,statemachine.enter_standby)
plots = safl.xy_plot(gui.frames['Plots'],'Topo','mm','Volts',['Keyence'])



# Populate initial values on the GUI
x_axis.poll_status()
x_jog_buttons.update_current_pos(x_axis.position)

# Enable the drive:
statemachine.enter_standby()

def gui_exit():
    x_axis.stop_motion()
    gui.window.destroy()


def main():
    python_loop_time.update(datetime.datetime.now())

    if statemachine.state != statemachine.previous_state: # check if state has changed since last loop or if in homing mode.
        state_display.update(statemachine.state_desc[statemachine.state])
        statemachine.check_state() # is the state has changed since the last loop run the state machine
    statemachine.previous_state = statemachine.state # update the previous_state

    if statemachine.state not in [0,1]: # the state is one where the axis is moving
        # x_axis.poll_status()
        statemachine.check_state()
        x_jog_buttons.update_current_pos(x_axis.position)

    if statemachine.state in [3,0,1]:
        daq.read_data()
        
    
    gui.window.after(10,main) # Rerun again after xxx milliseconds

def update_plotting(i):
        if daq.data:
            plots.refresh_plot(daq.data)
            # print(daq.data)
    
ani1= animation.FuncAnimation(plots.figure,update_plotting,interval=10)

main()



gui.window.protocol("WM_DELETE_WINDOW", gui_exit)
gui.window.mainloop()