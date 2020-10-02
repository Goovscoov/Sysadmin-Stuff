#!/bin/bash

#Script that automates to disable useraccounts
#This script also provides the capabilities to delete an useraccount and archive the homefolder.
#test

#usage output function
usage() {
echo "Script to disable or delete a user account(s)."
echo "Script provides options to remove or archive homedir of specified user account."
echo "Usage: ${0} -[dra] USERNAME ..." 
echo "
	OPTIONS:
	-d	Deletes accounts instead of disabling them
	-r	Removes the home directory associated with the account(s).
	-a	Creates an archive of the home directory associated with the accounts(s) and stores the archive in the /archives directory"
exit 1
}

#command execution check function
command_check() {
if [[ "${?}" -ne 0 ]]
then
	echo "The command did not executed properly" >&2
        exit 1
fi
}


#check if the script is bein executed with superuser prvileges
if [[ "${UID}" -ne 0 ]]
then
	echo "Your username is $(id -un) and your UID is ${UID}. You must be root te execute this script"
	exit 1
fi

# Parse the options.
while getopts dra OPTION
do
  case ${OPTION} in
    d) DELETE_USER='true' ;;
    r) REMOVE_OPTION='-r' ;;
    a) ARCHIVE='true' ;;
    ?) usage ;;
  esac
done

# Remove the options while leaving the remaining arguments.
shift "$(( OPTIND - 1 ))"

# If the user doesn't supply at least one argument, display usage.
if [[ "${#}" -lt 1 ]]
then
  usage
fi

# Execute supplied arguments on provided user accounts.
for USERNAME in "${@}"
do
	echo "Processing user: ${USERNAME}"
	
	#check if user exist on system
	USERID=$(id -u ${USERNAME})
	if [[ "${?}" -ne 0 ]]
	then
		echo "The user does not exist on the system"
		exit 1
	fi

	# if user exist parse arguments
        HOME_DIR="/home/${USERNAME}"
	readonly ARCHIVE_DIR='/archive'
        ARCHIVE_FILE="${ARCHIVE_DIR}/${USERNAME}.tgz"

	#check if userid is below 1000 (system users cannot be deleted)	
	if [[ "${USERID}" -lt 1000 ]]
	then
    	echo "Refusing to remove the ${USERNAME} account with UID ${USERID}." >&2
    	exit 1
  	fi

  	# -a option. Creating achrive folder if it does not exsist on the system. 
	if [[ "${ARCHIVE}" = 'true' ]]
	then
		if [[ ! -d "${ARCHIVE_DIR}" ]]
		then
			echo "Creating ${ARCHIVE_DIR} directory."
			mkdir -p ${ARCHIVE_DIR}
			command_check
		fi
		
		# Archive the user's home directory and move it into the ARCHIVE_DIR
	    	if [[ -d "${HOME_DIR}" ]]
	    	then
	      		echo "Archiving ${HOME_DIR} to ${ARCHIVE_FILE}"
	      		tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &> /dev/null
	      		command_check
	    	else
	      		echo "${HOME_DIR} does not exist or is not a directory." >&2
	      		exit 1
	   	fi
	fi 

	# -d and -r option. Delete a user or if no option disable the user.	
	if [[ "${DELETE_USER}" = 'true' ]]
	then
		userdel ${REMOVE_OPTION} ${USERNAME}
		command_check
    		echo "The account ${USERNAME} was deleted."
  	else
    		chage -E 0 ${USERNAME}
		command_check
    		echo "The account ${USERNAME} was disabled."
  	fi
done
exit 0
	


