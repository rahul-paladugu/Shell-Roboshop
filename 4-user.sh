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
script_dir=$PWD

#Configuring User
start_time=$(date +%s)
echo -e "$yellow Disabling default nodjs.. $reset"
dnf module disable nodejs -y &>>$log
echo -e "$yellow Enabling nodjs version 20.. $reset"
dnf module enable nodejs:20 -y &>>$log
echo -e "$yellow Installing Nodejs.. $reset"
dnf install nodejs -y &>>$log
echo -e "$yellow Creating system user $reset"
id=roboshop &>>$log
if [ $id -ne 0 ]; then
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log
else
 echo -e "$green User already exists.. $reset"
fi
echo -e "$yellow Creating App directory $reset"
mkdir -p /app 
echo -e "$yellow Downloading and unzipping code $reset"
curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip
rm -rf /app/*
cd /app 
unzip /tmp/user.zip
cd /app 
echo -e "$yellow Installing Dependencies... $reset"
npm install
#User Service Setup
echo -e "$yellow Configuring User Service.. $reset"
cp $script_dir/user.service /etc/systemd/system/user.service
systemctl daemon-reload
systemctl enable user 
systemctl start user
end_time=$(date +%s)
echo -e "$green Time taken to configure USER is $(($end_time - $start_time))Seconds. $reset"

