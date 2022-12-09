#!/bin/bash

def_port='5678'

CR=$'\e[1;31m' CG=$'\e[1;32m' CY=$'\e[1;33m' CB=$'\e[1;34m' CC=$'\e[1;36m' CW=$'\e[1;37m' RS=$'\e[1;0m'

architecture=`uname -m`

terminated() {
	printf "\n\n${RS} ${CR}[${CW}!${CR}]${CY} Program Finished....Thanks for using ${CR}[${CW}!${CR}]${RS}\n"
	exit 1
}

trap terminated SIGTERM
trap terminated SIGINT

kill_pid() {
	check_PID="php ngrok cloudflared"
	for process in ${check_PID}; do
		if [[ $(pidof ${process}) ]]; then
			killall ${process} > /dev/null 2>&1
		fi
	done
}

logo(){

clear
echo "${CY}
${CG}
${CG}██╗░░██╗██████╗░░█████╗░░██${CG}████╗███████╗
${CG}╚██╗██╔╝██╔══██╗██╔══██╗██╔${CG}════╝██╔════╝
${CG}░╚███╔╝░██████╔╝██║░░██║╚██${CG}███╗░█████╗░░
${CG}░██╔██╗░██╔═══╝░██║░░██║░╚═${CG}══██╗██╔══╝░░
${CG}██╔╝╚██╗██║░░░░░╚█████╔╝███${CG}███╔╝███████╗
${CG}╚═╝░░╚═╝╚═╝░░░░░░╚════╝░╚══${CG}═══╝░╚══════╝
${RS}
${CR} [${CW}~${CR}]${CY} Programmed By ${CG}${CC}Anonycodexia${CG}${RS}"

}

path(){
	logo
	printf "\n${RS} ${CR}[${CW}1${CR}]${CY} Use Default Path [xpose/server]"
	printf "\n${RS} ${CR}[${CW}2${CR}]${CY} Setup your own Path"
	printf "\n${RS}"
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Select your Hosting option: ${CC}"
	read red_path
	
	if [[ $red_path == 1 || $red_path == 01 ]]; then
		path=$'./server'
	elif [[ $red_path == 2 || $red_path == 02 ]]; then
		printf "\n${RS} ${CC}Enter Your File Path [Example : /home/xpose/server]"
		printf "\n${RS}"
		printf "\n${RS} ${CR}>>${CG} ${CC}"
		read path
	else
		printf "\n${RS} ${CR}[${CW}!${CR}]${CY} Invalid option ${CR}[${CW}!${CR}]${RS}\n"
		sleep 2 ; logo ; path
	fi

	[[ ! -d "$path" ]] && mkdir -p "$path"
	menu
}

package(){
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Setting up xpose..${RS}"
	if [[ -d "/data/data/com.termux/files/home" ]]; then
		if [[ ! $(command -v proot) ]]; then
			printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Installing ${CY}Proot${RS}\n"
			pkg install proot resolv-conf -y
		fi
	fi

	if [[ $(command -v php) && $(command -v curl) && $(command -v unzip) ]]; then
		printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Xpose Setup Completed !${RS}"
	else
		repr=(curl php unzip)
		for i in "${repr[@]}"; do
			type -p "$i" &>/dev/null || 
				{ 
					printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Installing... ${CY}${i}${RS}\n"
					
					if [[ $(command -v pkg) ]]; then
						pkg install "$i" -y
					elif [[ $(command -v apt) ]]; then
						sudo apt install "$i" -y
					elif [[ $(command -v apt-get) ]]; then
						sudo apt-get install "$i" -y
					elif [[ $(command -v dnf) ]]; then
						sudo dnf -y install "$i"
					else
						printf "\n${RS} ${CR}[${CW}!${CR}]${CY} Unfamiliar Distro ${CR}[${CW}!${CR}]${RS}\n"
						exit 1
					fi
				}
		done
	fi
}

