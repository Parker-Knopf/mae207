#include "sense.h"
#include "serialM.h"

// Constants

const int gearRatio = 380;
const static byte senseCount = 4; // Number of actuators
const float leverR[senseCount] = {22, 22, 22, 22}; // Lever arm of haptic actuator [mm]

// Pin Definitions

// Encoders
const byte p1enA = 20; // Inside Forearm (0) Encoder A
const byte p1enB = 21; // Inside Forearm (0) Encoder B
const byte p2enA = 22; // Outside Forearm (1) Encoder A
const byte p2enB = 23; // Outside Forearm (1) Encoder B
const byte d1enA = 8; // Inside Upper arm (2) Encoder A
const byte d1enB = 7; // Inside Upper arm (2) Encoder B
const byte d2enA = 6; // Outside Upper arm (3) Encoder A
const byte d2enB = 5; // Outside Upper arm (3) Encoder B
const byte en[senseCount][2] = {{p1enA, p1enB}, {p2enA, p2enB}, {d1enA, d1enB}, {d2enA, d2enB}};

// Motor Power
const byte p1m1 = 12; // Inside Forearm (0) Diode 1
const byte p1m2 = 11; // Inside Forearm (0) Diode 2
const byte p2m1 = 10; // Outside Forearm (1) Diode 1
const byte p2m2 = 9; // Outside Forearm (1) Diode 2
const byte d1m1 = 15; // Inside Upper arm (2) Diode 1
const byte d1m2 = 14; // Inside Upper arm (2) Diode 2
const byte d2m1 = 18; // Outside Upper arm (3) Diode 1
const byte d2m2 = 19; // Outside Upper arm (3) Diode 2
const byte pwm[senseCount][2] = {{p1m1, p1m2}, {p2m1, p2m2}, {d1m1, d1m2}, {d2m1, d2m2}};

// Objects
Sense sense[senseCount] = {Sense(leverR[0], pwm[0][0], pwm[0][1], en[0][0], en[0][1], gearRatio), Sense(leverR[1], pwm[1][0], pwm[1][1], en[1][0], en[1][1], gearRatio), Sense(leverR[2], pwm[2][0], pwm[2][1], en[2][0], en[2][1], gearRatio), Sense(leverR[3], pwm[3][0], pwm[3][1], en[3][0], en[3][1], gearRatio)};
SerialM comun = SerialM();

void setup() {

  // Encoder Interupts
  attachInterrupt(digitalPinToInterrupt(en[0][0]), en1A, CHANGE);
  attachInterrupt(digitalPinToInterrupt(en[0][1]), en1B, CHANGE);
  attachInterrupt(digitalPinToInterrupt(en[1][0]), en2A, CHANGE);
  attachInterrupt(digitalPinToInterrupt(en[1][1]), en2B, CHANGE);
  attachInterrupt(digitalPinToInterrupt(en[2][0]), en3A, CHANGE);
  attachInterrupt(digitalPinToInterrupt(en[2][1]), en3B, CHANGE);
  attachInterrupt(digitalPinToInterrupt(en[3][0]), en4A, CHANGE);
  attachInterrupt(digitalPinToInterrupt(en[3][1]), en4B, CHANGE);

  // Absolute Zero all Sense
  zeroSys();
}//end of setup

void loop() {
  // put your main code here, to run repeatedly:
  // comun.readData(); // Read the data from the Serail communication

  if (comun.readData()) {
    for (byte i = 0; i < senseCount ; i++) {
      sense[i].updateMotor(comun.D[i]);
    }
  }

  // Zero motors
  if (comun.D_zero != -1) {
    // do stuff to zero the motor using the current motor posotion and the motor index
    sense[comun.D_zero].setHZero();
    comun.D[comun.D_zero] = 0;
    // After operation reset D_zero
    comun.D_zero = -1;
  }

  // Reboot system to zero motors
  if (comun.reboot) {
    zeroSys();
    comun.reboot = false;
  }
}//end of loop

void zeroSys() {
  // Absolute Zero all Sense
  for (byte i = 0; i < senseCount; i++) {
    sense[i].absZero();
  }
  delay(.5);
  // Absolute Zero all Sense
  for (byte i = 0; i < senseCount; i++) {
    sense[i].absZero();
  }

}//end of zeroSys

void en1A() {
  sense[0].encoderA();
  // Motor encoder ISR Function
}//end of en1A

void en1B() {
  sense[0].encoderB();
  // Motor encoder ISR Function
}//end of en1B

void en2A() {
  sense[1].encoderA();
  // Motor encoder ISR Function
}//end of en1A

void en2B() {
  sense[1].encoderB();
  // Motor encoder ISR Function
}//end of en1B

void en3A() {
  sense[2].encoderA();
  // Motor encoder ISR Function
}//end of en1A

void en3B() {
  sense[2].encoderB();
  // Motor encoder ISR Function
}//end of en1B

void en4A() {
  sense[3].encoderA();
  // Motor encoder ISR Function
}//end of en1A

void en4B() {
  sense[3].encoderB();
  // Motor encoder ISR Function
}//end of en1B
