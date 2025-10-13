int position_commanded;
String vars1 = "Default Name";
float new_position_ref;

void print_EOT() {
  for (int i; i < 3; i++) {
    if (EOT[i]!= 0) {
      ComPort.write(EOT[i]);
    }
  }
  // ComPort.print("> ");

}

void processCommand(String command) {
  String command_unmodified = command;
  command.toLowerCase();      // convert all characters to lower case so that commands are not case sensitive.
  // if (command.substring(0, 5) != "write" && command.substring(0, 4) != "vars" && command.substring(0, 6) != "wrvars") {  // If the command is WRVARS or WRITE we don't want to remove the spaces or other characters.
  command.replace(" ", "");   // remove any spaces in the command
  command.replace("\n", "");  // remove new line character
  command.replace("\r", "");  //  remove carriage return character
  command.replace("\t", "");  // remove tab character
  command.replace(":", "");   // remove colon character
  command.replace("!","");  // this program doesn't do anything different with commands that start with "!"
  int comment_start = command.indexOf(';');
  if (comment_start != -1) {
    // ComPort.println("Command contains a comment!");
    command = command.substring(0, comment_start);
  }
  // }

  if (verbose) {
    ComPort.print("Command Received:");
    ComPort.println(command);
  }

  if (programming_mode && command != "end") {  // check if the controller is currently in programming mode.
    // ComPort.println("Writing all commands to SD card instead of executing")
    if (verbose) {
      ComPort.print("Writing to file: " + command);
    }
    append_to_file(program_filename, command);
    ComPort.println();
    ComPort.print("- ");

  } else if (command == "end") {  // if the recieved command is "end", exit programming mode.
    programming_mode = false;
    list_files();  // update the list of files that are on the SD card
    ComPort.println();
    ComPort.print("> ");


  } else if (!programming_mode && command.substring(0, 3) == "def") {  // if the received command is "def" enter programming mode.
    programming_mode = true;
    program_filename = command.substring(3) + ".PRG";
    //ComPort.println("Creating Program File: " + program_filename);
    ComPort.println();
    ComPort.print("> ");

  } else if (!programming_mode) {          // if we're not in programming mode, process the received command.
    if (command.substring(0, 1) == ";") {  //This line is a commment.  Ignore it.
      if (verbose) {
        ComPort.println("Comment: " + command_unmodified);
      }
    } else if (command.substring(0,6) == "drive1") {
      motor0.EnableRequest(true);
      print_EOT();

    } else if (command.substring(0,6) == "drive0") {
      motor0.EnableRequest(false);
      print_EOT();

    } else if (command.substring(0, 1) == "d" && !isLetters(command.substring(1, 2)) && command.substring(1) != 0) {
      position_commanded = Scale_mm_to_Steps(command.substring(1).toFloat());
      if (verbose) {
        ComPort.print("Position Commanded:");
        ComPort.println(position_commanded);
      } else {
        ComPort.println();
        ComPort.print("> ");
      }
    } else if (command.substring(0, 1) == "d" && command.substring(1) == 0) {
      ComPort.println(Scale_Steps_to_mm(position_commanded));
      ComPort.print(">");

    } else if (command == "pos") {
      ComPort.print("Current Commanded Position: ");
      ComPort.println(motor0.PositionRefCommanded());

    } else if (command == "tpm" || command == "!tpm") {
      ComPort.print("*TPM");
      if (motor0.PositionRefCommanded() >= 0) {
        ComPort.print("+");
      }
      ComPort.print(Scale_Steps_to_mm(motor0.PositionRefCommanded()));
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "go") {
      Move(position_commanded);
      if (verbose) {
        ComPort.print("Moving to Postion (steps): ");
        ComPort.println(position_commanded);
      } else {
        ComPort.println();
        ComPort.print("> ");
      }

    } else if (command == "s" || command == "!s") {
      motor0.MoveStopAbrupt();
      ComPort.println();
      ComPort.print("> ");

    } else if (command.substring(0, 4) == "scld" && command.substring(4) != 0) {
      SCLD = command.substring(4).toFloat();
      if (verbose) {
        ComPort.print("New SCLD value (steps/mm): ");
        ComPort.println(SCLD);
      }
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "scld") {
      if (verbose) {
        ComPort.print("Steps per mm: ");
        ComPort.println(SCLD);
      } else {
        ComPort.println(SCLD);
        ComPort.print("> ");
      }


    } else if (command.substring(0, 4) == "sclv" && command.substring(4) != 0) {
      SCLV = command.substring(4).toFloat();
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "sclv") {
      ComPort.println(SCLV);
      ComPort.print("> ");

    } else if (command.substring(0, 4) == "scla" && command.substring(4) != 0) {
      SCLA = command.substring(4).toFloat();
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "scla") {
      ComPort.println(SCLA);
      ComPort.print("> ");

    } else if (command.substring(0, 1) == "v" && command.substring(1).toFloat() != 0) {
      velocityLimit = Scale_Vel_mm_to_Steps(command.substring(1).toFloat());
      motor0.VelMax(velocityLimit);
      if (verbose) {
        ComPort.print("New Velocity Limit (steps/sec): ");
        ComPort.println(velocityLimit);
      }
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "v") {
      if (verbose) {
        ComPort.print("Current Velocity Limit: ");
        ComPort.println(Scale_Vel_Steps_to_mm(velocityLimit));
      } else {
        ComPort.println(Scale_Vel_Steps_to_mm(velocityLimit));
        ComPort.print("> ");
      }

    } else if (command.substring(0, 1) == "a" && command.substring(1) != 0 && !isLetters(command.substring(1, 2))) {
      accelerationLimit = Scale_Accel_mm_to_Steps(command.substring(1).toFloat());
      motor0.AccelMax(accelerationLimit);
      if (verbose) {
        ComPort.print("Accel Limit Set to: ");
        ComPort.println(accelerationLimit);
      }
      print_EOT();

    } else if (command == "enc_pos") {
      position = EncoderIn.Position();
      velocity = EncoderIn.Velocity();
      indexPosition = EncoderIn.IndexPosition();
      quadratureError = EncoderIn.QuadratureError();

      ComPort.print("Encoder Counts: ");
      ComPort.println(position);

    } else if (command == "a") {
      ComPort.println(Scale_Accel_Steps_to_mm(accelerationLimit));
      ComPort.print("> ");

    } else if (command.substring(0, 6) == "vars1=") {
      vars1 = command_unmodified.substring(6);
      if (verbose) {
        ComPort.print("vars1: ");
        ComPort.println(vars1);
      }
      ComPort.println();
      ComPort.print("> ");

    } else if (command.substring(0, 4) == "pset" && !isLetters(command.substring(4))) {
      new_position_ref = command.substring(4).toFloat();
      motor0.PositionRefSet(Scale_mm_to_Steps(new_position_ref));
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "echo0") {
      ECHO = false;
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "echo1") {
      ECHO = true;
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "verbose1") {
      verbose = true;
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "verbose0") {
      verbose = false;
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "scale1") {
      SCALE = true;
      ComPort.println();
      ComPort.print("> ");
    } else if (command == "scale0") {
      SCALE = false;
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "enc1") {
      ENC = true;
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "enc0") {
      ENC = false;
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "ma0") {
      MA = false;  // set movement mode to relative positioning.
      ComPort.println();
      ComPort.print("> ");
    } else if (command == "ma1") {
      MA = true;  // set movement mode to absolute positionig.
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "wrvars1") {
      ComPort.println(vars1);
      ComPort.print("> ");

    } else if (command.substring(0, 5) == "write") {
      ComPort.println(command_unmodified.substring(5));
      ComPort.print("> ");

    } else if (command == "tas") {
      ComPort.print("*TAS");                                     // Transfer Axis Status
      ComPort.print(moving_state);                                     // Moving/NotMoving
      ComPort.print(motor0.StatusReg().bit.MoveDirection);       // Move Direction
      if (moving_state && !motor0.StatusReg().bit.AtTargetVelocity) {  // Accelerating
        ComPort.print("1");
      } else {
        ComPort.print("0");
      }
      ComPort.print(motor0.StatusReg().bit.AtTargetVelocity);  // At Velocity
      ComPort.print("_");
      ComPort.print(homed);                                   // Home Successful
      ComPort.print(MA);                                      // Absolute/incremental
      ComPort.print(!motor0.StatusReg().bit.PositionalMove);  // Continuous/Preset (MC)
      ComPort.print(jog_mode);                                // Jog Mode/Not Jog Mode
      ComPort.print("_");
      ComPort.print("0");  // Joystick mode (not implemented in Teknic)
      ComPort.print(ENC);  // Encoder Step Mode (ENC0 or ENC1)
      ComPort.print("0");  // Position Maintenance (not implemented in Teknic
      ComPort.print("0");  // Stall Detected (Yes/NO) ESTALL
      ComPort.print("_");
      ComPort.print(!motor0.EnableRequest());                 // Drive ShutDown
      ComPort.print(motor0.StatusReg().bit.MotorInFault);     // Drive Fault Occured
      ComPort.print(motor0.StatusReg().bit.InPositiveLimit);  // Positive-Direction Hardware limit hit
      ComPort.print(motor0.StatusReg().bit.InNegativeLimit);  // Negative-Direction Hardware limit hit
      ComPort.print("_");
      ComPort.print(motor0.StatusReg().bit.InPositiveLimit);   // Positive-Direction Software limit hit (assuming hardware limits = software limits in Teknic)
      ComPort.print(motor0.StatusReg().bit.InNegativeLimit);   // Negative-Direction Hardware limit hit (assuming hardware limits = software limits in Teknic)
      ComPort.print(motor0.StatusReg().bit.AtTargetPosition);  // Within DeadBand
      ComPort.print(motor0.StatusReg().bit.AtTargetPosition);  // In Position
      ComPort.print("_");
      ComPort.print("0");                                      // distance streaming mode.  Not implemented in Teknic
      ComPort.print("0");                                      // velocity streaming mode.  Not implemented in Teknic
      ComPort.print("0");                                      // Position error exceeded (SMPER). Not implemented in Teknic
      ComPort.print(motor0.StatusReg().bit.AtTargetPosition);  // In target Zone (STRGTD & STRGTV)
      ComPort.print("_");
      ComPort.print("0");  // Target Zone Timeout Occured (not implemented in Teknic)
      ComPort.print("0");  // Motion Suspended pending GoWhen
      ComPort.print("0");  // LDT position read error
      ComPort.print("0");  // REgistration move initiated by trigger since last GO command
      ComPort.print("_");
      ComPort.print("0");  // RESERVED
      ComPort.print("0");  // Pre-emptive (OTF) GO or Registration profile not possible.
      ComPort.print("0");  // RESERVED
      ComPort.print("0");  // RESERVED
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "") {
    
      //ComPort.println("Empty Command Recieved.");
      // ComPort.println();
      // ComPort.print("> ");

    } else if (command.substring(0, 3) == "del") {
      String program_name = command.substring(3) + ".PRG";
      delete_file(program_name);
      ComPort.println();
      ComPort.print("> ");

    } else if (command == "status") {
      ComPort.print(motor0.StatusReg().bit.AtTargetPosition);
      ComPort.print(",");
      ComPort.print(motor0.StatusReg().bit.StepsActive);
      ComPort.print(",");
      ComPort.print(motor0.StatusReg().bit.AtTargetVelocity);
      ComPort.print(",");
      ComPort.print(motor0.StatusReg().bit.MoveDirection);
      ComPort.print(",");
      ComPort.print(motor0.StatusReg().bit.MotorInFault);
      ComPort.print(",");
      ComPort.print(motor0.StatusReg().bit.Enabled);
      ComPort.print(",");
      ComPort.print(motor0.StatusReg().bit.PositionalMove);
      ComPort.print(",");
      ComPort.print(motor0.StatusReg().bit.HlfbState);
      ComPort.print(",");
      ComPort.print(motor0.StatusReg().bit.AlertsPresent);
      ComPort.print(",");
      ComPort.print(motor0.StatusReg().bit.ReadyState);
      ComPort.print(",");
      ComPort.print(motor0.StatusReg().bit.Triggering);
      ComPort.print(",");
      ComPort.print(motor0.StatusReg().bit.InPositiveLimit);
      ComPort.print(",");
      ComPort.print(motor0.StatusReg().bit.InNegativeLimit);
      ComPort.print(",");
      ComPort.print(motor0.StatusReg().bit.InEStopSensor);
      ComPort.print(",");
      ComPort.print(Scale_Vel_Steps_to_mm(velocityLimit));
      ComPort.print(",");
      ComPort.print(motor0.AlertReg().bit.MotionCanceledInAlert);
      ComPort.print(",");
      ComPort.print(motor0.AlertReg().bit.MotionCanceledPositiveLimit);
      ComPort.print(",");
      ComPort.print(motor0.AlertReg().bit.MotionCanceledNegativeLimit);
      ComPort.print(",");
      ComPort.print(motor0.AlertReg().bit.MotionCanceledSensorEStop);
      ComPort.print(",");
      ComPort.print(motor0.AlertReg().bit.MotionCanceledMotorDisabled);
      ComPort.print(",");
      ComPort.print(motor0.AlertReg().bit.MotorFaulted);
      ComPort.print(",");
      ComPort.print(ConnectorIO0.State());
      ComPort.print(",");
      ComPort.print(ConnectorIO1.State());
      ComPort.print(",");
      ComPort.print(Scale_Steps_to_mm(motor0.PositionRefCommanded()));
      ComPort.print(",");
      ComPort.println(ConnectorA12.AnalogVoltage());

    } else if (command.substring(0, 6) == "digout") {
      if (command.substring(6, 7) == "0") {
        ConnectorIO0.State(command.substring(7).toInt());
      } else if (command.substring(6, 7) == "1") {
        ConnectorIO1.State(command.substring(7).toInt());
      }

      ComPort.println("> ");

    } else if (command == "clear") {
      HandleAlerts();

    } else if (command.substring(0, 3) == "jog") {
      VelocityMove(Scale_Vel_mm_to_Steps(command.substring(3).toFloat()));

    } else if (command == "ls") {
      list_files();

    } else if (command.substring(0, 6) == "dwavef") {
      if (verbose) {
        ComPort.println("Command Not Implemented: " + command);
      }
      ComPort.println();
      ComPort.print("> ");

    } else if (command.substring(0, 6) == "dautos") {
      if (verbose) {
        ComPort.println("Command Not Implemented: " + command);
      }
      ComPort.println();
      ComPort.print("> ");

    } else if (command.substring(0, 6) == "dautos") {
      if (verbose) {
        ComPort.println("Command Not Implemented: " + command);
      }
      ComPort.println();
      ComPort.print("> ");

    } else if (command.substring(0, 4) == "dres") {
      if (verbose) {
        ComPort.println("Command Not Implemented: " + command);
      }
      print_EOT();

    } else if (command.substring(0, 6) == "encpol") {
      if (verbose) {
        ComPort.println("Command Not Implemented: " + command);
      }
      ComPort.println();
      ComPort.print("> ");

    } else if (command.substring(0, 4) == "eres") {
      if (verbose) {
        ComPort.println("Command Not Implemented: " + command);
      }
      ComPort.println();
      ComPort.print("> ");

    } else if (command.substring(0, 2) == "lh") {
      if (verbose) {
        ComPort.println("Command Not Implemented: " + command);
      }
      ComPort.println();
      ComPort.print("> ");

    } else if (command.substring(0, 5) == "lhlvl") {
      if (verbose) {
        ComPort.println("Command Not Implemented: " + command);
      }
      ComPort.println();
      ComPort.print("> ");

    } else if (command.substring(0, 4) == "lhad") {
      if (verbose) {
        ComPort.println("Command Not Implemented: " + command);
      }
      ComPort.println();
      ComPort.print("> ");
    } else if (command.substring(0, 6) == "estall") {
      if (verbose) {
        ComPort.println("Command Not Implemented: " + command);
      }
      ComPort.println();
      ComPort.print("> ");

    } else if (command.substring(0, 4) == "esdb") {
      if (verbose) {
        ComPort.println("Command Not Implemented: " + command);
      }
      ComPort.println();
      ComPort.print("> ");

    } else if (command.substring(0, 3) == "esk") {
      if (verbose) {
        ComPort.println("Command Not Implemented: " + command);
      }
      ComPort.println();
      ComPort.print("> ");

    } else if (command.substring(0, 2) == "ad"|| command.substring(0,3)=="!ad") {
      accelerationLimit = Scale_Accel_mm_to_Steps(command.substring(3).toFloat());
      // motor0.AccelMax(Scale_Accel_Steps_to_mm(accelerationLimit));
      // ComPort.print(accelerationLimit);
      print_EOT();

    } else if (command.substring(0,3) == "eot" ) {
      String eot_string = command.substring(3);
      int indx_first_comma = eot_string.indexOf(',');
      int indx_last_comma  = eot_string.lastIndexOf(',');
      EOT[0] = eot_string.substring(0,indx_first_comma).toInt();
      EOT[1] = eot_string.substring(indx_first_comma+1,indx_last_comma).toInt();
      EOT[2] = eot_string.substring(indx_last_comma+1).toInt();
      // print_EOT();
      ComPort.println("");

    } else if (command=="tlim") {
      ComPort.print("*TLIM");
      int PosLim = -(motor0.StatusReg().bit.InPositiveLimit-1); // switch the sign.  I guess Teknic and Zeta use opposite notation for limit hit.
      int NegLim = -(motor0.StatusReg().bit.InNegativeLimit-1);
      ComPort.print(PosLim);
      ComPort.print(NegLim);
      ComPort.print("0"); // we don't use a homing switch so make this 0 all the time. 
      print_EOT();
    
    } else if (command=="startpwakeup") {
      print_EOT();

    } else if (command == "out.1-1" || command == "!out.1-1") {
      digitalWrite(IO4,true);
      print_EOT();

    } else if (command == "out.1-0" || command == "!out.1-0") {
      digitalWrite(IO4,false);
      print_EOT();
      
    } else if (command == "out.2-0" || command == "!out.2-0") {
      digitalWrite(IO5,false);
      print_EOT();

    } else if (command == "out.2-1"|| command == "!out.2-1") {
      digitalWrite(IO5,true);
      print_EOT();
      

    } else if (command == "test") {  // a place for Milliren to test out different things.
      ComPort.println("Printing EOT Characters:");
      for (int i =0; i<3; i++) {
        ComPort.write(EOT[i]);
      }

    } else if (command == "raisetolimit") {
      ComPort.println("Raising Motor to upper limit switch");
      motor0.MoveVelocity(Scale_Vel_mm_to_Steps(2));

    } else if (command == "xg") {
      XG();

    } else if (command == "xb") {
      XB();

    } else if (SD_files.indexOf(command) > 0) {  // Check if the command is one of the programs on the SD card. This should be the last thing we check before the else UNDEFINED Label
      command.toUpperCase();
      //ComPort.println("Command is a program on the SD Card!");
      run_program_from_SD(command + ".PRG");

    } else {
      ComPort.print("*UNDEFINED LABEL:");
      ComPort.println(command);
      ComPort.println("?");
    }
  }
}

bool isLetters(String str) {
  bool is_letters = true;
  if (str.length() > 0) {
    for (int i = 0; i < str.length(); i++) {
      is_letters = is_letters * isAlpha(str.charAt(i));
    }
  } else {
    is_letters = false;
  }

  return is_letters;
}