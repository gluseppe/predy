import de.looksgood.ani.*;

class ClustersPredictionHandler {

  
  //Flight is used to acquire starting position of the animation
  public Flight flight;
  JSONObject prediction;
  JSONObject clusters;
  JSONArray ownshipJClusters;
  ArrayList<Particle> arrParticles;
  HashMap<String,ArrayList<Cluster>> mapClusters;
  HashMap <Integer, Cluster> ownshipClusters;
  //int times[] = new int[]{30,60};
  //int times[] = new int[]{30, 60, 90, 120, 150, 180, 210, 240, 270, 300};
  int times[] = new int[]{60, 120, 180, 240, 300};
  boolean animationDone = false;
  Manager m;

  public ClustersPredictionHandler(Flight flight, Manager manager) {
    this.m = manager;
    this.flight = flight;
    this.arrParticles = new ArrayList();
    this.mapClusters = new HashMap();
    this.ownshipClusters = new HashMap();
    this.prediction = loadJSONObject("clusters_ownship/C3PO.json");
    loadPrediction();
  }


  public void draw() {
    drawPrediction();
    if (!animationDone) {
      animate();
      this.animationDone = true;
    }
  }
  
  void drawFlightPrediction() {
    for (String g : this.mapClusters.keySet()) {
      ArrayList<Cluster> cs = this.mapClusters.get(g);
      
      
      ArrayList<ScreenPosition> vertex = new ArrayList();     
      int cont = 0;
      for (Cluster c : cs) {
        if (cont == 0) {
          ScreenPosition fsp = map.getScreenPosition(c.flightLocation);
          //we need to add it twice as the first one is not going to appear on the screen
          vertex.add(new ScreenPosition(fsp.x,fsp.y));
          vertex.add(new ScreenPosition(fsp.x,fsp.y));
        }
        c.draw();
        ScreenPosition v = new ScreenPosition(c.x, c.y);
        vertex.add(v);
        cont ++;
      }
      
      noFill();
      stroke(color(0,255,0));
      strokeWeight(2);
      beginShape();
      cont = 0;
      float app_x = 0.0;
      float app_y = 0.0;
      for (ScreenPosition v: vertex) {
        curveVertex(v.x, v.y);
        app_x = v.x;
        app_y = v.y;
        cont ++;
        //println("vertex x:" + str(v.x));
        //println("vertex y:" + str(v.y));
        //println("vertexes");
      }
      curveVertex(app_x, app_y);
      endShape();
    }

  }
  
  void drawOwnshipPrediction() {
    int cont = 0;
    ArrayList<ScreenPosition> vertex = new ArrayList();
    for (Integer time : this.ownshipClusters.keySet()) {
      Cluster c = this.ownshipClusters.get(time);
      if (cont == 0) {
          ScreenPosition osp = map.getScreenPosition(ownshipLocation);
          vertex.add(new ScreenPosition(osp.x,osp.y));
          vertex.add(new ScreenPosition(osp.x,osp.y));
      }
      c.draw();
      ScreenPosition v = new ScreenPosition(c.x, c.y);
      vertex.add(v);
      cont ++;
    }
    
    noFill();
      stroke(color(0,255,0));
      strokeWeight(2);
      beginShape();
      cont = 0;
      float app_x = 0.0;
      float app_y = 0.0;
      for (ScreenPosition v: vertex) {
        curveVertex(v.x, v.y);
        app_x = v.x;
        app_y = v.y;
        cont ++;
        //println("vertex x:" + str(v.x));
        //println("vertex y:" + str(v.y));
        //println("vertexes");
      }
      curveVertex(app_x, app_y);
      endShape();
    
  }

  //should be done in a different thread
  void drawPrediction() {
    drawFlightPrediction();
    drawOwnshipPrediction();

      
     //<>//
  }

  public void clean() {
  }
  
  public void pulse() {
    for (String g : this.mapClusters.keySet()) {
      ArrayList<Cluster> cs = this.mapClusters.get(g);
      for (Cluster c : cs) {
        c.pulse();
        
      }
    }
    
    for (Integer i : this.ownshipClusters.keySet()) {
      Cluster c = this.ownshipClusters.get(i);
      c.pulse();
    }
    
    
  }

  private void animate() {

    for (Particle p : this.arrParticles) {
      p.animate();
    }
  }

  public void loadPrediction() {
    
    println("inside load prediction");
  
    
    this.ownshipJClusters = prediction.getJSONArray("ownship");
    for (int k=0;k<this.ownshipJClusters.size();k++){
      JSONArray time_and_center = this.ownshipJClusters.getJSONArray(k);
      int time = time_and_center.getInt(0);
      
      JSONArray jcenter = time_and_center.getJSONArray(1);
      float lat = jcenter.getFloat(1);
      float lon = jcenter.getFloat(0);
      float h = jcenter.getFloat(2);
      println("lat:"+str(lat)+" lon:"+str(lon));
      Cluster c = new Cluster(new Location(lat,lon),h, this.m.ownship.location , this.m);
      c.uncertainty = 2500;
      c.horizon = float(time);
      this.ownshipClusters.put(new Integer(time),c);
    }
    
    this.clusters = prediction.getJSONObject("clusters");
    for (Object key : this.clusters.keys()) {
      String intent_group = (String) key;
      JSONObject times_and_clusters = this.clusters.getJSONObject(intent_group);
      for (int t=0;t<this.times.length;t++) {
        int c_time = this.times[t];
        JSONObject j_cluster = times_and_clusters.getJSONObject(str(c_time));
        Cluster c = new Cluster(new Location(j_cluster.getFloat("lat"), j_cluster.getFloat("lon")), j_cluster.getFloat("h"), this.flight.location, this.m);
        c.uncertainty = j_cluster.getFloat("uncertainty");
        c.horizon = c_time;
        if (this.mapClusters.containsKey(intent_group)) {
          this.mapClusters.get(intent_group).add(c);
        }
        else
        {
          ArrayList a = new ArrayList<Cluster>();
          a.add(c);
          this.mapClusters.put(intent_group,a);
        }
        
      }
    }
    
    
    
  }
  
  
  
}