#!/bin/bash
sudo yum -y update
sudo yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h1>Final Group Assignment</h1><p>My private IP is <font color="blue">$myip</font></p><ul><li>Mohamed Zaheer Fasly</li><li>Stanley Amaobi Nnodu</li><li>Sandra Buma</li><li>Carlos Rodrigo Rivero</li></ul>"  >  /var/www/html/index.html
sudo systemctl start httpd
sudo systemctl enable httpd