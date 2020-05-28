#!/bin/bash

#simple script to create useraccounts

if [[ "${UID}" -ne 0 ]]
then
	echo "Your username is $(id -un) and your UID is ${UID}. You must be root te execute this script"
	exit 1
else
	read -p "Enter the username for this new user: " USERNAME 
	read -p "Enter the real name for this new user: " COMMENT
	useradd -c "${COMMENT}" -m ${USERNAME} >/dev/null 2>&1
	if [[ "${?}" -ne 0 ]]
	then
		echo "This account could not be created"
		exit 1
	else
		read -p "Enter the password for this new user: " PASSWORD
		echo ${PASSWORD} | passwd --stdin ${USERNAME} >/dev/null 2>&1
		if [[ "${?}" -ne  0 ]]
		then
			echo "The password for this account could not be set"
			exit 1
		else
			passwd -e ${USERNAME} >/dev/null 2>&1
			echo "Account created successfully:
		      		Username:		${USERNAME} 
		      		Real name:		${COMMENT}
		      		Password:		${PASSWORD}  #optional hidden in output
		    		created on:		$(date) 
		      		created on machine:	$(hostname)"
			exit 1
		fi

	fi
fi 





