class SerialM {

  // Serial Protocol
  double baudeRate = 115600;
  const char c = " | "; // Serial Data seperator
  const char d = "D:" // Data Indicator
  const char z = "Z:" // Zero Indicator
  const byte indSize = 2; // Size of serial Protocol indicator
  String rawData;
  const int dataSize;
  
  // Data
  int dataIndex[dataSize + 1];
  String data[dataSize];

  public:

    double D[dataSize]; // Heights of Motors [m]
    int D_zero = -1; // Height offsets of motors [m]

    SerialM(byte senseCount) {
      dataSize = senseCount;
      Serial.begin(baudeRate);
    }//end of constructor

    bool readData() {
      if (Serial.available() > 0) { //send data only when you recieve data
          rawData = Serial.read();
        
        if (rawData.indexOf(c) != -1 && rawData.indexOf(d) == 0) {
          findIndex();
          parseData();
          return true;
        }
        else if (rawData.indexOf(z) == 0) {
          parseZero();
        }
        else {return false;}
      else {return false;}
    }//end of readData

    float getData(int index) {
      // If an index given is outside Serial Protocol
      if (index < 0 || index >= dataSize) {
        return -1;
      }
      return D[index];
    }//end of getData

  private:

      void findIndex() {
          dataIndex[0] = indSize;
          dataIndex[dataSize + 1] = sizeof(rawData) + 1;
          int index[dataSize - 1] = rawData.indexOf(c);

          for (byte i = 1; i < dataSize -1; i++) {
            dataIndex[i] = index[i-1];
          }
        }//end of findIndex

      void parseData() {
        for (byte i = 0; i < dataSize; i++){
          data[i] = rawData.substring((index[i]), (index[i+1])
          D[i] = data[i].toFloat();
        }
      }//end of parseData

      void parseZero() {
        D_zero = substring(indSize, sizeof(rawData)).toInt;
        if (D_zero < 0 || D_zero > dataSize) {
          D_zero = -1
        }
      }//end of parseZero
};//end of SerialM
