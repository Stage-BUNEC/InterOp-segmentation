#!/bin/bash

# Liste Dossiers/Repertoires
datasFolder=../BUNEC_datas/var/crvs_dhis2/
cec_match=output/cec_match/
cec_non_match=output/cec_non_match/

# Liste fichiers
liste_fosa_tmp=tampon/liste_fosa.csv
list_fosa_origin=tools/liste_fosa.csv
log_update_fosa=tampon/update_fosa.csv

function checkRecords() {
    # Cette fonction verifie si oui/non le nombre de donnees/enregistrements
    # du fichier log de synchro et les donnees des dossiers CSV sont egales.
    # arg: Elle prend en entre le dossier journalier du FOSA. e.g: 2022-04-28

    # Nbre d'Enregistrement des fichiers de Synchro
    totalSync=$(grep -vc "event_id" "$1"/sync_log_*.csv)

    # Nbre d'Enregistr. des declarations de Naiss Fosa
    totalNaiss=$(grep -vc "commune_id" "$1"/csv/formulaire_de_declaration_de_naissances_fosa_*)

    # Nbre d'Enregistr. des declarations de Deces Fosa
    totalDeces=$(grep -vc "commune_id" "$1"/csv/formulaire_de_declaration_de_deces_fosa_*)

    # Nbre d'Enregistr. Total de Fosa
    totalFosa=$((totalNaiss + totalDeces))
    if ((totalFosa == totalSync)); then
        folder=$(echo "$1" | cut -d'/' -f5)
        #echo "[ OK ] in $folder"
    else
        folder=$(echo "$1" | cut -d'/' -f5)
        echo "[ Error ] Missing $((totalFosa - totalSync)) record(s) in $folder !!!"
        NbrError=$((NbrError + 1))
    fi
}

function checkFosa() {
    # Cette fonction verifie les FOSA non-repertorie et les ajoutes
    # au fichier de la liste des FOSA deja repertorie
    # arg: Elle prend en entre le dossier journalier du FOSA. e.g: 2022-04-28

    updateNbr=0
    cut -d"#" -f1,14,15,16,17,18 "$1"/csv/formulaire_de_declaration_de_naissances_fosa_* | grep -a -E "^[0-9]" | sort -k 1 -n | uniq >>$liste_fosa_tmp

    # On lit chaq ligne du fichier
    while read -r ligne; do
        orgUnit=$(echo "$ligne" | awk -F '#' '{print $2}')
        nbr=$(grep -c "$orgUnit" $list_fosa_origin)
        if [ "$nbr" -lt 1 ]; then
            # on MAJ la liste des FOSA
            echo "$ligne" >>$list_fosa_origin
            echo -e "[ Update ] $ligne" >>$log_update_fosa
            declare -i updateNbr=updateNbr+1
        fi
    done < <(cat $liste_fosa_tmp)

    echo "" >$liste_fosa_tmp
    if [ $updateNbr -eq 0 ]; then
        echo -e "\n[ ALL is UPTODATE ]"
    else
        echo -e "\n[ UPDATE DONE ! ]"
    fi

    return $updateNbr
}

function splitFosaToCEC() {
    # Cette fonction segmente les FOSA et les regroupes dans leur CEC respectif
    # arg: Elle prend en arg un dossier journalier du FOSA. e.g: 2022-04-28

    for fichier in "$1"/csv/*fosa*; do

        # Variable utile au % de progression
        nbrligne=$(wc -l <"${fichier}")
        step=$((nbrligne / 100))
        lignenbr=0
        percent=0
        filename=$(echo "$fichier" | cut -d'/' -f7)

        # On lit le contenu du fichier ligne par ligne
        while IFS= read -r ligne; do

            # recuperation du champ qui nous interesse
            id=$(echo "$ligne" | awk -F '#' '{print $1}')

            # on test si la variable a du cotenue ou non
            if [ -z "$id" ]; then
                echo "$ligne" >>"$cec_non_match""non_match.csv"
            else
                echo "$ligne" >>"$cec_match""$id""_""cec.csv"
            fi
            lignenbr=$((lignenbr + 1))
            if [ $lignenbr -eq $step ]; then
                percent=$((percent + 1))
                lignenbr=0
            fi

            # Affiche la progression de segmentation en %
            echo -ne "\rsegmenting of '$filename' ... ($percent %)"
        done <"$fichier"
        echo ""
    done
}

###################### Debut Verification ##########################

printf "\n--------------[ Start Checking ]------------------\n\n"

NbrError=0
printf "\n===| Record's Number checking... \n\n"
for folder in "$datasFolder"*; do
    checkRecords "$folder"
done
printf "\n===| End Record's Number Check. %s error's folder(s) \n" "$NbrError"

echo "800#dsdasdasda#test" >>$liste_fosa_tmp
echo "900#dsdadasdassdasda#test" >>$liste_fosa_tmp

printf "\n---\n"
sleep 1
printf "\n===| FOSA List checking... \n"
checkFosa "$datasFolder"2022-04-28
nbr=$?
printf "\n===| End FOSA List check %s Update(s)\n" "$nbr"
sleep 1
printf "\n\n----------------[ End Check ]----------------------\n\n"

###################### Debut Segmentation ##########################
echo "<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
printf "\n------------[ Start Segmentation ]-----------------\n\n"
sleep 1
printf "\n===| Split FOSA in each CEC... please wait... \n\n"
splitFosaToCEC "$datasFolder"2022-04-28

printf "\n-------------[ End Segmentation ]------------------\n\n"
sleep 1
