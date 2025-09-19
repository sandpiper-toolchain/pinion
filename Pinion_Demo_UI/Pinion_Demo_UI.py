import SAFL_tkinter_toolbox as safl
import datetime
import CleareCore_funcs

# Initialize and Configure the GUI
gui = safl.gui('SandPiper Demo GUI')
gui.add_tabs(['Main','Diagnostics'])
gui.add_frame(gui.tabs['Main'],'Status')

# Initialize Motor Controllers: 
x_axis = CleareCore_funcs.clearcore('COM11',9600,'m')

python_loop_time = safl.timestamp_looptime(gui.frames['Status'])
x_jog_buttons = safl.jog_buttons(gui.frames['Status'],'Jog X',x_axis.move_to_absolute_position)



# Populate initial values on the GUI
x_axis.poll_status()
x_jog_buttons.update_current_pos(x_axis.position)

# Enable the drive:
x_axis.enable()

def main():
    python_loop_time.update(datetime.datetime.now())

    x_axis.poll_status()
    moving = bool(x_axis.StepsActive)
    
    x_jog_buttons.enable_disable(not moving)

    if moving:
        x_axis.poll_status()
        x_jog_buttons.update_current_pos(x_axis.position)
    
    gui.window.after(50,main) # Rerun again after xxx milliseconds


main()
gui.window.mainloop()