function dtIcsDateAsFr(dt)
#:func (dt:str) -> str:
#
#  :param dt: un horodatage au format ics ``"AAAAMMJJThhmmssZ"``
#  :return: une date et heure au format ``"JJMMAAAA:HHMM"``
#  :remets au bon format horaire (ici UTC+2)

{
	jour = substr(dt,7,2)
	mois = substr(dt,5,2)
	annee = substr(dt,1,4)
	temps = substr(dt,10,4)
	hh = substr(temps,1,2)
	mm = substr(temps,3,2)
	hh = (hh/1)+UTC
	hh = add0(hh,2)
	temps = hh mm
    	str=jour mois annee":"temps
	return str
}

function add0(dt,len)
#:func (dt : Int, len : Int) -> str:
#  :remets un 0 devant un chiffre à une unitée 
#  :param dt: un chiffre X
#  :param len: le nombre de caractères à la sortie (supporte uniquement 2)
#  :return: une date et heure au format `"0"X` ou `X`
{
	if(dt <= 9){
		dt = 10 dt
		dt = substr(dt,2,len)
	}
	return dt
}


####################################################
####################################################
####################################################

BEGIN {
	date_max = 18340101
	#Prise en compte du décalage horaire du calendrier (calendriers ADE => 2)
	UTC = 2
}

#prends toutes les entrées correspondantes à un évènement
/^(BEGIN:VEVENT)/ , /^(END:VEVENT)/{
	delimiteur = index($0,":")
	key = substr($0, 1, delimiteur-1)
	val = substr($0, delimiteur+1)
	dict[key]=val
	#on supprime le dictionnaire afin d'éviter les valeurs fantômes si la ligne vaut "BEGIN:VEVENT"
	if ($0 == "BEGIN:VEVENT") {
		delete dict
	}
	else {
		#rien
	}
	#on traite l'évènement quand la ligne vaut "END:VEVENT"
	if ($0 == "END:VEVENT") {
		#on change le format des dates de début et de fin
        dt = dict["DTSTART"]
		date_debut = dtIcsDateAsFr(dt)
		dt2 = substr(dt,1,8)
		#On cherche la date la plus petite (non utilisé)
		#if(dt2 < date_min){			
		#	date_min = substr(dt2,1,8)
		#}
		#else{
		#	#rien
		#}
        	dt = dict["DTEND"]
		date_fin = dtIcsDateAsFr(dt)
		dt2 = substr(dt,1,8)

		#on cherche la date la plus grande
		if(dt2 > date_max){			
			date_max = substr(dt2,1,8)
		}
		else{
			#rien
		}

		#on découpe les heures et minutes de fin
		date = substr(date_debut,1,8)	
		delimiteur = index(date_debut,":")
		heure_debut = substr(date_debut, delimiteur+1,2)
		minute_debut = substr(date_debut, delimiteur+3,2)
		delimiteur = index(date_fin,":")
		heure_fin = substr(date_fin, delimiteur+1,2)
		minute_fin = substr(date_fin, delimiteur+3,2)
		h15 = heure_debut*4 + (minute_debut/15) + 1

		a=0 #compteur

		#interprétation des heures et minutes en tant que N
		heure_debut = heure_debut/1
		heure_fin = heure_fin/1
		minute_debut = minute_debut/1
		minute_fin = minute_fin/1

		#on parcours tous les quart d'heure de la journée actuelle en partant du début à la fin de l'évènement
		while(a == 0){
			#création du dictionnaire dict_h
			key_h = "h"h15 date
			val_h = 1
			dict_h[key_h]=val_h

			#incrémentation de 15 min à chaque itération
			minute_debut = minute_debut + 15
			h15 = h15+1
			
			if(minute_debut >= 60){
				minute_debut = minute_debut-60
				heure_debut = heure_debut + 1
			}
			if(heure_debut >= heure_fin){
				if(minute_debut >= minute_fin){
					a=1
					key_h = "h"h15 date # à modifier pour marge de 15 min
					val_h = 0
					dict_h[key_h]=val_h
				}
				else{
					#rien
				}
			}
			else{
				#rien
			}
		}
	}
}

END {
	#Changement du format de la date
	dt = date_max;date_max = dtIcsDateAsFr(dt)

	#On sépare le jour, date, année de date_act et date_max
	annee_f=substr(date_max,5,4)
	mois_f=substr(date_max,3,2)
	jour_f=substr(date_max,1,2)
	annee=substr(date_act,7,4)
	mois=substr(date_act,4,2)
	jour=substr(date_act,1,2)

	#Définition du dictionnaire comprenant le nombre de jour de chaque mois
	key = 1;val = 31;dict_j[key] = val
	key = 2;val = 28;dict_j[key] = val
	key = 3;val = 31;dict_j[key] = val
	key = 4;val = 30;dict_j[key] = val
	key = 5;val = 31;dict_j[key] = val
	key = 6;val = 30;dict_j[key] = val
	key = 7;val = 31;dict_j[key] = val
	key = 8;val = 31;dict_j[key] = val
	key = 9;val = 30;dict_j[key] = val
	key = 10;val = 31;dict_j[key] = val
	key = 11;val = 30;dict_j[key] = val
	key = 12;val = 31;dict_j[key] = val

	jour = jour/1;mois = mois/1;annee = annee/1
	jour_f = jour_f/1;mois_f = mois_f/1;annee_f = annee_f/1
	if(annee_f < annee && mois_f <  mois && jour_f < jour){
			e=1 #on ne lance pas s'il n'y a pas d'évènements
	}
	else{
		e = 0 #compteur
	}

	#cette boucle parcours tous les jours allant de la date de début à celle de fin
	while(e == 0){
		#si date fin
		if(annee_f == annee && mois_f ==  mois && jour_f == jour){
			e=1 # arrêt de la boucle
		}
		else{
			#rien
		}

		#Rajout du 0 si le nombre est inférieur à 9 (ex : 9 est mis sous forme "09" dans le dictionnaire)
		jour0 = jour;mois0 = mois;annee0=annee			
		dt = jour0;jour0 = add0(dt,2)
		dt = mois0;mois0 = add0(dt,2)

		#verifie si le contenu est nul puis print le contenu; tout cela pour h1 à h95
		d = 1 #compteur
		while(d<=(23*4+3)){
			date = jour0 mois0 annee0
			#si pour telle date et telle heure, le dict est nul, affecter 0 au dict (pour une valeur nulle techniquement vaut 0 MAIS !=0 d'où l'affectation)
			if(dict_h["h"d date] == 1 ){
				#rien
			}
			else{
				dict_h["h"d date] = 0
			}
			print(date ":h"d";"dict_h["h"d date])
			d = d + 1
		}
		jour = jour + 1
		#si 'jour' > au nombre de jours dans le mois (prends pas les années bisextilles en compte)
		if(jour >= dict_j[mois]+1){
			jour = jour - dict_j[mois]
			mois = mois + 1
		}
		else{
			#rien
		}
		if(mois >= 13){
			mois = 1
			annee = annee + 1
		}
		else{
			#rien
		}
	}
}
