import de.looksgood.ani.*;

class Cluster {
  
  Ani ani;
  
  int type = -1;
  int usingColor = -1;

  float x,y,altitude,size,ownshipAltitude,uncertainty;
  float bubble_radius;
  float end_x, end_y;
  float horizon;
  ScreenPosition sp;
  
  //flightlocation is the location of the flight to which the cluster/particle belongs
  //it is needed for the animation, we use it as starting point of the animation
  Location flightLocation;
  Location clusterLocation;
  UnfoldingMap map;
  
  public Cluster(float x, float y, float altitude, float ownshipAltitude, UnfoldingMap map) {
    this.x = x;
    this.y = y;
    this.altitude = altitude;
    this.ownshipAltitude = ownshipAltitude;
    this.map = map;
    this.bubble_radius = 0.0;
    //Ani.init(this);
  }
  
  public Cluster(Location clusterLocation, Location flightLocation, float clusterAltitude, float ownshipAltitude, UnfoldingMap map) {
    this.clusterLocation = clusterLocation;
    this.flightLocation = flightLocation;
    this.altitude = clusterAltitude;
    this.ownshipAltitude = ownshipAltitude;
    this.map = map;
    this.sp = map.getScreenPosition(flightLocation);
    this.x = sp.x;
    this.y = sp.y;
    this.bubble_radius = 0.0;
    
    
  }
  
  public Cluster(Location flightLocation, UnfoldingMap map) {
    this.flightLocation = flightLocation;
    this.map = map;
    this.bubble_radius = 0.0;
   //nothing to do here, but if you use this constructor you will have to set up x,y,altitude and ownship altitude 
  }
  
  
  
  public void draw(Location clusterLocation, float clusterAltitude, float ownshipAltitude) {
    this.clusterLocation = clusterLocation;
    this.altitude = clusterAltitude;
    this.ownshipAltitude = ownshipAltitude;
    draw();
  }
  
  float metersOfPixel() {
    float z = map.getZoomLevel();
    return earthC * cos(radians(this.clusterLocation.getLat()))/pow(2,z+8);
  }
  
  
  
  public void draw() {    
    //fill(color(0,255,0,100));
    //ellipse(x,y,20,20);
   
    
    
    //println("uncertainty:" + str(uncertainty));
    //println("meters of pixel:" + str(metersOfPixel()));
    //println("level:" + str(map.getZoomLevel()));
    this.size = this.uncertainty / metersOfPixel();
    //clusterRadius = this.size;
    
    //if you put this lines it won't animate, but it will draw them directly in the final position
    //and the position will be correct even after you move/zoom etc
    ScreenPosition sp = map.getScreenPosition(clusterLocation);
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
      
    drawUncertaintyRing(x,y);
  }
  
  
  void drawUncertaintyRing(float x, float y) {
    noFill();
    strokeWeight(clusterBorder + 2);
    stroke(color(0,255,0, 100));
    ellipse(x,y,this.bubble_radius,this.bubble_radius);
  }
   
  
  
  //draws the traffic when it has about the same altitude
  void drawImportant(float x, float y, float altitude, int zoomLevel, String callsign) {
    
    fill(ownshipColor);
    stroke(usingColor);
    strokeWeight(clusterBorder);
    ellipse(x, y, clusterRadius, clusterRadius);
    
  }


  void drawLower(float x, float y, float delta, int zoomLevel, String callsign) {
    
    float c_delta = delta;
    if (-delta <= -SEPARATION_THRESHOLD) 
      c_delta = SEPARATION_THRESHOLD;

    float blankSpace = (c_delta*(clusterRadius-minimumInnerRadiusCluster))/SEPARATION_THRESHOLD;
    float inner_radius = clusterRadius - blankSpace;
    
    noFill();
    stroke(usingColor);
    strokeWeight(clusterBorder);

    ellipse(x, y, clusterRadius, clusterRadius);
    fill(ownshipColor);
    noStroke();
    ellipse(x, y, inner_radius, inner_radius);

  }

  void drawHigher(float x, float y, float delta, int zoomLevel, String callsign) {
    
    float c_delta = delta;

    if (delta >= SEPARATION_THRESHOLD) 
      c_delta = SEPARATION_THRESHOLD;
    
    
    float whiteRadius = (c_delta*(clusterRadius-clusterBorder))/SEPARATION_THRESHOLD;
    
    fill(ownshipColor);
    stroke(usingColor);
    strokeWeight(clusterBorder);
    ellipse(x, y, clusterRadius, clusterRadius);
    noStroke();
    fill(color(80, 80, 80));
    ellipse(x, y, whiteRadius, whiteRadius);
    
    
  }
 
  //called by clusters prediction handler to animate the uncertainty bubble of the cluster
  //prediction handler will call each clusters.pulse accordingly to the associate time horizon
  //it will convey an animation of a series of clusters pulsing
  public void pulse() {
    float delay = this.horizon / 2000;
    ani = new Ani(this, 0.5, delay, "bubble_radius", this.size);
    ani.repeat(3);
    //Ani.to(this, 0.5, delay, "bubble_radius", this.size);
    
    
  }
  
  /**
  Set the x,y 
  **/
  public void animate() {
    ScreenPosition sp = map.getScreenPosition(this.clusterLocation);
    this.end_x = sp.x;
    this.end_y = sp.y;
    //(java.lang.Object theTarget, float theDuration, float theDelay, java.lang.String theFieldName, float theEnd) 
    //this.flightAni = Ani.from(this, 1.0, 0.0, "x", random(0,width));
    Ani.to(this, 1.0, "x", this.end_x);
    Ani.to(this, 1.0, "y", this.end_y);
    println("animate+++");
  }
  
  
}