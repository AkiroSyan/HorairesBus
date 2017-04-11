# HorairesBus
### Documentation française

---

### Classe permettant de récupérer facilement différentes données sur le site [data.metromobilite.fr](https://data.metromobilite.fr) et de les traiter afin de récupérer facilement les horaires des prochains bus passant par un arrrêt spécifié.

---

`BusLine()` : _Constructeur_ - Par défaut, met à jour la liste des lignes de bus/tram

Arguments :
* (optionnel) _String_ __id__ : Spécifie l'id de la ligne à charger. Si vide, se contente de mettre à jour la liste des lignes de bus/tram.

Retour :

Exemple :
```
maLigne = new Busline("C5");
```

***
`updateLines()` : Met à jour la liste des lignes de bus/tram

Arguments :

Retour :

***
`getLines()` : Retourne un tableau contenant les noms de toutes les lignes de bus/tram

Arguments :

Retour :
* _String[]_ : tableau contenant les noms des lignes.

Exemple :
```
l = new Busline();
printArray(l.getLines());

# Affiche :
[0] "11"
[1] "12"
...
[49] "D"
[50] "E"
```

***
`listStops()` : Renvoie un tableau contenant les noms des arrêts pour la ligne sélectionnée dans la direction souhaitée.

Arguments :
* _int_ __direction__ : spécifie la direction de la ligne, parmi `0` ou `1`.

Retour :
* _String[]_ : tableau contenant les noms des arrêts.

Exemple :
```
l = new Busline("C5");
l.listStops(0);

# Affiche :
[0] "GIERES, UNIVERSITES - BIOLOGIE"
[1] "SAINT-MARTIN-D'HERES, BIBLIOTHEQUES UNIVERSITAIRES"
...
[26] "GRENOBLE, ESCLANGON"
[27] "GRENOBLE, PALAIS DE JUSTICE"
```

***
`getStop()` : permet de sélectionner un arrêt et de retourner l'objet JSON qui lui est associé.

Arguments :
* _int_ __direction__ : spécifie la direction de la ligne, parmi `0` ou `1`.
* _String_ __name__ : nom de l'arrêt, tel qu'il est référencé dans le tableau renvoyé par `listStops()`

Retour :
* _JSONObject_ : objet représentant l'arrêt.

Exemple :
```
l = new Busline("C5");
print(l.getStop(0, "GRENOBLE, ESCLANGON"));

# Affiche :
{
  "parentStation": "SEM:GENESCLANGO",
  "trips": [
    67500,
    68220,
    68880,
    69480
  ],
  "stopId": "SEM:4280",
  "lon": 5.70683,
  "stopName": "GRENOBLE, ESCLANGON",
  "lat": 45.19126
}
```

***
`nextBus()` : retourne les horaires des prochains bus passant par l'arrêt sélectionné.

Arguments :

Retour :
* _JSONArray_ : tableau contenant un objet pour chaque ligne avec dedans les horaires des prochains bus de la ligne.

Exemple :
```
l = new Busline("C5");
l.getStop(0, "GRENOBLE, ESCLANGON");
printArray(l.nextBus());

# Affiche :
[
  {
    "times": [
      "20:36",
      ...
      "22:18"
    ],
    "desc": "Palais de Justice"
  },
  {
    "times": [
      "20:37",
      ...
      "23:02"
    ],
    "desc": "Universités - Biologie"
  }
]
```

***
`terminus()` : retourne un tableau contenant le terminus associé à chaque direction de la ligne.

Arguments :

Retour :
* _String[]_ : tableau contenant le terminus associé à chaque direction (`0` ou `1`) de la ligne.

Exemple :
```
l = new Busline("C5");
printArray(l.terminus());

# Affiche :
[0] "GRENOBLE, PALAIS DE JUSTICE"
[1] "GIERES, UNIVERSITES - BIOLOGIE"
```
