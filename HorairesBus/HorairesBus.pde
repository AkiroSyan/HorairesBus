BusLine line;
BusLine chosen;

int direction = 0;
int lineNumber = 40;
int stopNumber = 14;

void setup() {

  try {
    line = new BusLine();
  } 
  catch (NullPointerException e) {
    print("Impossible de récupérer le fichier. Êtes-vous bien connecté•e à Internet ?");
    exit();
  }
  
  String[] theline = line.getLines();
  
  println("Ligne choisie : ", theline[lineNumber]);
  
  chosen = new BusLine(theline[lineNumber]);
  
  String[] stops = chosen.listStops(direction);
  
  println("Arrêt choisi : ", stops[stopNumber]);

  chosen.setStop(direction, stops[stopNumber]);
  
  println("Terminus : ", chosen.terminus()[direction]);
  
  for(int i = 0; i < chosen.nextBus().size(); i++){
    JSONObject obj = chosen.nextBus().getJSONObject(i);
    println("Direction : ", obj.getString("desc"));
    String[] times = obj.getJSONArray("times").getStringArray();
    for(int j = 0; j < times.length && j < 4; j++) {
      println("    - ", times[j]); 
    }
  }
}

void draw() {
  exit();
}