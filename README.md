Présentation :
Ensemble de scripts qui permettent d'ouvrir et couper l'alimentation d'un Switch qui alimente en PoE les pc des salles de l'iut Nancy-Brabois par le biais d'un raspbery pi connecté au réseau.
L'objectif de ces scripts est de gérer l'alimentation du matériel des salles en fonction de leur occupation (déterminée par ADE).

Mise en place des scripts:
1) Verser tous les scripts dans le répertoire Téléchargements

2) Copier le paragraphe ci-dessous dans le terminal (Linux):

cd
ls | awk '
BEGIN{
}
{
    if($0 == "Downloads"){
        dnld=$0
    }
    if($0 == "Téléchargements"){
        dnld=$0
    }
}
END{
    print "Copier coller ce qui est affiché ci-dessous :"
    print "cd ~/"dnld
    print "sudo chmod u+x setup.sh"
    print "./setup.sh"
}'


Mise en place de l'arduino (modèle 3 b+)

1) installer python et la librairie gpiozero
Sudo apt install python3
sudo apt install python3-gpiozero
sudo apt install python-gpiozero

Attention : vérifier que le daemon pigpiod est démarré (il ne démarre pas par défaut)
=> démarrage : systemctl start pigpiod

3) Mise en place du matériel (LED dans le cas d'une demo)

+-----------------------+
|               .  .    |
|               .  .    |
|               .  .    |
|               .1 .    |
|               .3 .    |   1) GPIO 4 : Résistance (1K) + LED Verte => Masse
|               .  .    |   2) GPIO 27 : Résistance (1K) + LED Rouge => Masse
|               .2 .    |   3) GND : Masse
|               .  .    |
|               .  .    |
|               .  .    |
|               .  .    |
|               .  .    |
|               .  .    |
|               .  .    |
|               .  .    |
|               .  .    |
|               .  .    |
|               .  .    |
|               .  .    |
|               .  .    |
|                       |
|                       |
|                       |
|                       |
|                       |
|                       |
|                       |
+-----------------------+


4) Modification des paramètres
Veuillez changer les paramètres contenus entre les deux lignes contenant des # afin d'adapter le script selon vos contraintes
Les liens correspondant aux emplois du temps sont amenés à varier selon les années, afin de pallier ce problème il est recommandé de vérifier qu'ils sont corrects en cas de problèmes (s'il ne se produit rien lors de l'execution du script).
Démarche pour récupérer les liens :
    - Ouvrir l'ENT et appuyer sur la tuile "Planning global UL"
    - taper le nom de la salle dans la barre de recherche
    - cliquer sur le logo contenant un agenda (en bas à gauche)
    - cliquer sur "générer url" dans la fenêtre qui s'est ouverte
    - copier puis retirez le numéro contenant la semaine à la fin du liens (indiqué XX dans l'exemple)
      => ex : https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18294&projectId=11&calType=ical&nbWeeks=XX


##############################################################

commandes scripts :
1) awk -v date_act=$(date "+%d-%m-%Y") -f ./parsing.awk ./CALENDRIER.ics > FICHIER_STATUS.txt
2) awk -v date=$(date "+%d-%m-%Y;%T") -f ./getstate.awk ./FICHIER_STATUS.txt > FICHIER_STATUS_ACTUEL.txt
3) ./bash_script.sh

Utilité de chaque fichier :
- parsing.awk : parcours ADECal.ics et crée status.txt
- status.txt : contient l'état du matériel du premier au dernier évènement de ADECal.ics pour tous les jours à un intervalle de 15 min
=> Options :
    -sortie : date actuelle à dernière date OU première date à dernière date
- getstate.awk : prends la date/heure actuelle et cherche l'état du matériel dans status.txt et renvoi : 0 pour éteint / 1 pour allumé
- bash_script.sh : execute les programmes précédents et modifie (ou pas) l'état du matériel
=> Options :
    -gestion de salles multiples
    -période "toujours allumé"
    -actualisation du ou des calendrier(s) à des horaires définis
    -actualisation de l'état à un intervalle donné
