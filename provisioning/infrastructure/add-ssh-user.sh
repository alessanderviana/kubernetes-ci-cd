#! /bin/bash

SSH_USER="alessander"
shift
SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDHdy8fTUvaQ0sTsVZbrcirh3z0wcv9caobd4o7ief2RUSWRwBvfFkRvrvo7bYKswceSCzJJuuvklClEBfmlZg+YxPnK5gfX8Y+t43gSevpzdnuicN6bwoZScS8J0wOZ3e6wBZ3wpPMPfmI/iJFprmxRM3umhZ8U/9XpbhGZkK5WwMEqQi6yQiP0owq8UVoEOyfg5wquRPL4iQhoYLjQCW9fDXvX4IqkBn+5PCE+dxUng1vTIOgVmVd6HNrub9R15fJ7eBXHpzC9ydABSuo+Ie5aSgQ49FfVecQNDDCasZskp+srL5Yb/SuVBvOlUzih/1TgA0s5tbqTBYfLOx4DNeb alessander@inspiron"

# Create a user
adduser ${SSH_USER}

# And put a random password
# PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
# echo ${USER}:${PASSWORD} | chpasswd

# Add the user to the respective group so they can sudo
DISTRO=$( cat /proc/version | awk '{ print $8 }' )
# DISTRO=$( hostnamectl | grep 'Operating System' | awk '{ print $3 }' )
if [ "${DISTRO}" == "(Ubuntu" ]; then
  usermod -a -G sudo ${SSH_USER}
  CI_FILE="/etc/sudoers.d/90-cloud-init-users"
else
  usermod -a -G wheel ${SSH_USER}
  CI_FILE="/etc/sudoers.d/cloud-init"
fi

echo "${SSH_USER} ALL=(ALL) NOPASSWD:ALL" >> ${CI_FILE}

# add the ssh public key
su - ${SSH_USER} -c "umask 022 ; mkdir .ssh ; echo ${SSH_PUBLIC_KEY} >> .ssh/authorized_keys"
