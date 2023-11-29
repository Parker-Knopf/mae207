#include "motor.h"
#include "math.h"

class Sense : public Motor {

  float leverR; // Lever Arm radius of haptic actuator
  double d = 0;
  double theta_temp = 0;
  double threshold = 10; // boundry around the obstacle that is deemed unsafe [mm] 

  double Rc = 25; //maximum radius of the CAM [mm]
  double rc = 10; //minimum raidus of the CAM [mm]
  double theta_c = atan(rc/Rc);
  double d_JND = 3; //JND of normal displacement into the skin (minimum) [mm]
  double d_prime = d/cos(d_JND); //we can chage displacement into the skin to be larger than d_JND
  double theta_JND = atan(d_prime/Rc); //JND of angular displacement [degrees]

  double zeroed_angle = 0; //[degrees]
  double actual_angle = 0; //[degrees]

  public:

    Sense(float r, byte pwm1, byte pwm2, byte pA, byte pB, int ratio):Motor(pwm1, pwm2, pA, pB, ratio) {
        leverR = r;
    }//end of constructor 

    void updateMotor() {
        if (d < threshold/2) {
            theta_temp = theta_JND*(PI/180);
            setRads(theta_temp); //set medium pressure
        }
        else if (d < threshold){
            theta_temp  = 2*theta_JND*(PI/180);
            setRads(theta_temp);//set max pressure
        }
    }//end of updateMotor

  private:

};// end of Sense
