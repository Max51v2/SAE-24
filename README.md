Présentation :
Ensemble de scripts qui allument et éteignent le courant par le biais d'un relais connecté à un raspberry pi afin d'allumer et d'éteindre le matériel (Switch qui les alimente en PoE) des salles de l'iut Nancy-Brabois.

Mise en place des scripts:
1) Verser tous les scripts dans le répertoire Téléchargements (ou downloads)

2) Copier le paragraphe ci-dessous dans le terminal :

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
|               .  .    |
|               .1 .    |   1) GPIO 4 : Résistance (1K) + LED Verte => Masse
|               .2 .    |   2) GPIO 27 : Résistance (1K) + LED Rouge => Masse
|               .3 .    |   3) GND : Masse
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


Plan d'action :
- Si multiprise :
=> Utilisation du protocole SNMP (à voir quand on aura la documentation)
- Sinon :
=> Raspbery Pi possédant Raspbian qui sera relié à un relais sur lequel sera branché le matériel
    => Contrôle par ssh et changement de l'état du relais grâce à la commande gpio (changer l'état : gpio -g write PIN ETAT)

Dernières modifications :
-Contrôle du Raspberry Pi
-Rajout de commentaires
-Ajout des salles de TD
-Changement de la façon dont l'actualisation des calendriers se produit
=> au lieu d'actualiser tous les temps t, on actualise à un (ou des) horaire précis (marche du moment que l'actualisation de l'état de la salle < 3600s )
-Prise en compte du décalage horaire des calendriers dans Parsing.awk
-Modification de la présentation des 2 traces d'exécution afin qu'elles prennent moins de place et soient plus lisibles
-Prise en compte des calendriers ne contenant pas d'évènements
-Correction de bogue lors de la création de trace2.txt
=> actualisation de la trace que si changement d'état dans une salle
-Gestion de salles multiples
