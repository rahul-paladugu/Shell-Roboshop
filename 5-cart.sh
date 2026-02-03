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

#Configuring Cart
start_time=$(date +%s)
echo -e "$yellow Disabling default Nodejs & Enabling version 20 $reset"
dnf module disable nodejs -y &>>$log
dnf module enable nodejs:20 -y &>>$log
echo -e "$yellow Installing Nodejs $reset"
dnf install nodejs -y &>>$log
echo -e "$yellow Creating System User $reset"
id roboshop &>>$log
if [ $id -ne 0 ]; then
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log
else 
 echo -e "$green user already exists. Hence skipping... $reset"
fi
echo -e "$yellow Creating App directory and downloading code... $reset"
mkdir -p /app 
curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$log
rm -rf /app/* &>>$log
cd /app 
unzip /tmp/cart.zip &>>$log
echo -e "$yellow Installing Dependencies $reset"
cd /app 
npm install &>>$log
#Configuring Cart service

echo -e "$yellow Cart service setup $reset"
cp $script_dir/cart.service /etc/systemd/system/cart.service
systemctl daemon-reload
systemctl enable cart  &>>$log
systemctl start cart
end_time=$(date +%s)
echo -e "$green Time taken to configure CART is $(($end_time - $start_time))Seconds. $reset"
