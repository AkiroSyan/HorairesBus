/**
 * BusLine est une classe permettant d'interagir avec l'API de Métromobilité afin de récupérer les données concernant les transport
 * en commun de la ville de Grenoble.
 * Permet de récupérer toutes les lignes (bus et tram) de la ville, de sélectionner un arrêt et ensuite d'en afficher les horaires
 *
 * @author Tim Girard <tim@akiro.ovh>
 * @version 0.1
 */
class BusLine {
  private JSONObject[] line = new JSONObject[2]; //Tableau stockant la ligne dans les 2 directions
  private String[] lines_ids; //Tableau contenant les IDs des lignes SEMITAG
  private String line_id; //ID de la ligne sélectionnée
  private JSONObject[][] stops; //Tableau contenant les arrêts (objets JSON) de la ligne sélectionnée, dans les 2 directions
  private String[][] stops_names; //Idem, avec les noms
  private String url; //URL à appeler pour charger les infos de la ligne

  private JSONArray stops_times; //Tableau JSON contenant les horaires des lignes passant par l'arrêt choisi
  private JSONObject chosen_stop; //Objet contenant l'arrêt choisi
  private String chosen_stop_genid; //Identifiant SEMITAG de l'arrêt

  /**
   * Constructeur vide. Par défaut, actualise les lignes
   */
  BusLine() {
    updateLines(); //Met à jour les lignes de bus
  }

  /**
   * Constructeur. Charge en mémoire la ligne dont l'ID est passé en paramètre si celle-ci existe.
   *
   * @param id ID de la ligne à charger
   */
  BusLine(String id) {
    updateLines();
    if (this.contains(lines_ids, id)) { // Si la ligne passée en paramètre existe, alors on la charge.
      this.line_id = id;
      this.load();
    }
  }

  /**
   * Privée, appelée par le constructeur seulement. Charge en mémoire la ligne choisie.
   */
  private void load() {
    this.line = new JSONObject[2];
    this.url = "http://data.metromobilite.fr/api/ficheHoraires/json?route=SEM:" + this.line_id; //URL à appeler pour avoir les infos sur la ligne

    this.stops = new JSONObject[2][]; //Pour stocker la liste des arrêts dans chaque sens
    this.stops_names = new String[2][]; //Les noms des arrêts

    for (int j = 0; j < 2; j++) { //Pour chaque sens
      this.line[j] = loadJSONObject(this.url).getJSONObject(str(j)); //On reçoit un tableau JSON contenant 2 objets, donc on le met dans 2 objets JSON

      this.stops[j] = new JSONObject[this.line[j].getJSONArray("arrets").size()]; // On définit un tableau de la bonne taille pour les arrêts
      this.stops_names[j] = new String[this.line[j].getJSONArray("arrets").size()];

      for (int i = 0; i < this.stops[j].length; i++) { //Pour chaque arrêt de la ligne, on remplit le tableau
        this.stops[j][i] = this.line[j].getJSONArray("arrets").getJSONObject(i);
        this.stops_names[j][i] = this.line[j].getJSONArray("arrets").getJSONObject(i).getString("stopName");
      }
    }
  }

  /**
   * Met à jour les lignes de bus disponibles.
   *
   * @throws NullPointerException Si le site est indisponible
   */
  public void updateLines() throws NullPointerException { //Attention : Renvoie une erreur si pas de conenxion
    JSONArray lines = loadJSONArray("http://data.metromobilite.fr/api/routers/default/index/routes"); //URL à appeler pour avoir toutes les lignes
    StringList lines_buffer = new StringList();  //Liste "tampon" pour ajouter au fur et à mesure les lignes triées
    for (int i = 0; i < lines.size(); i++) {
      String id = lines.getJSONObject(i).getString("id"); //On récupère l'ID de la ligne…
      if ( "SEM".equals(id.substring(0, 3))) { //…pour enlever les lignes non SEMITAG
        lines_buffer.append(id.substring(4));
      }
    }

    lines_ids = new String[lines_buffer.size()]; //On convertit tout ça en tableau, plus optimisé
    lines_buffer.sort();
    lines_ids = lines_buffer.array();
  }

  /**
   * Retourne les IDs de toutes les lignes disponibles.
   * 
   * @return Tableau contenant les IDs des lignes disponibles
   */
  public String[] getLines() { 
    return this.lines_ids;
  }

  /**
   * Liste les arrêts de la ligne choisie dans la direction donnée.
   *
   * @param direction Direction de la ligne, doit être 0 ou 1
   *
   * @return Tableau contenant les noms de tous les arrêts
   */
  public String[] listStops(int direction) {
    if (this.line_id == null)
      return null;

    if (direction == 0 || direction == 1) { //Si une direction valide est fournie, on retourne la ligne correspondante
      return this.stops_names[direction];
    } else return null;
  }

