/*------------------------------------------------------------------------------
 * MoveAbsolutePosition
 *
 *    Command step pulses to move the motor's current position to the absolute
 *    position specified by "position"
 *    Prints the move status to the USB serial port
 *    Returns when HLFB asserts (indicating the motor has reached the commanded
 *    position)
 *
 * Parameters:
 *    int position  - The absolute position, in step pulses, to move to
 *
 * Returns: True/False depending on whether the move was successfully triggered.
 */
bool Move(int position) {
  // Check if a motor alert is currently preventing motion
  // Clear alert if configured to do so
  if (!motor0.StatusReg().bit.Enabled) {
    Diag_ComPort.println("Motor is Not Enabled.  Move Canceled");
    publish_mqtt_message_str("Alerts/x_axis","Motor is Not Enabled.  Move Canceled");
  }
  else if (motor0.StatusReg().bit.AlertsPresent) {
    Diag_ComPort.println("Motor alert detected.");
    PrintAlerts();
    if (HANDLE_ALERTS) {
      HandleAlerts();
    } else {
      Diag_ComPort.println("Enable automatic alert handling by setting HANDLE_ALERTS to 1.");
    }
    Diag_ComPort.println("Move canceled.");
    Diag_ComPort.println();
    return false;
  }

  else {
    // Command the move of absolute distance
    if (MA) {
      motor0.Move(position, MotorDriver::MOVE_TARGET_ABSOLUTE); // if MA = true then we are in absolution positioning mode. 
    } else {
      motor0.Move(position); // if MA = false, then we're in relative positioning mode. 
    }
  }
  // Check if motor alert occurred during move
  // Clear alert if configured to do so
  if (motor0.StatusReg().bit.AlertsPresent) {
    Diag_ComPort.println("Motor alert detected.");
    PrintAlerts();
    if (HANDLE_ALERTS) {
      HandleAlerts();
    } else {
      Diag_ComPort.println("Enable automatic fault handling by setting HANDLE_ALERTS to 1.");
    }
    Diag_ComPort.println("Motion may not have completed as expected. Proceed with caution.");
    Diag_ComPort.println();
    return false;
  } else {
    // Diag_ComPort.println("Move Done");
    return true;
  }
}
//------------------------------------------------------------------------------

bool VelocityMove(int commanded_Vel) {
  // Check if a motor alert is currently preventing motion
  // Clear alert if configured to do so
  if (motor0.StatusReg().bit.AlertsPresent) {
    Diag_ComPort.println("Motor alert detected.");
    PrintAlerts();
    if (HANDLE_ALERTS) {
      HandleAlerts();
    } else {
      Diag_ComPort.println("Enable automatic alert handling by setting HANDLE_ALERTS to 1.");
    }
    Diag_ComPort.println("Move canceled.");
    Diag_ComPort.println();
    return false;
  }

  //Diag_ComPort.print("Moving to absolute position: ");
  //Diag_ComPort.println(position);

  // Command the move of absolute distance
  motor0.MoveVelocity(commanded_Vel);

  // Waits for HLFB to assert (signaling the move has successfully completed)
  //Diag_ComPort.println("Moving.. Waiting for HLFB");
  //while ( (!motor0.StepsComplete() || motor0.HlfbState() != MotorDriver::HLFB_ASSERTED) &&
  //	!motor0.StatusReg().bit.AlertsPresent) {
  //    continue;
  //}
  // Check if motor alert occurred during move
  // Clear alert if configured to do so
  if (motor0.StatusReg().bit.AlertsPresent) {
    Diag_ComPort.println("Motor alert detected.");
    PrintAlerts();
    if (HANDLE_ALERTS) {
      HandleAlerts();
    } else {
      Diag_ComPort.println("Enable automatic fault handling by setting HANDLE_ALERTS to 1.");
    }
    Diag_ComPort.println("Motion may not have completed as expected. Proceed with caution.");
    Diag_ComPort.println();
    return false;
  } else {
    // Diag_ComPort.println("Move Done");
    return true;
  }
}
//------------------------------------------------------------------------------

void ring_bell() {
  if (change_bell_state) {
    change_bell_state = false;
  }
  if (moving_state) {
    digitalWrite(IO5,bell_state);
  }
  else {
    digitalWrite(IO5,false);
  }
}
