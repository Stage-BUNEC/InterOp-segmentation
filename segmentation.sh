
# Test pour s'assurer que l'on fait bonne usage du porgramme
if [ $# -ne 1 ]
then
	printf "Le nombre d'argument n'est pas correct\nUsage:\n\t/bin/sh $0 chemin/vers/repertoire\n\n"
	exit 0
fi
# fin du test

	
REPERTOIRE_CSV=$1
VIDE="id_vide"
REGEX="*fosa*" #pour rechercher uniquement les fosa, a modifier si on veut rechercher les cec par exemple
REPERTOIRE_FRAGMENTS=fragments/ #indiquer le repertoire des fragments


for fichier in `ls $REPERTOIRE_CSV | grep -E $REGEX`
do 
	chemin_complet=$REPERTOIRE_CSV$fichier
	printf "\n\n########## Debut lecture du fichier -> $chemin_complet ##########\n\n"

	# cette boucle permet de lire le contenu du fichier ligne par ligne
	while IFS= read -r ligne
	do
		id=`echo $ligne | awk -F '#' '{print $1}'` # recuperation du champ qui nous interesse

		# on test si la variable a du cotenue ou non
		if [ -z "$id" ]
		then
			`echo $ligne >> "$REPERTOIRE_FRAGMENTS""$VIDE""_""$fichier"` 
		else
			`echo $ligne >> "$REPERTOIRE_FRAGMENTS""$id""_""$fichier"` 
		fi
		
	done < $chemin_complet

	printf "\n\n########## Fin lecture du fichier -> $chemin_complet ##########\n\n"
done
