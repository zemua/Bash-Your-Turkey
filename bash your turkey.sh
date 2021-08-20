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
# * * * * * bash /home/user/path/coldturkey.sh

# if you want to see the "echo" messages logged by chron:
# sudo apt-get install postfix
# sudo apt-get install mutt
# then you can open mutt and browse chron messages as if they are mail

# to see chron log on the console:
# cat /var/log/syslog | grep -i cron

##############################################

## crontab needs to set the display in order to show notifications
## usually this command is
## export DISPLAY=:0
## but in some circumstances you may have to adjust it to for example
## export DISPLAY=:1
## to see a list of available displays run
## ps e | grep -Po " DISPLAY=[\.0-9A-Za-z:]* " | sort -u
## to see a list of displays assigned to user $user (replace it with username)
## ps e -u $usr | grep -Po " DISPLAY=[\.0-9A-Za-z:]* " | sort -u
## to see the current display number "echo $DISPLAY"
export DISPLAY=":1"
## you can check export available commands just typping "export"

# to send notifications type "notify-send" from cron
# eval "export $(egrep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u $LOGNAME gnome-session)/environ)";
# or...
# export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus
# execute the following
# env|grep -i runt
# and you shall get
# XDG_RUNTIME_DIR=/run/user/1000
# for the sound to work with spd-say or aplay
export XDG_RUNTIME_DIR=/run/user/1000

#######################################
############## GOOD APPS ##############
#######################################
# write here the name of the process of good applications
# for example office, inkscape, gimp, etc.
# examples:
declare -a jiayou=("netbeans" "android studio" "androidstudio" "inkscape" "gimp" "openshot" "eclipse" "dia" "code")
# write here the title of windows that shall be considered good
# for example when you are browsing the web on "stack overflow"
# in which case the process will be "firefox" or "chrome" which
# might not be rated as "good"
# examples:
declare -a jiayouzhang=("stack overflow" "stackoverflow" "oracle" "java" "netbeans" "android studio" "androidstudio" "sql" "jdbc" "stack exchange" "stackexchange" "desarrolladores de android" "android developer" "android develop" "geeksforgeeks" "SDK" "programming" "ranch.guide" "kotlin" "github" "gitlab" "codeberg" "coding in flow" "gitbook" "material design" "spring" "eclipse")

######################################
############## BAD APPS ##############
######################################
# bad processes that will cost you points
# write here for example "vlc", "playonlinux", "gameName"
# examples:
declare -a programa=("wine" "playonlinux" "Game.exe" "totem" "vlc" "twitch" "steam" "baldur" "telegram" "Discord")
#"gnome-software"

# here is the place for bad window titles that will cost you points
# for example if you are reading a book on "Calibre", but the title
# of the book is "Game of Thrones" instead of "Advanced Programming"
# you can recognize the former as a bad title
# examples:
declare -a nombre=("Diablo2" "Diablo 2" "baldur" "neverwinter" "never winter" "league of legends" " lol " "Diablo II" "DIABLOII" "PlayOnLinux" "youtube" "facebook" "twitter" "wuxia" "manga" "anime" "20minutos" "alerta digital" "antena 3" "bbc" "cadena ser" "cinco días" " cope " "diario de arousa" "diario de pontevedra")

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

importablesruta=/home/miguel/TurkeySharedTime/

## these files will add this time to the script's total count

declare -a archivosimportables=("movilTurkey.txt" "1599413598851_tfn_cyt.txt" "1599843636145_tfn_cyt.txt" "1605450254729_tfn_cyt.txt" "worker_tfn_cyt.txt" "1607193713080_tfn_cyt.txt" "1607195886843_tfn_cyt.txt" "210328bq1616957025020_tfn_cyt.txt")

