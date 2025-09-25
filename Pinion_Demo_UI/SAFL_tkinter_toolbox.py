import tkinter as tk
from tkinter import filedialog as fd
from tkinter import ttk
from tkinter import messagebox
import tkinter.scrolledtext as st
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import collections
import datetime
import os,sys
import json
import numpy as np
import threading

class gui(): # Creates a GUI Window when gui.window.mainloop() is called (must be the last line of the script its in)
    def __init__(self,title_string,**kwargs):

        #Initialize the window and set size of the window
        self.window= tk.Tk()
        #window.attributes('-fullscreen',True)
        # self.window.geometry('1200x600')
        #window.configure(background='white')

        # Give the window a title.
        self.window.title(title_string)
        if 'icon' in kwargs:
            self.window.iconbitmap(kwargs['icon'])

        self.frames = {} # allocate a dictionary for frames to be added to.
        self.tabs = {} # allocate a dictionary for tabs to be added to.

        self.skipped_scans = 0
        self.missed_records = 0

        if os.path.exists('Config.json'):
           with open('Config.json','r') as fid: 
                self.configs = json.load(fid)

    def add_tabs(self,tab_names_list):

        s = ttk.Style()
        s.configure('TNotebook.Tab', font=('URW Gothic L','11','bold') )

        self.nb = ttk.Notebook(self.window) ##make notebook to be filled with tabs.

        for i in tab_names_list:
            self.tabs[i] = ttk.Frame(self.nb)
            self.nb.add(self.tabs[i],text = i)

        self.nb.pack(fill=tk.BOTH,expand=True,side=tk.LEFT)

        self.nb.select(self.tabs[tab_names_list[0]]) # Start the GUI on page 1

    def add_frame(self,container,name):
        self.frames[name] = tk.LabelFrame(container,text=name,font=('Arial',12))
        self.frames[name].pack(fill=tk.BOTH,expand=True,side=tk.LEFT)

    def add_frame_below(self,container,name):
        self.frames[name] = tk.LabelFrame(container,text=name,font=('Arial',11,'italic'))
        self.frames[name].pack(fill=tk.X,side=tk.TOP)

    def add_tabs_in_frame(self,container,tab_names_list):
        self.nb_1 = ttk.Notebook(container)

        for i in tab_names_list:
            self.tabs[i] = ttk.Frame(self.nb_1)
            self.nb_1.add(self.tabs[i],text = i)

        self.nb_1.pack(fill=tk.BOTH,expand=True)

        self.nb_1.select(self.tabs[tab_names_list[0]]) # Start the GUI on page 1

    def update_configs(self,param_name,new_value):
        self.configs[param_name] = new_value


class value_display():
    def __init__(self,container,name_str):
        self.frame = tk.Frame(container,pady =2)
        self.frame.pack(fill=tk.X)

        self.value_label = tk.Label(self.frame,text = name_str ,font=('Calibri',10,'bold'),anchor='e',width=30,padx=4)
        self.value_label.pack(side=tk.LEFT)

        self.value = tk.Label(self.frame,text = '#####' ,font=('Calibri',10),anchor='w',width=30)#,padx=4)
        self.value.pack(side = tk.LEFT)

    def update(self,new_value,**kwargs):
        self.value['text'] = str(new_value)

        if 'background_color' in kwargs:
            self.value_label.configure(bg=kwargs['background_color'])
            self.value.configure(bg=kwargs['background_color'])

class textbox():
    def __init__(self,container,text):
        self.frame = tk.Frame(container,pady =2)
        self.frame.pack(fill=tk.X)

        self.value = tk.Label(self.frame,text = text ,font=('Calibri',10),anchor='n',wraplength=300,justify=tk.CENTER)#,padx=4)
        self.value.pack()

class current_status_setpoint():
    def __init__(self,container):
        self.frame = tk.Frame(container)
        self.frame.pack(fill=tk.X)

        self.status_label = tk.Label(self.frame,text='Current Status: ', font=('Calibri',10),width=18,anchor='e')
        self.status_label.pack(side=tk.LEFT)

        self.status = tk.Label(self.frame,text='Updating...',font=('Calibri',10,'italic'))
        self.status.pack(side=tk.LEFT)

        self.frame1 = tk.Frame(container)
        self.frame1.pack(fill=tk.X)

        self.setpoint_label = tk.Label(self.frame1,text='Current Setpoint: ',font=('Calibri',10),width=18,anchor='e')
        self.setpoint_label.pack(side=tk.LEFT)

        self.setpoint = tk.Label(self.frame1,text='Updating...',font=('Calibri',10,'italic'))
        self.setpoint.pack(side=tk.LEFT)

    def update(self,status,setpoint):
        self.status['text'] = str(status)
        self.setpoint['text'] = str(setpoint)

