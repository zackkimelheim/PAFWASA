// The program is adapted from MusicViz.pde developed by Abhinav Kr
// The weather data is retrieved using the Temboo library
// The initial animation is based on Random Loader 2 on OpenProcessing.org
// Authored by: Siyuan Hu & Zack Kimelheim

import ddf.minim.*;
import ddf.minim.analysis.*;
import com.temboo.core.*;
import com.temboo.Library.Yahoo.Weather.*;
import processing.serial.*;

// Create a session using the Temboo account application details
TembooSession session = new TembooSession("zackkimelheim", "myFirstApp", "TcXNZMLYo4AZ5pliItG94brUJLbK9Bxi");

// Create a Serial object to read signal from the Arduino
Serial myPort;

// music visualizer variables
Minim minim;
AudioPlayer player;
AudioMetaData meta;
BeatDetect beat;
int  r = 350; // radius of the outer circle
int timeTarget = 0;
float rad = 250; // radius of the inner circle
boolean musicFlag = true;
boolean textFlag = true;
int red, green, blue, alpha;

// weather gadget variables
String[] location;
int currentLocation = 0;
int locationLength = 4;
PFont fontVeryLarge, fontLarge, fontMedium, fontSmall;
String timeNow, textWeather;
int temperature, humidity, high, low, windSpeed;
XML weatherResults;
float inputVal = 0.0;
String clothesText = "";
String rainyClothesText = "";

// initial interface animation variables 
int N = 8, r1 = 150;
int m, t;

void setup()
{
  size(displayWidth, 750);
  background(100);
  minim = new Minim(this);
  player = minim.loadFile("All I Ask.mp3");
  meta = player.getMetaData();
  timeTarget = meta.length();
  beat = new BeatDetect();

  // Configure the serial port
  try {
    String portName = Serial.list()[2];
    myPort = new Serial(this, portName, 9600);
    myPort.bufferUntil('\n');
  } 
  catch (ArrayIndexOutOfBoundsException e) {
    e.printStackTrace();
  }

  // background color
  red = 64;
  green = 204;
  blue = 208;
  alpha = 50;

  // font styles 
  fontVeryLarge = createFont("Arial Black", 150);
  fontLarge = createFont("Arial Black", 60);
  fontMedium = createFont("Arial Black", 36);
  fontSmall = createFont("Arial Black", 24);


  // Set up the locations
  location = new String [locationLength];
  location[0] = "New York";
  location[1] = "Los Angeles";
  location[2] = "Nuuk";
  location[3] = "Miami";


  // Get the initial weather data 
  runGetWeatherByAddressChoreo();
  getTemperatureFromXML();
}

void draw()
{ 
  // this creates the background
  fill(red, green, blue, alpha);
  noStroke();
  rect(0, 0, width, height);


  if (inputVal > 60) {
    // start the music player
    player.play();

    // move the center to the middle of screen
    translate(width/2, height/2);

    // display the music visualizer
    displayVisualizer();

    // initialize the animation program at the begining
    m = 0;
    t = 0;

    fill(255); // text color
    if (musicFlag) {
      showTimeLeft();
      red = 64;
      green = 204;
      blue = 208;
    } else {
      if (textFlag) displayText1();
      else displayText2();
      float mappedVal = map(temperature, 0, 100, 0, 255);
      red = int(mappedVal);
      green = 0;
      blue = int(255 - mappedVal);
    }
    if (keyPressed) {
      if (key == 'w') {
        currentLocation = (currentLocation + 1) % locationLength;
        runGetWeatherByAddressChoreo(); // Run the GetWeatherByAddress Choreo function
        getTemperatureFromXML(); // Get the temperature from the XML results
      }
    }
  } else {
    background(64, 204, 208);
    player.pause();
    musicFlag = true;
    textFlag = true;
    initialAnimation();
  }
}

void mousePressed() {
  if (dist(mouseX, mouseY, width/2, height/2)<150) {
    musicFlag =!musicFlag;
    textFlag = true;
    background(red, green, blue, alpha);
  }
}

void keyPressed() {
  if (key == ' ') {
    textFlag = !textFlag;
  }
}

void initialAnimation() {
  translate(width>>1, height>>1);
  fill(255);

  // text in the middle of screen
  textFont(fontMedium);
  textAlign(CENTER);
  text("PAFWASA", 0, 15);

  // animation
  strokeWeight(10);
  stroke(255);
  for (int i = 0; i < N; i++) {
    float ang = 360/N;
    float k = 180*sin(radians(t));
    float l = r1*sin(radians(ang/2));
    float x = r1*cos(radians(ang*i));
    float y = r1*sin(radians(ang*i));
    pushMatrix();
    translate(x, y);
    rotate(PI/2 + radians(ang*i + (m > i ? k : 0))); // m is the number of rotating sticks
    line(-l, 0, l, 0);
    popMatrix();
  }
  if (t < 90) t += 3;
  else {
    t = 0;
    m++; // each iteration m is incremented by 1
    if (m > N) m = 0;
  }
}

void serialEvent(Serial myPort) {
  try {
    String inputStr = myPort.readString();
    inputVal = float(inputStr);
    println("Serial Input: " + inputVal);
    myPort.write('x');
  } 
  catch(NullPointerException e) {
    e.printStackTrace();
  }
}

