#!/bin/bash

###########################################################
# SET UP YOUR SCRIPT ON CHRON SO IT EXECUTES EVERY MINUTE #
###########################################################

# install some libraries that are needed for this script to work

# xprintidle helps to be able to get the idle time of the computer
# sudo apt-get install xprintidle

# xdotool helps to get the name of the windows you are working on
# sudo apt-get install xdotool

# to edit chron:
# crontab -e

# then on the last line of the file add five "*" and the location of your script
# * * * * * bash /home/user/path/thisfile.sh

# if you want to see the "echo" messages logged by chron:
# sudo apt-get install postfix
# sudo apt-get install mutt
# then you can open mutt and browse chron messages as if they are mail

# to see chron log on the console:
# cat /var/log/syslog | grep -i cron

##############################################

## some computers need to set the display in order to show notifications
export DISPLAY=:0

#######################################
############## GOOD APPS ##############
#######################################
# write here the name of the process of good applications
# for example office, inkscape, gimp, etc.
declare -a jiayou=("netbeans" "android studio" "androidstudio" "office" "inkscape" "gimp" "openshot")
# write here the title of windows that shall be considered good
# for example when you are browsing the web on "stack overflow"
# in which case the process will be "firefox" or "chrome" which
# might not be rated as "good"
declare -a jiayouzhang=("stack overflow" "stackoverflow" "oracle" "java" "netbeans" "android studio" "androidstudio" "sql" "jdbc" "stack exchange" "stackexchange" "android developer" "android develop" "SDK" "kotlin" "github" "gitlab" "codeberg" "material design")

######################################
############## BAD APPS ##############
######################################
# bad processes that will cost you points
# write here for example "vlc", "playonlinux", "gameName"
declare -a programa=("wine" "playonlinux" "Game.exe" "totem" "vlc")
# here is the place for bad window titles that will cost you points
# for example if you are reading a book on "Calibre", but the title
# of the book is "Game of Thrones" instead of "Advanced Programming"
# you can recognize the former as a bad title
declare -a nombre=("league of legends" " lol " "PlayOnLinux" "youtube" "facebook" "twitter" "wuxia" "manga" "anime" "discord" "games" "euronews" "messenger" "msn" "game" "reddit" "whatsapp" "one piece" "netflix" "watch online" "the walking dead" "amazon")

####################################
####################################
####################################

########################
# TIME IMPORT FROM TXT #
########################
# on each "read" line, read a txt file that you know will contain
# a numeric value measuring time from another app you want to sync
# in this case the time is imported in positive milliseconds, and this script
# works with negative minutes, so we make it negative, then conver
# milliseconds into minutes dividing by 60000

read importadoa < /home/user/your/path/first_import_file.txt
importadoa=$(( -1 * $importadoa / 60 / 1000 )) 
read importadob < /home/user/your/path/second_import_file.txt
importadob=$(( -1 * $importadob / 60 / 1000 ))

# then assemble all of them in a single variable that will be handled
# by the script

importadotot=$(( $importadoa + $importadob ))

# you can then use several services to sync
# I like SyncThing, but you can use also G-Drive, Dropbox, or any other


######################################
######## TIMES SET UP ################
######################################

# this is the "base" time limit, leave it at 0 by default
# if you want some "start-free" minutes, write them here
# in positive value
limite=0

# write here the iddle time that once surpased the script will
# not count more time as "working", because you are idle
# time is specified in milliseconds, so 60000 = 1 minute
inactividad=60000

# Write here the time you shall leave the computer at night
# and at what time you can get on it again
# once the hour goes beyond the "leave the computer" one, the script
# will not sum any more positive points for you, and all negative
# apps will be blocked, regardless of how many points you have
# if you want to disable it, just set the same time for both
horadormir=20 # this is the hour (0 to 23) that you shall leave the computer
minutodormir=30 # these are the minutes (0 to 59) that goes with the previous one
horadespertar=5 # this is the hour (0 to 23) that you can get to the computer again
minutodespertar=0 # this is the minute (0 to 59) that goes with the previous one

# here you can write the proportion of time that you shall work to get
# your play time. For example 4 will make you work for 4 minutes until
# you get 1 minute for play.
proporcion=4