download() {
	url="$1"
	output="$2"
	file=`basename $url`
	if [[ -e "$file" || -e "$output" ]]; then
		rm -rf "$file" "$output"
	fi
	curl --silent --insecure --fail --retry-connrefused \
		--retry 3 --retry-delay 2 --location --output "${file}" "${url}"

	if [[ -e "$file" ]]; then
		if [[ ${file#*.} == "zip" ]]; then
			unzip -qq $file > /dev/null 2>&1
		elif [[ ${file#*.} == "tgz" ]]; then
			tar -zxf $file > /dev/null 2>&1
		else
			mv -f $file $output > /dev/null 2>&1
		fi
		chmod +x $output > /dev/null 2>&1
		rm -rf "$file"
	else
		echo -e "\n${RS} ${CR}[${CW}!${CR}]${CY} Error occured while downloading ${CR}${output}."
		exit 1
	fi
}

install_ngrok() {
	if [[ -e "./ngrok" ]]; then
		printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Ngrok already installed.${RS}"
	else
		printf "\n${RS} ${CR}[${CW}-${CR}]${CC} Installing ngrok...${RS}"
		if [[ ("$architecture" == *'arm'*) || ("$architecture" == *'Android'*) ]]; then
			download 'https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm.tgz' 'ngrok'
		elif [[ "$architecture" == *'aarch64'* ]]; then
			download 'https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz' 'ngrok'
		elif [[ "$architecture" == *'x86_64'* ]]; then
			download 'https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz' 'ngrok'
		else
			download 'https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-386.tgz' 'ngrok'
		fi
	fi
}

install_cloudflared() {
	if [[ -e "./cloudflared" ]]; then
		printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Cloudflared already installed.${RS}"
	else
		printf "\n${RS} ${CR}[${CW}-${CR}]${CC} Installing Cloudflared...${RS}"
		if [[ ("$architecture" == *'arm'*) || ("$architecture" == *'Android'*) ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm' 'cloudflared'	
		elif [[ "$architecture" == *'aarch64'* ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64' 'cloudflared'
		elif [[ "$architecture" == *'x86_64'* ]]; then
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64' 'cloudflared'
		else
			download 'https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-386' 'cloudflared'
		fi
	fi
}

ngrok_auth() {
	if ! [[ -e ".ngrok.yml" && $(awk -F'authtoken: ' '{print $2}' "./.ngrok.yml" | xargs) != "" ]]; then
		{ logo; sleep 1; }
		echo -e "\n${CR} [${CW}!${CR}]${CG} Create an account on ${CY}ngrok.com${CG} & copy the token\n"
		sleep 3
		read -p "${CR} [${CW}?${CR}]${CY} Input Ngrok.com Token :${CY} " ngrok_token
		if [[ ${#ngrok_token} -lt 10 ]]; then
			echo -e "\n${CR} [${CQ}!${CR}]${CR} You have to input valid ngrok Token."
			sleep 2; menu;
		else
			./ngrok --config ".ngrok.yml" authtoken $ngrok_token > /dev/null 2>&1 &
		fi
	fi
}

localhost() {
	printf "\n${RS} ${CR}[${CW}-${CR}]${CY} Input Port [default:${def_port}]: ${CC}"
	read port
	port="${port:-${def_port}}"
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Starting PHP Server on Port ${CY}${port}${RS}\n"
	cd "$path" && php -S 127.0.0.1:"$port" > /dev/null 2>&1 &
	sleep 2
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Successfully xposed at : ${CY}http://127.0.0.1:$port ${RS}"
	printf "\n\n ${CR}[${CW}-${CR}]${CC} Press Ctrl + C to exit.${RS}\n"
	while [ true ]; do
		sleep 0.75
	done
}

ngrok() {
	ngrok_auth
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Starting PHP Server on Port ${CY}${def_port}${RS}\n"
	cd "$path" && php -S 127.0.0.1:"$def_port" > /dev/null 2>&1 &
	sleep 1
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Launching Ngrok on Port ${CY}${def_port}${RS}"

	if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./ngrok --config ".ngrok.yml" http 127.0.0.1:"$def_port" --log=stdout > /dev/null 2>&1 &
	else
		sleep 2 && ./ngrok --config ".ngrok.yml" http 127.0.0.1:"$def_port" --log=stdout > /dev/null 2>&1 &
	fi

	sleep 8
	ngrk=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -Eo '(https)://[^/"]+(.ngrok.io)')
	printf "\n\n${RS} ${CR}[${CW}-${CR}]${CG} Successfully xposed at : ${CY}${ngrk}${RS}"
	printf "\n\n ${CR}[${CW}-${CR}]${CC} Press Ctrl + C to exit.${RS}\n"
	while [ true ]; do
		sleep 0.75
	done
}

cloudflared() { 
	rm .cld.log > /dev/null 2>&1 &
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Starting PHP Server on Port ${CY}${def_port}${RS}\n"
	cd "$path" && php -S 127.0.0.1:"$def_port" > /dev/null 2>&1 &
	sleep 1
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Launching Cloudflared on Port ${CY}${def_port}${RS}"

	if [[ `command -v termux-chroot` ]]; then
		sleep 2 && termux-chroot ./cloudflared tunnel -url 127.0.0.1:"$def_port" --logfile ".cld.log" > /dev/null 2>&1 &
	else
		sleep 2 && ./cloudflared tunnel -url 127.0.0.1:"$def_port" --logfile ".cld.log" > /dev/null 2>&1 &
	fi

	sleep 8
	cldflr=$(grep -o 'https://[-0-9a-z]*\.trycloudflare.com' ".cld.log")
	printf "\n\n${RS} ${CR}[${CW}-${CR}]${CG} Successfully xposed at : ${CY}${cldflr}${RS}"
	printf "\n\n ${CR}[${CW}-${CR}]${CC} Press Ctrl + C to exit.${RS}\n"
	while [ true ]; do
		sleep 0.75
	done
}

menu() {
	logo
	echo -e "\n${CR} [${CW}01${CR}]${CG} Localhost"
	echo -e "${CR} [${CW}02${CR}]${CG} Ngrok.io"
	echo -e "${CR} [${CW}03${CR}]${CG} Cloudflared"
	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Select an Option: ${CB}"
	read REPLY

	case $REPLY in 
		1 | 01)
			localhost;;
		2 | 02)
			ngrok;;
		3 | 03)
			cloudflared;;
		*)
			printf "\n${RS} ${CR}[${CW}!${CR}]${CY} Invalid option ${CR}[${CW}!${CR}]${RS}\n"
			sleep 2; path;;
	esac
}

kill_pid
package
install_ngrok
install_cloudflared
pathstall_cloudflared
path