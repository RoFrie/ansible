#!/bin/bash

# enable host for ansible
set -e   # ErrExit

# Zeige Erklärung wenn Ansible-Server, sonst ausführen
if [ $(hostname) = "Ansible" ]; then
	echo "
Folgende Aktionen werden auf dem genannten Server ausgefüht:
Kopiere den PublicKey von diesem Server 'Ansible', erzeuge den Nutzer ansible, der sich dann ohne Passwort als root anmelden darf und aktualisiere den Server.

Siehe auch ct-Artikel Ansible-Strap und ct.de/yx3v auf heise.de

Welcher Server soll für Ansible-Ausfhrungen vorbereitet werden?"

	read server
	if [ -z "$server" ]; then
		echo "
	Nutzerabbruch
"
		exit
	else
		#cat $(dirname $0)/debansstrap.sh | sed "s|^PUBKEY=.*|PUBKEY=\"$(cat /ansible/.ssh/ecdsa.pub)\"|" >$(dirname $0)/debansstrapKey.sh
		#chmod ug+x $(dirname $0)/debansstrapKey.sh
		ssh root@$server 'bash -s' < $(dirname $0)/debansstrap.sh | sed "s|^PUBKEY=.*|PUBKEY=\"$(cat /ansible/.ssh/ecdsa.pub)\"|"
	fi

	exit 0
fi	

#set -x
# Var mit Public-Key
PUBKEY=""
#echo "PUBKEY: $PUBKEY" | tee ~/pubkey.txt # TESTING

# Erzeuge Nutzer ansible, wenn nicht existert
id -u ansible > /dev/null 2>&1 || adduser ansible --disabled-password --gecos "" --quiet

# Erzeuge Verz. /home/ansible und ../.ssh/authorized_keys als/Ff�r ansible
mkdir -p /home/ansible/.ssh
echo "$PUBKEY" > /home/ansible/.ssh/authorized_keys
chown -R ansible /home/ansible/.ssh

# Aktualisieren
apt-get update
apt-get install sudo

# Nutzer ansible als root ohne Passwort
grep -q ansible /etc/sudoers || echo "ansible ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers
