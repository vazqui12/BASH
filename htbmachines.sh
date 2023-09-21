#!/bin/bash

# Paleta de Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"


# Funcion para cerrar proceso al usar control + c
function ctrl_c(){
	echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
	tput cnorm;
	exit 1
}

# Ctrl+C
trap ctrl_c INT

# Variables globales
main_url="https://htbmachines.github.io/bundle.js"


# Help Panel (el parametro -e sirve para capturar caracteres especiales)
function helpPanel(){
	echo -e "\n${yellowColour}[+]${endColour}${grayColour} Uso:${endColour}\n"
	echo -e "\t${purpleColour}u)${endColour}${grayColour} Descargar o actualizar archivos necesarios${endColour}\n"
	echo -e "\t${purpleColour}m)${endColour}${grayColour} Buscar por un nombre de maquina${endColour}\n"
	echo -e "\t${purpleColour}i)${endColour}${grayColour} Buscar por direccion IP${endColour}\n"
	echo -e "\t${purpleColour}d)${endColour}${grayColour} Buscar por dificultad -->${redColour} Insane${endColour}${grayColour},${endColour}${purpleColour} Difícil${endColour}${grayColour},${endColour}${yellowColour} Media${endColour}${grayColour} o${endColour}${turquoiseColour} Fácil${endColour}\n"
	echo -e "\t${purpleColour}o)${endColour}${grayColour} Buscar por sistema operativo --> ${greenColour} Linux${endColour}${grayColour} o${endColour}${blueColour} Windows${endColour}\n"
	echo -e "\t${purpleColour}s)${endColour}${grayColour} Buscar por skill${endColour}\n"
	echo -e "\t${purpleColour}y)${endColour}${grayColour} Obtener link youtube${endColour}\n"
	echo -e "\t${purpleColour}h)${endColour}${grayColour} Mostrar este panel de ayuda${endColour}\n"
}

# Search Machine
function searchMachine(){
	machineName="$1" # Usamos el $1 para quedarnos con el valor del primer parámtro pasado por la terminal

	machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//')"

	if [ "$machineName_checker" ]; then
		echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la máquina${endColour}${blueColour} $machineName${endColour}${graycolour}:${endColour}\n"
	
		cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//'
	else
		echo -e "\n${redColour}[!] La maquina proporcionada no existe${endColour}\n"
	fi
}

# Update Files
function updateFiles() {
	if [ ! -f bundle.js ]; then
		tput civis
		echo -e "\n${yellowColour}[+]${endColour}${grayColour} Descargando archivos necesarios...${endColour}\n"
		curl -s $main_url > bundle.js
		js-beautify bundle.js | sponge bundle.js
		echo -e "\n${yellowColour}[+]${endColour}${grayColour} Todos los archivos han sido descargados${endColour}\n"
		tput cnorm
	else
		tput civis
		echo -e "\n${yellowColour}[+]${endColour}${grayColour} Comprobando si hay actualizaciones pendientes...${endColour}\n"
		curl -s $main_url > bundle_temp.js
		js-beautify bundle_temp.js | sponge bundle_temp.js
		md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
		md5_original_value=$(md5sum bundle.js | awk '{print $1}')

		if [ "$md5_temp_value" == "$md5_original_value" ]; then
			echo -e "\n${yellowColour}[+]${endColour}${grayColour} No se han encontrado actualizaciones${endColour}\n"
			rm bundle_temp.js
		else
			echo -e "\n${yellowColour}[+]${endColour}${endColour} Se han encontrado actualizaciones${endColour}\n"
			sleep 1

			rm bundle.js && mv bundle_temp.js bundle.js

			echo -e "\n${yellowColour}[+]${endColour}${grayColour} Los archivos han sido actualizados${endColour}\n"
		fi
		tput cnorm
	fi
}

# buscador de maquina por IP
function searchIP(){
	ipAddress="$1"

	if [ "$machineName" ]; then
		machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
		echo -e "\n${yellowColour}[+]${endColour}${grayColour} La maquina correspondiente para la IP${endColour}${blueColour} $ipAddress${endColour}${grayColour} es${endColour}${purpleColour} $machineName${endColour}\n"
	else
		echo -e "\n${redColour}[!] La direccion IP proporcionada no existe${endColour}\n"
	fi
}


