#include "ClearCore.h"

// MQTT Configuration Declarations
#include <Ethernet.h>
#include <ArduinoMqttClient.h>

// MAC address of the ClearCore
byte mac[] = {};

const char broker[] = "160.94.187.233";
int        port     = 1883;
// const char pub_topic[]  = "arduino/simple";
const char sub_topic[]   = "Commands/#";

const long interval = 200;
unsigned long previousMillis = 0;

// The port number on the server over which packets will be sent/received
#define PORT_NUM  1883

// The maximum number of characters to receive from an incoming packet
const size_t MAX_PACKET_LENGTH = 100;
// Buffer for holding received packets.
char packetReceived[MAX_PACKET_LENGTH];
size_t packetbufferIndex = 0;

// Set usingDhcp to false to use user defined network settings
bool usingDhcp = true;

// Initialize a client object
// The ClearCore will operate as a TCP client using this object
EthernetClient client;
MqttClient mqttClient(client);

int i = 0;
bool verbose = false;
bool moving_state = false;
bool last_moving_state = false;
unsigned long millis_timer;
bool bell_state = true;
bool change_bell_state = false;

bool MA = false;
bool homed = false;
bool jog_mode = false;
bool SCALE = true;
bool ENC = false;
bool ECHO = false;
bool programming_mode = false;
String program_filename;
String SD_files;


#define motor0 ConnectorM0
#define ComPort Serial0  // Serial is the USB Port, Serial0 is COM0 RJ45 connector, Serial1 is COM1 RJ45 connector. For Development Serial (USB) is convient, but in opperation, Serail 0 should be used.
#define Diag_ComPort Serial // USB ComPort

bool Diag_Port_enable = true;

// Define the velocity and acceleration limits to be used for each move
float SCLD = 1;//800 / 2.54;
float SCLV = 1;//800 / 2.54;
float SCLA = 1;//800 / 2.54;

long pos_at_last_trig = 0;

// int EOT[] = {13,0,0};

int velocityLimit = 1000;       // pulses per sec
int accelerationLimit = 10000;  // pulses per sec^2

// Declares user-defined helper functions.
// The definition/implementations of these functions are at the bottom of the sketch.
bool HANDLE_ALERTS = true;
void PrintAlerts();
void HandleAlerts();
bool MoveAbsolutePosition(int32_t position);
bool enable_status = false;


void setup() {
  ComPort.begin(9600);
  // while (!ComPort) {
  //   continue;
  // }
  ComPort.ttl(false);  // RS232 not TTL

  if (Diag_Port_enable) {
    Diag_ComPort.begin(9600);
    // while(!Diag_ComPort) {
    //   continue;
    // }
  }
 
  ConfigureMotor();
  configure_MQTT();
  list_files();
  // processCommand("wakeup");
}

void loop() {
   // call poll() regularly to allow the library to send MQTT keep alives which avoids being disconnected by the broker
  mqttClient.poll();

  // Publish Current Status to MQTT Broker on interval set by "interval"
  unsigned long currentMillis = millis();  
  if (currentMillis - previousMillis >= interval) {
    // save the last time a message was sent
    previousMillis = currentMillis;
      publish_status();
    }

  moving_state = motor0.StatusReg().bit.StepsActive;  //Check if the motor is currently moving
  if (millis()-millis_timer > 500) {
    bell_state = !bell_state;
    change_bell_state = true;
    millis_timer = millis();
  }
  if (moving_state != last_moving_state || change_bell_state) {
    ring_bell();
    last_moving_state = moving_state;
  }

  if (moving_state && Diag_Port_enable) {
    if (int(Scale_Steps_to_mm(motor0.PositionRefCommanded())*1000) != pos_at_last_trig) {
      pos_at_last_trig = int(Scale_Steps_to_mm(motor0.PositionRefCommanded())*1000);

      publish_mqtt_message_float("DAQ/x_position",Scale_Steps_to_mm(motor0.PositionRefCommanded())*1000);
      publish_mqtt_message_float("DAQ/keyence_volts",ConnectorA12.AnalogVoltage());
      // Diag_ComPort.print(Scale_Steps_to_mm(motor0.PositionRefCommanded())*1000,2);
      // Diag_ComPort.print(",");
      // Diag_ComPort.println(ConnectorA12.AnalogVoltage(),6);
    }

  }
  // ReadSerial_and_Process();
}
