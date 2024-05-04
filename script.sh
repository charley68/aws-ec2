#!/bin/bash
echo "*** Installing apache2"
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd