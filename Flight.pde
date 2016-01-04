import de.looksgood.ani.*;

class Flight {

  public static final int OWNSHIP = 0;
  public static final int TRAFFIC = 1;
  public static final int RAD = 1;
  public static final int DEG = 2;


  int type = -1;
  int usingColor = -1;
  
  private PVector speed; //vx, vy, vz

  Ani flightAni;
  public float x;
  public float y;

  public float ani_x;
  public float ani_y;

  public float altitude;

  public int relativeAltitude;
  
  
  
 // PredictionHandler predictionHandler;
  ClustersPredictionHandler predictionHandler;
  boolean predictionActive = false;
  boolean predictionRequested;
  
  String callsign;
  Location location;
  Manager m;


  public Flight(int type, Manager manager) {
    this.type = type;
    this.m = manager;
    this.location = new Location(0.0, 0.0);
    this.altitude = 0.0;
    this.speed = new PVector();
    
  }
  
  public void predictionRequested() {
    this.predictionActive = true;
    this.predictionHandler = new ClustersPredictionHandler(this, this.m);
//    this.predictionHandler = new PredictionHandler(map,this);
  }
  
  
  public void stopPrediction() {
    this.predictionActive = false;
    this.predictionHandler.clean();
    this.predictionHandler = null;
    
  }
  
  public void drawTime() {
    if (this.predictionActive) {
      this.predictionHandler.pulse();
    }
  }
  
  public void draw(String callsign) {
    float heading = getHeading(Flight.DEG);
    
    this.callsign = callsign;
    ScreenPosition sp = map.getScreenPosition(location);
    this.x = sp.x;
    this.y = sp.y; //<>// //<>//
    draw(sp.x,sp.y,this.altitude,heading,this.m.ownship.altitude,this.m.current_rot,this.m.map.getZoomLevel(),callsign);
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
      if (delta <= LOWER_THRESHOLD) {
        drawLower(x, y, abs(delta), heading, currentRot, zoomLevel, callsign);
      } else
      {
        if (delta >= HIGHER_THRESHOLD)
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
    text(callsign, 0+5, 0+trafficRadius+5);
    text("@" + int(altitude) + "ft", 0+5, 0+trafficRadius+LINESPACE);
    stroke(usingColor);
    strokeWeight(2);
    line(0, 0, 0, -lineLength);
    popMatrix();
  }

  private float getRot(float heading) {

    if (heading > 180) return -(360-heading);
    else return heading;
  }
  
  public void setSpeed(PVector speed) {
    this.speed = speed;
  }
  
  public void setLocation(Location location, float altitude) {
    this.location = location;
    this.altitude = altitude;
  }
  
  public void setStatus(float lat,float lon,float h,float vx,float vy,float vz) {
    this.location.setLat(lat);
    this.location.setLon(lon);
    this.altitude = h;
    this.speed.x = vx;
    this.speed.y = vy;
    this.speed.z = vz;
  }
  
   public float getHeading(int unit) {
    if (this.speed == null) return 0.0f;
    
    float vx = this.speed.x;
    float vy = this.speed.y;
    if (vx == 0.0 && vy == 0.0)
      return 0.0f;

    float rotAngle = (float) Math.acos(vy/(Math.sqrt(Math.pow(vx,2)+Math.pow(vy,2)))) * (float) (vx/Math.abs(vx));
    if (unit == Flight.RAD) return rotAngle;
    else
      return rotAngle * (180/(float)Math.PI);
  }

  
  //draws the traffic when it has about the same altitude
  void drawTraffic(float x, float y, float altitude, float heading, float currentRot, int zoomLevel, String callsign) {
    fill(ownshipColor);
    stroke(usingColor);
    strokeWeight(2);
    float rot = getRot(heading-currentRot);
    float delta = altitude - m.ownship.altitude;

    pushMatrix();
    translate(x, y);
    ellipse(0, 0, trafficRadius, trafficRadius);
    fill(usingColor);
    
    text(callsign, 0+5, 0+trafficRadius+5);
    fill(ownshipColor);
    text("@" + int(delta) + "ft", 0+5, 0+trafficRadius+LINESPACE);
    fill(usingColor);
    //text(callsign + " " + heading, 0, 0+trafficRadius+5);
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
    if (-delta <= -SEPARATION_THRESHOLD) 
      c_delta = SEPARATION_THRESHOLD;
     

    float blankSpace = (c_delta*(trafficRadius-minimumInnerRadiusTraffic))/SEPARATION_THRESHOLD;
    float inner_radius = trafficRadius - blankSpace;



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
    
    text(callsign, 0+5, 0+trafficRadius+5);
    text("@-" + int(delta) + "ft", 0+5, 0+trafficRadius+LINESPACE);
    
    //text(callsign + " -" + delta, 0, 0+trafficRadius+5);
    rotate(radians(rot));
    fill(usingColor);
    line(0, 0, 0, -lineLength);
    popMatrix();
  }

  void drawHigher(float x, float y, float delta, float heading, float currentRot, int zoomLevel, String callsign) {
    //println("drawing higher for "+callsign);
    fill(ownshipColor);
    stroke(usingColor);
    strokeWeight(trafficBorder);
    
    float c_delta = delta;

    if (delta >= SEPARATION_THRESHOLD) 
      c_delta = SEPARATION_THRESHOLD;

    float whiteRadius = (c_delta*(trafficRadius-trafficBorder))/SEPARATION_THRESHOLD;
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
    text(callsign, 0+5, 0+trafficRadius+5);
    text("@+" + int(delta) + "ft", 0+5, 0+trafficRadius+LINESPACE);
    //text(callsign + " +" + delta, 0, 0+trafficRadius+5);
    rotate(radians(rot));
    strokeWeight(trafficBorder);
    stroke(usingColor);
    line(0, 0, 0, -lineLength);
    popMatrix();
  }
  
  
  
  
}