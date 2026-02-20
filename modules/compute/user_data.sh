#! /bin/bash
yum update -y

yum install -y java-17-amazon-corretto aws-cli

mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

aws s3 cp s3://anant-monitoring-app/monitoring-app.jar app.jar

nohup java -jar app.jar --server.port=${APP_PORT_NO} > app.log 2>&1 &
