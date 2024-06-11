#!/bin/bash
sudo yum install -y docker
sudo yum install -y git
sudo systemctl start docker
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)"  -o /usr/local/bin/docker-compose
sudo mv /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose

API_URL="http://169.254.169.254/latest/api"
TOKEN=$(curl -X PUT "$API_URL/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 600")
TOKEN_HEADER="X-aws-ec2-metadata-token: $TOKEN"
METADATA_URL="http://169.254.169.254/latest/meta-data"
AZONE=$(curl -H "$TOKEN_HEADER" -s $METADATA_URL/placement/availability-zone)
IP_V4=$(curl -H "$TOKEN_HEADER" -s $METADATA_URL/public-ipv4)
INTERFACE=$(curl -H "$TOKEN_HEADER" -s $METADATA_URL/network/interfaces/macs/ | head -n1)
SUBNET_ID=$(curl -H "$TOKEN_HEADER" -s $METADATA_URL/network/interfaces/macs/$INTERFACE/subnet-id)
VPC_ID=$(curl -H "$TOKEN_HEADER" -s $METADATA_URL/network/interfaces/macs/$INTERFACE/vpc-id)

echo "Your EC2 instance works in: AvailabilityZone: $AZONE, VPC: $VPC_ID, VPC subnet: $SUBNET_ID, IP address: $IP_V4"

sudo chmod a+w /tmp

echo "$IP_V4" | sudo tee /tmp/ec2_ip_address.txt

HOME=/home/ec2-user
aws secretsmanager get-secret-value --region us-east-1 \
--secret-id "myproject/privkey" \
--query "SecretString" \
--output text > $HOME/.ssh/repo_key.pem
chmod 600 $HOME/.ssh/repo_key.pem
cat > $HOME/.ssh/config <<- EOF
Host github.com
Hostname github.com
IdentityFile=~/.ssh/repo_key.pem
EOF
    
ssh-keyscan github.com >> $HOME/.ssh/known_hosts
    
sudo chown ec2-user:ec2-user $HOME/.ssh/*
    
rm -rf a5-WeronikaMagdalena
sudo su - ec2-user -c "cd ; git clone git@github.com:pwr-cloudprogramming/a5-WeronikaMagdalena.git"

cd $HOME/a5-WeronikaMagdalena

docker-compose build --build-arg ip="$IP_V4" --no-cache

docker-compose up -d