  /**
   * Sélectionne l'arrêt de bus choisi dans la direction choisie.
   *
   * @param direction Direction de la ligne
   * @param name Nom de l'arrêt
   */
  public void setStop(int direction, String name) {
    if (this.line_id != null && (direction == 0 || direction == 1)&& this.contains(this.stops_names[direction], name)) { //Si la direction est valide et que la ligne contient l'arrêt
      for (JSONObject stop : this.stops[direction]) {
        if (stop.getString("stopName").equals(name)) { //On parcourt jusqu'à trouver l'arrêt et on le retourne
          this.chosen_stop = stop;
          this.chosen_stop_genid = stop.getString("parentStation");
        }
      }
    }
  }

  /**
   * Renvoie un tableau JSON contenant les horaires des prochains bus passant par l'arrêt choisi.
   *
   * @return Tableau JSON contenant les horaires de toutes les lignes de bus passant par l'arrêt
   */
  public JSONArray nextBus() {
    if (this.chosen_stop != null && this.chosen_stop_genid != "") { //Si un arrêt est bien sélectionné

      JSONArray stops_times_obj = new JSONArray(); //Nouvel objet pour stocker les horaires récupérés depuis internet

      try {
        stops_times_obj = loadJSONArray("http://data.metromobilite.fr/api/routers/default/index/clusters/"+this.chosen_stop_genid+"/stoptimes");
      } 
      catch (NullPointerException e) {
        println("No connexion…");
      }

      this.stops_times = new JSONArray(); //Nouvel objet pour stocker les horaires formatés

      int len = stops_times_obj.size(); // indique le nombre de lignes dont on a les horaires

      for (int i = 0; i < len; i++) { //Pour chaque ligne
        JSONObject stop_obj = stops_times_obj.getJSONObject(i); //On récupère l'objet (pour le traiter plus facilement)
        JSONObject stop = new JSONObject(); //On en crée un nouveau pour mettre les infos formatées sur l'arrêt
        stop.setString("desc", stop_obj.getJSONObject("pattern").getString("desc")); //On définit un nouveau tag "desc" dans notre objet "stop" et on y met la description de l'objet récupéré sur internet (le nom du terminus)

        JSONArray times_obj = stop_obj.getJSONArray("times"); //On récupère l'objet qui contient horaires
        JSONArray times = new JSONArray(); //On en crée un nouveau pour mettre les horaires formatés

        for (int j = 0; j < times_obj.size(); j++) { //Pour chaque horaire
          JSONObject the_time = times_obj.getJSONObject(j); //On le récupère
          String time_to_add = ""; //Temps à ajouter dans l'objet

          if (the_time.getBoolean("realtime")) { //Récupère l'horaire réel s'il exist, sinon l'horaire prévu
            time_to_add = this.toHuman(the_time.getInt("realtimeArrival"));
          } else {
            time_to_add = this.toHuman(the_time.getInt("scheduledArrival"));
          }

          times.setString(j, time_to_add); //On l'ajoute à notre objet qui recense les horaires formatés
        }

        stop.setJSONArray("times", times); //On ajoute notre objet recensant les horaires à l'objet "stop"

        this.stops_times.setJSONObject(i, stop); //On ajoute notre arrêt et ses horaires à la collection des autres
      }

      return this.stops_times;
    } else {
      return null;
    }
  }

  /**
   * Renvoie un tableau contenant le teminus de la ligne pour chaque direction.
   *
   * @return Tableau contenant le teminus de la ligne pour chaque direction
   */
  public String[] terminus() {
    if (this.line_id == null)
      return null;

    String[] terminus = new String[2];
    terminus[0] = this.stops_names[0][this.stops_names[0].length -1];
    terminus[1] = this.stops_names[1][this.stops_names[1].length -1];
    return terminus;
  }

  /**
   * Vérfiie si un élément est présent dans une collection.
   *
   * @param collection Tableau dans lequel chercher l'élement
   * @param element Élément à chercher
   *
   * @return True si l'élément est présent
   */
  private boolean contains(String[] collection, String element) {
    if (collection == null || element == null) 
      return false;

    for (int i = 0; i < collection.length; i++) {
      if (collection[i].equals(element)) {
        return true;
      }
    }
    return false;
  }

  /**
   * Convertit le temps en nombre de secondes depuis minuit vers un temps lisible par un humain de la forme hh:mm
   *
   * @param s Nombre de secondes à convertir
   *
   * @return Chaîne de caractère représentant le temps converti
   */
  private String toHuman(int s) {
    if (s <= 0) {
      return "missed";
    } else if (s > 0 && s < 60) {
      return "now";
    }
    int h = s / 3600; //Conversion du temps en nombre de secondes depuis minuit en hh:mm
    s -= h * 3600;
    int m = s / 60;

    String h_s = "";
    String m_s = "";

    h_s = (h < 10 ? "0"+str(h) : str(h)); // Pour transformer les heures du type 13:4 en 13:04
    m_s = (m < 10 ? "0"+str(m) : str(m));

    return h_s+":"+m_s;
  }
}