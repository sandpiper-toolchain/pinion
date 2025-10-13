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
  ComPort.println("Alerts present: ");
  if (motor0.AlertReg().bit.MotionCanceledInAlert) {
    ComPort.println("    MotionCanceledInAlert ");
  }
  if (motor0.AlertReg().bit.MotionCanceledPositiveLimit) {
    ComPort.println("    MotionCanceledPositiveLimit ");
  }
  if (motor0.AlertReg().bit.MotionCanceledNegativeLimit) {
    ComPort.println("    MotionCanceledNegativeLimit ");
  }
  if (motor0.AlertReg().bit.MotionCanceledSensorEStop) {
    ComPort.println("    MotionCanceledSensorEStop ");
  }
  if (motor0.AlertReg().bit.MotionCanceledMotorDisabled) {
    ComPort.println("    MotionCanceledMotorDisabled ");
  }
  if (motor0.AlertReg().bit.MotorFaulted) {
    ComPort.println("    MotorFaulted ");
  }
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
    //ComPort.println("Faults present. Cycling enable signal to motor to clear faults.");
    if (motor0.StatusReg().bit.Enabled) {
      motor0.EnableRequest(false);
      Delay_ms(10);
      motor0.EnableRequest(true);
    }
  }
  // clear alerts
  //ComPort.println("Clearing alerts.");
  motor0.ClearAlerts();
}
//------------------------------------------------------------------------------
