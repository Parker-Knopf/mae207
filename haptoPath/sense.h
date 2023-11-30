#include "motor.h"
#include "math.h"

class Sense : public Motor {

  float leverR; // Lever Arm radius of haptic actuator
  float theta_temp = 0;
  float threshold = 10; // boundry around the obstacle that is deemed unsafe [mm] 

  float Rc = 25; //maximum radius of the CAM [mm]  
  float d_JND = 3; //JND of normal displacement into the skin (minimum) [mm]
  
  float d_prime = 0; //we can chage displacement into the skin to be larger than d_JND
  float theta_JND = 0; //JND of angular displacement [degrees]

  float hOffsetAng = 0;
  float hOffset = 0;
  float theta = 0;

  public:

    Sense(float r, byte pwm1, byte pwm2, byte pA, byte pB, int ratio):Motor(pwm1, pwm2, pA, pB, ratio) {
        leverR = r;
    }//end of constructor 

    void updateMotor(float h) {
        if (h < threshold/2) {
            theta_temp = getThetaJND()*(PI/180); //convert to radians
            setRads(theta_temp); //set medium pressure
        }
        else if (h < threshold){
            theta_temp  = 2*getThetaJND()*(PI/180); //convert to radians
            setRads(theta_temp);//set max pressure
        }
    }//end of updateMotor

    void setHZero() {
      // Set H offset values
      hOffsetAng = theta;
      hOffset = 0; // code to find this
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

    float getThetaJND() {
      hOffsetAng = atan(hOffset/Rc);
      d_prime = d_JND/cos(d_JND); //we can chage displacement into the skin to be larger than d_JND
      theta_JND = atan(d_prime/Rc); //JND of angular displacement [degrees]
      if (theta_JND > 90) { //bound theta so it doesn't go past 90 degrees
          theta_JND = 90;
      }
      return theta_JND;
    }

};// end of Sense
