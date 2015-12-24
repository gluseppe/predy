
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