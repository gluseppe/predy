class FlightStatus {
  
  public static final int RAD = 1;
  public static final int DEG = 2;
  
  private Location location;
  public float h;
  
  private PVector speed; //vx, vy, vz
  
  public FlightStatus(Location location, float h, PVector speed) {
    this.location = location;
    this.h = h;
    this.speed = speed;
  }
  
  public FlightStatus() {
    this.location = null;
    this.h = -1;
    this.speed = null;
    
  }
  
  public Location getLocation() {
    return this.location;
  }
  
  public void setStatus(float lat,float lon,float h,float vx,float vy,float vz) {
    this.location.setLat(lat);
    this.location.setLon(lon);
    this.h = h;
    this.speed.x = vx;
    this.speed.y = vy;
    this.speed.z = vz;
  }
  
  //return the heading of the flight in degrees
  public float getHeading(int unit) {
    if (this.speed == null) return 0.0f;
    
    float vx = this.speed.x;
    float vy = this.speed.y;
    if (vx == 0.0 && vy == 0.0)
      return 0.0f;

    float rotAngle = (float) Math.acos(vy/(Math.sqrt(Math.pow(vx,2)+Math.pow(vy,2)))) * (float) (vx/Math.abs(vx));
    if (unit == this.RAD) return rotAngle;
    else
      return rotAngle * (180/(float)Math.PI);
  }
  
}