class setpoint_input():
    ''' 
    Creates a widget with a label, entry box and "set" button that looks like the following

    __________    ______________    ___________
   |  Label   |  |  Entry       |  |   Set     |
    __________    ______________    ___________

   This widget takes up 1 row and 3 columns in the GUI and is arranged using the 'grid' function

   Button action is set with "button_action" input argument
    '''

    def __init__(self,container,title_text,button_text,button_action,**kwargs):
        self.frame = tk.Frame(container,pady=2)
        self.frame.pack(fill=tk.X)
        self.label =  tk.Label(self.frame,text=title_text,font=('Calibri',10,'bold'),width=30,padx=4,anchor='e')
        self.entry =  tk.Entry(self.frame,font=('Calibri',10),width=10)
        self.button = tk.Button(self.frame,text=button_text,font=('Calibri',10),command=lambda:self.button_command(button_action),anchor='e',padx=4)

        if 'default_value' in kwargs:
            self.entry.insert(0,kwargs['default_value'])

        self.label.pack(side=tk.LEFT,padx=4)
        self.entry.pack(side=tk.LEFT)#,padx=4)
        self.button.pack(side=tk.LEFT,padx=4)

    def button_command(self,button_action):
        self.val = self.entry.get()
        button_action(float(self.val))

    def enable_disable(self,state):
        values = {1:'normal',0:'disabled'}
        self.button['state'] = values[state]


class Value_Entry():
    ''' 
    Creates a widget with a label, entry box that looks like the following

    __________    ______________   
   |  Label   |  |  Entry       |  |
    __________    ______________   

   
    '''

    def __init__(self,container,title_text,**kwargs):
        self.frame = tk.Frame(container,pady=2)
        self.frame.pack(fill=tk.X)
        self.label =  tk.Label(self.frame,text=title_text,font=('Calibri',10,'bold'),padx=4,anchor='e', width=20)
        self.entry =  tk.Entry(self.frame,font=('Calibri',10),width=30)

        if 'default_value' in kwargs:
            self.entry.insert(0,kwargs['default_value'])

        self.label.pack(side=tk.LEFT,padx=4)
        self.entry.pack(side=tk.LEFT)#,padx=4)

    def clear_entry(self):
        self.entry.delete(0,tk.END)
    def update_entry(self,new_value):
        self.clear_entry()
        self.entry.insert(0,new_value)


class addressed_setpoint_input():
    ''' 
    For used when a button action requires two arguments, the first of which is the address of a sensor

    Creates a widget with a label, entry box and "set" button that looks like the following

    __________    ______________    ___________
   |  Label   |  |  Entry       |  |   Set     |
    __________    ______________    ___________

   This widget takes up 1 row and 3 columns in the GUI and is arranged using the 'grid' function

   Button action is set with "button_action" input argument
    '''

    def __init__(self,container,title_text,button_text,button_action,address,**kwargs):
        self.address = address
        self.frame = tk.Frame(container,pady=2)
        self.frame.pack(fill=tk.X)
        self.label =  tk.Label(self.frame,text=title_text,font=('Calibri',10,'bold'),width=30,padx=4,anchor='e')
        self.entry =  tk.Entry(self.frame,font=('Calibri',10),width=5)
        self.button = tk.Button(self.frame,text=button_text,font=('Calibri',10),command=lambda:self.button_command(button_action),anchor='e',padx=4)

        if 'default_value' in kwargs:
            self.entry.insert(0,kwargs['default_value'])

        self.label.pack(side=tk.LEFT,padx=4)
        self.entry.pack(side=tk.LEFT)#,padx=4)
        self.button.pack(side=tk.LEFT,padx=4)

    def button_command(self,button_action):
        self.val = self.entry.get()
        button_action(self.address,float(self.val))

class gui_configs_update_input():
    ''' 
    Creates a widget with a label, entry box and "set" button that looks like the following

    __________    ______________    ___________
   |  Label   |  |  Entry       |  |   Set     |
    __________    ______________    ___________

   This widget takes up 1 row and 3 columns in the GUI and is arranged using the 'grid' function

   Button action is set with "button_action" input argument
    '''

    def __init__(self,container,title_text,button_text,configs_dict,config_param_name,**kwargs):
        self.frame = tk.Frame(container,pady=2)
        self.frame.pack(fill=tk.X)
        self.label =  tk.Label(self.frame,text=title_text,font=('Calibri',10,'bold'),width=30,padx=4,anchor='e')
        self.entry =  tk.Entry(self.frame,font=('Calibri',10))#,width=5)
        self.button = tk.Button(self.frame,text=button_text,font=('Calibri',10),command=lambda:self.button_command(configs_dict,config_param_name),anchor='e',padx=4)

        if 'default_value' in kwargs:
            self.entry.insert(0,kwargs['default_value'])

        self.label.pack(side=tk.LEFT,padx=4)
        self.entry.pack(side=tk.LEFT,padx=4)
        self.button.pack(side=tk.LEFT,padx=4)

    def button_command(self,configs_dict,config_param_name):
        self.val = self.entry.get()
        # print(len(self.val))
        if len(self.val)>0:
            configs_dict[config_param_name] = self.val
            with open('Config.json','w') as fid:
                json.dump(configs_dict,fid)

    def update_text(self,new_title_text):
        self.label['text']=new_title_text
        

