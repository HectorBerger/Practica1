#!/bin/bash
<< "STOP"
#Primer pas, eliminar el thumbnail_link i la description perquè no aporten informació important. Són els identificadors 12 i 16 respectivament.
cut --complement -d"," -f 12,16  supervivents.csv > primera_versio.csv

#Segon pas
awk -F',' '{if(NR==1) print$0; if($14=="False") print$0 }' primera_versio.csv > segona_versio.csv
linies_original=$(wc -l < primera_versio.csv)
linies_resta=$(wc -l < segona_versio.csv)

echo "S'han eliminat tantes files: $(($linies_original-$linies_resta))"

#Tercer pas
awk -F',' '{if(NR==1) print$0",Ranking_Views";else if ($8<1000000) print$0",Bo";else if ($8<10000000) print$0",Excel·lent"; else print$0",Estrella"}' segona_versio.csv > tercera_versio.csv

#Quart pas
for ((i=1;i<=$linies_resta;i++));do
	read line
	if [ $i -eq 1 ];then
		echo "$line,Rlikes,Rdislikes" > sortida.csv
	else
		V=$(echo "$line" | cut -d',' -f 8)
                L=$(echo "$line" | cut -d',' -f 9)
                DL=$(echo "$line" | cut -d',' -f 10)
                echo "$line,$((L*100/$V)),$(($DL*100/$V))" >> sortida.csv
	fi
done < tercera_versio.csv
STOP
#Cinqué pas
entrada=$*
if [[ ! -z "$entrada" ]];then
if [ -f sortida.csv ];then
	l=$(grep -m 1 -n "$entrada" sortida.csv | cut -b 1)
	line=$(head -n $l sortida.csv | tail -1)
	echo "$line" | cut -d',' -f 3,6,8,9,14,15,16

fi
fi
