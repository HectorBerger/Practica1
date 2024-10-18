#!/bin/bash

#Cinqué pas, en el cas que s'introdueixi un paràmtre de cerca.
entrada=$*
if [[ ! -z "$entrada" ]];then #Si la cadena d'entrada no és buida comprovar si existeix l`archiu sortida.csv
	if [[ -f sortida.csv ]];then
		for ((i=1;i<=$(wc -l < sortida.csv);i++));do #For per aïllar l'identificador del vídeo i el títol. ##Pot tardar una mica##
			read line
			if [ $i = 1 ];then
				echo "" >> infosearch.csv
			else
				(echo "$line" | cut -d',' -f 1,3) >> infosearch.csv
			fi
		done < sortida.csv
        	l=$(grep -m 1 -n -i "$entrada" infosearch.csv | cut -b 1) #Grep per trobar el número de la línea amb els paràmetres entrats coincidents.
        	if [[ ! -z $l ]];then #Si hi ha coincidències imprimir Title, Publish_time, views, likes, dislikes, Ranking_Views, Rlikes i Rdislikes per pantalla.
			sortida=$(head -n $l sortida.csv | tail -1)
        		echo "$sortida" | cut -d',' -f 3,6,8,9,10,15,16,17
		else
			echo "No s'han trobat coincidències."
		fi
		rm infosearch.csv
	else
		echo "No existeix l'archiu (sortida.csv). Per tant, no es pot realitzar la cerca."
	fi

else #En el cas que no hi hagi cap entrada de cerca es continua amb el processament del dataset, que comença amb supervivents.csv
#Primer pas, eliminar el thumbnail_link i la description perquè no aporten informació important. Són els identificadors 12 i 16 respectivament.
cut --complement -d"," -f 12,16  supervivents.csv > primera_versio.csv

#Segon pas, eliminem els vídeos que han estat eliminats o donan error, comprovant si (video_error_or_removed) és igual a True. També contarem quants han estat el·liminats, restant les linies de l'archiu després de fer la neteja amb l^archiu complet.
awk -F',' '{if(NR==1) print$0; if($14=="False") print$0 }' primera_versio.csv > segona_versio.csv
linies_original=$(wc -l < primera_versio.csv)
linies_resta=$(wc -l < segona_versio.csv)

echo "S'han eliminat tantes files: $(($linies_original-$linies_resta))"

#Tercer pas, afegirem una columna que ens classificarà els vídeos depenent de les visualitzacions.
awk -F',' '{if(NR==1) print$0",Ranking_Views";else if ($8<1000000) print$0",Bo";else if ($8<10000000) print$0",Excel·lent"; else print$0",Estrella"}' segona_versio.csv > tercera_versio.csv

#Quart pas, afegirem dues columnes amb el ratio de likes i dislikes en funció a les views.
for ((i=1;i<=$linies_resta;i++));do ##Pot tardar minuts##
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

#Al final fem un remove per eliminar tots els archius que ja no necessitem i on hem anant fent petits canvis.
rm primera_versio.csv segona_versio.csv tercera_versio.csv

fi

