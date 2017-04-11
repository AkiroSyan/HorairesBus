### HorairesBus - Documentation
---
Classe permettant de récupérer facilement différentes données sur le site [data.metromobilite.fr](https://data.metromobilite.fr) et de les traiter afin de récupérer facilement les horaires des prochains bus passant par un arrrêt spécifié.
--

`BusLine()` : _Constructeur_ - Par défaut, met à jour la liste des lignes de bus/tram

Arguments :
* _(optionnel)_ _String_ __id__ : Spécifie l'id de la ligne à charger. Si vide, se contente de mettre à jour la liste des lignes de bus/tram.

Retour :

Exemples :
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

Exemples :
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