void showTimeLeft() {
  textFont(fontLarge);
  textAlign(CENTER);
  int minute = (timeTarget/1000-millis()/1000)/60;
  int second = (timeTarget/1000-millis()/1000)%60;
  if (second >= 0) {
    if (second < 10)
      text(minute + ":0" + second, -7, 21);
    else
      text(minute + ":" + second, -7, 21);
  } else {
    timeTarget = timeTarget + meta.length();
    text("0:00", -7, 21);
  }
}

void displayVisualizer() {
  beat.detect(player.mix);
  fill(100, 100, 100, 50); // the color of the inner circle
  if (beat.isOnset()) 
    rad = rad*0.75; // creates a diminishing-effect circle
  else 
  rad = 250;
  ellipse(0, 0, 2*rad, 2*rad);

  stroke(100, 150);
  strokeWeight(1);
  int bsize = player.bufferSize();
  for (int i = 0; i < bsize; i+=5)
  {
    float x = (r)*cos(i*2*PI/bsize);
    float y = (r)*sin(i*2*PI/bsize);
    float x2 = (r + player.left.get(i)*100)*cos(i*2*PI/bsize);
    float y2 = (r + player.left.get(i)*100)*sin(i*2*PI/bsize);
    line(x, y, x2, y2);
  }
  beginShape();
  noFill();
  stroke(100, 150);
  for (int i = 0; i < bsize; i+=30)
  {
    float x2 = (r + player.left.get(i)*100)*cos(i*2*PI/bsize);
    float y2 = (r + player.left.get(i)*100)*sin(i*2*PI/bsize);
    vertex(x2, y2);
    pushStyle();
    stroke(200);
    strokeWeight(2);
    point(x2, y2);
    popStyle();
  }
  endShape();
}

void displayText1() {
  int marginLeft = 0;
  int marginTopTemperature = 20;
  int marginTopHumidity = 60;
  int marginTopLocation = 100;
  textAlign(CENTER);

  // Display temperature
  textFont(fontVeryLarge);
  String temperatureToShow = temperature + "ºF";
  text(temperatureToShow, marginLeft, marginTopTemperature);

  //display condition 
  textFont(fontMedium);
  String tempRange = low + "ºF - " + high + "ºF";
  text(tempRange, marginLeft, marginTopHumidity);

  // Display location
  textFont(fontMedium);
  text(location[currentLocation], marginLeft, marginTopLocation);
  
  textFont(fontSmall);
  text("Dressing Tips:", marginLeft, marginTopLocation + 50);
  text(clothesText, marginLeft, marginTopLocation + 80);
  text(rainyClothesText, marginLeft, marginTopLocation + 110);
} 

void displayText2() {
  int marginLeft = 0;
  int marginTopTemperature = -20;
  int marginTopHumidity = 50 + marginTopTemperature;
  int marginTopLocation = 50 + marginTopHumidity;

  textAlign(CENTER);
  // Display temperature
  textFont(fontLarge);
  String textToShow1 = textWeather;
  text(textToShow1, marginLeft, marginTopTemperature);

  //display condition 
  textFont(fontMedium);
  String textToShow2 = "Humidity: " + humidity + "%";
  text(textToShow2, marginLeft, marginTopHumidity);

  // Display location
  textFont(fontMedium);
  String textToShow3 = "Wind: " + windSpeed + " mph";
  text(textToShow3, marginLeft, marginTopLocation);
} 


void getTemperatureFromXML() {
  // Narrow down to weather condition
  XML condition = weatherResults.getChild("channel/item/yweather:condition");
  XML forecast = weatherResults.getChild("channel/item/yweather:forecast"); 
  XML atmosphere = weatherResults.getChild("channel/yweather:atmosphere"); 
  XML wind = weatherResults.getChild("channel/yweather:wind"); 

  // Get the current temperature in Fahrenheit from the weather conditions
  timeNow = condition.getString("date");
  temperature = condition.getInt("temp");
  high = forecast.getInt("high");
  low = forecast.getInt("low");

  textWeather = condition.getString("text");
  humidity = atmosphere.getInt("humidity");
  windSpeed = wind.getInt("speed");

  if (temperature > 65) {
    // warm
    clothesText = "It's beautiful outside! Don't dress too heavily";
  } else if (temperature > 45) {
    // chilly
    clothesText = "It's springy out! Wear a couple of layers!";
  } else if (temperature > 20) {
    clothesText = "Bring your winter jacket";
  } else {
    clothesText = "Extremely cold. Stay indoors!";
  }

  if (textWeather.contains("ain") || textWeather.contains("hunder") || textWeather.contains("rizzl") || textWeather.contains("hower")) {
    rainyClothesText = "Umbrella, Rain jacket";
  } else {
    rainyClothesText = "";
  }
} 

void runGetWeatherByAddressChoreo() {
  // Create the Choreo object using your Temboo session
  GetWeatherByAddress getWeatherByAddressChoreo = new GetWeatherByAddress(session);
  // Set inputs
  getWeatherByAddressChoreo.setAddress(location[currentLocation]);
  // Run the Choreo and store the results
  GetWeatherByAddressResultSet getWeatherByAddressResults = getWeatherByAddressChoreo.run();
  // Store results in an XML object
  weatherResults = parseXML(getWeatherByAddressResults.getResponse());
} 