class Restart_GUI_Button():
    '''
    Creates a widget with a Label and one button below it:

    Label Text goes here: 
    ________________
    | Button       |
    ________________
    '''

    def __init__(self,container,button_action):
        self.frame = tk.Frame(container,pady=2)
        self.frame.pack(fill=tk.X)
        self.label = tk.Message(self.frame,text='The Python Program must be restarted in order for changes to any of the settings on this page to take effect.  Click the button below to restart the program with the new settings. ')
        self.label.pack(fill=tk.X,padx=4,pady=4)
        self.b = tk.Button(self.frame,text = 'Save Settings and Restart Program',font=('Calibri',10),command=lambda:self.button_command(button_action),width=40,bg='red')
        self.b.pack()

    def button_command(self,button_action):
        # close and restart the program
        button_action()
        python = sys.executable
        os.execl(python, python, * sys.argv)


class one_button():
    '''
    Creates a widget with 1 button

    __________  
   |  button 1| 
    __________  
   '''
    def __init__(self,container,button_label,b1_action,**kwargs):
        self.frame = tk.Frame(container,pady=2)
        self.frame.pack(fill=tk.X)
        self.b1 = tk.Button(self.frame,text = button_label,font=('Calibri',10),command=b1_action,width=20)
        # self.b2 = tk.Button(self.frame,text = button_labels[1],font=('Calibri',10),command=b2_action,width = 20)

        # self.start.grid(row=row,column=col,sticky='e')
        # self.stop.grid(row=row,column = col+1)
        # self.reset.grid(row=row,column=col+2,sticky='w')
        # self.b1.pack(side=tk.LEFT,padx=2,pady=2)
        self.b1.pack(padx=2,pady=2)
        # self.b2.pack(side=tk.LEFT,padx=2,pady=2)

        if "background_color" in kwargs:
            self.b1.config(background=kwargs['background_color'])

    def disable_button(self):
        self.b1['state'] = 'disabled'
    
    def enable_button(self):
        self.b1['state'] = 'normal'


class two_buttons():
    '''
    Creates a widget with 2 buttons

    __________    ____________ 
   |  button 1|  |  button 2   |
    __________    ____________ 
   '''
    def __init__(self,container,button_labels,b1_action,b2_action):
        self.frame = tk.Frame(container,pady=2)
        self.frame.pack()
        self.b1 = tk.Button(self.frame,text = button_labels[0],font=('Calibri',10),command=b1_action,width=20)
        self.b2 = tk.Button(self.frame,text = button_labels[1],font=('Calibri',10),command=b2_action,width = 20)

        # self.start.grid(row=row,column=col,sticky='e')
        # self.stop.grid(row=row,column = col+1)
        # self.reset.grid(row=row,column=col+2,sticky='w')
        self.b1.pack(side=tk.LEFT,padx=2,pady=2)
        self.b2.pack(side=tk.LEFT,padx=2,pady=2)

    def update_state(self,state_array):
        values = {1:tk.SUNKEN,0:tk.RAISED}
        
        self.b1['relief'] = values[state_array[0]]
        self.b2['relief'] = values[state_array[1]]
    def enable_disable(self,state_array):
        values = {1:'normal',0:'disabled'}

        self.b1['state'] = values[state_array[0]]
        self.b2['state'] = values[state_array[1]]



class start_stop_buttons():
    '''
    Creates a widget with 2 buttons - START, STOP

    __________    ____________  
   |  Start   |  |  Stop      | 
    __________    ____________  
   '''
    def __init__(self,container,start_action,stop_action):
        self.frame = tk.Frame(container,pady=2)
        self.frame.pack()
        self.start = tk.Button(self.frame,text = 'Start',font=('Calibri',10),command=start_action,width=12)
        self.stop = tk.Button(self.frame,text = 'Stop',font=('Calibri',10),command=stop_action,width=12)
        # self.reset= tk.Button(self.frame,text = 'Clear Errors',font=('Calibri',10),command=reset_action,width=12)

        # self.start.grid(row=row,column=col,sticky='e')
        # self.stop.grid(row=row,column = col+1)
        # self.reset.grid(row=row,column=col+2,sticky='w')
        self.start.pack(side=tk.LEFT,padx=2)
        self.stop.pack(side=tk.LEFT,padx=2)
        # self.reset.pack(side=tk.LEFT,padx=2)
    def disable_buttons(self):
        self.start['state']  = 'disabled'
        self.stop['state']   = 'disabled'
        # self.reset['state']  = 'disabled'

    def enable_buttons(self):
        self.start['state']  = 'normal'
        self.stop['state']   = 'normal'
        # self.reset['state']  = 'normal'

