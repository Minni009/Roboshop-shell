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

curl -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
VALIDATE $? "Downloading Cart application" 

cd /app 

unzip -o /tmp/cart.zip &>> $LOGFILE
VALIDATE $? "Unzipping cartapplication" 

npm install &>> $LOGFILE
VALIDATE $? "installing dependencies" 

#use absolute path becauser absolute path exits there
cp /home/centos/Roboshop-shell/cart.service /etc/systemd/system/cart.service &>> $LOGFILE
VALIDATE $? "Copying cart service file"

systemctl daemon-reload &>> $LOGFILE
VALIDATE $? " cart daemon cart" 

systemctl enable cart &>> $LOGFILE
VALIDATE $? " enable cart " 

systemctl start cart &>> $LOGFILE
VALIDATE $? " start cart " 

cp /home/centos/Roboshop-shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? " copying mongo repo " 

dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? " installing mongodb client " 

mongo --host $MONGODB_HOST </app/schema/cart.js &>> $LOGFILE
VALIDATE $? " LOADING cart data into MongoDB " 
