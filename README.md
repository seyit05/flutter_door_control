🛠 ESP8266 Firmware (Modbus TCP)
This project includes a simple firmware example for ESP8266 to control a relay using Modbus TCP protocol.

The ESP8266 listens for Modbus TCP coil commands to toggle Relay 4 (connected to pin D2 or GPIO4).

📦 Required Libraries

ModbusIP_ESP8266
EEPROM
ESP8266WiFi

🔌 Example Code


#include <ESP8266WiFi.h>
#include <ModbusIP_ESP8266.h>

const char* ssid = "YourWiFiSSID";
const char* password = "YourWiFiPassword";

const int RELAY_PIN = 4; // GPIO4 = D2

ModbusIP mb;

void setup() {
  Serial.begin(115200);
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, LOW);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("WiFi connected");

  mb.server();
  mb.addCoil(1); // Coil address 1 controls the relay
}

void loop() {
  mb.task();
  bool coilState = mb.Coil(1);
  digitalWrite(RELAY_PIN, coilState ? HIGH : LOW);
}


📡 How It Works
The mobile app sends a write coil Modbus TCP command to coil address 1.

ESP8266 reads that coil and toggles RELAY_PIN accordingly.

You can integrate this with a Flutter app via HTTP or socket communication.
