#!/bin/bash
ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.joinaiops76.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log" 
echo "Script started executing at $TIMESTAMP" &>> $LOGFILE
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

dnf module disable nodejs -y &>> $LOGFILE
VALIDATE $? "disabling current Nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "Enabling Nodejs18" 

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "Installing NodeJS18" 

id roboshop
if [ $? -ne 0 ]
then 
  useradd roboshop
else 
  echo -e "roboshop already exist $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory" 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE
VALIDATE $? "Downloading Catalogue application" 

cd /app 

unzip -o /tmp/catalogue.zip &>> $LOGFILE
VALIDATE $? "Unzipping catalogue application" 

npm install &>> $LOGFILE
VALIDATE $? "installing dependencies" 

#use absolute path becauser absolute path exits there
cp /home/centos/Roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE
VALIDATE $? "Copying catalogue service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " catalogue daemon catalogue" 

systemctl enable catalogue &>> $LOGFILE
VALIDATE $? " enable catalogue " 

systemctl start catalogue &>> $LOGFILE
VALIDATE $? " start catalogue " 

cp /home/centos/Roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? " copying mongo repo " 

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? " installing mongodb client " 

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE
VALIDATE $? " LOADING catalogue data into MongoDB " 





