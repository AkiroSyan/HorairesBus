class BusLine {
  private JSONArray lines;
  private JSONObject[] line = new JSONObject[2];
  private String[] lines_ids;
  private String line_id;
  private JSONObject[][] stops;
  private String[][] stops_names;
  private String url;

  private JSONArray stops_times;
  private JSONObject chosen_stop;
  private String chosen_stop_genid;

  BusLine() {
    updateLines();
  }

  BusLine(String id) {
    updateLines();
    if (this.contains(lines_ids, id)) {
      this.line_id = id;
      this.load();
    }
  }

  private void load() {
    this.line = new JSONObject[2];
    this.url = "http://data.metromobilite.fr/api/ficheHoraires/json?route=SEM:" + this.line_id;

    this.stops = new JSONObject[2][];
    this.stops_names = new String[2][];

    for (int j = 0; j < 2; j++) {
      this.line[j] = loadJSONObject(this.url).getJSONObject(str(j));

      this.stops[j] = new JSONObject[this.line[j].getJSONArray("arrets").size()];
      this.stops_names[j] = new String[this.line[j].getJSONArray("arrets").size()];

      for (int i = 0; i < this.stops[j].length; i++) {
        this.stops[j][i] = this.line[j].getJSONArray("arrets").getJSONObject(i);
        this.stops_names[j][i] = this.line[j].getJSONArray("arrets").getJSONObject(i).getString("stopName");
      }
    }
  }

  public void updateLines() throws NullPointerException {
    lines = loadJSONArray("http://data.metromobilite.fr/api/routers/default/index/routes");
    StringList lines_buffer = new StringList();
    for (int i = 0; i < lines.size(); i++) {
      String id = lines.getJSONObject(i).getString("id");
      if ( "SEM".equals(id.substring(0, 3))) {
        lines_buffer.append(id.substring(4));
      }
    }

    lines_ids = new String[lines_buffer.size()];
    lines_buffer.sort();
    lines_ids = lines_buffer.array();
  }

  public String[] getLines() {
    return this.lines_ids;
  }
  
  public String[] listStops(int direction) {
    if (direction < this.stops_names.length) {
      return this.stops_names[direction];
    } else {
      return this.stops_names[0];
    }
  }

  public JSONObject getStop(int direction, String name) {
    if ((direction == 0 || direction == 1) && this.contains(this.stops_names[direction], name)) {
      for (JSONObject stop : this.stops[direction]) {
        if (stop.getString("stopName").equals(name)) {
          println(stop.getString("parentStation"));
          this.chosen_stop = stop;
          this.chosen_stop_genid = stop.getString("parentStation");
          return stop;
        }
      }
    }
    return new JSONObject();
  }

  public JSONArray nextBus() {
    if (this.chosen_stop != null && this.chosen_stop_genid != "") {

      JSONArray stops_times_obj = new JSONArray();

      try {
        stops_times_obj = loadJSONArray("http://data.metromobilite.fr/api/routers/default/index/clusters/"+this.chosen_stop_genid+"/stoptimes");
      } 
      catch (NullPointerException e) {
        println("No connexion…");
      }

      this.stops_times = new JSONArray();

      int len = stops_times_obj.size();

      println(stops_times_obj.size());

      for (int i = 0; i < len; i++) {
        JSONObject stop_obj = stops_times_obj.getJSONObject(i);
        JSONObject stop = new JSONObject();
        stop.setString("desc", stop_obj.getJSONObject("pattern").getString("desc"));

        JSONArray times_obj = stop_obj.getJSONArray("times");
        JSONArray times = new JSONArray();

        for (int j = 0; j < times_obj.size(); j++) {
          JSONObject the_time = times_obj.getJSONObject(j);
          String time_to_add = "";

          if (the_time.getBoolean("realtime")) {
            time_to_add = this.toHuman(the_time.getInt("realtimeArrival"));
          } else {
            time_to_add = this.toHuman(the_time.getInt("scheduledArrival"));
          }

          times.setString(j, time_to_add);
        }

        stop.setJSONArray("times", times);

        this.stops_times.setJSONObject(i, stop);
      }

      println("Loaded");

      return this.stops_times;
    } else {
      return new JSONArray();
    }
  }

  public String[] terminus() {
    String[] terminus = new String[2];
    terminus[0] = this.stops_names[0][this.stops_names[0].length -1];
    terminus[1] = this.stops_names[1][this.stops_names[1].length -1];
    return terminus;
  }

  private boolean contains(String[] haystack, String needle) {
    for (int i = 0; i < haystack.length; i++) {
      if (haystack[i].equals(needle)) {
        return true;
      }
    }
    return false;
  }

  public String toHuman(int s) {
    if (s < 60) {
      return "now";
    }
    int h = s / 3600;
    s -= h * 3600;
    int m = s / 60;

    String h_s = "";
    String m_s = "";

    h_s = (h < 10 ? "0"+str(h) : str(h));
    m_s = (m < 10 ? "0"+str(m) : str(m));

    return h_s+":"+m_s+"";
  }
}