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
echo -e "$yellow Installing python3.. $reset"
dnf install python3 gcc python3-devel -y &>>$log
echo -e "$yellow Creating system user.. $reset"
if id -u roboshop &>>$log; then
 echo -e "$green user already exists. Hence skipping... $reset"
else 
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log
fi
echo -e "$yellow Creating App directory and downloading code.. $reset"
mkdir -p /app &>>$log
curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$log
rm -rf /app/*
cd /app 
unzip /tmp/payment.zip &>>$log
echo -e "$yellow Installing dependencies.. $reset"
cd /app 
pip3 install -r requirements.txt &>>$log
#Setup Payment Service
echo -e "$yellow Setup payment service.. $reset"
cp $script_dir/payment.service /etc/systemd/system/payment.service
systemctl daemon-reload &>>$log
systemctl enable payment  &>>$log
systemctl start payment &>>$log
end_time=$(date +%s)
echo -e "$green Time taken to configure Payment is $(($end_time - $start_time))Seconds. $reset"
