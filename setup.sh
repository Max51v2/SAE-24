#!/bin/bash

cd

#On recupère le nom des répertoires
ls | awk '
BEGIN{
}
{
    if($0 == "Downloads"){
        print $0
    }
    if($0 == "Téléchargements"){
        print $0
    }
}' > dnld.txt
ls | awk '
BEGIN{
}
{
    if($0 == "Desktop"){
        print $0
    }
    if($0 == "Bureau"){
        print $0
    }
}
' > desk.txt

#On met le nom des répertoires dans des variables
dnld=$(cat dnld.txt)
desk=$(cat desk.txt)

#On crée le dossier SAE24 dans le Bureau
mkdir ~/$desk/SAE24

#On déplace les fichiers dans le dossier SAE24
cd
mv -T ./$dnld/bash_script.sh ./$desk/SAE24/bash_script.sh
mv -T ./$dnld/getstate.awk ./$desk/SAE24/getstate.awk
mv -T ./$dnld/parsing.awk ./$desk/SAE24/parsing.awk
mv -T ./$dnld/README.txt ./$desk/SAE24/README.txt

#Création du dossier calendrier
mkdir ~/$desk/SAE24/calendrier

#On donne les droits d'execution pour le script principal
chmod u+x ~/$desk/SAE24/bash_script.sh

#Suppression des fichiers de configuration
rm ~/dnld.txt
rm ~/desk.txt

#On donne la commande permettant la suppression de setup.sh
echo "Copier coller la commande ci-dessous : "
echo "rm ~/"$dnld"/setup.sh"
sleep 15

#Positionnement dans le répertoire du script
cd ~/$desk/SAE24
echo "Fin de la configuration"

#On donne l'instruction afin de démarrer le programme
echo "Pour executer le script veuillez recopier la commande ci-dessous :"
echo "./bash_script.sh"
