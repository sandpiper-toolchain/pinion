
#include <SPI.h>
#include <Ethernet.h>
#include <ArduinoMqttClient.h>


// MAC address of the ClearCore
byte mac[] = {};

const char broker[] = "160.94.187.233";
int        port     = 1883;
const char pub_topic[]  = "arduino/simple";
const char sub_topic[]   = "test/topic";

const long interval = 100;
unsigned long previousMillis = 0;

int count = 0;

// The port number on the server over which packets will be sent/received
#define PORT_NUM 1883

// The maximum number of characters to receive from an incoming packet
#define MAX_PACKET_LENGTH 100
// Buffer for holding received packets.
unsigned char packetReceived[MAX_PACKET_LENGTH];

// Set usingDhcp to false to use user defined network settings
bool usingDhcp = true;

// Initialize a client object
// The ClearCore will operate as a TCP client using this object
EthernetClient client;

MqttClient mqttClient(client);
  
void setup(){
  // Set up serial communication between ClearCore and PC serial terminal
  Serial.begin(9600);
  uint32_t timeout = 5000;
    uint32_t startTime = millis();
    while (!Serial && millis() - startTime < timeout) {
        continue;
    }
  
  // Set connector IO0 as a digital output
  // When IO0 state is true, a LED will light on the
  // ClearCore indicating a successful connection to a server 
  pinMode(IO0, OUTPUT);

  // Make sure the physical link is active before continuing
  while (Ethernet.linkStatus() == LinkOFF) {
    Serial.println("The Ethernet cable is unplugged...");
    delay(1000);
  }
  
  // Configure with an IP address assigned via DHCP
  if (usingDhcp) {
    // Use DHCP to configure the local IP address
    bool dhcpSuccess = Ethernet.begin(mac);
    if (dhcpSuccess) {
      Serial.print("DHCP successfully assigned an IP address: ");
      Serial.println(Ethernet.localIP());
    } else {
      Serial.println("DHCP configuration was unsuccessful!");
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
    Serial.print("Assigned manual IP address: ");
    Serial.println(Ethernet.localIP());
    
    //Optionally, set additional network addresses if needed

    //IpAddress myDns = myDns(192, 168, 1, 1);
    //IpAddress gateway = gateway(192, 168, 1, 1);
    //IpAddress netmask = subnetress(255, 255, 255, 0);

    //Ehternet.begin(mac, ip, myDns, gateway, subnet);
  }
    // Attempt to connect to a server
    Serial.print("Attempting to connect to the MQTT broker: ");
    Serial.println(broker);

  if (!mqttClient.connect(broker, port)) {
    Serial.print("MQTT connection failed! Error code = ");
    Serial.println(mqttClient.connectError());

    while (1);
  }

  Serial.println("You're connected to the MQTT broker!");
  Serial.println();

  Serial.print("Subscribing to topic: ");
  Serial.println(sub_topic);
  Serial.println();

  // set the message receive callback
  mqttClient.onMessage(onMqttMessage);

  // subscribe to a topic
  mqttClient.subscribe(sub_topic);
}
      
void loop(){
    
    // Make sure the physical link is active before continuing
    while (!Ethernet.linkStatus() == LinkOFF) {
      Serial.println("The Ethernet cable is unplugged...");
    }

    // call poll() regularly to allow the library to send MQTT keep alives which
    // avoids being disconnected by the broker
    mqttClient.poll();

    // to avoid having delays in loop, we'll use the strategy from BlinkWithoutDelay
    // see: File -> Examples -> 02.Digital -> BlinkWithoutDelay for more info
    unsigned long currentMillis = millis();
  
    if (currentMillis - previousMillis >= interval) {
      // save the last time a message was sent
      previousMillis = currentMillis;

      // Serial.print("Sending message to topic: ");
      // Serial.println(pub_topic);
      // Serial.print("hello ");
      // Serial.println(count);
      // Serial.println();

      // send message, the Print interface can be used to set the message contents
      mqttClient.beginMessage(pub_topic);
      mqttClient.print("hello ");
      mqttClient.print(count);
      mqttClient.endMessage();

      count++;

      
    }

  }

  void onMqttMessage(int messageSize) {
    // we received a message, print out the topic and contents
    Serial.println("Received a message with topic '");
    Serial.print(mqttClient.messageTopic());
    Serial.print("', length ");
    Serial.print(messageSize);
    Serial.println(" bytes:");

    // use the Stream interface to print the contents
    while (mqttClient.available()) {
      Serial.print((char)mqttClient.read());
    }
    Serial.println();

    Serial.println();
  }
    