class start_stop_reset_buttons():
    '''
    Creates a widget with 3 buttons - START, STOP and RESET 

    __________    ____________    ___________
   |  Start   |  |  Stop      |  |  Reset    |
    __________    ____________    ___________
   '''
    def __init__(self,container,start_action,stop_action,reset_action):
        self.frame = tk.Frame(container,pady=2)
        self.frame.pack()
        self.start = tk.Button(self.frame,text = 'Start',font=('Calibri',10),command=start_action,width=12)
        self.stop = tk.Button(self.frame,text = 'Stop',font=('Calibri',10),command=stop_action,width=12)
        self.reset= tk.Button(self.frame,text = 'Clear Errors',font=('Calibri',10),command=reset_action,width=12)

        # self.start.grid(row=row,column=col,sticky='e')
        # self.stop.grid(row=row,column = col+1)
        # self.reset.grid(row=row,column=col+2,sticky='w')
        self.start.pack(side=tk.LEFT,padx=2)
        self.stop.pack(side=tk.LEFT,padx=2)
        self.reset.pack(side=tk.LEFT,padx=2)


class enable_disable_reset_buttons():
    '''
    Creates a widget with 3 buttons - START, STOP and RESET 

    __________    ____________    ___________
   |  Start   |  |  Stop      |  |  Reset    |
    __________    ____________    ___________
   '''
    def __init__(self,container,start_action,stop_action,reset_action):
        self.frame = tk.Frame(container,pady=2)
        self.frame.pack()
        self.start = tk.Button(self.frame,text = 'Enable',font=('Calibri',10),command=start_action,width=12)
        self.stop = tk.Button(self.frame,text = 'Disable',font=('Calibri',10),command=stop_action,width=12)
        self.reset= tk.Button(self.frame,text = 'Clear Errors',font=('Calibri',10),command=reset_action,width=12)

        # self.start.grid(row=row,column=col,sticky='e')
        # self.stop.grid(row=row,column = col+1)
        # self.reset.grid(row=row,column=col+2,sticky='w')
        self.start.pack(side=tk.LEFT,padx=2)
        self.stop.pack(side=tk.LEFT,padx=2)
        self.reset.pack(side=tk.LEFT,padx=2)
    def disable_buttons(self):
        self.start['state']  = 'disabled'
        self.stop['state']   = 'disabled'
        self.reset['state']  = 'disabled'

    def enable_buttons(self):
        self.start['state']  = 'normal'
        self.stop['state']   = 'normal'
        self.reset['state']  = 'normal'

class fwd_rev_stop_reset_buttons():
    '''
    Creates a widget with 3 buttons - START, STOP and RESET 

    __________   __________    ____________    ___________
   |  Foward  | |  Reverse |  |  Stop      |  |  Reset    |
    __________   __________    ____________    ___________
   '''
    def __init__(self,container,row,col,forward_action,reverse_action,stop_action,reset_action):
        self.frame = tk.Frame(container)
        self.frame.pack()
        self.forward = tk.Button(self.frame,text = 'Forward',font=('Calibri',10),command=forward_action)
        self.reverse = tk.Button(self.frame,text = 'Reverse',font=('Calibri',10),command=reverse_action)
        self.stop = tk.Button(self.frame,text = 'Stop',font=('Calibri',10),command=stop_action)
        self.reset= tk.Button(self.frame,text = 'Reset',font=('Calibri',10),command=reset_action)

        # self.forward.grid(row=row,column=col,sticky='e')
        # self.reverse.grid(row=row,column=col+1)
        # self.stop.grid(row=row,column = col+2)
        # self.reset.grid(row=row,column=col+3)
        self.forward.pack(side=tk.LEFT)
        self.reverse.pack(side=tk.LEFT)
        self.stop.pack(side=tk.LEFT)
        self.reset.pack(side=tk.LEFT)


class live_data_plot():
    '''
    At the beginning of the GUI program insert: 
    plots = safl.live_data_plot(gui.frames['Plots'],500,2,'Motor Speed','RPM',['Motor 1 RPM','Motor 1 Command'])
    plotdata = {'ts':'','data':[]}

    In the looped part of the program:
    plotdata['ts'] = datetime.datetime.now()
    plotdata['data'] = [float(wheels.motor1_rpm),float(wheels.velocity_cmd_1)]

    At the end of the program (after the looped part):
    def update_plotting(i):
        plots.update_plot(plotdata['ts'],plotdata['data'])
    
    ani1= animation.FuncAnimation(plots.figure,update_plotting,interval=250)
    '''
    def __init__(self,container,buffersize,num_plots,title,ylabel,legend_lbls):

        self.data_sets = []
        for i in range(num_plots):
            self.data_sets.append(collections.deque([(datetime.datetime.now(),float('nan'))],maxlen=buffersize))

        self.figure = plt.Figure(figsize=(6,2.5), dpi=100)
        self.ax1 = self.figure.add_subplot(111)
        self.line1 = FigureCanvasTkAgg(self.figure, container)

        self.l = []
        for i in range(num_plots):
            temp, = self.ax1.plot(*zip(*self.data_sets[i]))
            self.l.append(temp)

        self.ax1.set_title(title)
        self.ax1.set_ylabel(ylabel)
        self.ax1.grid()

        self.lgnd = self.ax1.legend(legend_lbls,loc='upper left')

        self.line1.get_tk_widget().pack(fill = tk.BOTH,expand = True)

    def update_plot(self,ts,data_points):
        for i in range(len(data_points)):
            self.data_sets[i].append((ts,data_points[i]))
            self.l[i].set_data(*zip(*self.data_sets[i]))

        self.ax1.relim()
        self.ax1.autoscale_view()

