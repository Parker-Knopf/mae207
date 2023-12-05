class Motor {

  // Encoder
  volatile int count = 0; // Absolute encoder counts
  int setCount = 0; // Set counts to reach
  volatile bool A = false; // Encoder A val
  volatile bool Aval = true; // Old Encoder A val
  volatile bool B = false; //Encoder B val
  volatile bool Bval = true; // Old Encoder B val

  // PID contoller in system
  const float kp = .3;
  const float kd = .08;
  const float ki = 0.01;

  long prevT = 0;
  float prevE = 0;
  float eintegral = 0;
  const byte bound = 1;
  byte power = 255;

  // Pins
  byte pinA;
  byte pinB;
  byte pinPWM1;
  byte pinPWM2;


  public:

    float gearRatio = 380; // Polulu Motor (380:1)
    float radPerCount = (2*PI) / (12 * gearRatio); // Polulu Miro-metal motor

    Motor(byte pwm1, byte pwm2, byte pA, byte pB, int ratio) {
      pinPWM1 = pwm1;
      pinPWM2 = pwm2;
      pinA = pA;
      pinB = pB;
      gearRatio = ratio;
      pinMode(pinPWM1, OUTPUT);
      pinMode(pinPWM2, OUTPUT);
      pinMode(pinA, INPUT_PULLUP);
      pinMode(pinB, INPUT_PULLUP);
    }//end of constructor

    void zero() {
      // Zero count values
      count = 0;
      setCount = 0;
      run(false);
    }//end of zero

    void setCounts(int val) {
      // Set counts to reach

      // Serial.print("COUNT: ");
      // Serial.println(count);
      // Serial.print("SETCOUNT VALUE: ");
      // Serial.println(val);
      setCount = val;
      run(true);
    }//end of setCounts

    int getCount() {
      // Return current count
      return count;
    }//end of getCount

    void setRads(float val) {
      // Set rads to reach
      setCounts(val / radPerCount);
    }//end of setRads

    float getRads() {
      //Return current rads
      return count * radPerCount;
    }//end of getRads

    void maxPower(byte val) {
      power = val;
    }//end of setPower

    void encoderA() {
      // ISR Function A for encoder counts

      A = digitalRead(pinA);
      B = digitalRead(pinB);

      if (A == Aval) {return;} // False pulse
      // look for a low-to-high on channel A
      if (A) {
        // check channel B to see which way encoder is turning
        if (!B) {
          // Serial.println("A: A1B0");
          count ++; // CW
        }
        else {
          // Serial.println("A: A1B1");
          count --; // CCW
        }
      }

      else {
        // check channel B to see which way encoder is turning
        if (B) {
          // Serial.println("A: A0B1");
          count ++; // CW
        }
        else {
          // Serial.println("A: A0B0");
          count --; // CCW
        } 
      }

      run(true);
      Aval = A;
    }//end of encoderA

    void encoderB() {
      // ISR Function B for encoder counts

      A = digitalRead(pinA);
      B = digitalRead(pinB);

      if (B == Bval) {return;} // False pulse
      // look for a low-to-high on channel A
      if (A) {
        // check channel B to see which way encoder is turning
        if (B) {
          // Serial.println("B: A1B1");
          count ++; // CW
        }
        else {
          // Serial.println("B: A1B0");
          count --; // CCW
        }
      }

      else  {
        // check channel B to see which way encoder is turning
        if (!B) {
          // Serial.println("B: A0B0");
          count ++; // CW
        }
        else {
          // Serial.println("B: A0B1");
          count --; // CCW
        } 
      }
      run(true);
      Bval = B;
    }//end of encoderB

  private:

    void run(bool state) {
      // Turn on/off Motor
      if (state) {setPower(controler());}
      else {setPower(0);}
    }//end of run

    void setPower(int pwm) {
      // Set the singal to the motor controller
      if (pwm > power) {pwm = power;}
      else if (pwm < 0) {pwm = 0;}
      Serial.println(pwm);

      if (setCount > count) {
        analogWrite(pinPWM1, pwm);
        analogWrite(pinPWM2, 0);
      }
      else if (setCount < count) {
        analogWrite(pinPWM1, 0);
        analogWrite(pinPWM2, pwm);
      }
      else {
        analogWrite(pinPWM1, 0);
        analogWrite(pinPWM2, 0);
      }
    }//end of setPower

    int controler() {
      // PID controler
      
      // Time change
      long currT = micros();
      float dT = ((float)(currT - prevT))/1.0e6;
      prevT = currT;

      // Error computation
      int e = setCount - count;

      if (abs(e) < bound) {return 0;}

      // Derivative Calculation
      float dedt = (e - prevE) / dT;
      prevE = e;

      // Integral Calculation
      eintegral += e * dT;

      // Control 
      return abs(kp*e +kd*dedt + ki*eintegral);
    }//end of controler
};//end of Encoder