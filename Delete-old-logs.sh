#!/bin/bash

#Adding Colours
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
reset="\e[0m"
files_path="/home/ec2-user/logs"
logs=$(find $files_path -name "*.log" -mtime +14 -type f)
root_user=$(id -u)
#Check root access
if [ $root_user -ne 0 ]; then
  echo -e "${red}Please run the script using root access..${reset}"
  exit 1
fi

while IFS= read -r line
do
 echo -e "Deleting the old logs..${yellow} $line ${reset}"
 rm -f $logs
 echo -e "Deleted the log -${yellow} $line ${yellow}"
done <<< $logs
