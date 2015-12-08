import processing.core.PApplet;
import de.fhpotsdam.unfolding.core.Coordinate;
import de.fhpotsdam.unfolding.providers.OpenStreetMap.GenericOpenStreetMapProvider;


class PMapBoxProvider extends GenericOpenStreetMapProvider {
  private String resourceId;
  private String accessToken;

  public final String api = "https://api.mapbox.com/v4/";
  public final String format = ".png";
  
  public PMapBoxProvider(String resourceId, String accessToken) {
    super();
    this.resourceId = resourceId;
    this.accessToken = accessToken;
    
  }
  
  
  //https://api.mapbox.com/v4/{mapid}/{z}/{x}/{y}.{format}?access_token=<your access token>
  public String[] getTileUrls(Coordinate coordinate) {
    String url = api + this.resourceId + "/" + getZoomString(coordinate) + format + "?access_token=" + this.accessToken;
    return new String[] { url };

  }
  
}