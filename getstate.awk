#la commande renvoi la variable date="JJ:MM:AAA;HH:MM:SS"
BEGIN{
	split(date,a,";") #a[1]=JJ:MM:AAAA / a[2]=HH:MM:SS
	split(a[2],heure,":") #heure[1]=HH / heure[2]=MM / heure[3]=SS
	h = heure[1]/1
	m = heure[2]/1
	h15 = (h)*4+(m-(m%15))/15 #On calcule le Nème quart d'heure
	split(a[1],date2,"-") #date2[1]=JJ / date2[2]=MM / date2[3]=AAAA
	date = date2[1] date2[2] date2[3] #remise de la date au format utilisé dans le fichier.txt
}
{	
	split($0,b,";") #b[1]=champ / b[2]=statut
	if(b[1] == date":h"h15){ #si le champ correspond à la date
		print(b[2])
		resultat=b[2];
	}
}
#S'il n'y a pas d'évènement dans le calendrier, il faut renvoyer 0
END{
	#Si le résultat est non nul alors on ne fait rien, sinon on renvoi 0
	if(resultat=="1" || resultat=="0"){
		#rien
	}
	else{
		print "0"
	}
}