class xy_plot():
    def __init__(self,container,title,xlabel,ylabel,legend_lbls):
        self.dataset = [[float('nan'),float('nan')]]
        self.figure = plt.Figure(figsize=(6,2.5), dpi=100)
        self.ax1 = self.figure.add_subplot(111)
        self.line1 = FigureCanvasTkAgg(self.figure, container)

        self.l, = self.ax1.plot(*zip(*self.dataset))
       
        self.ax1.set_title(title)
        self.ax1.set_ylabel(ylabel)
        self.ax1.set_xlabel(xlabel)
        self.ax1.grid()

        self.lgnd = self.ax1.legend(legend_lbls,loc='upper left')

        self.line1.get_tk_widget().pack(fill = tk.BOTH,expand = True)

    def refresh_plot(self,data_array):
        # print(data_array)
        self.l.set_data(*zip(*data_array))
        self.ax1.relim()
        self.ax1.autoscale_view()


class timestamp_looptime():
    def __init__(self,container):
        # Last Loop time
        self.frame = tk.Frame(container)
        self.frame.pack(fill=tk.X)
        self.frame2 = tk.Frame(container)
        self.frame2.pack(fill=tk.X)

        self.timestamp_label = tk.Label(self.frame,text='Current Timestamp',font=('Calibri',10,'bold'),anchor='e',width=30,padx=4)
        self.timestamp_value = tk.Label(self.frame,text=str(datetime.datetime.now()),font=('Calibri',10),anchor='w',width=25,padx=4)
        self.looptime_label  = tk.Label(self.frame2,text='Last Loop Time',font=('Calibri',10,'bold'),anchor='e',width=30,padx=4)
        self.looptime_value  = tk.Label(self.frame2,text='### sec',font=('Calibri',10),anchor='w',width=25,padx=4)

        self.timestamp_label.pack(side=tk.LEFT)
        self.timestamp_value.pack(side=tk.LEFT)
        self.looptime_label.pack(side=tk.LEFT)
        self.looptime_value.pack(side=tk.LEFT)

    def update(self,ts):
        split_ts = str(ts).split('.')
        last_ts = datetime.datetime.strptime(self.timestamp_value['text'],'%Y-%m-%d %H:%M:%S.%f')
            
        # Update the Timestamp label
        
        self.timestamp_value['text']= str(ts) #f"{split_ts[0]}.{int(round(float('.'+split_ts[1]),3)*1000)}"

        # Update the Loop time Label
        loop_time = (ts-last_ts)
        self.looptime_value['text'] = str(round((loop_time.seconds+loop_time.microseconds/1000/1000)*1000,3))+'  milliseconds'
        
        
