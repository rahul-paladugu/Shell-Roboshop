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
#Creating Logs Folder to store the results
logs_folder="/var/logs/shell-roboshop"
mkdir -p $logs_folder
script_name=$(echo $0 | cut -d "." -f1)
log="$logs_folder/$script_name.log"
#Requesting user to run the script using root access.
if [ $user -ne 0 ]; then
  echo -e "$red Please run the script using root access. $reset"
  exit 1
fi
#Catalogue Configuration
start_time=$(date +$s)
echo -e "$yellow Disabling default version of Nodejs. $reset"
dnf module disable nodejs -y
error_handler nodejs
echo -e "$yellow Enabling version 20 of Nodejs. $reset"
dnf module enable nodejs:20 -y
error_handler nodejs
echo -e "$yellow Installing Nodejs. $reset"
dnf install nodejs -y
error_handler Install_nodejs
echo -e "$yellow Adding system User. $reset"
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
error_handler system_user
mkdir -p /app 
error_handler app_directory
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
error_handler download_code
cd /app 
error_handler pointing_app_directory
unzip /tmp/catalogue.zip
error_handler unzip_code
cd /app 
error_handler pointing_app_directory
npm install &>>$log
error_handler instaiing_dependencies
echo -e "$yellow configuring catalogue service.... $reset"
cp $(echo $PWD)/catalogue.service /etc/systemd/system/catalogue.service
error_handler service_setup
systemctl daemon-reload
systemctl enable catalogue
systemctl start catalogue
error_handler start_service
cp $(echo $PWD)/mongo.repo /etc/yum.repos.d/mongo.repo
error_handler mongo_repo
dnf install mongodb-mongosh -y
error_handler install_mongosh
mongosh --host mongodb.rscloudservices.icu </app/db/master-data.js
error_handler load_mongo_schema
end_time=$(date +$s)
echo -e "$yellow Catalogue configuration is completed. Time taken in $(($end_time - $start_time)) Seconds. $reset"





