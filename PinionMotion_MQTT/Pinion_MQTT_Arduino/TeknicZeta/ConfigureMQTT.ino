
void configure_MQTT() {

  // Configure with an IP address assigned via DHCP
  if (usingDhcp) {
    // Use DHCP to configure the local IP address
    bool dhcpSuccess = Ethernet.begin(mac);
    if (dhcpSuccess) {
      // Diag_ComPort.print("DHCP successfully assigned an IP address: ");
      // Diag_ComPort.println(Ethernet.localIP());
    } else {
      // Diag_ComPort.println("DHCP configuration was unsuccessful!");
      while (true) {
        // TCP will not work without a configured IP address
        continue;
      }
    }
  } else {
    // Configure with a manually assigned IP address
    // ClearCore MAC address
    byte mac[] = {0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED};
    //  ClearCore IP address:
    IPAddress ip(192, 168, 0, 103);

    // Set ClearCore's IP address
    Ethernet.begin(mac, ip);
    // Diag_ComPort.print("Assigned manual IP address: ");
    // Diag_ComPort.println(Ethernet.localIP());
    
    //Optionally, set additional network addresses if needed

    //IpAddress myDns = myDns(192, 168, 1, 1);
    //IpAddress gateway = gateway(192, 168, 1, 1);
    //IpAddress netmask = subnetress(255, 255, 255, 0);

    //Ehternet.begin(mac, ip, myDns, gateway, subnet);
  }
    // Attempt to connect to a server
    // Diag_ComPort.print("Attempting to connect to the MQTT broker: ");
    // Diag_ComPort.println(broker);

  if (!mqttClient.connect(broker, port)) {
    Diag_ComPort.print("MQTT connection failed! Error code = ");
    Diag_ComPort.println(mqttClient.connectError());

    while (1);
  }

  Diag_ComPort.println("You're connected to the MQTT broker!");
  Diag_ComPort.println();

  Diag_ComPort.print("Subscribing to topic: ");
  Diag_ComPort.println(sub_topic);
  Diag_ComPort.println();

  // set the message receive callback
  mqttClient.onMessage(onMqttMessage);

  // subscribe to a topic
  mqttClient.subscribe(sub_topic);
}


void onMqttMessage(int messageSize) {
  packetbufferIndex = 0;
    // we received a message, print out the topic and contents
    // Diag_ComPort.println("Received a message with topic '");
    Diag_ComPort.print(mqttClient.messageTopic());
    // Diag_ComPort.print("', length ");
    // Diag_ComPort.print(messageSize);
    // Diag_ComPort.println(" bytes:");

    // use the Stream interface to print the contents
    while (mqttClient.available()) {
      packetReceived[packetbufferIndex++] = (char)mqttClient.read();
      // Diag_ComPort.print((char)mqttClient.read());
    }
    packetReceived[packetbufferIndex] = '\0';
    Diag_ComPort.println(packetReceived);

    Diag_ComPort.println();
  }