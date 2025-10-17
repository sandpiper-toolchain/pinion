#include <SPI.h>
#include <SD.h>

File myFile;
File root;
File entry;

String command_buffer;
String Topic_buffer;
String Value_buffer;


const size_t FILE_BUFFER_SIZE = 256;
char fileBuffer[FILE_BUFFER_SIZE];
size_t file_bufferIndex = 0;
size_t ii = 0;

void list_files() {
  if (!SD.begin()) {
    Diag_ComPort.println("SD Card didn't initialize properly. Bummer.");
  } else {
    SD_files = "";
    root = SD.open("/");
    while (true) {
      entry = root.openNextFile();
      if (!entry) {
        break;
      }
      //Diag_ComPort.println(entry.name());
      SD_files = SD_files + entry.name() + "\t";
      // SD_files.toLowerCase();
      ii++;
      entry.close();
    }
  }
  if (verbose) {
    Diag_ComPort.println(SD_files);
  }
}

void run_program_from_SD(String filename) {
  if (!SD.begin()) {
    Diag_ComPort.println("SD Card didn't initialize properly. Bummer Dude.");
  } else {
    myFile = SD.open(filename);  // filename can only be 8 characters long.  File extension can only be 3 characters.
    Diag_ComPort.print("Opening SD Card File: ");
    Diag_ComPort.println(filename);

    if (myFile) {
      while (myFile.available()) {
        int nextbyte = myFile.read();
        // Diag_ComPort.println(nextbyte);
        if (nextbyte == 44 || nextbyte == 125) { // char(54) = , (comma) char(125) is closed curly brace }
          Diag_ComPort.println("Reached a comma or close brace.");
          Diag_ComPort.println(char(nextbyte));
          fileBuffer[file_bufferIndex++] = '\0';
          file_bufferIndex = 0;
          Diag_ComPort.println(fileBuffer);
          // Value_buffer.replace("}","").replace("{","");
          command_buffer = fileBuffer;
          command_buffer.replace("\"","");
          command_buffer.replace("{","");
          Topic_buffer = command_buffer.substring(0,command_buffer.indexOf(':'));
          Value_buffer = command_buffer.substring(command_buffer.indexOf(':')+1);

          Diag_ComPort.print("Topic: ");
          Diag_ComPort.println(Topic_buffer);
          Diag_ComPort.print("Value: ");
          Diag_ComPort.println(Value_buffer);

          ProcessMQTTCommand(Topic_buffer,Value_buffer);

   
        } else {
          if (file_bufferIndex < FILE_BUFFER_SIZE - 1) {
            fileBuffer[file_bufferIndex++] = (char)nextbyte;
          } else {
            Diag_ComPort.println("Error: Command too long. Buffer cleared.");
            file_bufferIndex = 0;  // Clear the buffer on overflow
        }
        }
      }
    } else {
      Diag_ComPort.println("Unable to Open file on SD Card.");
    }
}
}

// void run_program_from_SD(String filename) {
//   if (!SD.begin()) {
//     Diag_ComPort.println("SD Card didn't initialize properly. Bummer.");

//   } else {
//     myFile = SD.open(filename);  // filename can only be 8 characters long.  File extension can only be 3 characters.

//     if (myFile) {
//       while (myFile.available()) {
//         int nextbyte = myFile.read();
//         if (nextbyte == char(13) || nextbyte == char(10) || nextbyte == char(58)) {
//           fileBuffer[file_bufferIndex] = '\0';
//           //Diag_ComPort.println(fileBuffer);
//           processCommand(fileBuffer);
//           file_bufferIndex = 0;
//         } else {
//           if (file_bufferIndex < BUFFER_SIZE - 1) {
//             fileBuffer[file_bufferIndex++] = (char)nextbyte;
//           } else {
//             Diag_ComPort.println("Error: Command too long. Buffer cleared.");
//             file_bufferIndex = 0;  // Clear the buffer on overflow
//           }
//         }
//       }

//       myFile.close();
//       //float value = atof(fileBuffer);

//       file_bufferIndex = 0;

//     } else {
//       Diag_ComPort.println("Error reading Steps_per_mm from SD Card.");
//     }
//   }
// }

void delete_file(String filename) {
  if (!SD.begin()) {
    Diag_ComPort.println("SD Card didn't initialize properly. Bummer.");

  } else {
    SD.remove(filename);
  }
}

void append_to_file(String filename, String text_to_append) {
  // check if SD is initialized:
  if (!SD.begin()) {
    Diag_ComPort.println("SD Card didn't initialize properly. Bummer.");

  } else {
    myFile = SD.open(filename, FILE_WRITE);  // filename can only be 8 characters long.  File extension can only be 3 characters.

    if (myFile) {
      myFile.print(text_to_append);
      myFile.close();
    } else {
      Diag_ComPort.println("Error writing to SD Card.");
    }
  }
}

void write_value_to_SD(String filename, float value) {

  // check if SD is initialized:
  if (!SD.begin()) {
    Diag_ComPort.println("SD Card didn't initialize properly. Bummer.");

  } else {
    SD.remove(filename);                     // delete the file if it already exists.  We don't want to append, just write the latest value so that its saved in non-volatile memory.
    myFile = SD.open(filename, FILE_WRITE);  // filename can only be 8 characters long.  File extension can only be 3 characters.

    if (myFile) {
      myFile.println(value);
      myFile.close();
    } else {
      Diag_ComPort.println("Error writing new Steps_per_mm to SD Card.");
    }
  }
}

void write_String_to_SD(String filename, String string) {

  // check if SD is initialized:
  if (!SD.begin()) {
    Diag_ComPort.println("SD Card didn't initialize properly. Bummer.");

  } else {
    SD.remove(filename);                     // delete the file if it already exists.  We don't want to append, just write the latest value so that its saved in non-volatile memory.
    myFile = SD.open(filename, FILE_WRITE);  // filename can only be 8 characters long.  File extension can only be 3 characters.

    if (myFile) {
      myFile.println(string);
      myFile.close();
    } else {
      Diag_ComPort.println("Error writing new Steps_per_mm to SD Card.");
    }
  }
}

// float read_value_from_SD(String filename) {

//   // check if SD is initialized:
//   if (!SD.begin()) {
//     Diag_ComPort.println("SD Card didn't initialize properly. Bummer.");

//   } else {
//     myFile = SD.open(filename);  // filename can only be 8 characters long.  File extension can only be 3 characters.

//     if (myFile) {
//       while (myFile.available()) {
//         int nextbyte = myFile.read();
//         if (file_bufferIndex < BUFFER_SIZE - 1) {
//           fileBuffer[file_bufferIndex++] = (char)nextbyte;
//         } else {
//           Diag_ComPort.println("Error: Command too long. Buffer cleared.");
//           file_bufferIndex = 0;  // Clear the buffer on overflow
//         }
//       }
//       fileBuffer[file_bufferIndex] = '\0';
//       myFile.close();
//       float value = atof(fileBuffer);

//       file_bufferIndex = 0;
//       return value;
//     } else {
//       Diag_ComPort.println("Error reading Steps_per_mm from SD Card.");
//       return -1;
//     }
//   }
// }
