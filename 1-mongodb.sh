#!/bin/bash

red="\e[31m"
green="\e[32m"
yellow="\e[33m"
reset="\e[0m"
user=$(id -u)
#Validation Function to identify the errors.
error_handler () {
  if [ $? -ne 0 ]; then
    echo -e "$red Execution of $1 is failure. Please review the logs. $reset"
    exit 1
  else
    echo -e "$green Execution of $1 is success. $reset"
  fi
}

#Requesting user to run the script using root access.
if [ $user -ne 0 ]; then
  echo -e "$red Please run the script using root access. $reset"
  exit 1
fi
#Creating Logs Folder to store the results
logs_folder="/var/logs/shell-roboshop"
mkdir -p $logs_folder
script_name=$(echo $0 | cut -d "." -f1)
log="$logs_folder/$script_name.log"

#Configuring Mongodb
echo -e "$yellow Copying Mongodb repo. $reset"
cp "$(echo $PWD)/mongo.repo" "/etc/yum.repos.d/mongo.repo"
error_handler Adding_Repo_File
echo -e "$yellow Installing Mongodb. $reset"
dnf install mongodb-org -y &>>$log
error_handler Mongodb_Installation
systemctl enable mongod &>>$log
error_handler enabling_service
systemctl start mongod &>>$log
error_handler start_the_service
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf 
error_handler updating_ip
systemctl restart mongod &>>$log
error_handler restarting_mongod_service
