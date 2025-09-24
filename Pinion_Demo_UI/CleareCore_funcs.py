import serial
import time
import numpy as np

class clearcore_motion():
    def __init__(self,com_port,baudrate,units):
        try: 
            self.com = serial.Serial(com_port,baudrate,timeout=1)
            self.com.reset_input_buffer()
        except Exception as e:
            print(f'Error Opening COM Port for Teknic ClearCore: {e}')
            self.com = ''

        self.travel_vel = 100
        self.jog_vel    = 5
        self.scan_vel   = 30

        self.target = 0
        

        self.units = units
        self.send_command('echo0')
        self.send_command('verbose0') # turn off Verbose Response
        self.send_command('ma1') # put the controller into absolute position mode. 
        self.scaler = {'m':1000,'mm':1} # GUI will always display in mm, but sometimes the motor controller is configured in meters. 

        self.set_velocity(self.travel_vel)

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
        self.send_command(f'pset {posn/self.scaler[self.units]:.4f}')

    def set_velocity(self,vel):
        self.send_command(f'v {vel/self.scaler[self.units]:.4f}')

    def read_position(self):
        try:
            response = self.send_command(f'tpm')
            response = response.replace('TPM','')
            response = response.replace('>','')
            response = response.replace('+','')
            response = response.replace('*','')
            self.position = float(response.strip())
        except Exception as e:
            print(f'Error Refreshing Position: {e}')
            self.position = float('nan')

    def home_axis(self):
        self.jog(-5) # mm/s

        self.poll_status()
        while bool(self.StepsActive):
            print(self.InNegativeLimit)
            self.poll_status()


    def enable(self):
        self.send_command(f'drive1')
        # self.wait_for_HLFB()

    def disable(self):
        self.send_command(f'drive0')

    def move_to_absolute_position(self,target):
        self.send_command('ma1')
        command = f'd{target/self.scaler[self.units]:0.4f}'
        self.send_command(command)
        self.send_command('go')

    def relative_move(self, dist): 
        self.send_command('ma0')
        command = f'd{dist/self.scaler[self.units]:0.4f}'
        self.send_command(command)
        self.send_command('go')

    def jog(self,vel):
        command = f'jog {vel/self.scaler[self.units]:.4f}'
        self.send_command(command)
        # self.send_command('ma1') # put the controller back into absolute positioning mode. 

    def stop_motion(self):
        command = f's'
        self.send_command(command)

    def set_output_IO(self,connector_num,state):
        command = f'digout{connector_num} {state}'
        self.send_command(command)
        # print(f'Digital Output Command: {command}')

    def wait_for_HLFB(self):
        self.poll_status()
        while self.StepsActive != 0:
            # self.read_position()
            # print(f'current position: {self.position} counts.  HLFB = {self.HlfbState}')
            self.poll_status()
        print('Move Finished')
            
    def clear_faults(self):
        self.send_command(f'clear')
    
    def Send_Program(self,filename):
        print('Sending New Program to ClearCore')
        self.send_command('verbose1')
        with open(filename,'r') as fid: 
            for line in fid:
                print(f'Sending line: {line}')
                self.send_command(line)
                time.sleep(0.5)

        self.send_command('verbose0')

    def poll_status(self):
        status_str = self.send_command('status')
        # print(status_str)
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
    def __init__(self,com_port,baudrate):
        self.data = []
        
        try: 
            self.com = serial.Serial(com_port,baudrate,timeout=1)
            self.com.reset_input_buffer()
        except Exception as e:
            print(f'Error Opening COM Port for DAQ Teknic ClearCore: {e}')
            self.com = ''

    def read_data(self):
        if self.com.in_waiting > 0:
            # read the bytes and convert from binary array to ASCII
            # data_str = self.com.read(self.com.in_waiting).decode('ascii') 
            data_str = self.com.readline().decode('utf-8')
            # print the incoming string without putting a new-line
            # ('\n') automatically after every print()
            # print(data_str, end='')

            # Format the data string so it can be appended to an array
            if data_str[0] == '>': # each received data string should start with a >.  If not we've recieved data somewhere in the middle of a transmission
                data_str = data_str.replace('>','')
                # data_str = data_str.replace('\n','')
                # data_str = data_str.replace('\r','')
                this_data = data_str.strip().split(',')
                for i in range(len(this_data)):
                    this_data[i] = float(this_data[i])
                self.data.append(this_data)
                # print(self.data)
            else: 
                print(f"Incomplete Data transmission: {data_str}")
                print(f"First Character: {data_str[0]}")


if __name__ == '__main__':
    x_axis = clearcore_motion('COM11',9600,'m')

    x_axis.clear_faults()

    x_axis.poll_status()
    x_axis.enable()
    x_axis.set_velocity(50)

    x_axis.home_axis()