importableslength=${#archivosimportables[@]}
importadotot=0

for (( i=1; i<${importableslength}+1; i++ ));
do
	q=${archivosimportables[$i-1]}
	q="${importablesruta}${q}"
	read valorenarchivo < $q
	importadoa=$(( -1 * $valorenarchivo / 60 / 1000 ))
	importadotot=$(( $importadoa + $importadotot ))
done

## these files are the times by group exported from the phone app
declare -a array_conditions=()

################################################
## no need to touch the content of this function
################################################
function checkconditionmet()
{
	local __file_content=$1
	local __required_minutes=$2
	local __offsetdays=$3
	local __condition_name=$4
	
	IFS='-' read -ra my_array <<< "$__file_content"
	
	local __year=${my_array[0]}
	local __month=${my_array[1]}
	__month=$(( $__month + 1 )) ## The MONTH value in Java Calendar starts in 0, we use Java standard for the formats
	__month=$(printf "%02d" $__month) ## format with leading 0
	local __day=${my_array[2]}
	local __millis=${my_array[3]}
	
	local __temp_timestamp="${__year}-${__month}-${__day}"
	local __provided_timestamp=$( date -d ${__temp_timestamp} +"%s" )
	
	local __current_date=$( date +'%Y-%m-%d' )
	local __current_timestamp=$( date -d ${__current_date} +"%s" )
	
	local __one_day_time=$(( 60 * 60 * 24 ))
	local __offset_time=$(( $__one_day_time * $__offsetdays ))
	local __expected_timestamp=$(( $__current_timestamp - $__offset_time ))
	
	local __provided_minutes=$(( $__millis / 1000 / 60 ))
	
	local __prereturn=0
	if [ $__provided_timestamp -lt $__expected_timestamp ]
	then
		__prereturn=0
		echo "${__condition_name} no cumplido, , fecha ${__provided_timestamp} menor que ${__expected_timestamp}"
	elif [ $__provided_minutes -lt $__required_minutes ]
	then
		__prereturn=0
		echo "${__condition_name} no cumplido, minutos ${__provided_minutes} menor que ${__required_minutes}"
	else
		__prereturn=1
		#echo "${__condition_name} cumplido, fecha ${__provided_timestamp} mayor que ${__expected_timestamp} y minutos ${__provided_minutes} mayor que ${__required_minutes}"
	fi
	
	array_conditions+=("$__prereturn")
}
################################################
################################ end of function
################################################

## these are the files that you are going to import
## modify them to match your needs
read tiempomeditacion < "${importablesruta}Meditación.txt"
read tiempoejercicio < "${importablesruta}Ejercicio.txt"
read tiempolectura < "${importablesruta}Lectura.txt"
read tiempoidiomas < "${importablesruta}Idiomasss.txt"

## and these are the parameters for the content, indicate minutes required, and "for the last X days" 0=today 1=yesterday etc
## modify them to match your needs
checkconditionmet $tiempomeditacion 30 0 "meditacion"
checkconditionmet $tiempoejercicio 15 0 "ejercicio"
#checkconditionmet $tiempolectura 60 1 "lectura"
#checkconditionmet $tiempoidiomas 30 2 "idiomas"

# write usage logs to the following dir
log_dir=/home/miguel/LogTurkey/


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
horadormir=22 #21/5 # this is the hour (0 to 23) that you shall leave the computer
minutodormir=30 #30 # these are the minutes (0 to 59) that goes with the previous one
horadespertar=5 #5 # this is the hour (0 to 23) that you can get to the computer again
minutodespertar=30 #30 # this is the minute (0 to 59) that goes with the previous one

# here you can write the proportion of time that you shall work to get
# your play time. For example 4 will make you work for 4 minutes until
# you get 1 minute for play.
proporcion=4

# here you can set a limit of minutes that you can keep on stash without using them.
# the number here must be NEGATIVE
# for example if you set it to -60, once you have 60 minutes saved up, even if
# you keep working, you will not earn any more points
# by default this value is set high so it doesn't affect, though this feature
# can help cherish the points you make while working
erlimite=$(( -999999999 ))

# here you can set the limit of points you can get on a day
# this will help to distribute your time in different things
# there is other stuff you need to do in addition to programming
# set the limit in minutes (4 hours = 240) (8 hours = 480) (24 hours = 1440)
limitdailypoints=$(( 1440 ))

# if you are going to sync with another txt program
# write the path to your export file in the following variable
# note that time is exported in milliseconds
rutaexport="${importablesruta}ubuntuTurkey.txt"


#################################################################################
#################################################################################
#################################################################################
################ YOU DON'T NEED TO TOUCH STUFF BELOW FROM HERE ##################
#################################################################################
#################################################################################
#################################################################################

### because xprintidle gets reseted by mp3 players and such, this is another way... that gets very busy
#touch .systemidle.txt
#touch .last_input.txt
#touch .input.txt
#read systemidle < .systemidle.txt
#systemidle=$(( 1 * $systemidle ))
#input=".input.txt"
#last_input=".last_input.txt"
#timeout 60 xinput test-xi2 --root > .input.txt
#if cmp -s "$input" "$last_input";
#        then
#            systemidle=$(( 1 + $systemidle ))
#        else
#            systemidle=0
#fi
#timeout 1 xinput test-xi2 --root > .last_input.txt
#echo $systemidle > .systemidle.txt
###

idle=$(xprintidle)
#idle=$(( 60000 * $systemidle ))
echo ausente por $idle milisegundos, limite en $inactividad milisegundos

############# Check if all conditions are met

all_conditions_met=1
for i in "${array_conditions[@]}"
do
	if [[ "$i" == 0 ]];
	then
		all_conditions_met=0
	fi
done

if [[ $all_conditions_met -eq 1 ]]
	then
		echo "Todas las condiciones cumplidas"
fi

############ Read saved variables
touch -a .fecha.txt
read fecha < .fecha.txt
hoy=$( date +'%d/%m/%Y' )
touch -a .minutos.txt
read minutos < .minutos.txt
touch -a .cerrando.txt
read cerrando < .cerrando.txt
touch -a .summtoday.txt
read summtoday < .summtoday.txt
summtoday=$(( 1 * $summtoday ))
touch -a "${importablesruta}sum_export_conditions2.txt"
touch -a .sum_export_conditions2.txt
read sum_export_conditions2 < .sum_export_conditions2.txt
sum_export_conditions2=$(( 1 * $sum_export_conditions2 ))
touch -a "${importablesruta}sum_export_conditions1.txt"
touch -a .sum_export_conditions1.txt
read sum_export_conditions1 < .sum_export_conditions1.txt
sum_export_conditions1=$(( 1 * $sum_export_conditions1 ))
touch -a "${importablesruta}sum_export_conditions.txt"
touch -a .sum_export_conditions.txt
read sum_export_conditions < .sum_export_conditions.txt
sum_export_conditions=$(( 1 * $sum_export_conditions ))
#################################


limiteacumulado=$(( $erlimite * $proporcion ))
tiempodormir=$(( $horadormir * 60 + $minutodormir ))
tiempodespertar=$(( $horadespertar * 60 + $minutodespertar ))
eslahora=0

actualizar_tiempo () {
	mhora=$( date '+%H' )
	mhora=$(( 10#$mhora )) #force conversion to base 10, remove leading zeros
	minuto=$( date '+%M' )
	minuto=$(( 10#$minuto )) #force conversion to base 10, remove leading zeros
	hora=$(( 60 * $mhora ))
	tiempo=$(( $hora + $minuto ))
}

notificame () {
	eslahora=1
	/usr/bin/notify-send "It is time to turn off the computer..." "DECREASING POINTS"
	# spd-say "go. go. go, to sleep."
	spd-say "es de noche, quitando puntos"
	sleep 30
	/usr/bin/notify-send "It is time to turn off the computer..." "DECREASING POINTS"
	# spd-say "go. go. go, to sleep."
	spd-say "es de noche, quitando puntos"
	
	# disccount points, even if app isn't negative, if we are in sleep time
	minutos=$(( $minutos + $proporcion))
}

notificar_no_clasificada() {
	/usr/bin/notify-send "Cannot categorize this app" "Logged as neutral"
	spd-say "o" # warning of missing category for the current process/window
}

eshoradedormir () {
	tiempoantesdedormir=$(( $tiempodormir-$tiempo ))
	if [ $tiempodormir -gt $tiempodespertar ] && [ $tiempo -gt $tiempodormir ] && [ $idle -lt $inactividad ]
	then
		notificame
	elif [ $tiempodormir -gt $tiempodespertar ] && [ $tiempo -lt $tiempodespertar ] && [ $idle -lt $inactividad ]
	then
		notificame
	elif [ $tiempodormir -lt $tiempodespertar ] && [ $tiempo -gt $tiempodormir ] && [ $tiempo -lt $tiempodespertar ] && [ $idle -lt $inactividad ]
	then
		notificame
	elif [ $tiempoantesdedormir -lt 11 ] && [ $tiempoantesdedormir -ge 0 ]
	then
		/usr/bin/notify-send "$tiempoantesdedormir minutes to enter night-time"
		# spd-say "minutes left for shutting down the PC: $tiempoantesdedormir"
		spd-say "se acerca la noche"
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


# Name of current window
#ventana=$( xprop -id $(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5) WM_NAME | sed -nr 's/.*= "(.*)"$/\1/p' )
ventana=$(xdotool getwindowfocus getwindowname)

# Name of the current process
viendo=$( ps -e | grep $(xdotool getwindowpid $(xdotool getwindowfocus)) | grep -v grep | awk '{print $4}' )

# PID for killing the current process if necessary
ventana_pid=$(xdotool getactivewindow getwindowpid)


if [[ $fecha != $hoy ]]
	then
		fecha=$hoy
		cerrando=0
		summtoday=0
		sum_export_conditions2=$(( $sum_export_conditions1 ))
		sum_export_conditions1=$(( $sum_export_conditions ))
		sum_export_conditions=0
fi


if [[ $(( $limite-$minutos )) -gt 0 ]]
	then
		cerrando=0
fi
if [[ $all_conditions_met -eq 0 ]]
	then
		cerrando=1
fi

# flag
avisar=0
sumado=0
jiayouguo=0

anunciaacumuladopositivo() {
	aapresto=$(( -1 * $minutos - $importadotot ))
	aapnotifrating=$(( $proporcion * 5 )) ## Change the number after the % to modify positive notification proportions.
	aapresto=$(( $aapresto % $aapnotifrating )) 
	if [[ $aapresto -eq 0 ]]
		then
			aaprestante=$(( -1 * $minutos - $importadotot ))
			aaprestante=$(( $aaprestante / $proporcion ))
			_h=$(( $aaprestante/60 ))
			_h=$(printf "%02d" $_h)
			_m=$(( $aaprestante%60 ))
			_m=$(printf "%02d" $_m)
			/usr/bin/notify-send "Accumulated..." "${_h}:${_m}"
			##spd-say "acumulated ${aaprestante} minutes"
	fi
}

anunciaacumuladonegativo() {
	aapresto=$(( -1 * $minutos - $importadotot ))
	aapnotifrating=$(( $proporcion * 5 )) ## Change the number after the % to modify positive notification proportions.
	aapresto=$(( $aapresto % $aapnotifrating )) 
	if [[ $aapresto -lt 4 ]]
		then
			aaprestante=$(( -1 * $minutos - $importadotot ))
			aaprestante=$(( $aaprestante / $proporcion ))
			_h=$(( $aaprestante/60 ))
			_h=$(printf "%02d" $_h)
			_m=$(( $aaprestante%60 ))
			_m=$(printf "%02d" $_m)
			/usr/bin/notify-send "Decreased down to..." "${_h}:${_m}"
			##spd-say "decreasing down to ${aaprestante} minutes"
	fi
}

sumaminuto() { #of negative app (or when it is toque de queda)
	if [[ $sumado == 0 ]]
		then
			sumado=1
			accion=1
			minutos=$(( $minutos + $proporcion ))
			#echo "discounting..."
			anunciaacumuladonegativo
	fi
}

puede_contar=1
sumajiayou() { #of positive app
	accion=2
	if [[ $eslahora != 1 ]] && [[ $jiayouguo == 0 ]]
		then
			jiayouguo=1
			sum_export_conditions=$(( $sum_export_conditions + 1 ))
			sum_export_conditions1=$(( $sum_export_conditions1 + 1 ))
			sum_export_conditions2=$(( $sum_export_conditions2 + 1 ))
			if [[ $summtoday -lt $limitdailypoints ]] && [[ $all_conditions_met -eq 1 ]]
				then
				minutos=$(( $minutos - 1 ))
				summtoday=$(( $summtoday + 1 ))
				#echo "increasing..."
				#anunciaacumuladopositivo ## comment this line to not notify of positive points accumulated
			else
				puede_contar=0
			fi
	fi
}

cierra_proceso() {
	if [[ $all_conditions_met -eq 0 ]]
		then
			/usr/bin/notify-send "Conditions not met, closing"
			spd-say "condiciones no cumplidas, cerrando"
	fi
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
	if [[ $(( $t )) -lt 0 ]] || [[ $eslahora == 1 ]] || [[ $all_conditions_met -eq 0 ]]
	then
		cerrando=1
	else
		cerrando=0
	fi

	if [ $avisar == 1 ]
	then
		/usr/bin/notify-send "The time is running out" "minutes left: ${t}"
		spd-say "minutes left: ${t}"
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
read tiempoexport < .minutos.txt

exporta() {
	tiempoexport=$(( -1 * $tiempoexport * 60 * 1000 ))
	echo $tiempoexport > $rutaexport
}


echo ">>>>> process: >>>> $viendo"
echo ">>>>> window: >>>>> $ventana"

if [[ $accion == 0 ]] && [[ $esbuena == 0 ]]
	then
		echo "neutral app, we don't do anything"
		if [[ $idle -lt $inactividad ]]
			then
				tipo_informe="neutral"
			else
				tipo_informe="neutral-inactivo"
		fi
		#notificar_no_clasificada
fi
if [[ $accion == 0 ]] && [[ $esbuena == 1 ]]
	then
		echo "good app, but you have been innactive"
		tipo_informe="innactive-but-good"
		#spd-say "a" # warning for continue working
fi
if [[ $accion == 1 ]]
	then
		echo "bad app!!! decreasing points!!! -----------"
		tipo_informe="bad"
		exporta
fi
if [[ $accion == 2 ]] && [[ $eslahora != 1 ]]
	then
		if [[ $puede_contar == 1 ]]
			then
				echo "good app, increasing points ++++++++++"
		fi
		tipo_informe="good"
		exporta
fi
if [[ $accion == 2 ]] && [[ $eslahora == 1 ]]
	then
		echo "good app, but you are out of the schedule"
		tipo_informe="out-of-schedule-but-good"
fi



#echo "imported minutes = ${importadotot}"
#echo "internal minutes = ${minutos}"
_h=$(( $t/60 ))
_h=$(printf "%02d" $_h)
_m=$(( $t%60 ))
_m=$(printf "%02d" $_m)
echo "${_h}:${_m} left"


echo $fecha > .fecha.txt
echo $summtoday > .summtoday.txt
echo $sum_export_conditions2 > .sum_export_conditions2.txt # positive time used today, yesterday and the day before
echo $sum_export_conditions1 > .sum_export_conditions1.txt # positive time used today and yesterday
echo $sum_export_conditions > .sum_export_conditions.txt # positive time used today

######################################################### adjust format and export to shared folder
## EXPORT FUNCTION ##
function exportconditiondateandmillis()
{
	local __offsetdays=$1
	local __millis=$2
	local __resultvar=$3
	
	local __current_date=$( date +'%Y-%m-%d' )
	local __current_timestamp=$( date -d ${__current_date} +"%s" )
	
	local __one_day_time=$(( 60 * 60 * 24 ))
	local __offset_time=$(( $__one_day_time * $__offsetdays ))
	local __expected_timestamp=$(( $__current_timestamp - $__offset_time ))
	local __offset_date=$( date -d @$__expected_timestamp +"%Y-%m-%d" )
	
	IFS='-' read -ra my_array <<< "$__offset_date"
	
	local __year=${my_array[0]}
	local __month=${my_array[1]}
	__month=$(( 10#$__month - 1 )) ## The MONTH value in Java Calendar starts in 0, we use Java standard for the formats
	__month=$(printf "%02d" $__month) ## format with leading 0
	local __day=${my_array[2]}
	
	__offset_date="${__year}-${__month}-${__day}"
	
	eval $__resultvar="'${__offset_date}-${__millis}'"
}
## TODAY TIME ##
milis_for_export=$(( $sum_export_conditions * 60 * 1000 ))
exportconditiondateandmillis 0 $milis_for_export resultvar
echo $resultvar > "${importablesruta}sum_export_conditions.txt"
## 1-DAY OFFSET TIME ##
milis_for_export=$(( $sum_export_conditions1 * 60 * 1000 ))
exportconditiondateandmillis 1 $milis_for_export resultvar
echo $resultvar > "${importablesruta}sum_export_conditions1.txt"

## 2.DAY OFFSET TIME ##
milis_for_export=$(( $sum_export_conditions2 * 60 * 1000 ))
exportconditiondateandmillis 2 $milis_for_export resultvar
echo $resultvar > "${importablesruta}sum_export_conditions2.txt"

#####################################################################################################


macumuladotot=$(( $minutos + $importadotot ))
if [[ $macumuladotot -lt $limiteacumulado ]] && [[ $accion == 2 ]]
	then
		echo "you have reached the limit of TOTAL ACCUMULATED points"
		/usr/bin/notify-send "you have reached the limit of TOTAL ACCUMULATED points"
	else
		echo $minutos > .minutos.txt
fi

if [[ $summtoday -ge $limitdailypoints ]] && [[ $accion == 2 ]]
	then
		echo "you have reached the limit of DAILY points"
		/usr/bin/notify-send "you have reached the limit of DAILY points"
fi

if [[ $all_conditions_met -eq 0 ]] && [[ $accion == 2 ]]
	then
		echo "you don't met all conditions"
		/usr/bin/notify-send "You don't met all conditions"
fi

summtodayresto=$(( $limitdailypoints - $summtoday ))
#echo "$summtoday points earned today, and $summtodayresto to be earned"
_h=$(( $sum_export_conditions/60 ))
_h=$(printf "%02d" $_h)
_m=$(( $sum_export_conditions%60 ))
_m=$(printf "%02d" $_m)
echo "${_h}:${_m} used"

echo $cerrando > .cerrando.txt

mensaje_log="${mhora}-${minuto} /\t${viendo} /\t${ventana}\r"

# set file for logs into the log folder
dia_hoy=$(date +"%Y-%m-%d")
log_dir="${log_dir}/${dia_hoy}/"
mkdir -p "${log_dir}"
archivo_logs="${log_dir}${dia_hoy}-${tipo_informe}.txt"

echo -e $mensaje_log >> $archivo_logs

minutos_logs="${log_dir}${dia_hoy}.txt"
echo -e "${mhora}-${minuto} - Total ${t} and internal ${minutos} - last activity ${tipo_informe} - ${viendo}\r" >> $minutos_logs

if [[ $accion == 2 ]]
	then
		archivo_sumatorio="${log_dir}${dia_hoy}-sumatorio-positivo.txt"
		touch -a $archivo_sumatorio
		read sumatorio_actual < $archivo_sumatorio
		sumale_uno=$(( $sumatorio_actual + 1 ))
		echo $sumale_uno > $archivo_sumatorio
fi
if [[ $accion == 0 ]] && [[ $esbuena == 0 ]] && [[ $idle -lt $inactividad ]]
	then
		archivo_sumatorio="${log_dir}${dia_hoy}-sumatorio-neutral.txt"
		touch -a $archivo_sumatorio
		read sumatorio_actual < $archivo_sumatorio
		sumale_uno=$(( $sumatorio_actual + 1 ))
		echo $sumale_uno > $archivo_sumatorio
fi
if [[ $accion == 0 ]] && [[ $esbuena == 0 ]] && [[ ! $idle -lt $inactividad ]]
	then
		archivo_sumatorio="${log_dir}${dia_hoy}-sumatorio-neutral-inactivo.txt"
		touch -a $archivo_sumatorio
		read sumatorio_actual < $archivo_sumatorio
		sumale_uno=$(( $sumatorio_actual + 1 ))
		echo $sumale_uno > $archivo_sumatorio
fi
if [[ $accion == 1 ]]
	then
		archivo_sumatorio="${log_dir}${dia_hoy}-sumatorio-negativo.txt"
		touch -a $archivo_sumatorio
		read sumatorio_actual < $archivo_sumatorio
		sumale_uno=$(( $sumatorio_actual + 1 ))
		echo $sumale_uno > $archivo_sumatorio
fi
if [[ $accion == 0 ]] && [[ $esbuena == 1 ]]
	then
		archivo_sumatorio="${log_dir}${dia_hoy}-sumatorio-positivo-inactivo.txt"
		touch -a $archivo_sumatorio
		read sumatorio_actual < $archivo_sumatorio
		sumale_uno=$(( $sumatorio_actual + 1 ))
		echo $sumale_uno > $archivo_sumatorio
fi

