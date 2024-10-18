#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.joinaiops76.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log" 
exec &>$LOGFILE

echo "Script started executing at $TIMESTAMP" 
VALIDATE() {
    if [ $1 -ne 0 ]
    then 
      echo -e " $2...$R FAILED $N"
      exit 1
    else
      echo -e " $2...$G SUCCESS $N"
    fi  
}
if [ $ID -ne 0 ]
then 
  echo -e "$R Please run this script with Root access $N"
  exit 1
else
  echo -e "Hyy $G Root user $N"
fi
dnf install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y 
VALIDATE $? "Installing Remi release"

dnf module enable redis:remi-6.2 -y 
VALIDATE $? "Enabling Redis"

dnf install redis -y 
VALIDATE $? "Installing Redis"

set -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf
VALIDATE $? "Allowing remote connections"

systemctl enable redis 
VALIDATE $? "Enabling Redis"

systemctl start redis 
VALIDATE $? "Starting Redis"



