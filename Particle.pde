import de.looksgood.ani.*;

class Particle {
  
  Ani ani;
  int type = -1;
  int usingColor = -1;

  float x,y,altitude,size,ownshipAltitude;
  float end_x, end_y;
  
  Location flightLocation;
  Location particleLocation;
  UnfoldingMap map;
  
  
  
  
  public Particle(float x, float y, float altitude, float ownshipAltitude, UnfoldingMap map) {
    this.x = x;
    this.y = y;
    this.altitude = altitude;
    this.ownshipAltitude = ownshipAltitude;
    this.map = map;
    
    //Ani.init(this);
  }
  
  public Particle(Location particleLocation, Location flightLocation, float particleAltitude, float ownshipAltitude, UnfoldingMap map) {
    this.particleLocation = particleLocation;
    this.flightLocation = flightLocation;
    this.altitude = particleAltitude;
    this.ownshipAltitude = ownshipAltitude;
    this.map = map;
    ScreenPosition sp = map.getScreenPosition(flightLocation);
    this.x = sp.x;
    this.y = sp.y;
    
    
  }
  
  public Particle() {
   //nothing to do here, but if you use this constructor you will have to set up x,y,altitude and ownship altitude 
  }
  
  
  public void draw() {    
    //fill(color(0,255,0,100));
    //ellipse(x,y,20,20);
    
    //if you put this lines it won't animate, but it will draw them directly in the final position
    //and the position will be correct even after you move/zoom etc
    ScreenPosition sp = map.getScreenPosition(particleLocation);
    this.x = sp.x;
    this.y = sp.y;
    
    
      int zoomLevel = 11;
      usingColor = trafficColor;
      float delta =  altitude - ownshipAltitude;
      if (delta <= LOWER_THRESHOLD) {
        drawLower(x, y, abs(delta), zoomLevel, "");
      } else
      {
        if (delta >= HIGHER_THRESHOLD)
          drawHigher(x, y, abs(delta), zoomLevel, "");
        else
          drawImportant(x, y, altitude, zoomLevel, "");
      }
  }
   
  
  
  //draws the traffic when it has about the same altitude
  void drawImportant(float x, float y, float altitude, int zoomLevel, String callsign) {
    fill(ownshipColor);
    stroke(usingColor);
    strokeWeight(2);
    ellipse(x, y, trafficRadius, trafficRadius);
    
  }


  void drawLower(float x, float y, float delta, int zoomLevel, String callsign) {
    float c_delta = delta;
    if (-delta <= -SEPARATION_THRESHOLD) 
      c_delta = SEPARATION_THRESHOLD;

    float blankSpace = (c_delta*(trafficRadius-minimumInnerRadiusTraffic))/SEPARATION_THRESHOLD;
    float inner_radius = trafficRadius - blankSpace;
    
    noFill();
    stroke(usingColor);
    strokeWeight(2);

    ellipse(x, y, trafficRadius, trafficRadius);
    fill(ownshipColor);
    noStroke();
    ellipse(x, y, inner_radius, inner_radius);

  }

  void drawHigher(float x, float y, float delta, int zoomLevel, String callsign) {
    float c_delta = delta;

    if (delta >= SEPARATION_THRESHOLD) 
      c_delta = SEPARATION_THRESHOLD;

    float whiteRadius = (c_delta*12)/SEPARATION_THRESHOLD;

    fill(ownshipColor);
    stroke(usingColor);
    strokeWeight(2);

    ellipse(x, y, trafficRadius, trafficRadius);
    fill(color(80, 80, 80));
    noStroke();
    ellipse(0, 0, whiteRadius, whiteRadius);
  }
 
  
  /**
  Set the x,y 
  **/
  public void animate() {
    ScreenPosition sp = map.getScreenPosition(this.particleLocation);
    this.end_x = sp.x;
    this.end_y = sp.y;
    //(java.lang.Object theTarget, float theDuration, float theDelay, java.lang.String theFieldName, float theEnd) 
    //this.flightAni = Ani.from(this, 1.0, 0.0, "x", random(0,width));
    Ani.to(this, 1.0, "x", this.end_x);
    Ani.to(this, 1.0, "y", this.end_y);
    println("animate+++");
  }
  
  
}