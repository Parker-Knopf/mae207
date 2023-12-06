#include "motor.h"
#include "math.h"

class Sense : public Motor {

  // Constants
  float Rc; //Radius of the CAM [mm]  

  // Logic
  float threshold = 10; // boundry around the obstacle that is deemed unsafe [mm] 
  float d_JND = 3; //JND of normal displacement into the skin (minimum) [mm]
  float hMax;
  
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
        hMax = r;
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
      maxPower(150);
      setRads(-2*PI);

      int oldCount = -100;
      while (oldCount != getCount()) {
        oldCount = getCount();
        delay(150);
      }
      maxPower(255);
      zero(); // Zero encoder
    }//end of absZero

  private:
  
    float motorTheta(float h) {
      // might need to do some linear mapping between h and actual indentation
      hTotal = bound(hOffset + h); //absolute h [mm]
      thetaTemp = asin(hTotal/Rc); //[rads]
      return thetaTemp;
    }//end of motorTheta

    float bound(float h) {
      if (h > hMax) { //bound theta so it doesn't go past 90 degrees
        h = hMax;
      }
      else if (h < 0) {
        h = 0;
      }
      return h;
    }//end of bound

};// end of Sense
