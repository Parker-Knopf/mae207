String msg;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(115600);
}

void loop() {
  // put your main code here, to run repeatedly:

  if (Serial.available()>0) {
    msg = Serial.readString();
    Serial.print("This what we got: ");
    Serial.print(msg);
  }
}
