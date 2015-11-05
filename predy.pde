import de.fhpotsdam.unfolding.providers.*;
import de.fhpotsdam.unfolding.utils.MapUtils;
import de.fhpotsdam.unfolding.UnfoldingMap;
import de.fhpotsdam.unfolding.geo.Location;
import de.fhpotsdam.unfolding.providers.MBTilesMapProvider;
import java.util.HashTable;


UnfoldingMap map;
HashTable traffic;

public static final String ACCESS_TOKEN = "pk.eyJ1IjoiZ2x1c2VwcGUiLCJhIjoiY2lnODVuOHEyMDdyeHZrbHgxd3YxaHd3MCJ9.y3I1ac6f8QhOeaQgmHknEA";
public static final String MAP_ID = "gluseppe.581d9fd9";
public static final String SERVER = "http://127.0.0.1:8080/";
public static final String TRAFFIC_BRANCH = "";
public static final String OWNSHIP_BRANCH = "";
public static final String PREDICTION_BRANCH = "";
private int elapsedTime = -1;
private int lastUpdate = 0;
private int updatePeriodSeconds = 1;
private int updatePeriod = updatePeriodSeconds * 1000;

void setup() {
  //size(800,600,P2D);
  fullScreen(P2D,1);
  //map = new UnfoldingMap(this, new MBTilesMapProvider(mbTilesString));
  map = new UnfoldingMap(this, new CustomMapBoxProvider(MAP_ID,ACCESS_TOKEN));
  MapUtils.createDefaultEventDispatcher(this,map);
  map.setTweening(true);
  Location parisLocation = new Location(48.864716f, 2.349014f);
  map.zoomAndPanTo(5, parisLocation);
  //float maxPanningDistance = 30; // in km
  //map.setPanningRestriction(berlinLocation, maxPanningDistance);
}


void draw() {
  
  //if new data was received, then update the interface
  //requests are launched as different threads
  launchRequestsIfNeeded();
  
  //checks if request threads returned, if so, updates interface
  updateUIIfNeeded();
  
  
  map.draw();
  Location location = map.getLocation(mouseX, mouseY);
  fill(0);
  text(location.getLat() + ", " + location.getLon(), mouseX, mouseY);
  fill(255,0,50,50);
  noStroke();
  ellipse(100,100,50,50);
  
}


void launchRequestsIfNeeded() {
  elapsedTime = millis();  //measures elapsed time from start of the program, convert in seconds
  //if it's the time, request for new data
  if (elapsedTime - lastUpdate > updatePeriod) {  
  //if more than a 1 second is passed from last update, then it's time to update again the aircraft positions 
    lastUpdate = elapsedTime;
    println("lastupdate:" + lastUpdate);
    //update ownship position data
    thread("requestOwnship");
    //update traffic position data
    thread("requestTraffic");
  }
  
}


void updateUIIfNeeded() {
  
}


//THREAD FUNCTIONS
void requestTraffic() {
  
}


void requestOwnship() {
  String jsonString = loadStrings("");
  
  /*
  JSONArray json = parseJSONArray(data);
  if (json == null) {
    println("JSONArray could not be parsed");
  } else {
    String species = json.getString(1);
    println(species);
    */
    
  /*
   json = loadJSONObject("data.json");
  int id = json.getInt("id");
  String species = json.getString("species");
  String name = json.getString("name");

  println(id + ", " + species + ", " + name);
  
  */
  
  
  
  
}


void requestPrediction() {
  
}

//END THREAD FUNCTIONS