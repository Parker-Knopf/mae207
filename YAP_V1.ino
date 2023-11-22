#inlude "math.h"

void setup() {
  // put your setup code here, to run once:

  double d = [];
  double current_theta = [];
  double threshold = 10; // boundry around the obstacle that is deemed unsafe [mm] 
  double theta_JND = 10; //minimally percieved angle [degrees]

  double R = 25; //maximum radius of the CAM [mm]
  double r = 10; //minimum raidus of the CAM [mm]
  double theta_c = atan(r/R);
  double d_JND = 3; //JND of normal displacement into the skin [mm]
  double d_prime = d/cos(d_JND);
  double theta_JND = atan(d_prime/R);

  double zeroed_angle = 0; //[degrees]
  double actual_angle = 0; //[degrees]
}

void calibrate() {
  //need a calibration process to have the CAM resting on the user's skin (not hovering/no gap)
  //make sure motor is backdrivable 
  
  // the user will manually turn the cam until it is barely in contact with the skin
  while true
    actual_angle= getCAMangle();
    if  (zeroed_angle != actual_angle){
      zeroed_angle = actual_angle;
    }
    else {
      break;
    }
    end
}

void loop() {
  //track distances/velocities of the user to the obstacle
  // we are given the distances d1,d2 (distal arm) and d3,d4(proximal arm) of the each arm to the obstacle 
  d = [d1 d2 d3 d4]; 
  //check for safety conditions for each motor 1-4 and assign theta value
  for i = 1:4 {
    if (d(i) < threshold/2) {
      setCAMangle(i) = theta_JND; //set medium pressure
    }
    else if (d(i) < threshold){
      setCAMangle(i) = 2*theta_JND; //set max pressure
    }
  }
}