class log_data():
    def __init__(self,container,write_every):
        self.write_every = write_every
        self.indx = 0
        self.frame = tk.Frame(container)
        # self.frame.pack(fill=tk.X)
        self.frame.pack()

        self.label = tk.Label(self.frame,text='Data File name: ',font = ('Calibri',10),width=16,anchor='e')
        self.label.pack(side=tk.LEFT)

        self.file = tk.Label(self.frame,text='DataFile.csv',font=('Courier',10),relief=tk.SUNKEN,bg='white')#,width=20)
        self.file.pack(side=tk.LEFT)

        self.browse_button = tk.Button(self.frame,text='Browse',command=self.select_file)
        self.browse_button.pack(side=tk.LEFT)

        self.default_filepath = os.environ['USERPROFILE'].replace(os.sep,'/')
        self.filename = self.default_filepath+'/Desktop/DataFile.csv'

        self.frame2 = tk.Frame(container)
        self.frame2.pack(fill=tk.X)
        self.toggle_button = tk.Button(self.frame2,text='Start Logging Data',command=self.toggle_datalogging,relief=tk.RAISED,width=40)
        self.toggle_button.pack(side=tk.TOP)#,fill=tk.X)

        self.status = 'Stopped'

    def toggle_datalogging(self):
        if self.toggle_button['relief'] == tk.SUNKEN:
            self.toggle_button['relief'] = tk.RAISED
            self.toggle_button['text'] = 'Start Logging Data'
            self.status = 'Stopped'
        else:
            self.toggle_button['relief'] = tk.SUNKEN
            self.toggle_button['text'] = 'Stop Logging Data'
            self.status = 'Recording'


    def select_file(self):
        self.filename = fd.asksaveasfilename(defaultextension='.csv')

        # If user doesn't input a file location and filename, save to desktop
        if len(self.filename)==0:
            self.filename = self.default_filepath+'/Desktop/Datalog_'+ datetime.datetime.now().strftime('%Y-%m-%d_%H%M%S')+'.csv'

        self.file['text'] = self.filename.split('/')[-1]

    def write_data(self,gui,header,data):

        self.indx = self.indx +1 

        if self.indx == self.write_every:
            # Check if the file already exists.  Append to the file if it does
            try:
                if self.toggle_button['relief']  == tk.SUNKEN:
                    if os.path.exists(self.filename):
                        with open(self.filename,'a') as fid:
                            for d in range(len(data)):
                                if d == 0:
                                    fid.write(str(data[d]))
                                else:
                                    fid.write(','+str(data[d]))
                            fid.write('\n')
                    else:
                        with open(self.filename,'a') as fid:
                            for h in range(len(header)):
                                if h == 0:
                                    fid.write(str(header[h]))
                                else: 
                                    fid.write(','+str(header[h]))
                            fid.write('\n')

                            for d in range(len(data)):
                                if d == 0:
                                    fid.write(str(data[d]))
                                else:
                                    fid.write(','+str(data[d]))
                            fid.write('\n')
            except Exception as e:
                print(e)
                gui.missed_records = gui.missed_records+1

            self.indx = 0

class select_file_open(): 
    def __init__(self,container,**kwargs):
        self.frame = tk.Frame(container)
        # self.frame.pack(fill=tk.X)
        self.frame.pack()

        self.label = tk.Label(self.frame,text='Select File to Open',font = ('Calibri',10),width=16,anchor='e')
        self.label.pack(side=tk.LEFT)

        self.file = tk.Label(self.frame,text='Delta Basin Calcs.xls',font=('Courier',10),relief=tk.SUNKEN,bg='white')#,width=20)
        self.file.pack(side=tk.LEFT)

        if "default_file" in kwargs:
            self.filename = kwargs["default_file"]
        
        if "allowed_file_types"  in kwargs: 
            self.allowed_file_types = kwargs["allowed_file_types"]
        else: 
            self.allowed_file_types = ''

        self.browse_button = tk.Button(self.frame,text='Browse',command=self.select_file)
        self.browse_button.pack(side=tk.LEFT)

    def select_file(self):
        self.filename = fd.askopenfilename(filetypes=[('Allowed File Types', self.allowed_file_types)])
        # print(f'Selected File: {self.filename}')

        # # If user doesn't input a file location and filename, save to desktop
        # if len(self.filename)==0:
        #     self.filename = self.default_filepath+'/Desktop/Datalog_'+ datetime.datetime.now().strftime('%Y-%m-%d_%H%M%S')+'.csv'

        self.file['text'] = self.filename.split('/')[-1]

class scrolling_text_box():
    def __init__(self,container,title):
        self.frame = tk.Frame(container)
        self.frame.pack(fill=tk.X)

        self.label = tk.Label(self.frame,text=title,font = ('Calibri',11),width=16,anchor='w')
        self.label.pack(fill=tk.BOTH,expand=True,side=tk.TOP)

        self.text_box = st.ScrolledText(self.frame,font = ("Calibri",10),background='black',foreground='white')
        self.text_box.pack(fill=tk.BOTH,expand=True,side=tk.TOP)
        self.text_box.see('end')


    def add_text(self,text_to_add):
        self.text_box.insert(tk.INSERT,text_to_add)
        self.text_box.see('end')
    def clear_all_text(self):
        self.text_box.delete('1.0',tk.END)

