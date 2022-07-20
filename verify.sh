#!/bin/bash

# Dossier contenant les donnees
datasFolder=../BUNEC_datas/var/crvs_dhis2/
liste_fosa_tmp=tampon/liste_fosa.csv
list_fosa_origin=tools/liste_fosa.csv
log_update_fosa=tampon/update_fosa.csv

function checkRecords() {
    # Cette fonction verifie si oui/non le nombre de donnees/enregistrements
    # du fichier log de synchro et les donnees des dossiers CSV sont egales.

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

    cut -d"#" -f1,14,15,16,17,18 "$1"/csv/formulaire_de_declaration_de_naissances_fosa_* | grep -a -E "^[0-9]" | sort -k 1 -n | uniq >>$liste_fosa_tmp
    cat $liste_fosa_tmp | (
        while read -r ligne; do
            orgUnit=$(echo "$ligne" | awk -F '#' '{print $2}')
            nbr=$(grep -c "$orgUnit" $list_fosa_origin)
            if [ "$nbr" -lt 1 ]; then
                # on MAJ la liste des FOSA
                echo "$ligne" >>$list_fosa_origin
                echo "[ Update ] $ligne" >>$log_update_fosa
            fi
        done
    )
    echo "" >$liste_fosa_tmp
}

###################### Debut Verification ##########################

printf "\n--------------[ Start Checking ]-----------------\n"

NbrError=0
printf "\n===| Record's Number checking... \n\n"
for folder in "$datasFolder"*; do
    checkRecords "$folder"
done
printf "\n===| End Record's Number Check. %s error's folder(s) \n" "$NbrError"

echo "800#dsdasdasda#test" >>$liste_fosa_tmp
echo "900#dsdadasdassdasda#test" >>$liste_fosa_tmp
UpdateNbr=0
printf "\n---\n"
printf "\n===| FOSA list checking... \n"
checkFosa "$datasFolder"2022-04-28 $UpdateNbr
printf "\n===| End FOSA check  \n"
printf "\n----------------[ End Check ]-----------------\n\n"
