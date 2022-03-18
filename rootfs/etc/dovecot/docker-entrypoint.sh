#!/bin/bash

PASSWD_FILE="/etc/dovecot/users"
CONF_FILE="/etc/dovecot/dovecot-docker.conf"
THIS_GID=2000
UID_OFFSET=2000

echo "Welcome to steilerGroup Mail-Archive, powered by dovecot!"

uservar_base="IMAP_USER_"
user_index=1
user_var="${uservar_base}${user_index}"

if [ -z ${!user_var} ]; then
    echo "No $user_var defined, cannot startup without user definitions!"
    exit 1
else
    > $PASSWD_FILE
    while [ ! -z ${!user_var} ]; do
        THIS_USER="${!user_var}"
        if [[ $THIS_USER =~ ":" ]]; then
            USERNAME=${THIS_USER%%:*} 
            PASSWORD=${THIS_USER#*:}
            HASHED_PASSWORD=$(doveadm pw -s SHA512-CRYPT -p ${PASSWORD})
            THIS_UID=$((user_index+$UID_OFFSET))
            echo "${USERNAME}:${HASHED_PASSWORD}:${THIS_UID}:${THIS_GID}::/home/virtual/test" >> $PASSWD_FILE
            echo "Created user $USERNAME"
        else
            echo "User does not have a password (seperator is missing)!"
        fi

        # Setting for next iteration
        ((user_index++))
        user_var="${uservar_base}${user_index}"
    done
    echo "All users created!"
    cat $PASSWD_FILE
fi
echo "Starting dovecot..."
exec /usr/sbin/dovecot -c "/etc/dovecot/dovecot.conf" -F