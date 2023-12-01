#include "motor.h"
#include "math.h"

class Sense : public Motor {

  // Constants
  float Rc; //Radius of the CAM [mm]  

  // Logic
  float threshold = 10; // boundry around the obstacle that is deemed unsafe [mm] 
  float d_JND = 3; //JND of normal displacement into the skin (minimum) [mm]
  float hMax = 0;
  
  // Offset Vals
  float hOffsetAng = 0;
  float hOffset = 0;
  float hTotal = 0;
  float theta = 0;
  float thetaTemp = 0;
  float thetaMax = PI/2;

  public:

    Sense(float r, byte pwm1, byte pwm2, byte pA, byte pB, int ratio):Motor(pwm1, pwm2, pA, pB, ratio) {
        Rc = r;
    }//end of constructor 

    void updateMotor(float h) {
      theta = motorTheta(h);
      setRads(theta); // set motor angle
    }//end of updateMotor

    void setHZero() {
      // Set H offset values
      hOffsetAng = getRads(); // get the angle of motor that's being guided by joystick
      hOffset = Rc*sin(hOffsetAng); // small angle approximation
    }//end of setZero

    void absZero() {
      maxPower(100);
      setRads(-2*PI);

      int oldCount = -100;
      while (oldCount != getCount()) {
        oldCount = getCount();
        delay(200);
        Serial.println("-");
      }
      Serial.println("ZERO");
      maxPower(255);
      zero(); // Zero encoder
    }//end of absZero

  private:
  
    float motorTheta(float h) {
      // might need to do some linear mapping between h and actual indentation
      hTotal = hOffset + h; //absolute h [mm]
      thetaTemp = asin(hTotal/Rc); //[rads]
      return bound(thetaTemp);
    }//end of motorTheta

    float bound(float thetaTemp) {
      if (thetaTemp > thetaMax) { //bound theta so it doesn't go past 90 degrees
        thetaTemp = thetaMax;
      }
      else if (theta < 0) {
        thetaTemp = 0;
      }
      return thetaTemp;
    }//end of bound

};// end of Sense