class table():
    def __init__(self,container,title,col_width,**kwargs):
        # Set the column headings to bold:
        style = ttk.Style()
        style.configure("Treeview.Heading",font = ("Calibri",10,'bold'))
        
        self.col_width = col_width
        self.frame = tk.Frame(container)
        self.frame.pack(fill=tk.X)
        self.horz_frame = tk.Frame(container)
        self.horz_frame.pack(fill='x')
        self.label = tk.Label(self.frame,text=title,font=('URW Gothic L','11','italic'),width=16,anchor='w')
        self.label.pack(fill=tk.BOTH,expand=True,side=tk.TOP)

        self.tree = ttk.Treeview(master = self.frame)
        self.tree.pack(fill=tk.BOTH,expand=True,side='left')

        if 'height' in kwargs:
            self.tree.configure(height=kwargs['height'])

        # Constructing vertical scrollbar
        # with treeview
        verscrlbar = ttk.Scrollbar(self.frame,orient ="vertical",command = self.tree.yview)
        verscrlbar.pack(side ='right',fill='y')#, fill ='x')        
        self.tree.configure(yscrollcommand = verscrlbar.set)

        horzscrlbar = ttk.Scrollbar(self.horz_frame,orient ="horizontal",command = self.tree.xview)
        horzscrlbar.pack(side ='bottom',fill='x',expand=True)#, fill ='x')        
        self.tree.configure(xscrollcommand = horzscrlbar.set)

    def name_columns(self,headers): 
        nums = []
        for i in range(len(headers)):
            nums.append(f'{i}')
        self.tree["columns"] = nums
        
        

        for n in nums:
            self.tree.column(n,width=self.col_width,anchor='c',stretch=True)
        

        for i in range(len(headers)):
            self.tree.heading(f'{i}',text=headers[i])
        self.tree["show"] = "headings"

    def add_row(self,array):
        self.tree.insert("",tk.END,values=array)

    def clear_all_rows(self):
        for row in self.tree.get_children(): 
            self.tree.delete(row)

class COM_Port_Selector():
    def __init__(self,container,title,device_name,config_dict,config_dict_key):
        self.com_ports = ['COM0','COM1','COM2','COM3','COM4','COM5','COM6','COM7','COM8','COM9','COM10','COM11','COM12','COM13','COM14','COM15','COM16','COM17','COM18','COM19','COM20']
        self.port = tk.StringVar()
        self.port.set(config_dict[config_dict_key])

        self.frame = tk.LabelFrame(container,text=title,font=('Calibri',11,'italic'))
        self.frame.pack(anchor='nw',pady=4)
        tk.Label(self.frame,text='Select COM Port for '+device_name,width=50,anchor='w').pack(anchor='w')
        self.com_select = tk.OptionMenu(self.frame,self.port,*self.com_ports)
        self.com_select.pack(anchor='sw')


def popup_warning(title,yes_no_question,yes_action=any,no_action=any):
    response = messagebox.showwarning(title=title,message=yes_no_question )

    if response == 'ok':
        yes_action
    else:
        pass

def h_line(container):
    ttk.Separator(container).pack(fill=tk.X)

class radio_buttons():
    def __init__(self,container,title,number_of_buttons,button_labels,**kwargs):
        self.frame = tk.Frame(container)
        self.frame.pack(fill=tk.X)

        self.label = tk.Label(self.frame,text=title,font=('Calibri',11,'bold'))
        self.label.pack(anchor='w')

        self.value = tk.IntVar()
        self.selected = -1

        for i in range(number_of_buttons):
           tk.Radiobutton(self.frame,text=button_labels[i],value=i,variable=self.value,command=self.update).pack(side=tk.LEFT)

        if "default_selection" in kwargs: 
            self.value.set(int(kwargs["default_selection"]))

    def update(self):
        self.selected = self.value.get()
        
        return self.selected

class jog_buttons():
    def __init__(self,container,title,enter_button_action,left_arrow_action,right_arrow_action,release_action):
        self.enter_button_action = enter_button_action
        self.left_arrow_action = left_arrow_action
        self.right_arrow_action = right_arrow_action
        self.release_action = release_action
        # self.jog_speed = jog_speed
        self.title = title
        self.frame = tk.Frame(container)
        self.frame.pack(fill=tk.X)
        self.entry_value = tk.StringVar()

        self.label = tk.Label(self.frame,text=title,font=('Calibri',11,'bold'))
        self.label.pack(side = tk.LEFT)

        self.left_button = tk.Button(self.frame,text='\u2190',font=('Calibri',15,'bold')) # \u2190 is unicode Left Arrow
        self.left_button.pack(side=tk.LEFT)
        self.left_button.bind("<ButtonPress-1>",self.left_arrow)
        self.left_button.bind("<ButtonRelease-1>",self.button_released)

        self.current_value = tk.Entry(self.frame,font=('Calibri',11),width=25,bg='white',textvariable=self.entry_value)
        self.current_value.pack(side=tk.LEFT)
        self.current_value.bind("<Return>",self.enter_action)

        self.right_button = tk.Button(self.frame,text='\u2192',font=('Calibri',15,'bold')) # \u2192 is unicode Right Arrow.
        self.right_button.pack(side=tk.LEFT)
        self.right_button.bind("<ButtonPress-1>",self.right_arrow)
        self.right_button.bind("<ButtonRelease-1>",self.button_released)


        self.current_pos = tk.Label(self.frame,text='Current Position: ',font=('Calibri',11,'bold'))
        self.current_pos.pack(side=tk.LEFT)
        

    def update_current_pos(self,new_pos):
        # self.current_value.config(state='normal')
        # self.current_value.delete(0,tk.END)
        # self.current_value.insert(0,new_pos)
        # self.current_value.config(state='disabled')
        self.current_pos['text'] = f'Current Position: {new_pos:.1f} mm'

    def enable_disable(self,state:bool):
        if state:
            self.current_value.config(state='normal')
        else:
            self.current_value.config(state='disabled')

    # def update_target_pos(self,new_target):
    #     self.target_value['text'] = f'Target: {new_target} mm'

    def enter_action(self,event):
        value = self.current_value.get()
        # print(f'{self.title} Entry is: {value}')
        # self.update_target_pos(value)
        self.enter_button_action(float(value))

    def left_arrow(self,event):
        # print('Left arrow Pressed!')
        self.left_arrow_action()

    def right_arrow(self,event):
        # print('right arrow pressed')
        self.right_arrow_action()

    def button_released(self,event):
        # print('Button released!')
        self.release_action()


