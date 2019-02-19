#!/bin/bash

echo "bootscript initiated" > /tmp/results.txt 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce
sudo systemctl start docker
sudo docker run --name my-nginx -p 8080:80 -d nginx
echo "bootscript done" >> /tmp/results.txt

exit 0
