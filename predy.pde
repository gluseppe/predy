import de.fhpotsdam.unfolding.providers.*; //<>// //<>// //<>// //<>// //<>//
import de.fhpotsdam.unfolding.utils.MapUtils;
import de.fhpotsdam.unfolding.UnfoldingMap;
import de.fhpotsdam.unfolding.geo.Location;
import de.fhpotsdam.unfolding.providers.MBTilesMapProvider;
import de.fhpotsdam.unfolding.utils.ScreenPosition;
import java.util.Iterator;


UnfoldingMap map;



private int elapsedTime = -1;
private int lastUpdate = 0;
private int updatePeriodSeconds = 1;
private int updatePeriod = updatePeriodSeconds * 1000;
PVector rotateCenter;

Manager m;
Location ownshipLocation = null;
float current_rot = 0.0f;

Flight ownship;
//variables in request traffic
JSONObject jTraffic;
String callsign;
StringList trafficList;
int currentTrafficIndex;

HashMap<String,Flight> traffic;

//end variables for request traffic

//graphic setup variables
boolean activePrediction = false;
String predictionActiveFor;

//end graphics

void setup() {
  //size(800,600,P2D);
  fullScreen(P2D, 1);
  map = new UnfoldingMap(this, new PMapBoxProvider(MAP_ID, ACCESS_TOKEN));
  MapUtils.createDefaultEventDispatcher(this, map);
  //map.setTweening(true);
  Location parisLocation = new Location(48.864716f, 2.349014f);
  map.zoomAndPanTo(9, parisLocation);
  this.m = new Manager(this,map);
  this.trafficList = new StringList(); 
  //float maxPanningDistance = 30; // in km
  //map.setPanningRestriction(berlinLocation, maxPanningDistance);
  this.currentTrafficIndex = -1;
  this.traffic = new HashMap();
  Ani.init(this);
}


void draw() {

  //if new data was received, then update the interface
  //requests are launched as different threads

  map.draw();

  launchRequestsIfNeeded();
  Location location = map.getLocation(mouseX, mouseY);
  fill(0);
  text(location.getLat() + ", " + location.getLon(), mouseX, mouseY);
  fill(255, 0, 50, 50);
  noStroke();
  ellipse(mouseX, mouseY, 50, 50);

  //Location parisLocation = new Location(48.864716f, 2.349014f);
  //ScreenPosition test = map.getScreenPosition(parisLocation);
  //fill(0,255,0,50);
  //ellipse(test.x,test.y,50,50);
  //checks if request threads returned, if so, updates interface
  updateUIIfNeeded();
}


//TOP LEVEL FUNCTIONS

void launchRequestsIfNeeded() {
  elapsedTime = millis();  //measures elapsed time from start of the program, convert in seconds
  //if it's the time, request for new data
  if (elapsedTime - lastUpdate > updatePeriod) {  
    //if more than a 1 second is passed from last update, then it's time to update again the aircraft positions 
    lastUpdate = elapsedTime;
    //println("lastupdate:" + lastUpdate);
    //update ownship position data
    thread("requestOwnship");
    //update traffic position data
    thread("requestTraffic");
  }
}


void updateUIIfNeeded() {
  if (this.ownship !=null)
  {
    Location loc = this.ownship.location;
    map.panTo(loc);
    drawOwnship(this.ownship, "ownship");
    drawTraffic();
    rotateMap(this.ownship);
    drawSelectedFlight();
    drawScale(loc);
    
  } else {
    println("ownship location was null");
  }
}


//END TOP LEVEL FUNCTIONS

//DRAWING FUNCTIONS
void drawOwnship(Flight ownship, String callsign) {
  ownship.draw("OWNSHIP");
}


void drawSelectedFlight() {
  String selectedFlight = "'z'< use keys >'m'";
  if (currentTrafficIndex != -1)
    selectedFlight = trafficList.get(currentTrafficIndex);
    
  stroke(color(255,255,255));
  strokeWeight(3);
  fill(255,255,255);
  text("Selected:"+selectedFlight, 100, height-50);
}

void drawScale(Location l) {
  float z = map.getZoomLevel();
  float earthC = 40075000;
  float d_px = earthC * cos(radians(l.getLat()))/pow(2,z+8);
  stroke(color(255,255,255));
  strokeWeight(3);
  fill(255,255,255);
  line(width-300,height-50,width-200,height-50);
  text(str(d_px*100) + " meters", width-230,height-60);
}



void drawIntruderFlight(float lat, float lon, float altitude, float vx, float vy, float vz, String callsign) {
  if (traffic.containsKey(callsign)) {
    Flight f = traffic.get(callsign);
    f.setStatus(lat,lon,altitude,vx,vy,vz);
    f.draw(callsign);
  }
  else
  {
    Flight aTraffic = new Flight(Flight.TRAFFIC,this.m);
    aTraffic.setStatus(lat,lon,altitude,vx,vy,vz);
    traffic.put(callsign,aTraffic);
    aTraffic.draw(callsign);
    
  }
  
  
  //println("number of flights:" + str(traffic.size()));
}