# here you can set a limit of minutes that you can keep on hold without using
# the number here must be negative
# for example if you set it to 60, once you have 60 minutes saved up, even if
# you keep working, you will not earn any more points
# by default this value is set too high so it doesn't affect, though this feature
# can help cherish the points you make working
erlimite=$(( -525600 )) # negative value!

# to sync with another txt time-tracker
# write the path to your export file in the following variable
# note that time is exported in milliseconds
rutaexport=/home/user/your/export/path/export_file.txt

# some computers need to specify this next line before the notify-send command
# to be able to send notifications from chron, if you don't, just delete them
# from the script body:
# eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)";

#####################################################################################
#####################################################################################
#####################################################################################
################ YOU DON'T NEED TO TOUCH THE STUFF BELOW FROM HERE ##################
#####################################################################################
#####################################################################################
#####################################################################################


limiteacumulado=$(( $erlimite * $proporcion ))
tiempodormir=$(( $horadormir * 60 + $minutodormir ))
tiempodespertar=$(( $horadespertar * 60 + $minutodespertar ))
eslahora=0

actualizar_tiempo () {
	mhora=$( date '+%H' )
	minuto=$( date '+%M' )
	hora=$(( 60 * $mhora ))
	tiempo=$(( $hora + $minuto ))
}

notificame () {
	eslahora=1
	eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)";
	/usr/bin/notify-send "It is time to be closing stuff..." "And turn off the computer.................."
	spd-say "it is time to shut down the PC, go do other stuff."
	sleep 30
	/usr/bin/notify-send "It is time to be closing stuff..." "And turn off the computer.................."
	spd-say "it is time to shut down the PC, go do other stuff."
}

eshoradedormir () {
	tiempoantesdedormir=$(( $tiempodormir-$tiempo ))
	if [ $tiempodormir -gt $tiempodespertar ] && [ $tiempo -gt $tiempodormir ]
	then
		notificame
	elif [ $tiempodormir -gt $tiempodespertar ] && [ $tiempo -lt $tiempodespertar ]
	then
		notificame
	elif [ $tiempodormir -lt $tiempodespertar ] && [ $tiempo -gt $tiempodormir ] && [ $tiempo -lt $tiempodespertar ]
	then
		notificame
	elif [ $tiempoantesdedormir -lt 6 ] && [ $tiempoantesdedormir -gt 0 ]
	then
		eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)";
		/usr/bin/notify-send "$tiempoantesdedormir minutes to enter night-time"
		spd-say "minutes left for shutting down the PC: $tiempoantesdedormir"
	fi
}

###################
actualizar_tiempo
eshoradedormir
###################

#################################################################################
#################################################################################
#################################################################################

