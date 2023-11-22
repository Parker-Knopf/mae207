#include "motor.h"

class Sense : public Motor {

    float leverR; // Lever Arm radius of haptic actuator

public:

    Sense(float r, byte pwm1, byte pwm2, byte pA, byte pB, int ratio):Motor(pwm1, pwm2, pA, pB, ratio) {
        leverR = r;
    }//end of constructor 

private:

};// end of Sense