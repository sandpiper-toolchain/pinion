void publish_mqtt_message_str(String topic,String value){
  // Diag_ComPort.println(value.length());
  mqttClient.beginMessage(topic,value.length(),false,0,false); //payload,length,retained,qos,dup
  mqttClient.print(value);
  mqttClient.endMessage();
}

void publish_status() {
  String status_str = "{\"AtTargetPosition\":"+String(motor0.StatusReg().bit.AtTargetPosition)+
                       ",\"StepsActive\":"+String(motor0.StatusReg().bit.StepsActive)+
                       ",\"MotorInFault\":"+String(motor0.StatusReg().bit.MotorInFault)+
                       ",\"Enabled\":"+String(motor0.StatusReg().bit.Enabled)+
                       ",\"AlertsPresent\":"+String(motor0.StatusReg().bit.AlertsPresent)+
                       ",\"ReadyState\":"+String(motor0.StatusReg().bit.ReadyState)+
                       ",\"InPositiveLimit\":"+String(motor0.StatusReg().bit.InPositiveLimit)+
                       ",\"InNegativeLimit\":"+String(motor0.StatusReg().bit.InNegativeLimit)+
                       ",\"InEStopSensor\":"+String(motor0.StatusReg().bit.InEStopSensor)+
                       ",\"VelocityLimit\":"+String(Scale_Vel_Steps_to_mm(velocityLimit),4)+
                       ",\"MotorFaulted\":"+String(motor0.AlertReg().bit.MotorFaulted)+
                       ",\"ConnectorIO0_State\":"+String(ConnectorIO0.State())+
                       ",\"ConnectorIO1_State\":"+String(ConnectorIO1.State())+
                       ",\"CurrentPosition\":"+String(Scale_Steps_to_mm(motor0.PositionRefCommanded()),4)+
                       ",\"ConnectorA12_Volts\":"+String(ConnectorA12.AnalogVoltage(),4)+
                       ",\"Scale\":"+String(SCLD,4)+
                       "}";
  // Diag_ComPort.println(String(Scale_Steps_to_mm(motor0.PositionRefCommanded()),4));
  // Diag_ComPort.println(status_str);
  // Diag_ComPort.println(count++);
  // Diag_ComPort.println(System_Name+"/motion/x_axis/status");
  publish_mqtt_message_str(System_Name+"/motion/x_axis/status",status_str);
}