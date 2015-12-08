import de.looksgood.ani.*;

class Flight {

  public static final int OWNSHIP = 0;
  public static final int TRAFFIC = 1;

  public static final float LOWER_THRESHOLD = -50.0;
  public static final int SAME = -1;
  public static final float HIGHER_THRESHOLD = 50.0;
  public static final float SEPARATION_THRESHOLD = 500.0;
  public static final int MINIMUM_INNER_RADIUS = 2;

  public static final int TRAFFIC_RADIUS = 15;
  public static final int MAXIMUM_INNER_RADIUS = TRAFFIC_RADIUS-MINIMUM_INNER_RADIUS;

  int trafficAlpha = 200;

  int magenta = color(255, 0, 255, trafficAlpha);
  int green = color(0, 255, 0, trafficAlpha);
  int yellow = color(255, 255, 0, trafficAlpha);

  float trafficRadius = 15;
  int lineLength = 40;


  int ownshipColor = magenta;
  int trafficColor = green;
  int type = -1;
  int usingColor = -1;

  Ani flightAni;
  public float x;
  public float y;

  public float ani_x;
  public float ani_y;

  public float altitude;

  public int relativeAltitude;
  private float ownshipAltitude;
  
  PredictionHandler predictionHandler;
  boolean predictionActive = false;
  boolean predictionRequested;
  public boolean particleActive = false;
  Particle p;
  
  String callsign;
  
  Location location;
  Location ownshipLocation;
  UnfoldingMap map;


  public Flight(int type, UnfoldingMap map) {
    this.type = type;
    this.map = map;
    p = new Particle();
  }
  
  
  public void predictionRequested(UnfoldingMap map) {
    this.predictionActive = true;
    this.predictionHandler = new PredictionHandler(map,this);
  }
  
  
  public void stopPrediction() {
    this.predictionActive = false;
    this.predictionHandler.clean();
    this.predictionHandler = null;
    
  }
  
  public void draw(Location location, float altitude, float heading, float ownshipAltitude, float currentRot, int zoomLevel, String callsign) {
    
    this.altitude = altitude;
    this.ownshipAltitude = ownshipAltitude;
    this.callsign = callsign;
    this.location = location;
    ScreenPosition sp = map.getScreenPosition(location);
    this.x = sp.x;
    this.y = sp.y;
    draw(sp.x,sp.y,altitude,heading,ownshipAltitude,currentRot,zoomLevel,callsign);
  }


  /**
   Current rot is the map current rotation
   */
  public void draw(float x, float y, float altitude, float heading, float ownshipAltitude, float currentRot, int zoomLevel, String callsign) {
    
    switch(type) {
    case OWNSHIP:
      usingColor = ownshipColor;
      drawOwnship(x, y, altitude, heading, currentRot, zoomLevel, callsign);
      break;

    case TRAFFIC:
      usingColor = trafficColor;
      float delta =  altitude - ownshipAltitude;
      if (delta <= Flight.LOWER_THRESHOLD) {
        drawLower(x, y, abs(delta), heading, currentRot, zoomLevel, callsign);
      } else
      {
        if (delta >= Flight.HIGHER_THRESHOLD)
          drawHigher(x, y, abs(delta), heading, currentRot, zoomLevel, callsign);
        else
          drawTraffic(x, y, altitude, heading, currentRot, zoomLevel, callsign);
      }
      break;
    }
    
    if (this.predictionActive) {
      this.predictionHandler.draw();
    }
    
  }

  private void drawOwnship(float x, float y, float altitude, float heading, float currentRot, int zoomLevel, String callsign) {

    fill(usingColor);
    noStroke();
    pushMatrix();
    translate(x, y);
    ellipse(0, 0, trafficRadius, trafficRadius);
    text(callsign + " " + altitude, 0, 0+trafficRadius+5);
    stroke(usingColor);
    strokeWeight(2);
    line(0, 0, 0, -lineLength);
    popMatrix();
  }

