#!/bin/bash
#echo "*** Installing apache2"
#sudo yum install httpd -y
#sudo systemctl start httpd
#sudo systemctl enable httpd
mkdir /apps
chown ec2-user /apps
sudo yum install python3-pip -y
sudo pip3 install flask

aws s3 cp s3://steve-app-bucket/demo.py /apps/demo.py
python3 /apps/demo.py
