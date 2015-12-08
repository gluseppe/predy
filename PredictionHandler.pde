import de.looksgood.ani.*;

class PredictionHandler {

  UnfoldingMap map;
  //Flight is used to acquire starting position of the animation
  public Flight flight;
  JSONObject prediction;
  ArrayList<Particle> arrParticles;
  //int times[] = new int[]{30,60};
  int times[] = new int[]{30, 60, 90, 120, 150, 180, 210, 240, 270, 300};
  boolean animationDone = false;

  public PredictionHandler(UnfoldingMap map, Flight flight) {
    this.map = map;
    this.flight = flight;
    this.arrParticles = new ArrayList();
    this.prediction = loadJSONObject("blondie23_30_10.json");
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

    fill(255, 0, 0);
    ellipse(20, 20, 50, 50);

    for (Particle p : this.arrParticles) {
      p.draw();
    }
  }

  public void clean() {
  }

  private void animate() {

    for (Particle p : this.arrParticles) {
      p.animate();
    }
  }

  private void loadPrediction() {
    JSONArray times_and_intents = this.prediction.getJSONArray(this.flight.callsign);
    //println("size of array is " + times_and_intents.size());
    JSONObject predictions = times_and_intents.getJSONObject(0);
    for (int i=0; i<this.times.length; i++) {
      JSONArray particles = predictions.getJSONArray(str(times[i]));
      /*
      
       for(int j=0;j<particles.size();j++) {
       float[] v_particle = particles.getJSONArray(j).getFloatArray();
       ScreenPosition p_pos = map.getScreenPosition(new Location(v_particle[1],v_particle[0]));
       Particle p = new Particle(flight.x, flight.y, v_particle[2],flight.ownshipAltitude);
       p.end_x = p_pos.x;
       p.end_y = p_pos.y;
       arrParticles.add(p);
       }
       
       */

      for (int j=0; j<particles.size(); j++) {
        float[] v_particle = particles.getJSONArray(j).getFloatArray();

        Particle p = new Particle(new Location(v_particle[1], v_particle[0]), this.flight.location, v_particle[2], flight.ownshipAltitude, map); 
        arrParticles.add(p);
      }
    }
  }
}