  private float getRot(float heading) {

    if (heading > 180) return -(360-heading);
    else return heading;
  }

  
  //draws the traffic when it has about the same altitude
  void drawTraffic(float x, float y, float altitude, float heading, float currentRot, int zoomLevel, String callsign) {
    fill(ownshipColor);
    stroke(usingColor);
    strokeWeight(2);
    float rot = getRot(heading-currentRot);

    pushMatrix();
    translate(x, y);
    ellipse(0, 0, trafficRadius, trafficRadius);
    fill(usingColor);
    text(callsign + " " + heading, 0, 0+trafficRadius+5);
    rotate(radians(rot));
    stroke(usingColor);
    strokeWeight(2);
    line(0, 0, 0, -lineLength);
    popMatrix();
  }


  void drawLower(float x, float y, float delta, float heading, float currentRot, int zoomLevel, String callsign) {
    fill(usingColor);
    noStroke();

    //println("drawing lower for "+callsign);
    //println("delta is: "+delta);
    float c_delta = delta;
    float rot = getRot(heading-currentRot);
    if (-delta <= -Flight.SEPARATION_THRESHOLD) 
      c_delta = Flight.SEPARATION_THRESHOLD;
     

    float blankSpace = (c_delta*(Flight.TRAFFIC_RADIUS-Flight.MINIMUM_INNER_RADIUS))/Flight.SEPARATION_THRESHOLD;
    float inner_radius = Flight.TRAFFIC_RADIUS - blankSpace;



    pushMatrix();
    translate(x, y);
    noFill();
    stroke(usingColor);
    strokeWeight(2);

    ellipse(0, 0, trafficRadius, trafficRadius);
    fill(ownshipColor);
    noStroke();
    ellipse(0, 0, inner_radius, inner_radius);
    stroke(usingColor);
    fill(usingColor);
    strokeWeight(2);
    text(callsign + " -" + delta, 0, 0+trafficRadius+5);
    rotate(radians(rot));
    fill(usingColor);
    line(0, 0, 0, -lineLength);
    popMatrix();
  }

  void drawHigher(float x, float y, float delta, float heading, float currentRot, int zoomLevel, String callsign) {
    //println("drawing higher for "+callsign);
    fill(ownshipColor);
    stroke(usingColor);
    strokeWeight(2);
    
    float c_delta = delta;

    if (delta >= Flight.SEPARATION_THRESHOLD) 
      c_delta = Flight.SEPARATION_THRESHOLD;

    float whiteRadius = (c_delta*12)/Flight.SEPARATION_THRESHOLD;
    //float externalSrtroke = Flight.TRAFFIC_RADIUS - whiteRadius;
    //println("delta:"+delta);
    //println("whiteradius:"+whiteRadius);


    float rot = getRot(heading-currentRot);

    pushMatrix();
    translate(x, y);
    //noFill();
    //stroke(usingColor);
    //strokeWeight(2);
    //fill(usingColor);
    ellipse(0, 0, trafficRadius, trafficRadius);
    fill(color(80, 80, 80));
    noStroke();
    ellipse(0, 0, whiteRadius, whiteRadius);
    fill(usingColor);    
    text(callsign + " +" + delta, 0, 0+trafficRadius+5);
    rotate(radians(rot));
    strokeWeight(2);
    stroke(usingColor);
    line(0, 0, 0, -lineLength);
    popMatrix();
  }
  
  public void particle() {
    particleActive = (!particleActive);
    
    p.x = this.x;
    p.y = this.y;
    p.altitude = this.ownshipAltitude;
    p.ownshipAltitude = this.ownshipAltitude;
    //p.animate(mouseX,mouseY);
    
      
      //(java.lang.Object theTarget, float theDuration, float theDelay, java.lang.String theFieldName, float theEnd) 
      //this.flightAni = Ani.from(this, 1.0, 0.0, "x", random(0,width));
      //this.flightAni = Ani.from(this, 1.0, 0.0, "y", random(0,height));
    
    this.flightAni = Ani.to(this, 1.0, "trafficRadius", random(10, 90));
  }
}