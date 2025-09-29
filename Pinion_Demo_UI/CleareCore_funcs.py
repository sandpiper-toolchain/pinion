import serial
import time
import numpy as np

class clearcore_motion():
    '''
    Opens a comm port for for the control of a ClearCore motion controller. Typically this COM port is COM-0 on the ClearCore. The com port is used strictly for the control of the motor and monitoring its state.  Measurements of current position and analog inputs are done with a similar class called "clearcore_daq". 

    Inputs: 
    com_port (string): the name of the com port on your computer that you are using to connect to the ClearCore (NOT the com port on the ClearCore).  You can find which com port you are using in Windows Device Manager. 
    baudrate (int): the baudrate of the ClearCore serial port (typically 9600)
    units (string e.g. 'mm' or 'm'): The units that the ClearCore is using for scaling from steps to engineering units. The Pinion GUI always uses mm, but the ClearCore is sometimes set up in meters. Specifying the units here always Python to accurately scale from the ClearCore units to mm when polling position or sending motion commands. 

    Returns: an object referencing the ClearCore with atributes and actions relevant to controlling the axis
    '''
    def __init__(self,com_port,baudrate,units):

        # Attempt to open the com port and throw an error if the com port cannot be found
        try: 
            self.com = serial.Serial(com_port,baudrate,timeout=0.1)
            self.com.reset_input_buffer()
            self.com.flush()
        except Exception as e:
            print(f'Error Opening COM Port for Teknic ClearCore: {e}')
            self.com = ''

        # Set some default values
        self.travel_vel = 100
        self.jog_vel    = 5
        self.scan_vel   = 30
        self.target = 0
        
        self.units = units #pass the units that the motor controller is using to the clearcore_motion object. This is maybe a legacy thing.  Some of the Zetas on NCED carts used meters instead of mm because of max number sizes allowed be to saved to variables. I kept the units the same in the ClearCore so it could also function as a Zeta

        # Set Execute a few commands to get the ClearCore ready to communicate with the GUI program
        self.send_command('echo0') # turn off echo so ClearCore doesn't echo back each character it receives over serial
        self.send_command('verbose0') # turn off Verbose Response
        self.send_command('ma1') # put the controller into absolute position mode. 
        self.scaler = {'m':1000,'mm':1} # GUI will always display in mm, but sometimes the motor controller is configured in meters. 
        self.set_velocity(self.travel_vel) # set the velocity to the default travel velocity


        # Intialize the status variables that will be populated with the poll_status() command
        self.AtTargetPos                 = -999
        self.StepsActive                 = -999
        self.AtTargetVel                 = -999
        self.MoveDir                     = -999
        self.MotorInFault                = -999
        self.Enabled                     = -999
        self.PositionalMove              = -999
        self.HlfbState                   = -999
        self.AlertsPresent               = 1
        self.MotorReadyState             = -999
        self.Triggering                  = -999
        self.InPositiveLimit             = -999
        self.InNegativeLimit             = -999
        self.InEStopSensor               = -999
        self.VelSetPoint                 = -999 #Counts per second
        self.MotionCanceledInAlert       = 1
        self.MotionCanceledPositiveLimit = 1
        self.MotionCanceledNegativeLimit = 1
        self.MotionCanceledSensorEStop   = 1
        self.MotionCanceledMotorDisabled = 1
        self.MotorFaulted                = 1
        self.MotionCanceledInAlert       = 1
        self.MotionCanceledPositiveLimit = 1
        self.MotionCanceledNegativeLimit = 1
        self.MotionCanceledSensorEStop   = 1
        self.MotionCanceledMotorDisabled = 1
        self.MotorFaulted                = 1
        self.IO0_state                   = 0
        self.IO1_state                   = 0
        self.position                    = float('nan')
        self.A12_volts                   = float('nan')


    def send_command(self,command):
        '''
        Function to format and send serial commands to the ClearCore and read back the response. 

        Input: command (string) the command you want to send to the ClearCore

        Returns: the response received from the ClearCore as a string. If an error is encountered while sending or receiving the response will be 'NAN'
        '''
        command_encoded = (command+chr(13)).encode() # using \n for newline/carriage return doesn't seem to work. 
        # print(f'Command as Send: {command_encoded}')
        try:
            self.com.write(command_encoded)
            response = self.com.readline()
        except Exception as e:
            print(f'Error Communicating with ClearCore: {e}')
            response = b'NAN'
        # print(f'response: {response}')

        return response.decode('utf-8')
    
    def set_absoulute_position(self,posn):
        '''
        Sends the command to set the absolute position of the ClearCore controller. 

        Input: posn (float or int) is the position in mm that you want to set the position to. If the controller is set up in meters, this function will scale to meters before sending the command.

        Returns: None
        '''
        self.send_command(f'pset {posn/self.scaler[self.units]:.4f}')

    def set_velocity(self,vel):
        '''
        Send the command to set the velocity for ClearCore to use while moving.

        Input: vel (float or int) is the velocity in mm/s. This function will scale to the units being used on the controller (e.g. meters)

        Returns: None
        '''
        self.send_command(f'v {vel/self.scaler[self.units]:.4f}')

    def enable(self):
        '''
        Send the command to enable the motor.

        Input: None

        Returns: None
        '''
        self.send_command(f'drive1')

    def disable(self):
        '''
        Send the command to disable the motor.

        Input: None

        Returns: None
        '''
        self.send_command(f'drive0')

    def move_to_absolute_position(self,target):
        '''
        Send the command to move to an absolute position using the current velocity setting.

        Input: target (numeric) the position in mm to move to.  If the ClearCore is set to units other than mm, this function will scale appropriately before sending the command.

        Returns: None
        '''
        self.send_command('ma1') # Put the ClearCore in absolute positioning mode.
        command = f'd{target/self.scaler[self.units]:0.4f}'
        self.send_command(command)
        self.send_command('go')

    def relative_move(self, dist): 
        '''
        Send the command to move a relative distance using the current velocity setting.

        Input: dist (numeric) the distance in mm to move.  If the ClearCore is set to units other than mm, this function will scale appropriately before sending the command.

        Returns: None
        '''
        self.send_command('ma0')
        command = f'd{dist/self.scaler[self.units]:0.4f}'
        self.send_command(command)
        self.send_command('go')

    def jog(self,vel):
        '''
        Send the command to jog (make a velocity move without a set distance or target position) IMPORTANT: after sending this command the motor will continue moving at the input velocity until a limit switch is tripped or the user sends the "stop_motion" command.

        Input: vel (numeric) the velocity in mm/s to move at.  If the ClearCore is set to units other than mm, this function will scale appropriately before sending the command.

        Returns: None
        '''
        command = f'jog {vel/self.scaler[self.units]:.4f}'
        self.send_command(command)

    def stop_motion(self):
        '''
        Send the command to stop the axis using the ClearCore command: "MoveStopAbrupt"

        Input: None

        Returns: None
        '''
        command = f's'
        self.send_command(command)

    def set_output_IO(self,connector_num,state):
        '''
        Send the command to turn on or off one of the 6 I/O Ports on the ClearCore. 

        Inputs: 
        connector_num (Int): the number of the I/O to turn on/off. Allowable values are 0-5 and correspond to the I/O ports on the Clearcore labeled "I/O-0" to "I/O-5" 
        state (Int or Bool): The state you would like to set the I/O output to. 1 or True = On/High.  0 or False = Off/Low

        Returns: None
        '''
        command = f'digout{connector_num} {state}'
        self.send_command(command)

    def wait_for_HLFB(self):
        '''
        Wait for the ClearCore to finish the current move. IMPORTANT: This command will pause execution of any following commands until the current move has completed. This function will continuously poll the status of the ClearCore and look for the "StepsActive" flag to be False, indicating that the axis is no longer moving. 

        Inputs: None

        Returns: None
        '''
        self.poll_status()
        while self.StepsActive != 0:
            self.poll_status()
        # print('Move Finished')
            
    def clear_faults(self):
        '''
        Send the Command to clear motor faults to the ClearCore controller. 

        Inputs: None

        Returns: None
        '''
        self.send_command(f'clear')
    
    def Send_Program(self,filename):
        '''
        Open a text file, read its contents line by line and send them through the serial port to the ClearCore. This command can be used to send Zeta-like programs to the ClearCore that will be saved on the SD card and can be executed by calling the name of the program.

        Inputs: filename (string), the filepath and name of the text file to be read and sent. Example `C:/Users/milli079/Documents/GitHub/pinion/TeknicZeta_Stepper/ZetaPrgs/MillirenDevSetup/DBII_Milliren.PRG`

        Returns: None
        '''
        print('Sending New Program to ClearCore')
        self.send_command('verbose1')
        with open(filename,'r') as fid: 
            for line in fid:
                print(f'Sending line: {line}')
                self.send_command(line)
                time.sleep(0.5)

        self.send_command('verbose0')

    def poll_status(self):
        '''
        Poll the ClearCore for its current status and update all the values relevant to the current state of the ClearCore. Parameters retrieved with this command include, StepsActive, Enabled, InPositiveLimit, InNegativeLimit, position, Analog input voltage, etc.

        Input: None

        Retunrs: None
        '''
        status_str = self.send_command('status')
        status_str = status_str.strip()
        status_str = status_str.replace('>','')
        status_array = status_str.split(',')

        if status_array[0] != '':
            try: 
                self.AtTargetPos    = int(status_array[0])
                self.StepsActive    = int(status_array[1])
                self.AtTargetVel    = int(status_array[2])
                self.MoveDir        = int(status_array[3])
                self.MotorInFault   = int(status_array[4])
                self.Enabled        = int(status_array[5])
                self.PositionalMove = int(status_array[6])
                self.HlfbState      = int(status_array[7])
                self.AlertsPresent  = int(status_array[8])
                self.MotorReadyState= int(status_array[9])
                self.Triggering     = int(status_array[10])
                self.InPositiveLimit= int(status_array[11])
                self.InNegativeLimit= int(status_array[12])
                self.InEStopSensor  = int(status_array[13])
                self.VelSetPoint    = float(status_array[14])*self.scaler[self.units]
                self.MotionCanceledInAlert = int(status_array[15])
                self.MotionCanceledPositiveLimit = int(status_array[16])
                self.MotionCanceledNegativeLimit = int(status_array[17])
                self.MotionCanceledSensorEStop = int(status_array[18])
                self.MotionCanceledMotorDisabled = int(status_array[19])
                self.MotorFaulted                = int(status_array[20])
                self.IO0_state                   = int(status_array[21])
                self.IO1_state                   = int(status_array[22])
                self.position                    = float(status_array[23])*self.scaler[self.units]
                self.A12_volts                   = float(status_array[24])

            except Exception as e:
                print(f'Error Parsing Status Array: {e}')
                print(f'StatusArray Received: {status_array}')
                self.AtTargetPos                 = -999
                self.StepsActive                 = -999
                self.AtTargetVel                 = -999
                self.MoveDir                     = -999
                self.MotorInFault                = -999
                self.Enabled                     = -999
                self.PositionalMove              = -999
                self.HlfbState                   = -999
                self.AlertsPresent               = 1
                self.MotorReadyState             = -999
                self.Triggering                  = -999
                self.InPositiveLimit             = -999
                self.InNegativeLimit             = -999
                self.InEStopSensor               = -999
                self.VelSetPoint                 = -999 #Counts per second
                self.MotionCanceledInAlert       = 1
                self.MotionCanceledPositiveLimit = 1
                self.MotionCanceledNegativeLimit = 1
                self.MotionCanceledSensorEStop   = 1
                self.MotionCanceledMotorDisabled = 1
                self.MotorFaulted                = 1
                self.MotionCanceledInAlert       = 1
                self.MotionCanceledPositiveLimit = 1
                self.MotionCanceledNegativeLimit = 1
                self.MotionCanceledSensorEStop   = 1
                self.MotionCanceledMotorDisabled = 1
                self.MotorFaulted                = 1
                self.IO0_state                   = 0
                self.IO1_state                   = 0
                self.position                    = float('nan')
                self.A12_volts                   = float('nan')


