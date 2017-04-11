BusLine line;
BusLine chosen;

void setup() {

  println("Hello");
  try {
    println("Updating...");
    line = new BusLine();
  } 
  catch (NullPointerException e) {
    print("Unable to retrieve file. Please check your Internet connexion");
    exit();
  }
  printArray(line.getLines());
  chosen = new BusLine("C5");
  println("Terminus : ");
  printArray(chosen.terminus());
  println("Line with terminus 0 : ");
  printArray(chosen.listStops(0));

  print(chosen.getStop(1, "GRENOBLE, ESCLANGON"));
  
  printArray(chosen.nextBus());
}

void draw() {
  exit();
}