float new_position_ref;
int position_commanded_steps;
float position_commanded_mm;

void ProcessMQTTCommand(String Topic, String Value) {
  Diag_ComPort.print("Topic: ");
  Diag_ComPort.println(Topic);
  Diag_ComPort.print("Value: ");
  Diag_ComPort.println(Value);

  // Diag_ComPort.println(Topic.substring(Topic.indexOf('/')+1));

  Value.replace(" ", "");  // Remove any spaces that might be in the value string.
  if (programming_mode && Topic != "Commands/EndProgram") {
    list_files();
    if (SD_files.indexOf(program_filename) > 0) {
      append_to_file(program_filename, ",");
    } else {
      append_to_file(program_filename, "{");
    }
    append_to_file(program_filename, "\"");
    append_to_file(program_filename, Topic);
    append_to_file(program_filename, "\":");
    append_to_file(program_filename, Value);
    //Programming mode.  Write files to a JSON file on the SD card instead of executing this commands.
    Diag_ComPort.println("Writing Commands to SD Card");
  } else if (Topic == "Commands/BeginProgram" && !programming_mode) {
    programming_mode = true;
    program_filename = Value + ".JSN";
    delete_file(program_filename);
  } else if (Topic == "Commands/EndProgram") {
    append_to_file(program_filename, "}");
    programming_mode = false;
    list_files();
  } else if (Topic == "Commands/Enable") {
    if (Value == "1" || Value == "True" || Value == "true") {
      motor0.EnableRequest(true);
      Diag_ComPort.println("Motor Enabled!");
    } else if (Value == "0" || Value == "False" || Value == "false") {
      motor0.EnableRequest(false);
    } else {
      motor0.EnableRequest(true);
    }

  } else if (Topic == "Commands/Disable") {
    motor0.EnableRequest(false);

  } else if (Topic == "Commands/SetAbsolutePosition") {
    Diag_ComPort.println(Value);
    new_position_ref = Value.toFloat();
    motor0.PositionRefSet(Scale_mm_to_Steps(new_position_ref));

  } else if (Topic == "Commands/SetVelocity") {
    velocityLimit = Scale_Vel_mm_to_Steps(Value.toFloat());
    motor0.VelMax(velocityLimit);

  } else if (Topic == "Commands/MoveToAbsolutePosition") {
    MA = true;  // Move absolute = True
    position_commanded_mm = Value.toFloat();
    position_commanded_steps = Scale_mm_to_Steps(position_commanded_mm);
    Move(position_commanded_steps);
  } else if (Topic == "Commands/RelativeMove") {
    MA = false;  // Move absolute = False
    position_commanded_mm = Value.toFloat();
    position_commanded_steps = Scale_mm_to_Steps(position_commanded_mm);
    Move(position_commanded_steps);
  } else if (Topic == "Commands/Jog") {
    VelocityMove(Scale_Vel_mm_to_Steps(Value.toFloat()));
  } else if (Topic == "Commands/StopMotion") {
    // The Value doesn't matter in this case.  If this message is sent through, no matter what the payload is it will stop motion.
    motor0.MoveStopAbrupt();

  } else if (Topic == "Commands/ClearFaults") {
    HandleAlerts();

  } else if (Topic == "Commands/SetOutputIO/ConnectorIO_0") {
    if (Value == "1" || Value == "True" || Value == "true") {
      ConnectorIO0.State(true);
    } else {
      ConnectorIO0.State(false);
    }
  } else if (Topic == "Commands/SetOutputIO/ConnectorIO_1") {
    if (Value == "1" || Value == "True" || Value == "true") {
      ConnectorIO1.State(true);
    } else {
      ConnectorIO1.State(false);
    }
  } else if (Topic == "Commands/ListSDFiles") {
    Diag_ComPort.print("List of Files on SD Card: ");
    Diag_ComPort.println(SD_files);
    // publish_mqtt_message_str("Commands/ListSDFiles",SD_files);

  } else if (SD_files.indexOf(Topic.substring(Topic.indexOf('/')+1)) > 0) { // Check if the command is the name of a program on the SD card.
    Diag_ComPort.println("Command is the name of a program on the SD card!");
    run_program_from_SD(Topic.substring(Topic.indexOf('/')+1)+".JSN");
  
  } else {
    Diag_ComPort.print("Undefined Command with Topic: ");
    Diag_ComPort.println(Topic);

  }
}