 #!/bin/bash

#Primer pas, eliminar el thumbnail_link i la description perquè no aporten informació important. Són els identificadors 12 i 16 respectivament.
cut --complement -d "," -f 12,16 -n supervivents.csv > proba.txt 
