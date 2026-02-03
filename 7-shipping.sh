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
echo -e "$yellow Installing Maven.. $reset"
dnf install maven -y
echo -e "$yellow Creating System User.. $reset"
if id -u roboshop ; then
 echo -e "$green user already exists. Hence skipping... $reset"
else 
 useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log
fi
echo -e "$yellow Creating App directory and downloading code.. $reset"
mkdir -p /app
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
rm -rf /app/*
cd /app 
unzip /tmp/shipping.zip
echo -e "$yellow Installing dependencies.. $reset"
cd /app 
mvn clean package 
mv target/shipping-1.0.jar shipping.jar
#Setup shipping service
echo -e "$yellow Shipping service setup.. $reset"
cp $script_dir/shipping.service /etc/systemd/system/shipping.service
systemctl daemon-reload
systemctl enable shipping 
systemctl start shipping
#Setup shipping service
echo -e "$yellow configuring SQL connection.. $reset"
dnf install mysql -y 
echo -e "$yellow Loading Schema.. $reset"
mysql -h mysql.rscloudservices.icu -uroot -pRoboShop@1 < /app/db/schema.sql
mysql -h mysql.rscloudservices.icu -uroot -pRoboShop@1 < /app/db/app-user.sql
mysql -h mysql.rscloudservices.icu -uroot -pRoboShop@1 < /app/db/master-data.sql
echo -e "$yellow restarting shipping.. $reset"
systemctl restart shipping
end_time=$(date +%s)
echo -e "$green Time taken to configure Shipping is $(($end_time - $start_time))Seconds. $reset"
