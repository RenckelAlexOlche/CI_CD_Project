#!bin/bash
sudo apt-get update
sudo apt-get install nano

sudo apt-get update
sudo apt-get install \
  ca-certificates \
  curl \
  gnupg \
  lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null


sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin


sudo docker network create target-app-net
sudo docker run --name mysql-server-container -e MYSQL_ROOT_PASSWORD=31xLobOJO4fFUKE62oOFA8ev1jhFRq -d -p 3306:3306 -v mysql:/var/lib/mysql --network=target-app-net mysql

sleep 5
sudo docker exec mysql-server-container mysql -u root --password=31xLobOJO4fFUKE62oOFA8ev1jhFRq -e "create database devops_finaltask_db;"
