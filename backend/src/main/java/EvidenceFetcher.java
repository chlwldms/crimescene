import java.io.FileReader;
import java.io.IOException;
import com.google.gson.*;

public class EvidenceFetcher {
    private Gson gson;
    private FileReader reader;
    private String criminalName;

    public EvidenceFetcher(String criminalName) {
        this.gson = new Gson();
        this.criminalName = criminalName;
    }
    
    public String fetchEvidence(String location, String entity, int targetID) {
        try {
            this.reader = new FileReader("./" + location + ".json");

            JsonObject jsonObject = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray jsonArray = jsonObject.getAsJsonArray(entity);
            
            for (int i = 0; i < jsonArray.size(); i++) {
                JsonObject item = jsonArray.get(i).getAsJsonObject();
                if (item.get("id").getAsInt() == targetID) {
                    String description = item.get("description").getAsString();
                    return processEvidence(description);
                }
            }
            
        } catch (IOException e) {
            System.err.println("Error: " + e.getMessage());
            return null;
        } finally {
            try {
                if (reader != null) {
                    reader.close();
                }
            } catch (IOException e) {
                System.err.println("Error: " + e.getMessage());
            }
        }

        return null;
    }
    
    private String processEvidence(String description) {
    	description = description.replace("OOO", criminalName);
    	String gender = "남자";
        if (!criminalName.equals("한규상") && !criminalName.equals("김윤복")) {
            gender = "여자";
        }
    	description = description.replace("XX", gender);
    	return description;
    }
}
