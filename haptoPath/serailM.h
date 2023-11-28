class serialM {
double baudeRate = 115600;
double D = [];
char c = ",";
char tempChar = "";
String tempString = "";
int i = 0;

const int data_size = 4;
int index[data_size];
String subString[data_size];

public:
void setup() {
  Serial.begin(baudeRate);
}

void readData() {
  if (Serial.available() >0) { //send data only when you recieve data
      tempString = Serial.read();
    
    if (tempString.indexOf(c) != -1) {
      findIndex(tempString);
      separate(tempString, index);
      setParameters();

    }
  }

float getData(int index) {
  return D[index];

}
private:

    void findIndex(String s) {
        index = s.indexOf(c); 
      }

    void separate(String s, int index) {
      for (int i = 0; i <4; i++){
        if (i == 0) {
          subString[i] = s.substring(0, (index(i)));
          
        }
        else {
          subString[i] = s.substring((index(i-1)+1), (index(i))
        }
      }

      
    }

    void setParameters() {
      for(int i = 0; i<4; i++){
        D[i] = substring[i].toInt();
      }

    }

};//end of serialM
