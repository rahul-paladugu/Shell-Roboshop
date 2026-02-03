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
echo -e "$yellow Installing 1.24 version nginx.. $reset"
dnf module disable nginx -y &>>$log
dnf module enable nginx:1.24 -y &>>$log
dnf install nginx -y &>>$log
echo -e "$yellow Enabling nginx.. $reset"
systemctl enable nginx &>>$log
systemctl start nginx &>>$log
echo -e "$yellow Removing default content & downloading roboshop config.. $reset"
rm -rf /usr/share/nginx/html/* 
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$log
cd /usr/share/nginx/html 
unzip /tmp/frontend.zip &>>$log
#Setup Nginx service
echo -e "$yellow Setup nginx service.. $reset"
cp $script_dir/nginx.service /etc/nginx/nginx.conf
echo -e "$yellow restart nginx.. $reset"
systemctl restart nginx 
end_time=$(date +%s)
echo -e "$green Time taken to configure nginx is $(($end_time - $start_time))Seconds. $reset"