class splash_screen():
    def __init__(self):
        # Create object
        splash_root = tk.Tk()
        
        # Adjust size
        splash_root.geometry("200x200")
        
        # Set Label
        splash_label = tk.Label(splash_root,text="Splash Screen",font=18)
        splash_label.pack()
        
        # main window function
        def main(): 
            # destroy splash window
            splash_root.destroy()

        
        # Set Interval
        splash_root.after(3000,main)
        
        splash_thread = threading.Thread(target=splash_root.mainloop)
        splash_thread.start()
        # Execute tkinter
        splash_root.mainloop()


class massa_settings():
    def __init__(self,container,name_str,id_num,button_action):
        massa_frame = tk.LabelFrame(container,text=name_str,font=('Arial',12))
        massa_frame.pack(fill=tk.BOTH,expand=True,side=tk.TOP)
        self.massa_id_display = value_display(container=massa_frame,name_str='Massa ID Number')
        self.massa_error_display = value_display(container=massa_frame,name_str='Status')
        self.massa_target_display =value_display(container=massa_frame,name_str='Target Acquired')
        self.massa_strength_display = value_display(container=massa_frame,name_str='Signal Strength')
        self.massa_temp_display = value_display(container=massa_frame,name_str='Massa Temperature')
        self.massa_dist_display = value_display(container=massa_frame,name_str='Raw Distance Measurement')
        self.massa_water_depth_display = value_display(container=massa_frame,name_str='Water Depth Measurement')
        self.massa_offset_display = value_display(container=massa_frame,name_str='Current Depth Offset')

        addressed_setpoint_input(container=massa_frame,title_text='Depth Offset (cm)',button_text='Set',button_action=button_action,address=id_num)

    def update(self,massa_obj,id_num):
        try:
            ids = np.array(massa_obj.massa_id_array)

            idx = np.where(ids==id_num)[0].item()

            self.massa_id_display.update(f'{massa_obj.massa_id_array[idx]}')
            self.massa_error_display.update(f'{massa_obj.error_array[idx]}')
            self.massa_target_display.update(f'{massa_obj.target_array[idx]}')
            self.massa_strength_display.update(f'{massa_obj.strength_array[idx]}')
            self.massa_temp_display.update(f'{massa_obj.massa_temperature_array[idx]:.1f} degC')
            self.massa_dist_display.update(f'{massa_obj.dist_cm_array[idx]:.2f} cm')
            self.massa_water_depth_display.update(f'{massa_obj.water_depth_array[idx]:.2f} cm')
            
            self.massa_offset_display.update(f'{massa_obj.offsets[idx]:.2f} cm')  
        except Exception as e:
            print(f'Error Updating Massa GUI: {e}')

class RunTimer():
    """
    timer.start() - should start the timer
    timer.pause() - should pause the timer
    timer.resume() - should resume the timer
    timer.get() - should return the current time
    """

    def __init__(self):
        print('Initializing timer')
        self.timestarted = None
        self.timepaused = None
        self.paused = False

    def start(self):
        """ Starts an internal timer by recording the current time """
        # print("Starting timer")
        if self.timestarted is None:            
            self.timestarted = datetime.datetime.now()
        elif self.paused:
            self.resume()


    def pause(self):
        """ Pauses the timer """
        if self.timestarted is None:
            raise ValueError("Timer not started")
        if self.paused:
            raise ValueError("Timer is already paused")
        # print('Pausing timer')
        self.timepaused = datetime.datetime.now()
        self.paused = True

    def resume(self):
        """ Resumes the timer by adding the pause time to the start time """
        if self.timestarted is None:
            raise ValueError("Timer not started")
        if not self.paused:
            raise ValueError("Timer is not paused")
        # print('Resuming timer')
        pausetime = datetime.datetime.now() - self.timepaused
        self.timestarted = self.timestarted + pausetime
        self.paused = False

    def get(self):
        """ Returns a timedelta object showing the amount of time
            elapsed since the start time, less any pauses """
        # print('Get timer value')
        if self.timestarted is None:
            # raise ValueError("Timer not started")
            return datetime.timedelta(hours=0)
        if self.paused:
            return self.timepaused - self.timestarted
        else:
            return datetime.datetime.now() - self.timestarted