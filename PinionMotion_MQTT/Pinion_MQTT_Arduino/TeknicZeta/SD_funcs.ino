#include <SPI.h>
#include <SD.h>

File myFile;
File root;
File entry;

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
      SD_files.toLowerCase();
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

    if (myFile) {
      while (myFile.available()) {
        int nextbyte = myFile.read();
        if (nextbyte == char(58)) { // char(58) = : (colon)
          fileBuffer[file_bufferIndex] = '\0';
          file_bufferIndex = 0;
          Diag_ComPort.println(fileBuffer);
          Topic_buffer = fileBuffer; // If we just made it to a colon, then we have finished reading the Topic from the file. 
        } else if (nextbyte == char(54)) { // char(54) = , (comma)
          fileBuffer[file_bufferIndex] = '\0';
          file_bufferIndex = 0;
          Diag_ComPort.println(fileBuffer);
          Value_buffer = fileBuffer;
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
