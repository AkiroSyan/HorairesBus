BusLine line;
BusLine chosen;

void setup() {

  try {
    line = new BusLine();
  } 
  catch (NullPointerException e) {
    print("Impossible de récupérer le fichier. Êtes-vous bien connecté•e à Internet ?");
    exit();
  }
  chosen = new BusLine("13");

  chosen.setStop(1, "GRENOBLE, ANDRE ARGOUGES");
  
  printArray(chosen.nextBus());
}

void draw() {
  exit();
}