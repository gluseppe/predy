import de.looksgood.ani.*;

class Cluster {
  
  Ani ani;
  
  int type = -1;
  int usingColor = -1;

  float x,y,altitude,size,uncertainty;
  float bubble_radius;
  float end_x, end_y;
  float horizon;
  ScreenPosition sp;
  
  //flightlocation is the location of the flight to which the cluster/particle belongs
  //it is needed for the animation, we use it as starting point of the animation
  Location flightLocation;
  Location clusterLocation;
  Manager m;
  
  public Cluster(Location clusterLocation, float clusterAltitude, Location flightLocation, Manager manager) {
    this.m = manager;
    this.clusterLocation = clusterLocation;
    this.flightLocation = flightLocation;
    this.altitude = clusterAltitude;
    this.sp = map.getScreenPosition(flightLocation);
    this.x = sp.x;
    this.y = sp.y;
    this.bubble_radius = 0.0;
    
    
  }
  
  
  public void draw(Location clusterLocation, float clusterAltitude) {
    this.clusterLocation = clusterLocation;
    this.altitude = clusterAltitude;
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
      float delta =  altitude - this.m.ownship.altitude;
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
    float delay = this.horizon / 80;
    AniSequence seq = new AniSequence(this.m.applet);
    seq.beginSequence();
      seq.add(new Ani(this, 0.3, delay, "bubble_radius", this.size, Ani.EXPO_OUT,"onEnd:pulseBack"));
      //seq.add(new Ani(this, 1.0, "bubble_radius", 0.0));
    seq.endSequence();
    seq.start();
    
    //ani.repeat(1);
    //Ani.to(this, 0.5, delay, "bubble_radius", this.size);
  }
  
  public void pulseBack() {
    Ani.to(this,0.2,"bubble_radius",0);
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