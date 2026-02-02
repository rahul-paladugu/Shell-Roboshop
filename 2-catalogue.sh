#!/bin/bash

red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
reset="\e[0m"
user=$(id -u)
script_directory=$PWD
#Validation Function to identify the errors.
error_handler () {
  if [ $? -ne 0 ]; then
    echo -e "$red $1 is failed. Please review the logs. $reset"
    exit 1
  else
    echo -e "$green $1 is success. $reset"
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
dnf module disable nodejs -y &>>$log
error_handler Disable_Nodejs
echo -e "$yellow Enabling version 20 of Nodejs. $reset"
dnf module enable nodejs:20 -y &>>$log
error_handler Enabling_Nodejs_20_Version
echo -e "$yellow Installing Nodejs. $reset"
dnf install nodejs -y &>>$log
error_handler Install_Nodejs
echo -e "$yellow Adding system User. $reset"
id roboshop &>>$log
if [ $? -ne 0 ]; then
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log
else
 echo -e "$blue User already exists. Skipping...... $reset"
fi
error_handler system_user
mkdir -p /app 
error_handler app_directory
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$log
error_handler download_code
cd /app 
error_handler pointing_app_directory
rm -rf /app/*
error_handler removing_existing_code
unzip /tmp/catalogue.zip &>>$log
error_handler unzip_code
cd /app 
error_handler pointing_app_directory
npm install &>>$log
error_handler instaiing_dependencies
#Catalogue Service Setup
echo -e "$blue configuring catalogue service.... $reset"
cp $script_directory/catalogue.service /etc/systemd/system/catalogue.service
error_handler service_setup
systemctl daemon-reload &>>$log
systemctl enable catalogue &>>$log
systemctl start catalogue
error_handler start_service
echo -e "$blue Catalogue service configuration is sucess.... $reset"
#Configuring the mongodb in catalogue.
cp $script_directory/mongo.repo /etc/yum.repos.d/mongo.repo &>>$log
error_handler mongo_repo
dnf install mongodb-mongosh -y &>>$log
error_handler install_mongosh
mongosh --host mongodb.rscloudservices.icu </app/db/master-data.js &>>$log
error_handler load_mongo_schema
end_time=$(date +$s)
echo -e "$yellow Catalogue configuration is completed. Time taken in $(($end_time - $start_time)) Seconds. $reset"





