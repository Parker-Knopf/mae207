#include "sense.h"

// Constants

const int gearRatio = 380;
const byte senseCount = 4; // Number of actuators
const float leverR = 0.025; // Lever arm of haptic actuator [m]

// Pin Definitions

// Encoders
const byte p1enA = 20; // Proximal Motor 1 Encoder A
const byte p1enB = 21; // Proximal Motor 1 Encoder B
const byte p2enA = 7; // Proximal Motor 2 Encoder A
const byte p2enB = 8; // Proximal Motor 2 Encoder B
const byte d1enA = 22; // Distal Motor 1 Encoder A
const byte d1enB = 23; // Distal Motor 1 Encoder B
const byte d2enA = 5; // Distal Motor 2 Encoder A
const byte d2enB = 6; // Distal Motor 2 Encoder B
const byte en[senseCount][2] = {{p1enA, p1enB}, {p2enA, p2enB}, {d1enA, d1enB}, {d2enA, d2enB}};

// Motor Power
const byte p1m1 = 10; // Proximal Motor 1 Diode 1
const byte p1m2 = 9; // Proximal Motor 1 Diode 2
const byte p2m1 = 19; // Proximal Motor 2 Diode 1
const byte p2m2 = 18; // Proximal Motor 2 Diode 2
const byte d1m1 = 11; // Distal Motor 1 Diode 1
const byte d1m2 = 12; // Distal Motor 1 Diode 2
const byte d2m1 = 14; // Distal Motor 2 Diode 1
const byte d2m2 = 15; // Distal Motor 2 Diode 2
const byte pwm[senseCount][2] = {{p1m1, p1m2}, {p2m1, p2m2}, {d1m1, d1m2}, {d2m1, d2m2}};

// Objects
Sense sense[senseCount] = {Sense(leverR, pwm[0][0], pwm[0][1], en[0][0], en[0][1], gearRatio), Sense(leverR, pwm[1][0], pwm[1][1], en[1][0], en[1][1], gearRatio), Sense(leverR, pwm[2][0], pwm[2][1], en[2][0], en[2][1], gearRatio), Sense(leverR, pwm[3][0], pwm[3][1], en[3][0], en[3][1], gearRatio)};


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
}

void loop() {
  // put your main code here, to run repeatedly:
  for i = 1:4 {
    Sense[i].updateMotor();
  }
}


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
