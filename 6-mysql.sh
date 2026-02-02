#!/bin/bash
#Adding Colours
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
reset="\e[0m"
id=$(id -u)
if [ $id -ne 0 ]; then
 echo -e "$red Please run the script using root access. $reset"
 exit 1
fi
#Catching Errors
set -e
trap 'echo -e "$red Error executing Line: $LINENO Command is $BASH_Command $reset"' ERR

#Enabling Logs
log_directory="/var/logs/robo-shop"
mkdir -p $log_directory
script_name=$(echo $0 | cut -d "." -f1)
log="$log_directory/$script_name.log"

#Configuring Mysql
start_time=$(date +%s)
echo -e "$yellow Installing Mysql Server $reset"
dnf install mysql-server -y &>>$log
systemctl enable mysqld &>>$log
systemctl start mysqld 
echo -e "$yellow Setting root password $reset"
mysql_secure_installation --set-root-pass RoboShop@1 &>>$log
end_time=$(date +%s)
echo -e "$green Time taken to configure MySQL is $(($end_time - $start_time))Seconds. $reset"
