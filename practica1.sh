#!/bin/bash

#Primer pas, eliminar el thumbnail_link i la description perquè no aporten informació important. Són els identificadors 12 i 16 respectivament.
cut --complement -d"," -f 12,16  supervivents.csv > primera_versio.csv

#
awk -F',' '{if(NR==1) print$0; if($14=="False") print$0 }' primera_versio.csv > segona_versio.csv
linies_original=$(wc -l < primera_versio.csv)
linies_resta=$(wc -l < segona_versio.csv)

echo "S'han eliminat tantes files: $(($linies_original-$linies_resta))"

awk -F',' '{if(NR==1) print$0",Ranking_Views"; if ($8<1000000) print$0",Bo";else if ($8<10000000) print$0",Excel·lent"; else print$0",Estrella"}' segona_versio.csv > tercera_versio.csv
