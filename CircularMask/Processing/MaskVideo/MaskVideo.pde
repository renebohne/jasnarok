import processing.video.*;


//String filename = "/Users/micah/Dropbox/video/The Glitch Mob - We Can Make The World Stop (Official Video)-720p.mp4";
String filename = "clip1.mp4";


float zoom = 2;

SerialNeopixel opc;
Serial myPort;
Movie movie;
PGraphics[] pyramid;

void setup()
{
  size(480, 240, P3D);

  // Connect to the local instance of fcserver. You can change this line to connect to another computer's fcserver
  
  String portName = "COM1";//"COM8";//Serial.list()[1];
  System.out.println(portName);
  //myPort = new Serial(this, portName, 57600);
  //myPort.bufferUntil(10);    
  opc = new SerialNeopixel(this, myPort);
 
  
  for(int i=0;i<12;i++)
  {
    opc.ledStripNoOffset(i*5, 5, width/2, height/2, 20, 0.52*i, i%2!=0);
  }
  
  
  movie = new Movie(this, filename);
  movie.loop();

  pyramid = new PGraphics[4];
  for (int i = 0; i < pyramid.length; i++) {
    pyramid[i] = createGraphics(width / (1 << i), height / (1 << i), P3D);
  }
}

void keyPressed() {
  if (key == ' ') movie.pause();
  if (key == ']') zoom *= 1.1;
  if (key == '[') zoom *= 0.9;
}

void keyReleased() {
  if (key == ' ') movie.play();
}  

void movieEvent(Movie m)
{
  m.read();
}

void draw()
{
  // Scale to width, center height
  int mWidth = int(pyramid[0].width * zoom);
  
  int mHeight = mWidth * movie.height;
  if(movie.width >0)
  {
    mHeight = mWidth * movie.height / movie.width;

  }
  
  // Center location
  float x, y;

  if (mousePressed) {
    // Pan horizontally and vertically with the mouse
    x = -mouseX * (mWidth - pyramid[0].width) / width;
    y = -mouseY * (mHeight - pyramid[0].height) / height;
  } else {
    // Centered
    x = -(mWidth - pyramid[0].width) / 2;
    y = -(mHeight - pyramid[0].height) / 2;
  }

  pyramid[0].beginDraw();
  pyramid[0].background(0);
  pyramid[0].image(movie, x, y, mWidth, mHeight);
  pyramid[0].endDraw();

  for (int i = 1; i < pyramid.length; i++) {
    pyramid[i].beginDraw();
    pyramid[i].image(pyramid[i-1], 0, 0, pyramid[i].width, pyramid[i].height);
    pyramid[i].endDraw();
  }

  image(pyramid[pyramid.length - 1], 0, 0, width, height);
}