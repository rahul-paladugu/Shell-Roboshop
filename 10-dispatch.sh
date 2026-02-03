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
trap 'echo -e "$red Error executing Line: $LINENO Command: $BASH_COMMAND $reset"' ERR

#Enabling Logs
log_directory="/var/logs/robo-shop"
mkdir -p $log_directory
script_name=$(echo $0 | cut -d "." -f1)
log="$log_directory/$script_name.log"
script_dir=$PWD

#Configuring Cart
start_time=$(date +%s)
echo -e "$yellow Installing golang.. $reset"
dnf install golang -y -y &>>$log
echo -e "$yellow Creating system user.. $reset"
if id -u roboshop &>>$log; then 
 echo -e "$green user already exists. Hence skipping... $reset"
else 
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log
fi
echo -e "$yellow Creating App directory and downloading code.. $reset"
mkdir -p /app &>>$log
curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip 
rm -rf /app/*
cd /app 
unzip /tmp/dispatch.zip
echo -e "$yellow Installing dependencies.. $reset"
cd /app 
go mod init dispatch
go get 
go build
#Setup Payment Service
echo -e "$yellow Setup Dispatch service.. $reset"
cp $script_dir/dispatch.service /etc/systemd/system/dispatch.service
systemctl daemon-reload
systemctl daemon-reload
end_time=$(date +%s)
echo -e "$green Time taken to configure Dispatch is $(($end_time - $start_time))Seconds. $reset"
