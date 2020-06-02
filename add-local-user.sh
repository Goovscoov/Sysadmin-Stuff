#!/bin/bash
# If the user doesn't supply at least one argument, then give them help.

PASSWORD=$(date +%s%N | sha256sum | head -c48)

if [[ "${UID}" -ne 0 ]]
then
	echo "Your username is $(id -un) and your UID is ${UID}. You must be root te execute this script"
	exit 1
elif [[ "${#}" -lt 1 ]]
then
	echo "Usage: ${0} USERNAME [USERNAME]..."
	echo "You must specify at least one username in order to create a account"
else
	for USERNAME in "${@}"
	do
		useradd -c "${USERNAME}" -m "${USERNAME}" &> /dev/null
		echo "${PASSWORD}" | passwd --stdin "${USERNAME}" &> /dev/null
		passwd -e "${USERNAME}" &> /dev/null 

		if [[ "${?}" -ne  0 ]]
		then
			echo "Account creation for the account "${USERNAME}" was not successfull"
			exit 1
		else	
			echo "Account created successfully:
		      		Username:		${USERNAME} 
		      		Password:		${PASSWORD} #show optional in case password is set manually
		    		created on:		$(date) 
		      		created on machine:	$(hostname)"
		fi
	done
fi
