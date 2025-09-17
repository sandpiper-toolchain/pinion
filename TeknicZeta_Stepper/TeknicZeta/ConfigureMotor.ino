// Variables to store encoder state
int32_t position = 0;
int32_t velocity = 0;
int32_t indexPosition = 0;
int32_t lastIndexPosition = 0;
bool quadratureError = false;

void ConfigureMotor() {
  // Sets the input clocking rate. This normal rate is ideal for ClearPath
  // step and direction applications.
  MotorMgr.MotorInputClocking(MotorManager::CLOCK_RATE_LOW);

  // Sets all motor connectors into step and direction mode.
  MotorMgr.MotorModeSet(MotorManager::MOTOR_ALL,
                        Connector::CPM_MODE_STEP_AND_DIR);

  // Set the motor's HLFB mode to bipolar PWM
  // motor0.HlfbMode(MotorDriver::HLFB_MODE_HAS_BIPOLAR_PWM);
  // motor0.HlfbMode(MotorDriver::HLFB_MODE_STATIC);
  // Set the HFLB carrier frequency to 482 Hz
  // motor0.HlfbCarrier(MotorDriver::HLFB_CARRIER_482_HZ);

  // Invert the Enable Input
  motor0.PolarityInvertSDEnable(true);
  motor0.PolarityInvertSDDirection(true);
  // motor0.PolarityInvertSDHlfb(true);

  // Sets the maximum velocity for each move
  motor0.VelMax(velocityLimit);

  // Set the maximum acceleration for each move
  motor0.AccelMax(accelerationLimit);

  // Set the Estop buttom
  motor0.EStopConnector(CLEARCORE_PIN_IO2);

   // Set Estop Decel
  motor0.EStopDecelMax(128000);

  // Set up Limit Switches
  motor0.LimitSwitchPos(CLEARCORE_PIN_IO0);
  motor0.LimitSwitchNeg(CLEARCORE_PIN_IO1);

  // Configure IO ports for Relay controls
  ConnectorIO4.Mode(Connector::OUTPUT_DIGITAL);
  ConnectorIO5.Mode(Connector::OUTPUT_DIGITAL);

  // Configure Analog Input Channels for Measurement
  ConnectorA12.Mode(Connector::INPUT_ANALOG);

  // Configure Encoder Input
  EncoderIn.Enable(true);
  EncoderIn.Position(0);
  

}
