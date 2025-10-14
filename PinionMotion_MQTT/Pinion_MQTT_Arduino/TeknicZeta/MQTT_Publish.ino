void publish_mqtt_message_float(char topic[],float value){
  mqttClient.beginMessage(topic);
  mqttClient.print(value,4);
  mqttClient.endMessage();
}

void publish_mqtt_message_int(char topic[],int value){
  mqttClient.beginMessage(topic);
  mqttClient.print(value);
  mqttClient.endMessage();
}

void publish_status() {
  publish_mqtt_message_int("motion/x_axis/AtTargetPosition",motor0.StatusReg().bit.AtTargetPosition);  
  publish_mqtt_message_int("motion/x_axis/StepsActive",motor0.StatusReg().bit.StepsActive);  
  // publish_mqtt_message_int("motion/x_axis//AtTargetVelocity",motor0.StatusReg().bit.AtTargetVelocity);  
  publish_mqtt_message_int("motion/x_axis/MoveDirection",motor0.StatusReg().bit.MoveDirection);  
  publish_mqtt_message_int("motion/x_axis/MotorInFault",motor0.StatusReg().bit.MotorInFault);  
  publish_mqtt_message_int("motion/x_axis/Enabled",motor0.StatusReg().bit.Enabled);  
  // publish_mqtt_message_int("motion/x_axis/PositionalMove",motor0.StatusReg().bit.PositionalMove);  
  publish_mqtt_message_int("motion/x_axis/HlfbState",motor0.StatusReg().bit.HlfbState);
  publish_mqtt_message_int("motion/x_axis/AlertsPresent",motor0.StatusReg().bit.AlertsPresent);  
  publish_mqtt_message_int("motion/x_axis/ReadyState",motor0.StatusReg().bit.ReadyState);  
  // publish_mqtt_message_int("motion/x_axis/Triggering",motor0.StatusReg().bit.Triggering);
  publish_mqtt_message_int("motion/x_axis/InPositiveLimit",motor0.StatusReg().bit.InPositiveLimit);
  publish_mqtt_message_int("motion/x_axis/InNegativeLimit",motor0.StatusReg().bit.InNegativeLimit);  
  publish_mqtt_message_int("motion/x_axis/InEStopSensor",motor0.StatusReg().bit.InEStopSensor);  
  publish_mqtt_message_float("motion/x_axis/VelocityLimit",Scale_Vel_Steps_to_mm(velocityLimit));  
  // publish_mqtt_message_int("motion/x_axis/MotionCanceledInAlert",motor0.AlertReg().bit.MotionCanceledInAlert);  
  // publish_mqtt_message_int("motion/x_axis/MotionCanceledInPositiveLimit",motor0.AlertReg().bit.MotionCanceledPositiveLimit);  
  // publish_mqtt_message_int("motion/x_axis/MotionCanceledInNegativeLimit",motor0.AlertReg().bit.MotionCanceledNegativeLimit);  
  // publish_mqtt_message_int("motion/x_axis/MotionCanceledSensorEStop",motor0.AlertReg().bit.MotionCanceledSensorEStop);
  // publish_mqtt_message_int("motion/x_axis/MotionCanceledMotorDisabled",motor0.AlertReg().bit.MotionCanceledMotorDisabled);  
  publish_mqtt_message_int("motion/x_axis/MotorFaulted",motor0.AlertReg().bit.MotorFaulted);
  publish_mqtt_message_int("motion/x_axis/ConnectorIO0_State",ConnectorIO0.State());
  publish_mqtt_message_int("motion/x_axis/ConnectorIO1_State",ConnectorIO1.State());
  publish_mqtt_message_float("motion/x_axis/CurrentPosition",Scale_Steps_to_mm(motor0.PositionRefCommanded()));
  publish_mqtt_message_int("motion/x_axis/ConnectorA12_Volts",ConnectorA12.AnalogVoltage());
}