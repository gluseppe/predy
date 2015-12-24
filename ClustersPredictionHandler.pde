import de.looksgood.ani.*;

class ClustersPredictionHandler {

  UnfoldingMap map;
  //Flight is used to acquire starting position of the animation
  public Flight flight;
  JSONObject prediction;
  JSONObject clusters;
  ArrayList<Particle> arrParticles;
  HashMap<String,ArrayList<Cluster>> mapClusters;
  //int times[] = new int[]{30,60};
  //int times[] = new int[]{30, 60, 90, 120, 150, 180, 210, 240, 270, 300};
  int times[] = new int[]{60, 120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020, 1080, 1140, 1200};
  boolean animationDone = false;

  public ClustersPredictionHandler(UnfoldingMap map, Flight flight) {
    this.map = map;
    this.flight = flight;
    this.arrParticles = new ArrayList();
    this.mapClusters = new HashMap();
    this.prediction = loadJSONObject("blondie23_60_20_cluster.json");
    loadPrediction();
  }


  public void draw() {
    drawPrediction();
    if (!animationDone) {
      animate();
      this.animationDone = true;
    }
  }

  //should be done in a different thread
  void drawPrediction() {

    //fill(255, 0, 0);
    //ellipse(20, 20, 50, 50);
/*
    for (Particle p : this.arrParticles) {
      p.draw();
    }
*/    
    for (String g : this.mapClusters.keySet()) {
      ArrayList<Cluster> cs = this.mapClusters.get(g);
      
      
      ArrayList<ScreenPosition> vertex = new ArrayList();
      
      int cont = 0;
      for (Cluster c : cs) {
        if (cont == 0) {
          ScreenPosition fsp = map.getScreenPosition(c.flightLocation);
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

  public void clean() {
  }
  
  public void pulse() {
    for (String g : this.mapClusters.keySet()) {
      ArrayList<Cluster> cs = this.mapClusters.get(g);
      for (Cluster c : cs) {
        c.pulse();
        
      }
    }
    
    
  }

  private void animate() {

    for (Particle p : this.arrParticles) {
      p.animate();
    }
  }

  private void loadPrediction() {
    JSONArray times_and_intents = this.prediction.getJSONArray(this.flight.callsign);
    //println("size of array is " + times_and_intents.size());
    //JSONObject predictions = times_and_intents.getJSONObject(0);
    /*
    for (int i=0; i<this.times.length; i++) {
      JSONArray particles = predictions.getJSONArray(str(times[i]));
      
      
       for(int j=0;j<particles.size();j++) {
       float[] v_particle = particles.getJSONArray(j).getFloatArray();
       ScreenPosition p_pos = map.getScreenPosition(new Location(v_particle[1],v_particle[0]));
       Particle p = new Particle(flight.x, flight.y, v_particle[2],flight.ownshipAltitude);
       p.end_x = p_pos.x;
       p.end_y = p_pos.y;
       arrParticles.add(p);
       }
       
      

      for (int j=0; j<particles.size(); j++) {
        float[] v_particle = particles.getJSONArray(j).getFloatArray();

        Particle p = new Particle(new Location(v_particle[1], v_particle[0]), this.flight.location, v_particle[2], flight.ownshipAltitude, map); 
        arrParticles.add(p);
      }
      
    }
    */
    
    this.clusters = prediction.getJSONObject("clusters");
    for (Object key : this.clusters.keys()) {
      String intent_group = (String) key;
      JSONObject times_and_clusters = this.clusters.getJSONObject(intent_group);
      for (int t=0;t<this.times.length;t++) {
        int c_time = this.times[t];
        JSONObject j_cluster = times_and_clusters.getJSONObject(str(c_time));
        Cluster c = new Cluster(new Location(j_cluster.getFloat("lat"), j_cluster.getFloat("lon")), this.flight.location, j_cluster.getFloat("h"), flight.ownshipAltitude,map);
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