# Joc_de_Ghicit_Numarul

Acest proiect este un joc interactiv de ghicit numărul, realizat în Bash și distribuit sub forma unei imagini Docker.

Aplicația rulează complet într-un container și necesită doar Docker instalat pe sistemul gazdă.

Cerințe
-------
- Docker Engine (docker.io)

Verificați dacă Docker este instalat:

``
docker --version
``

Imagine Docker
--------------
Imaginea este publicată pe Docker Hub:

**luraaa18/joc_de_ghicit_numarul**

Descărcarea imaginii
--------------------
Pentru a descărca imaginea de pe Docker Hub:

``
docker pull luraaa18/joc_de_ghicit_numarul
``

Verificare:

``
docker images | grep joc_de_ghicit_numarul
``

Rularea jocului
----------------------------
Jocul este interactiv și trebuie rulat cu TTY.

Rulare simplă:

``
docker run -it --rm luraaa18/joc_de_ghicit_numarul --player "Laura"
``

Această comandă:
- pornește jocul în mod interactiv
- șterge containerul după terminare

Persistența datelor (clasament și statistici)
----------------------------------------------
Jocul salvează datele în container în directorul /data:
- highscores.json
- stats.txt

Pentru a păstra aceste fișiere pe sistemul local, se mapează un director local.

Crearea directorului local:

``
mkdir -p data
``

Rulare cu mapare volum:

``
docker run -it --rm -v "$(pwd)/data:/data" luraaa18/joc_de_ghicit_numarul --player "Laura"
``

După rulare, fișierele vor fi disponibile local:
data/highscores.json
data/stats.txt

Rulare cu argumente
-------------------
Argumentele sunt transmise direct scriptului jocului.

Nivel de dificultate și număr de încercări:

``
docker run -it --rm -v "$(pwd)/data:/data" luraaa18/joc_de_ghicit_numarul --level hard --max_tries 10
``

Mod multiplayer:

``
docker run -it --rm -v "$(pwd)/data:/data" luraaa18/joc_de_ghicit_numarul --multiplayer --players 2
``

Afișare clasament:

``
docker run -it --rm -v "$(pwd)/data:/data" luraaa18/joc_de_ghicit_numarul --highscores
``

Afișare statistici jucător:

``
docker run -it --rm -v "$(pwd)/data:/data" luraaa18/joc_de_ghicit_numarul --stats --player "Laura"
``

Observații
----
- Aplicația rulează pe Alpine Linux
- Toate dependențele (bash, jq, coreutils) sunt incluse în imagine
- Nu este necesară nicio configurare suplimentară în afară de Docker

Licență
-------
Proiect educațional – temă.