class clearcore_daq():
    '''
    Opens a com port on the computer to communicate with the ClearCore Controller in order to read scan data (position of the axis and sensor output measured on the analog input).  The port is separate from the clearcore_motion port so that it doesn't interfer with any of the motion commands. Typically the USB port on the ClearCore is used.  Connecting the ClearCore to your computer with a USB cable mounts the ClearCore as a com port on your computer. You can find the com port number with Windows Device Manager. 

    Inputs: 
        com_port (string e.g. 'COM1'): The com port your computer should use to communicate with the ClearCore. You can find this port with Windows Device Manager. 
        baudrate (int): The baudrate the ClearCore is using to communicate.  This must match the baudrate the ClearCore is programmed to use (typically 115200)

    Returns: 
        an object referencing the ClearCore controller with atttributes and actions relevant to collecting data with the ClearCore.

    '''
    def __init__(self,com_port,baudrate):
        self.data_array = []
        try: 
            self.com = serial.Serial(com_port,baudrate,timeout=0.1)
            self.com.reset_input_buffer()
        except Exception as e:
            print(f'Error Opening COM Port for DAQ Teknic ClearCore: {e}')
            self.com = ''

    def read_data(self,scale_array,z_probe):
        '''
        '''
        if self.com.in_waiting > 0:
            # read the bytes and convert from binary array to ASCII
            data_str = self.com.read(self.com.in_waiting).decode('ascii') 

            # Format the data string so it can be appended to an array            
            data_str_array = data_str.split('\n')
            data_split_array = []
            # temp_data = []
            for i in range(len(data_str_array)):
                temp = data_str_array[i].split(',')
                data_split_array.append(temp)
                
                temp_data = []
                for j in range(len(data_split_array[-1])):
                    temp_data.append(data_split_array[i][j].replace('>','').replace('\r',''))
                # print(f"temp_data = {temp_data}")
                
                if not temp_data == [] and not temp_data == ['']:
                    for k in range(len(temp)):
                        temp_data[k] = float(temp_data[k])
                    self.data_array.append(temp_data)

            # convert the data_array to a numpy array so its easier to work with.
            self.data = np.asarray(self.data_array,dtype='float')
            # Apply the scale factors to convert from voltage to mm
            self.data[:,1] = z_probe - self.data[:,1]*scale_array[0] + scale_array[1]


if __name__ == '__main__':
    daq = clearcore_daq('COM6',115200)

    try: 
        while True: 
            daq.read_data()

            # print(daq.data)

            time.sleep(0.5)

    except KeyboardInterrupt:
        print('Stopping')


