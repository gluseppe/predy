import processing.core.PApplet;
import de.fhpotsdam.unfolding.core.Coordinate;
import de.fhpotsdam.unfolding.providers.OpenStreetMap.*;


public class CustomMapBoxProvider extends GenericOpenStreetMapProvider {

  private String resourceId;
  private String accessToken;

  public static String api = "https://api.mapbox.com/v4/";
  public static String format = ".png";

  //https://api.mapbox.com/v4/{mapid}/{z}/{x}/{y}.{format}?access_token=<your access token>


  public CustomMapBoxProvider(String resourceId, String accessToken) {
    super();
    this.resourceId = resourceId;
    this.accessToken = accessToken;

  }

  public String[] getTileUrls(Coordinate coordinate) {
    String url = api + this.resourceId + "/" + getZoomString(coordinate) + format + "?access_token=" + this.accessToken;
    return new String[] { url };

  }





}