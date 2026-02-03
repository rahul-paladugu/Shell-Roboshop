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
echo -e "$yellow Copying rabbitmq repo.. $reset"
cp $script_dir/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
echo -e "$yellow Installing rabbitmq.. $reset"
dnf install rabbitmq-server -y &>>$log
systemctl enable rabbitmq-server &>>$log
systemctl start rabbitmq-server &>>$log
echo -e "$yellow Creating rabbitmq system user.. $reset"
rabbitmqctl add_user roboshop roboshop123 &>>$log
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$log
end_time=$(date +%s)
echo -e "$green Time taken to configure Shipping is $(($end_time - $start_time))Seconds. $reset"