# buscador de enlace a video youtube de la maquina
function getYoutubeLink(){
	machineName="$1"

	youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"

	if [ "$youtubeLink" ]; then
		echo -e "\n${yellowColour}[!] El link al tutorial de esta maquina es:${endColour}${blueColour} $youtubeLink${endColour}\n"
	else
		echo -e "\n${redColour}[!] La maquina proporcionada no existe${endColour}\n"
	fi
}

# Buscador de maquinas segund dificultad
function getMachinesDifficulty(){
	difficulty="$1"

	results_check="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column )"

	if [ "$results_check" ]; then
		if [ "$difficulty" == "Insane" ]; then
                        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando las maquinas que poseen la dificultad${endColour}${redColour} $difficulty${endColour}${grayColour}:${endColour}\n"
                        cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
                elif [ "$difficulty" == "Difícil" ]; then
                        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando las maquinas que poseen la dificultad${endColour}${purpleColour} $difficulty${endColour}${grayColour}:${endColour}\n"
                        cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
                elif [ "$difficulty" == "Media" ]; then
                        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando las maquinas que poseen la dificultad${endColour}${yellowColour} $difficulty${endColour}${grayColour}:${endColour}\n"
                        cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
                else
                        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando las maquinas que poseen la dificultad${endColour}${turquoiseColour} $difficulty${endColour}${grayColour}:${endColour}\n"
                        cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
                fi
	else
		echo -e "\n${redColour}[!] La dificultad proporcionada no existe${endColour}\n"
	fi
}


# Buscador de maquinas segun sistema operativo
function getOSMachines(){
	os="$1"

	os_results="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$os_results" ]; then
        	if [ "$os" == "Linux" ]; then
                         echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando las maquinas que poseen el sistema operativo${endColour}${greenColour} $os${endColour}${grayColour}:${endColour}\n"
                         cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
                else
                        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando las maquinas que poseen el sistema operativo${endColour}${blueColour} $os${endColour}${grayColour}:${endColour}\n"
                        cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
                fi
    else
        echo -e "\n${redColour}[!] El sistema operativo proporcionado no existe${endColour}\n"
    fi
}


# Buscador maquinas segun OS y dificultad
function getOSDifficultyMachines(){
	difficulty="$1"
	os="$2"

	check_results="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$check_results" ]; then
		echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando las maquinas con dificultad${endColour}${blueColour} $difficulty${endColour}${grayColour} y sistema operativo${endColour}${purpleColour} $os${endColour}\n"
		cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${redColour}[!] Se ha indicado un OS o dificultad incorrecta${endColour}\n"
	fi
}

# Buscar maquina por skill
function getSkill(){
	skill="$1"

	check_skill="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$check_skill" ]; then
        echo -e "\n${yellowColour}[+]${endColour}${grayColour} Mostrando las maquinas con la skill${endColour}${blueColour} $skill${endColour}\n"
        cat bundle.js | grep "skills: " -B 6 | grep $skill -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
    else
        echo -e "\n${redColour}[!] Se ha indicado una skill incorrecta${endColour}\n"
    fi

}



# Indicadores (-i para que sea un valor integer)
declare -i parameter_counter=0
declare -i chivato_difficulty=0
declare -i chivato_os=0


# Menu
# m tiene : porque se espera que se proporcione un argumento siempre que se use -m. Con -h no es necesario
# especificar argumento. La variable arg contiene el valor de la opcion actual que ha sido analizada por
# getopts.
while getopts "m:ui:y:d:o:s:h" arg; do
	case $arg in
		m) machineName="$OPTARG"; let parameter_counter+=1;; # $OPTARG almacena el valor asociado al parametro indicado
		u) let parameter_counter+=2;;
		i) ipAddress="$OPTARG"; let parameter_counter+=3;;
		y) machineName="$OPTARG"; let parameter_counter+=4;;
		d) difficulty="$OPTARG";chivato_difficulty=1; let parameter_counter+=5;;
		o) os="$OPTARG";chivato_os=1; let parameter_counter+=6;;
		s) skill="$OPTARG"; let parameter_counter+=7;;
		h) ;; # Para cada sentencia hay que poner ;; para cerrarla
	esac
done

# utilizamos -eq cuando comparamos valores numericos
if [ $parameter_counter -eq 1 ]; then 
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
	getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
	getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
	getOSMachines $os
elif [ $parameter_counter -eq 7 ]; then
	getSkill $skill
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
	getOSDifficultyMachines $difficulty $os
else
	helpPanel
fi
