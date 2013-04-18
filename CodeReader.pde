import processing.video.*;
import com.google.zxing.*;
import simpleML.*;
import java.awt.image.BufferedImage;

Capture cam;
com.google.zxing.Reader reader = new com.google.zxing.MultiFormatReader();

int WIDTH = 640;
int HEIGHT = 480;
String toAirport;

public class GeoPosition {
  public float lat, lng;

  GeoPosition(float _lat, float _lng) {
    lat = _lat;
    lng = _lng;
  }

  public String toString() {
    return "GeoPosition(" + lat + "," + lng + ")";
  }
}

GeoPosition iuav = new GeoPosition(45.434464, 12.3266);

void setup() {
  size(WIDTH, HEIGHT);
  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    // println("Available cameras:");
    // for (int i = 0; i < cameras.length; i++) {
    //   println(cameras[i]);
    // }
    cam = new Capture(this, cameras[0]);
    cam.start();
  }
}


void draw() {
  if (cam.available() == true) {
    cam.read();
    image(cam, 0,0);
    try {
      BufferedImage buf = new BufferedImage(WIDTH, HEIGHT, 1);
      buf.getGraphics().drawImage(cam.getImage(),0,0,null);
      LuminanceSource source = new BufferedImageLuminanceSource(buf);
      BinaryBitmap bitmap = new BinaryBitmap(new HybridBinarizer(source));
      Result result = reader.decode(bitmap);
      if (result.getText() != null) {
        String str = result.getText();
        println("Boarding pass: " + str);

        // String passengerName = str.substring(2,20);
        // String bookingReference = str.substring(23,30);
        // String fromAirport = str.substring(30,33);
        toAirport = str.substring(33,36);
        // String flightNumber = str.substring(36,43);
        // String seat = str.substring(46,51);

        String url = "http://compasscloud-geocoder.herokuapp.com/" + iuav.lat + "," + iuav.lng + "/" + toAirport;
        HTMLRequest req = new HTMLRequest(this, url);
        req.makeRequest();
        delay(4000);
      }
    } catch (Exception e) {
      // println(e.toString());
    }
  }
}

void netEvent(HTMLRequest ml) {
  float angle = Float.parseFloat(ml.readRawSource());
  println("Angle from IUAV to " + toAirport + " is " + angle + " degrees.");
}
