import paho.mqtt.client as mqtt
import json
import numpy as np

class ClearCoreMQTT_motion(): 
    def __init__(self,broker_address:str,broker_port:int,units:str,scale_array):
        self.mqttc = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
        self.mqttc.on_message = self.on_message
        self.mqttc.connect(broker_address,broker_port,60)
        self.mqttc.subscribe("motion/x_axis/status")
        self.mqttc.loop_start()

        # Set some default values
        self.travel_vel = 100
        self.jog_vel    = 5
        self.scan_vel   = 30
        self.target = 0
        
        self.units = units #pass the units that the motor controller is using to the clearcore_motion object. This is maybe a legacy thing.  Some of the Zetas on NCED carts used meters instead of mm because of max number sizes allowed be to saved to variables. I kept the units the same in the ClearCore so it could also function as a Zeta
        
        self.data_array = []
        self.status_array = {}

        self.scale_array = scale_array

    # The callback for when a PUBLISH message is received from the server.
    def on_message(self,client, userdata, msg):
        # print(msg.topic+" "+str(msg.payload))
        if msg.topic == "motion/x_axis/status":
            self.status_array = json.loads(msg.payload)
            # print(self.status_array["ConnectorA12_Volts"])
        if msg.topic == "DAQ":
            self.data_message = json.loads(msg.payload)
            
            if "z_position" in self.data_message:
                z_probe = self.data_message['z_position']
            else:
                z_probe = 668

            self.data_array.append([self.data_message[0],self.data_message[1]])
                        # convert the data_array to a numpy array so its easier to work with.
            self.data = np.asarray(self.data_array,dtype='float')

            # Apply the scale factors to convert from voltage to mm
            self.data[:,1] = z_probe - self.data[:,1]*self.scale_array[0] + self.scale_array[1]


    def set_absolute_position(self,posn):
        self.mqttc.publish("Commands/SetAbsolutePosition",posn)

    def set_velocity(self,vel):
        self.mqttc.publish("Commands/SetVelocity",vel)

    def enable(self):
        self.mqttc.publish("Commands/Enable",1)
    
    def disable(self):
        self.mqttc.publish("Commands/Disable",0)

    def move_to_absolute_position(self,target):
        self.mqttc.publish("Commands/MoveToAbsolutePosition",target)
    
    def relative_move(self, dist):
        self.mqttc.publish("Commands/RelativeMove",dist)

    def jog(self,vel):
        self.mqttc.publish("Commands/Jog",vel)

    def stop_motion(self):
        self.mqttc.publish("Commands/StopMotion",0)

    def clear_faults(self):
        self.mqttc.publish("Commands/ClearFaults")
        self.mqttc.publish("Alerts/x_axis","OK")

    def SetOutputIO(self,connector_num,state:bool):
        if connector_num == 0:
            self.mqttc.publish("Commands/SetOutputIO/ConnectorIO_0",state)
        elif connector_num == 1: 
            self.mqttc.publish("Commands/SetOutputIO/ConnectorIO_1",state)

if __name__ == "__main__":
    import time

    CC_MQTT = ClearCoreMQTT_motion("160.94.187.233",1883)
    count = 0
    try:
        while True:
            print(f'Loop Number: {count}')
            count = count+1
            time.sleep(1)
            CC_MQTT.set_absolute_position(count)
    except KeyboardInterrupt:
        print("Stopping")
        CC_MQTT.mqttc.loop_stop()
        CC_MQTT.mqttc.disconnect()