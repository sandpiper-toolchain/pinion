import SAFL_tkinter_toolbox as safl
import datetime

gui = safl.gui('SandPiper Demo GUI')

gui.add_tabs(['Main','Diagnostics'])
gui.add_frame(gui.tabs['Main'],'Status')

python_loop_time = safl.timestamp_looptime(gui.frames['Status'])
x_jog_buttons = safl.jog_buttons(gui.frames['Status'],'Jog X')

def main():
    python_loop_time.update(datetime.datetime.now())
    
    # x_jog_buttons.enable_disable(not moving)

    #if moving:
        # x_jog_buttons.update_current_pos()
    
    gui.window.after(250,main)


main()
gui.window.mainloop()