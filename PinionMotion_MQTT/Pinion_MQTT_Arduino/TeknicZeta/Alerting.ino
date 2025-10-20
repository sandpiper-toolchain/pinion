/*------------------------------------------------------------------------------
 * PrintAlerts
 *
 *    Prints active alerts.
 *
 * Parameters:
 *    requires "motor" to be defined as a ClearCore motor connector
 *
 * Returns: 
 *    none
 */
void PrintAlerts() {
  // report status of alerts
  Diag_ComPort.println("Alerts present: ");
  String Alerts_Str = "Alerts Present:\n";
  if (motor0.AlertReg().bit.MotionCanceledInAlert) {
    Diag_ComPort.println("    MotionCanceledInAlert ");
    Alerts_Str  = Alerts_Str+"    MotionCanceledInAlert ";
  }
  if (motor0.AlertReg().bit.MotionCanceledPositiveLimit) {
    Diag_ComPort.println("    MotionCanceledPositiveLimit ");
    Alerts_Str  = Alerts_Str+"    MotionCanceledPositiveLimit ";
  }
  if (motor0.AlertReg().bit.MotionCanceledNegativeLimit) {
    Diag_ComPort.println("    MotionCanceledNegativeLimit ");
    Alerts_Str  = Alerts_Str+"    MotionCanceledNegativeLimit ";
  }
  if (motor0.AlertReg().bit.MotionCanceledSensorEStop) {
    Diag_ComPort.println("    MotionCanceledSensorEStop ");
    Alerts_Str  = Alerts_Str+"    MotionCanceledSensorEStop ";
  }
  if (motor0.AlertReg().bit.MotionCanceledMotorDisabled) {
    Diag_ComPort.println("    MotionCanceledMotorDisabled ");
    Alerts_Str = Alerts_Str + "    MotionCanceledMotorDisabled ";
  }
  if (motor0.AlertReg().bit.MotorFaulted) {
    Diag_ComPort.println("    MotorFaulted ");
    Alerts_Str = Alerts_Str + "    MotorFaulted ";
  }

  publish_mqtt_message_str("Alerts/x_axis", Alerts_Str);
}
//------------------------------------------------------------------------------


/*------------------------------------------------------------------------------
 * HandleAlerts
 *
 *    Clears alerts, including motor faults. 
 *    Faults are cleared by cycling enable to the motor.
 *    Alerts are cleared by clearing the ClearCore alert register directly.
 *
 * Parameters:
 *    requires "motor" to be defined as a ClearCore motor connector
 *
 * Returns: 
 *    none
 */
void HandleAlerts() {
  if (motor0.AlertReg().bit.MotorFaulted) {
    // if a motor fault is present, clear it by cycling enable
    //Diag_ComPort.println("Faults present. Cycling enable signal to motor to clear faults.");
    if (motor0.StatusReg().bit.Enabled) {
      motor0.EnableRequest(false);
      Delay_ms(10);
      motor0.EnableRequest(true);
    }
  }
  // clear alerts
  //Diag_ComPort.println("Clearing alerts.");
  motor0.ClearAlerts();
}
//------------------------------------------------------------------------------