# para mensaje final 0=nada 1=mala 2=buena
accion=0
esbuena=0
# variable funcional para los bucles for
programalength=${#programa[@]}
nombrelength=${#nombre[@]}
jiayoulength=${#jiayou[@]}
jiayouzhanglength=${#jiayouzhang[@]}


ventana=$( xprop -id $(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5) WM_NAME | sed -nr 's/.*= "(.*)"$/\1/p' )

viendo=$( ps -e | grep $(xdotool getwindowpid $(xdotool getwindowfocus)) | grep -v grep | awk '{print $4}' )

ventana_pid=$(xdotool getactivewindow getwindowpid)

idle=$(xprintidle)
echo ausente por $idle milisegundos, limite en $inactividad milisegundos

touch -a fecha.txt
read fecha < fecha.txt
hoy=$( date +'%d/%m/%Y' )
touch -a minutos.txt
read minutos < minutos.txt
touch -a cerrando.txt
read cerrando < cerrando.txt


if [[ $fecha != $hoy ]]
	then
		fecha=$hoy
		cerrando=0
fi


if [[ $(( $limite-$minutos )) -gt 0 ]]
	then
		cerrando=0
fi

# flag
avisar=0
sumado=0
jiayouguo=0

sumaminuto() {
	if [[ $sumado == 0 ]]
		then
			sumado=1
			accion=1
			minutos=$(( $minutos + $proporcion ))
			echo "discounting..."
	fi
}

sumajiayou() {
	accion=2
	if [[ $eslahora != 1 ]] && [[ $jiayouguo == 0 ]]
		then
			jiayouguo=1
			minutos=$(( $minutos - 1 ))
			echo "increasing..."
	fi
}

cierra_proceso() {
	kill -9 $ventana_pid
}



for (( i=1; i<${jiayoulength}+1; i++ ));
do
	j=${viendo,,}
	k=${jiayou[$i-1],,}
	if [[ $j =~ $k ]]
		then
			esbuena=1
			if [[ $idle -lt $inactividad ]]
				then
					echo "process contains: $k"
					sumajiayou
					avisar=0
			fi
	fi
done

for (( i=1; i<${jiayouzhanglength}+1; i++ ));
do
	l=${ventana,,}
	m=${jiayouzhang[$i-1],,}
	if [[ $l =~ $m ]]
		then
			esbuena=1
			if [[ $idle -lt $inactividad ]]
				then
					echo "window contains: $m"
					sumajiayou
					avisar=0
			fi
	fi
done


for (( i=1; i<${nombrelength}+1; i++ ));
do
	u=${ventana,,}
	v=${nombre[$i-1],,}
	if [[ $u =~ $v ]]
		then
					echo "window contains: $v"
					sumaminuto
					avisar=1
					if [[ $cerrando == 1 ]] || [[ $eslahora == 1 ]]
						then
						eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)";
						if [[ $eslahora == 1 ]]
							then
								/usr/bin/notify-send "It is time" "it is already too late"
							fi
					fi
	fi
done


for (( i=1; i<${programalength}+1; i++ ));
do
	y=${viendo,,}
	z=${programa[$i-1],,}
	if [[ $y =~ $z ]]
		then
					echo "process contains: $z"
					sumaminuto
					avisar=1
					if [[ $cerrando == 1 ]] || [[ $eslahora == 1 ]]
						then
						eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)";
						if [[ $eslahora == 1 ]]
							then
								/usr/bin/notify-send "Es la hora" "ya es muy tarde"
							fi
					fi
	fi
done



t=$(( $limite -$minutos/$proporcion -$importadotot/$proporcion ))

if [ $(( $t )) -lt 11 ]
then
	if [[ $(( $t )) -lt 0 ]] || [[ $eslahora == 1 ]]
	then
		cerrando=1
	else
		cerrando=0
	fi

	if [ $avisar == 1 ]
	then

		eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)";
		/usr/bin/notify-send "The time is running out" "minutes left: ${t}"
		spd-say "the time is running out, minutes left: ${t}"
	fi
fi


if [[ $cerrando == 1 ]] && [[ $avisar == 1 ]]
then
	cierra_proceso
fi

if [[ $eslahora == 1 ]] && [[ $avisar == 1 ]]
then
	cierra_proceso
fi



touch -a $rutaexport
read tiempoexport < minutos.txt

exporta() {
	tiempoexport=$(( -1 * $tiempoexport * 60 * 1000 ))
	echo $tiempoexport > $rutaexport
}


echo "process: $viendo"
echo "window: $ventana"

if [[ $accion == 0 ]] && [[ $esbuena == 0 ]]
	then
		echo "neutral app, we don't do anything"
fi
if [[ $accion == 0 ]] && [[ $esbuena == 1 ]]
	then
		echo "good app, but you have been innactive"
fi
if [[ $accion == 1 ]]
	then
		echo "bad app!!! decreasing points!!!"
		exporta
fi
if [[ $accion == 2 ]] && [[ $eslahora != 1 ]]
	then
		echo "good app, increasing points"
		exporta
fi
if [[ $accion == 2 ]] && [[ $eslahora == 1 ]]
	then
		echo "good app, but you are out of the schedule"
fi



echo "imported minutes = ${importadotot}"
echo "internal minutes = ${minutos}"
echo "with the current proportion, you have ${t} minutes left"


echo $fecha > fecha.txt

if [[ $minutos -lt $limiteacumulado ]]
	then
		echo "you have reached the limit of points"
		eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)";
		/usr/bin/notify-send "you have reached the limit of points"
	else
		echo $minutos > minutos.txt
fi

echo $cerrando > cerrando.txt


