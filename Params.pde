public static final String ACCESS_TOKEN = "pk.eyJ1IjoiZ2x1c2VwcGUiLCJhIjoiY2lnODVuOHEyMDdyeHZrbHgxd3YxaHd3MCJ9.y3I1ac6f8QhOeaQgmHknEA";
public static final String MAP_ID = "gluseppe.581d9fd9";
public static final String SERVER = "http://127.0.0.1:8080/";
public static final String TRAFFIC_BRANCH = "traffic?item=traffic";
public static final String OWNSHIP_BRANCH = "traffic?item=myState";
public static final String PREDICTION_BRANCH = "prediction";
public static final char SPACEBAR = ' ';
public static final float METERS_TO_FEET = 3.2808399;

public static final String OWNSHIP_REQ_URL = SERVER+OWNSHIP_BRANCH;
public static final String TRAFFIC_REQ_URL = SERVER+TRAFFIC_BRANCH;


//http://localhost:8080/prediction?flight_id=C-3PO&deltaT=30&nsteps=2&raw=true&cluster=true
int DELTA_T = 60;
int N_STEPS = 5;
String RAW = "true";
String CLUSTER = "true";





  //COLORS
  int trafficAlpha = 200; 
  int magenta = color(255, 0, 255, trafficAlpha);
  int green = color(0, 255, 0, trafficAlpha);
  int yellow = color(255, 255, 0, trafficAlpha);
  int ownshipColor = magenta;
  int trafficColor = green;

  //SHAPES AND DIMENSIONS
  float trafficRadius = 10;
  float clusterRadius = 15;
  float clusterBorder = 3;
  float trafficBorder = 3;
  float minimumInnerRadiusTraffic = 2;
  float maximumInnerRadiusTraffic = trafficRadius-minimumInnerRadiusTraffic;
  float minimumInnerRadiusCluster = 2;
  float maximumInnerRadiusCluster = clusterRadius-minimumInnerRadiusCluster;
  float lineLength = 40;
  final float LOWER_THRESHOLD = -50.0;
  final int SAME = -1;
  final float HIGHER_THRESHOLD = 50.0;
  final float SEPARATION_THRESHOLD = 500.0;
  final float MINIMUM_INNER_RADIUS = 2;


  float earthC = 40075000;

  //public static final int TRAFFIC_RADIUS = 15;
  //public static final int MAXIMUM_INNER_RADIUS = TRAFFIC_RADIUS-MINIMUM_INNER_RADIUS;