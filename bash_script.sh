#!/bin/bash

#Création du dictionnaire sous la forme dict_link["salle"]=liens
declare -A dict_link
dict_link["Shannon11"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18307&projectId=11&calType=ical&nbWeeks="
dict_link["Shannon12"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18306&projectId=11&calType=ical&nbWeeks="
dict_link["Tanenbaum"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=14396&projectId=11&calType=ical&nbWeeks="
dict_link["Edison"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18292&projectId=11&calType=ical&nbWeeks="
dict_link["Chappe"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18308&projectId=11&calType=ical&nbWeeks="
dict_link["Bell"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18291&projectId=11&calType=ical&nbWeeks="
dict_link["Zimmermann"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18293&projectId=11&calType=ical&nbWeeks="
dict_link["Backus"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18294&projectId=11&calType=ical&nbWeeks="
dict_link["Von-neumann"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18295&projectId=11&calType=ical&nbWeeks="
dict_link["Ritchie"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18296&projectId=11&calType=ical&nbWeeks="
dict_link["TD21"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18321&projectId=11&calType=ical&nbWeeks="
dict_link["TD22"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18320&projectId=11&calType=ical&nbWeeks="
dict_link["TD23"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18319&projectId=11&calType=ical&nbWeeks="
dict_link["TD24"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18318&projectId=11&calType=ical&nbWeeks="
dict_link["TD25"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18317&projectId=11&calType=ical&nbWeeks="
dict_link["TD26"]="https://planning.univ-lorraine.fr/jsp/custom/modules/plannings/anonymous_cal.jsp?resources=18316&projectId=11&calType=ical&nbWeeks="


#Création d'un dictionnaire sous la forme : dict_IP_target["salle"]="@IP_target"
#On met "null" si on n'associe pas de raspberry pi à la salle, sinon on met son adresse IP
declare -A dict_IP_target
dict_IP_target["Shannon11"]="null"
dict_IP_target["Shannon12"]="null"
dict_IP_target["Tanenbaum"]="null"
dict_IP_target["Edison"]="null"
dict_IP_target["Chappe"]="null"
dict_IP_target["Bell"]="null"
dict_IP_target["Zimmermann"]="null"
dict_IP_target["Backus"]="null"
dict_IP_target["Von-neumann"]="null"
dict_IP_target["Ritchie"]="null"
dict_IP_target["TD21"]="null"
dict_IP_target["TD22"]="null"
dict_IP_target["TD23"]="null"
dict_IP_target["TD24"]="null"
dict_IP_target["TD25"]="null"
dict_IP_target["TD26"]="null"

#variables compteurs
a=0
c=1

#####################################################################################
#Intervalle
intervalle=10 #temps en secondes avant chaque actualisation

#Horaire(s) actualisation de l'emploi du temps
horaires=("08" "09" "10") #Format : ("h1" "h2" ... "hn") / horaires allants de 00 à 23

#Maintenir allumé :
actif=0 #1 pour oui / 0 pour non
# Minuit s'écrit 24
h_debut=20
h_fin=21

#Mettre le nom des salles à administrer / Format : ("salle1" "salle2" ... "salleN") 
#Salles disponibles : Shannon11/Shannon12/Tanenbaum/Edisson/Chappe/Bell/Zimmermann/Backus/Von-neumann/Ritchie/TD21/TD22/TD23/TD24/TD25/TD26
Salles=("Shannon11" "Shannon12" "Tanenbaum" "Edison" "Chappe" "Bell" "Zimmermann" "Backus" "Von-neumann" "Ritchie" "TD21" "TD22" "TD23" "TD24" "TD25" "TD26")

#Raspberry Pi
port=4 #LED verte
port2=27 #LED Rouge
#####################################################################################



#on met extodo dans une position inexistante pour toutes les salles
declare -A dict_extodo
for str in ${Salles[@]};
do
    dict_extodo[$str]=2
done
declare -A dict_todo

#Déclaration du dictionnaire ayant pour paramètres key=horaire et val="00"
#Le jour=0 car le calendrier n'a pas encore été actualisé
declare -A dict_restart
for str in ${horaires[@]};
do
    dict_restart[$str]="00"
done

nb_iteration=0;

#On cherche si on passe par minuit pendant la période d'activation
if [ "$h_debut" -gt "$h_fin" ] #add_24 : 1=oui / 0=non
then
    add_24=1
else
    add_24=0
fi

#Réinitialisation des LED des raspberry pi
#code python > Reset.py (facultatif)
for str in ${Salles[@]};
do
    if [ ${dict_IP_target[$str]} = "null" ]
    then
        #rien
        skip=1
    else
        echo "from gpiozero import LED" > Reset.py
        echo "green = LED("$port")" >> Reset.py
        echo "red = LED("$port2")" >> Reset.py
        echo "green.off()" >> Reset.py
        echo "red.off()" >> Reset.py

        #Lancement du script
        PIGPIO_ADDR=${dict_IP_target[$str]} python3 -Wignore -q Reset.py
    fi
done

echo "salle:(@IP Salle):mode:status:state:date" > trace.txt
echo "la présence d'un '#' signifie qu'aucun appareil n'est associé à la salle" >> trace.txt
echo >> trace.txt

#DEBUT

#boucle infinie
while [ "$a" -lt "$c" ]
do

    for str in ${Salles[@]};
    do
        #récupération de l'edt de chaque salle (mettre en com lors de test pour éviter de spam le serveur)
        curl -L -o ./calendrier/ADECal_$str.ics ${dict_link["$str"]}`date "+%V"` #ajouter -s pour retirer la sortie de curl
        echo "Traitement calendrier salle "$str
        #Retrait du return carriage
        cat ./calendrier/ADECal_$str.ics > ./calendrier/temp.txt
        sed 's/\r$//g' ./calendrier/temp.txt > ./calendrier/ADECal_$str.ics
        awk -v date_act=$(date "+%d-%m-%Y") -f ./parsing.awk ./calendrier/ADECal_$str.ics > ./calendrier/status_$str.txt
    done

    #Trace
    { echo "Actualisation de(s) emploi du temps"; echo " : "; date +%T/%d-%m-%Y; } | sed ':a;N;s/\n/ /;ba' >> trace.txt
    echo >> trace.txt

    #On met la date et l'heure de la dernière actualisation dans le dict
    if [ "$nb_iteration" = 0 ]
    then
        dict_restart[$(date "+%H")]="$(date "+%e")"
        let "nb_iteration=$nb_iteration+1"
    fi
    running=1 #On réactive la boucle de traitement des salles

    #cette boucle s'exécute pendant une durée 'tempsexec' afin d'actualiser le calendrier en cas de modifications
	while [ "$running" = 1 ]
	do
        #si le paramètre de période active est désactivé, on regarde status.txt
        if [ "$actif" = 0 ]
        then
            mode="NORMAL"

        #S'il est activé on vérifie l'heure
        elif [ "$actif" = 1 ]
        then
            h_act=$(date "+%H")
            #On vérifie la position de la plage horaire : 1=passe par minuit / 0=passe pas par minuit
            if [ "$add_24" = 0 ]
            then
                #si on est dans la plage horaire active : h_debut <= h_act < h_fin
                if [ "$h_debut" -le "$h_act" ] && [ "$h_act" -lt "$h_fin" ]
                then #activation
                    mode="CHANGE"
                else #sinon exécution normale
                    mode="NORMAL"
                fi
            elif [ "$add_24" = 1 ]
            then
                let "h_fin_add24 = $h_fin+24"
                #si on est dans la plage : 0 <= h_act < h_fin
                if [ "$h_act" -lt "$h_fin" ]
                then
                    let "h_act_add24 = $h_act+24"
                else
                    h_act_add24=$h_act
                fi
                #si on est dans la plage horaire active : h_debut <= h_act+24 < h_fin+24
                if [ "$h_debut" -le "$h_act_add24" ] && [ "$h_act_add24" -lt "$h_fin_add24" ]
                then #activé
                    mode="CHANGE"
                else #sinon exécution normale
                    mode="NORMAL"
                fi
            fi
        fi

		#interrompt le script pendant un intervalle de temps t
        echo "pause de "$intervalle"s"
        sleep $intervalle

        #On vérifie l'état de chaque salle
        act="0" #trace
        for str in ${Salles[@]};
        do
            #On cherche ici à enregistrer la valeur de todo précédente
            if [ "${dict_extodo[$str]}" = 2 ] # '$extodo'=2 sur la première itération  
            then
                dict_extodo[$str]=3
            else
                dict_extodo[$str]=${dict_todo[$str]}
            fi

            #On défini 'todo' => mode= "CHANGE" : période active / "NORMAL" hors période
            if [ "$mode" = "NORMAL" ]
            then
                #On récupère le statut provenant de 'status.txt' qui provient lui-même de 'ADECal.ics'
                dict_todo[$str]=$(awk -v date=$(date "+%d-%m-%Y;%T") -f ./getstate.awk ./calendrier/status_$str.txt)
            elif [ "$mode" = "CHANGE" ]
            then
                #On ignore le statut et on met l'état '1' qui signifie allumé
                dict_todo[$str]=1
            fi

            #On définit s'il faut envoyer une requête
            #state : "NULL" = ne rien faire / "CHANGE" = changer l'état
            if [ "${dict_extodo[$str]}" = "${dict_todo[$str]}" ]
            then
                state="NULL"
            elif [ "${dict_extodo[$str]}" = 2 ]
            then
                state="CHANGE"
                echo $str" : "$state
            elif [ "${dict_extodo[$str]}" != "${dict_todo[$str]}" ] #si changement d'état ou 1ere itération et allumé
            then
                state="CHANGE"
                echo $str" : "$state
            fi

            #Trace d'exécution
            #{ echo $str; echo ":"; echo $mode; echo ":"; echo ${dict_todo[$str]}; echo ":"; echo $state; echo ":"; date +%d-%m-%Y/%T; } | sed ':a;N;s/\n/ /;ba' >> trace.txt

            #On change l'état de la salle (pas encore fait)
            if [ "$state" = "CHANGE" ] #trace
            then
                act="1"
            fi

	        if [ "${dict_IP_target[$str]}" = "null" ] && [ "$state" = "CHANGE" ]
            then
                if [ "$state" = "CHANGE" ] && [ "${dict_todo[$str]}" = 1 ]
                then
                    echo "# ALLUMAGE du Switch salle "$str >> trace.txt
                    { echo "#"; echo $str; echo ":"; echo ${dict_IP_target[$str]}; echo ":"; echo $mode; echo ":"; echo ${dict_todo[$str]}; echo ":"; date +%T/%d-%m-%Y; } | sed ':a;N;s/\n/ /;ba' >> trace.txt
                    echo >> trace.txt
                elif [ "$state" = "CHANGE" ] && [ "${dict_todo[$str]}" = 0 ]
                then
                    echo "# Exctinction du Switch salle "$str >> trace.txt
                    { echo "#"; echo $str; echo ":"; echo ${dict_IP_target[$str]}; echo ":"; echo $mode; echo ":"; echo ${dict_todo[$str]}; echo ":"; date +%T/%d-%m-%Y; } | sed ':a;N;s/\n/ /;ba' >> trace.txt
                    echo >> trace.txt
                fi
            else
            	if [ "$state" = "CHANGE" ] && [ "${dict_todo[$str]}" = 1 ]
            	then
            	    #code python > TurnOn.py
            	    echo "from gpiozero import LED" > TurnOn.py
            	    echo "green = LED("$port")" >> TurnOn.py
            	    echo "red = LED("$port2")" >> TurnOn.py
            	    echo "green.on()" >> TurnOn.py
	                echo "red.off()" >> TurnOn.py

                	#Lancement du script
       		        PIGPIO_ADDR=${dict_IP_target[$str]} python3 -Wignore -q TurnOn.py

                    #Trace d'exécution
                    echo "ALLUMAGE du Switch salle "$str >> trace.txt
                    { echo $str; echo ":"; echo ${dict_IP_target[$str]}; echo ":"; echo $mode; echo ":"; echo ${dict_todo[$str]}; echo ":"; date +%T/%d-%m-%Y; } | sed ':a;N;s/\n/ /;ba' >> trace.txt
                    echo >> trace.txt
                elif [ "$state" = "CHANGE" ] && [ "${dict_todo[$str]}" = 0 ]
                then
                    #code python > TurnOff.py
                    echo "from gpiozero import LED" > TurnOff.py
                    echo "green = LED("$port")" >> TurnOff.py
                    echo "red = LED("$port2")" >> TurnOff.py
                    echo "red.on()" >> TurnOff.py
                    echo "green.off()" >> TurnOff.py

                    #Lancement du script
                    PIGPIO_ADDR=${dict_IP_target[$str]} python3 -Wignore -q TurnOff.py

                    #Trace d'exécution
                    echo "EXCTIONCTION du Switch salle "$str >> trace.txt
                    { echo $str; echo ":"; echo ${dict_IP_target[$str]}; echo ":"; echo $mode; echo ":"; echo ${dict_todo[$str]}; echo ":"; date +%T/%d-%m-%Y; } | sed ':a;N;s/\n/ /;ba' >> trace.txt
                    echo >> trace.txt
                fi
            fi
        done

        #Construction trace2.txt
        #S'il y'a un changement, on reconstruit la trace en parcourant toutes les salles
        #Note : n'est pas viable pour savoir s'il y'a extinction ou allumage (on prends ici l'état actuel en compte)
        if [ "$act" = "1" ]
        then
            echo "Salle : Etat" > trace2.txt
            for str in ${Salles[@]};
            do
                if [ "${dict_todo[$str]}" = 1 ]
                then
                    echo $str" : Allumé" >> trace2.txt
                elif [ "${dict_todo[$str]}" = 0 ]
                then
                    echo $str" : Eteint" >> trace2.txt
                fi
            done
        fi

        #On parcours tous les horaires d'actualisation
		for str in ${horaires[@]};
        do
            #Si l'horaire actuel correspond à un horaire d'act et que la date d'act ne correspond pas à aujourd'hui, on actualise
            if [ "${dict_restart[$str]}" != "$(date "+%e")" ] && [ "$str" = "$(date "+%H")" ]
            then
                #Arrêt de la boucle de traitement afin de renouveler les calendriers
                running=0
                #Affectation de la date d'act pour l'heure donnée
                dict_restart[$str]=$(date "+%e")
            fi
        done
	done
done
