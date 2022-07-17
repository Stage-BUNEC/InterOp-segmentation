#!/bin/bash

function check() {
    # Cette fonction verifie si oui/non les Enregistr sont completes
    # NB: On fait -1 pour ne pas compter la ligne d'en-tete

    # Nbre d'Enregistrement des fichiers de Synchro
    tSync=$(grep "" -c "$1"sync_log_*)
    totalSync=$((tSync - 1))

    # Nbre d'Enregistr. des declarations de Naiss Fosa
    tNaissFosa=$(grep "" -c "$1"csv/formulaire_de_declaration_de_naissances_fosa_*)
    totalNaiss=$((tNaissFosa - 1))

    # Nbre d'Enregistr. des declarations de Deces Fosa
    tDecesFosa=$(grep "" -c "$1"csv/formulaire_de_declaration_de_deces_fosa_*)
    totalDeces=$((tDecesFosa - 1))

    # Nbre d'Enregistr. Total de Fosa
    totalFosa=$((totalNaiss + totalDeces))
    if ((totalFosa == totalSync)); then
        echo "[ OK ] in $1"
    else
        echo "[ Error ] Missing $((totalFosa - totalSync)) record(s) in $1 !!!"
        NbrError=$((NbrError + 1))
    fi

}

#Debut Verification
NbrError=0
printf "\nStart Checking...\n\n"
for folder in */; do
    check "$folder"
done
printf "\nEnd Checking. %s error's folder(s)\n\n" "$NbrError"
