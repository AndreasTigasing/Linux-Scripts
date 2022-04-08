#!/bin/bash
#########################
#Author:Andreas Tigasing#
#########################
#Backstory
: <<'COMMENT'
In the User Management challenge lab, you were tasked with creating users and groups.
Using the commands one at a time from the command line can be a tedious process and
could lead to potential errors in syntax. It is your duty, as an administrator, to make
the process as seamless and efficient as possible.
COMMENT
​
###COLORING BLOCK###
RED='\033[0;31m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
###COLORING BLOCK###
​
[ $UID = 0 ] || {
    printf "\n  insufficient permission.\n\n"
    printf "    script must be run as root, user: '%s' can't.\n\n" "$USER"
    exit 1
}
​
##############
#--Username--#
##############
​
###Read username input###
read -p "Username: " username
echo "Entered username $username"
echo -e "Checking if user exists... \n"
sleep 1
​
###Checks if username exist###
getent passwd $username >> /dev/null
​
while [ $? -eq 0 ]
  do
    echo -e "User already exists. \n"
    read -p "Input other username: " username
    getent passwd $username >> /dev/null
  done
​
echo -e "Username selected: ${WHITE}$username${NC} \n"
​
###########
#--Group--#
###########
​
###Asks if you want to use username as a group name###
read -r -p "Do you want to use username as group? [Y/N]" response
​
###If you want to use username as group name, then gives an username variable to group###
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
group=$username
getent group $group >> /dev/null
while [ $? -eq 0 ]
  do
    echo -e "Group already exists. \n"
    read -p "Input other group: " group
    getent group $group >> /dev/null
  done
echo -e "Group name selected: ${WHITE}$group${NC} \n"
​
###Elif you dont want to use username as group name, then asks for the group name###
elif [[ "$response" =~ ^([nN][oO]|[nN])$ ]]; then
read -p "Group: " group
echo -e "Checking if group exists... \n"
sleep 1
getent group $group >> /dev/null
while [ $? -eq 0 ]
  do
    echo -e "Group already exists. \n"
    read -p "Input other group: " group
    getent group $group >> /dev/null
  done
​
###If you inputed any other character, it exits the script, bc u have fat fingers and cant read###
else
sleep 1
echo "You are dumb AF"
exit 1
fi
​
###Asks if you want to use random password
read -r -p "Do you want to use random generated password? [Y/N]" randpass
​
if [[ "$randpass" =~ ^([yY][eE][sS]|[yY])$ ]]; then
###Generates random password###
password=$(cat /dev/urandom | tr -dc A-Za-z0-9 | head -c12)
​
###If you want to input your own password###
elif [[ "$randpass" =~ ^([nN][oO]|[nN])$ ]]; then
  read -p "Enter password: " password
​
###If you were dumb enough to enter any other variable, you will be greeted with an exit code of 1 :)###
else
  sleep 1
  echo "You are dumb AF"
  exit 1
fi
###Shows your progress so far
cat <<TAG
​
Creating account:
        Username : $username
           Group : $group
        Password : $password
Password expires : 7 days
  User directory : /$username
TAG
​
###Asks for confirmation###
read -p "Create [Y/N]? " create
​
if [[ "$create" =~ ^([yY][eE][sS]|[yY])$ ]]; then
  groupadd $group || {
    echo -e "\n ${RED}groupadd command failed.${NC} \n\n"
    exit 1
  }
  useradd -m -s /bin/bash -g $group -p $password $username || {
    echo -e "\n ${RED}useradd command failed.${NC} \n\n"
    exit 1
  }
  passwd -x 7 $username || {
    echo -e "\n ${RED}passwd age setting failed.${NC} \n\n"
    exit 1
  }
  mkdir /$username || {
    echo -e "\n ${RED}mkdir command failed.${NC} \n\n"
    exit 1
  }
  chown $username.$groupname /$username && chmod 1770 /$username || {
    echo -e "\n ${RED}mkdir command failed.${NC} \n\n"
    exit 1
  }
​
###Tells you what you had done###
clear
  cat <<TAG
​
Created new user!
​
        Username : $username
           Group : $group
        Password : $password
Password expires : 7 days
  User directory : /$username
​
Remind the user that he/she has to change their password in 7 days!
​
TAG
​
else
  echo -e "\n\nNo user created - user inputed $create"
fi
​
​
​
exit 0