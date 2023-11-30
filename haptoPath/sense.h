#include "motor.h"
#include "math.h"

class Sense : public Motor {

  float leverR; // Lever Arm radius of haptic actuator
  float theta = 0;
  float threshold = 10; // boundry around the obstacle that is deemed unsafe [mm] 
  float hTotal = 0;

  float Rc = 25; //maximum radius of the CAM [mm]  
  float d_JND = 3; //JND of normal displacement into the skin (minimum) [mm]
  
  float theta_JND = 0; //JND of angular displacement [degrees]

  float hOffsetAng = 0;
  float hOffset = 0;
  float hTotal = 0;
  float hMax = 0; 
  float theta = 0;

  public:

    Sense(float r, byte pwm1, byte pwm2, byte pA, byte pB, int ratio):Motor(pwm1, pwm2, pA, pB, ratio) {
        leverR = r;
    }//end of constructor 

    void updateMotor(float h) {
        theta = motorTheta(h)*(PI/180); //convert to radians
        setRads(theta); // set motor angle
    }//end of updateMotor

    void setHZero() {
      // Set H offset values
      hOffsetAng = getRads()*(PI/180); // get the angle of motor that's being guided by joystick
      hOffset = Rc*sin(hOffsetAng); // small angle approximation 
      
    }//end of setZero

    void absZero() {
      setRads(-2*PI);

      int oldCount = -100;
      while (oldCount != getCount()) {
        oldCount = getCount();
      }
      zero(); // Zero encoder
    }//end of absZero

  private:
  
    float motorTheta(float h) {
      // might need to do some linear mapping between h and actual indentation
      hTotal = h_offset + h; //d_JND should vary based on the data input 
      theta_JND = atan(hTotal/Rc); //JND of angular displacement [degrees]
      //theta_JND = 2*atan(hTotal/2*Rc); //using the chord approach
      if (theta_JND > 90) { //bound theta so it doesn't go past 90 degrees
          theta_JND = 90;
      }
      return theta_JND;
    }

};// end of Sense