void drawTraffic() {
  if (jTraffic != null) {
    float lat, lon, h, vx, vy, vz;
    String cs;
    JSONObject fs;
    Iterator i = jTraffic.keyIterator();
    //ScreenPosition sp;

    while (i.hasNext()) {

      cs = (String) i.next();
      this.trafficList.appendUnique(cs);
      fs = jTraffic.getJSONObject(cs);
      lat = fs.getFloat("lat");
      lon = fs.getFloat("lon");
      h = fs.getFloat("h")*METERS_TO_FEET;
      vx = fs.getFloat("vx");
      vy = fs.getFloat("vy");
      vz = fs.getFloat("vz");
      
      //sp = map.getScreenPosition(new Location(lat, lon));

      drawIntruderFlight(lat, lon, h, vx, vy, vz, cs);
    }
  }
}


//END DRAWING FUNCTIONS



//UTILITY FUNCTIONS
float getRot(float heading) {

  if (heading > 180) return -(360-heading);
  else return heading;
}

public void rotateMap(Flight ownship) {

  float oHead = this.ownship.getHeading(FlightStatus.DEG);
  ScreenPosition sp = map.getScreenPosition(ownship.location);
  map.mapDisplay.setInnerTransformationCenter(sp);
  //float rot = getRot(oHead);
  float d = oHead - current_rot;
  float rot = getRot(d);

  map.rotate(-radians(rot));

  this.current_rot = oHead;
  this.m.current_rot = this.current_rot;
}

public float getHeading(int unit, float vx, float vy) {
  if (vx == 0.0 && vy == 0.0)
    return 0.0f;

  float rotAngle = (float) Math.acos(vy/(Math.sqrt(Math.pow(vx, 2)+Math.pow(vy, 2)))) * (float) (vx/Math.abs(vx));
  if (unit == Flight.RAD) return rotAngle;
  else
    return rotAngle * (180/(float)Math.PI);
}
//END UTILITY FUNCTIONS

//THREAD FUNCTIONS
void requestTraffic() {
  jTraffic = loadJSONObject(TRAFFIC_REQ_URL);
  /*
  Iterator i = jTraffic.keyIterator();
   
   while(i.hasNext()) {
   
   callsign = (String) i.next();
   println(callsign);
   FlightStatus fs = new FlightStatus(new Location(jTraffic.getFloat("lat"),jTraffic.getFloat(lon)),jTraffic.getFloat("h"),new PVector(jTraffic.getFloat("vx"),jTraffic.getFloat("vy"),jTraffic.getFloat("vz"));
   traffic.put(callsign,fs);
   }
   
   */
}


void requestOwnship() {
  //{"h": 1793.2, "lon": 0.6976448569, "lat": 48.7798111273, "vx": 139.71504, "vy": 103.88276, "vz": 12.19092}
  JSONObject jOwnship = loadJSONObject(OWNSHIP_REQ_URL);
  /*
  float lat = jOwnship.getFloat("lat");
  float lon = jOwnship.getFloat("lon");
  float h = jOwnship.getFloat("h");
  float vx = jOwnship.getFloat("vx");
  float vy = jOwnship.getFloat("vy");
  float vz = jOwnship.getFloat("vz");
  */

  if (this.ownship != null) {
    this.ownship.setStatus(jOwnship.getFloat("lat"), jOwnship.getFloat("lon"),jOwnship.getFloat("h"), jOwnship.getFloat("vx"), jOwnship.getFloat("vy"), jOwnship.getFloat("vz"));
  } else
  {
    println("ownship created");
    //ownshipLocation = new Location(jOwnship.getFloat("lat"), jOwnship.getFloat("lon"));
    this.ownship = new Flight(Flight.OWNSHIP,this.m);
    this.m.ownship = this.ownship;
    this.ownship.setStatus(jOwnship.getFloat("lat"), jOwnship.getFloat("lon"), jOwnship.getFloat("h"), jOwnship.getFloat("vx"), jOwnship.getFloat("vy"), jOwnship.getFloat("vz"));
  }
  //<>//
}


void requestPrediction() {
} //<>//

//END THREAD FUNCTIONS



void keyPressed() {
  if (key==CODED)
   {
     switch(keyCode) {
       case BACKSPACE: break;
       
   }
     
   }
   else
   {
     switch(key) {
       case ' ': { 
         activePrediction = ! activePrediction;
         if (activePrediction) {
           if (currentTrafficIndex!= -1)
           {
             println("activating prediction");
             Flight f = traffic.get(trafficList.get(currentTrafficIndex));
             f.predictionRequested();
             predictionActiveFor = f.callsign;
           }
         }
         else {
           Flight f = traffic.get(predictionActiveFor);
           f.stopPrediction();
           predictionActiveFor = null;
           
         }
         break;
       }
       case 'm': {
         if (trafficList.size() > 0) 
           currentTrafficIndex = (currentTrafficIndex + 1) % trafficList.size();
         break;
       }
       case 'z': {
         if (trafficList.size() > 0) {
           currentTrafficIndex = currentTrafficIndex - 1;
           if (currentTrafficIndex <= -1)
             currentTrafficIndex = trafficList.size()-1;
         }
         break;
       }
       case 'p': 
       {
         //if (this.currentPredictedTraffic != null) {
         // this.currentPredictedTraffic.drawTime();
         //}
         if (predictionActiveFor != null) {
           Flight f = traffic.get(predictionActiveFor);
           f.drawTime();
         }
         break; 
       }
     }
   }
       
  
  
}