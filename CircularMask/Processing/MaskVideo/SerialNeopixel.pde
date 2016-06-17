import processing.serial.*;
import java.util.Arrays;


public class SerialNeopixel implements Runnable
{
  Serial myPort;  // Create object from Serial class

  Thread thread;
  //OutputStream output, pending;

  int[] pixelLocations;
  byte[] packetData;
  boolean enableShowLocations;

  SerialNeopixel(PApplet parent, Serial s)
  {
    myPort = s;

    thread = new Thread(this);
    thread.start();
    this.enableShowLocations = true;
    parent.registerMethod("draw", this);
  }


  // Set the location of a single LED
  void led(int index, int x, int y)  
  {
    // For convenience, automatically grow the pixelLocations array. We do want this to be an array,
    // instead of a HashMap, to keep draw() as fast as it can be.
    if (pixelLocations == null) {
      pixelLocations = new int[index + 1];
    } else if (index >= pixelLocations.length) {
      pixelLocations = Arrays.copyOf(pixelLocations, index + 1);
    }

    pixelLocations[index] = x + width * y;
  }

  // Set the location of several LEDs arranged in a strip.
  // Angle is in radians, measured clockwise from +X.
  // (x,y) is the center of the strip.
  
  void ledStrip(int index, int count, float x, float y, float spacing, float angle, boolean reversed)
  {
    float s = sin(angle);
    float c = cos(angle);
    for (int i = 0; i < count; i++) {
      led(reversed ? (index + count - 1 - i) : (index + i), 
        (int)(x + (i - (count-1)/2.0) * spacing * c + 0.5), 
        (int)(y + (i - (count-1)/2.0) * spacing * s + 0.5));
    }
  }
  
  void ledStripNoOffset(int index, int count, float x, float y, float spacing, float angle, boolean reversed)
  {
    float s = sin(angle);
    float c = cos(angle);
    for (int i = 0; i < count; i++) {
      led(reversed ? (index + count - 1 - i) : (index + i), 
        (int)(x - ((i+1) * spacing * c)), 
        (int)(y - ((i+1) * spacing * s)));
    }
  }

  // Set the locations of a ring of LEDs. The center of the ring is at (x, y),
  // with "radius" pixels between the center and each LED. The first LED is at
  // the indicated angle, in radians, measured clockwise from +X.
  void ledRing(int index, int count, float x, float y, float radius, float angle)
  {
    for (int i = 0; i < count; i++) {
      float a = angle + i * 2 * PI / count;
      led(index + i, (int)(x - radius * cos(a) + 0.5), 
        (int)(y - radius * sin(a) + 0.5));
    }
  }

  // Set the location of several LEDs arranged in a grid. The first strip is
  // at 'angle', measured in radians clockwise from +X.
  // (x,y) is the center of the grid.
  void ledGrid(int index, int stripLength, int numStrips, float x, float y, 
    float ledSpacing, float stripSpacing, float angle, boolean zigzag)
  {
    float s = sin(angle + HALF_PI);
    float c = cos(angle + HALF_PI);
    for (int i = 0; i < numStrips; i++) {
      ledStrip(index + stripLength * i, stripLength, 
        x + (i - (numStrips-1)/2.0) * stripSpacing * c, 
        y + (i - (numStrips-1)/2.0) * stripSpacing * s, ledSpacing, 
        angle, zigzag && (i % 2) == 1);
    }
  }

  // Set the location of 64 LEDs arranged in a uniform 8x8 grid.
  // (x,y) is the center of the grid.
  void ledGrid8x8(int index, float x, float y, float spacing, float angle, boolean zigzag)
  {
    ledGrid(index, 8, 8, x, y, spacing, spacing, angle, zigzag);
  }

  // Should the pixel sampling locations be visible? This helps with debugging.
  // Showing locations is enabled by default. You might need to disable it if our drawing
  // is interfering with your processing sketch, or if you'd simply like the screen to be
  // less cluttered.
  void showLocations(boolean enabled)
  {
    enableShowLocations = enabled;
  }


  // Automatically called at the end of each draw().
  // This handles the automatic Pixel to LED mapping.
  // If you aren't using that mapping, this function has no effect.
  // In that case, you can call setPixelCount(), setPixel(), and writePixels()
  // separately.
  void draw()
  {
    if (pixelLocations == null) {
      System.out.println("No pixels defined yet");
      return;
    }


    System.out.println("preparing package");
    int numPixels = pixelLocations.length;

    if (myPort == null)
    {
      System.out.println("myPort is null");
    }

    loadPixels();
    try {
      if (myPort!=null)
      {
        myPort.write((byte) 'O');
        myPort.write((byte) 'P');
        myPort.write((byte) 'C');
      }

      for (int i = 0; i < numPixels; i++) {
        int pixelLocation = pixelLocations[i];
        int pixel = pixels[pixelLocation];
        byte r = (byte) (pixel>>16);
        byte g = (byte) (pixel>>8);
        byte b = (byte) pixel;

        if (myPort!=null)
        {
          myPort.write(r);
          myPort.write(g);
          myPort.write(b);
        }

        if (enableShowLocations) {
          pixels[pixelLocation] = 0xFFFFFF ^ pixel;
        }
      }
    } 
    catch (Exception e) {
      dispose();
    }


    if (enableShowLocations) {
      updatePixels();
    }
  }



  void dispose()
  {

    //disconnect
  }

  public void run()
  {
    // Thread tests server connection periodically, attempts reconnection.
    // Important for OPC arrays; faster startup, client continues
    // to run smoothly when mobile servers go in and out of range.
    for (;; ) {

      if (myPort == null) { // No OPC connection?
        try {              // Make one!
        } 
        catch (Exception e) {
          dispose();
        }
      }

      // Pause thread to avoid massive CPU load
      try {
        Thread.sleep(500);
      }
      catch(InterruptedException e) {
      }
    }
  }
}