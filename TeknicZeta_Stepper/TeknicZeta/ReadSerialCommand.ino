const size_t BUFFER_SIZE = 256;
char serialBuffer[BUFFER_SIZE];
size_t bufferIndex = 0;

void ReadSerial_and_Process() {
  if (ComPort.peek() != -1) {           // Check if a character was received
    int incomingChar = ComPort.read();  // Non-blocking call
    if (ECHO) {
      ComPort.print((char)incomingChar);
    }
    //SerialPort0.SendLine(incomingChar);
    if (incomingChar == 13 || incomingChar == 58) {  // 13=carriage return, 10=line feed, 58 = : (colon)
      serialBuffer[bufferIndex] = '\0';    // Null-terminate the string
      if (ECHO) {
        ComPort.println("");
      }
      processCommand(serialBuffer);  // Process the command
      bufferIndex = 0;                     // Reset the buffer index for the next command
    } else {
      // Add character to buffer if there's space
      if (bufferIndex < BUFFER_SIZE - 1) {
        serialBuffer[bufferIndex++] = (char)incomingChar;
      } else {
        ComPort.println("Error: Command too long. Buffer cleared.");
        bufferIndex = 0;  // Clear the buffer on overflow
      }
    }
  }
}