const int photoPin = A3; //constant
int photoVal; //store value from photoresistor


void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  // pinMode(photoPin, INPUT); //set photoPin -A0 pin as input
}

void loop() {
  // put your main code here, to run repeatedly:
  photoVal = analogRead(photoPin);
  Serial.println((String) photoVal);
}

