#include <Adafruit_NeoPixel.h>

#define PIN 3



Adafruit_NeoPixel strip = Adafruit_NeoPixel(60, PIN, NEO_GRB + NEO_KHZ800);


void setup() {
  pinMode(13, OUTPUT);
  Serial.begin(57600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
  strip.begin();
  strip.show(); // Initialize all pixels to 'off'
}

#define NUMBER_OF_BYTES 180
int pixelData[NUMBER_OF_BYTES];
//60*3 = 180 bytes
int byteCounter = -1;

int waitForChar(char c)
{
  int timeout = 100;
  char in = c + 1;
  if (Serial.available() > 0) {
    while (in != c)
    {
      in = Serial.read();
      timeout--;
      if (timeout == 0)
      {
        return -1;
      }
    }
    return 1;
  }
}

void loop()
{
  //WAIT for OPC message header
  if (byteCounter == -1)
  {
    
    if (waitForChar('O') == -1) {
      return;
    }
    if (waitForChar('P') == -1) {
      return;
    }
    if (waitForChar('C') == -1) {
      return;
    }
    byteCounter = 0;
    digitalWrite(13, HIGH);
    Serial.println("OPC received");
  }
  else
  {
    if (Serial.available() > 2)
    {

      // get incoming bytes:
      int r = Serial.read();
      int g = Serial.read();
      int b = Serial.read();

      if( (r == 'O') && (g == 'P') && (b == 'C') )
      {
        byteCounter = 0;
        return;
      }
      
      pixelData[byteCounter++] = r;
      pixelData[byteCounter++] = g;
      pixelData[byteCounter++] = b;

      /*
      Serial.print(r,DEC);
      Serial.print(' ');
      Serial.print(g,DEC);
      Serial.print(' ');
      Serial.print(b,DEC);
      Serial.println("---");
      */
      
      if (byteCounter == NUMBER_OF_BYTES)
      {
        for (int i= 0; i < 60; i++)
        {
          strip.setPixelColor(i, strip.Color(pixelData[3 * i], pixelData[3 * i + 1], pixelData[3 * i + 2]) );
        }
       
     
        strip.show();
        digitalWrite(13, LOW);
        Serial.println("180 bytes received");
        byteCounter = -1;
      }
    }
  }
}
