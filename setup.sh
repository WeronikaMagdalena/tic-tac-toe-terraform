#!/bin/bash
# This script contains command related to instruction only
apt-get update -y
apt-get install -y awscli
HOME=/home/ubuntu
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
chown ubuntu:ubuntu $HOME/.ssh/*
su - ubuntu -c "cd ; git clone git@github.com:pwr-cloudprogramming/a5-WeronikaMagdalena.git"

#!/bin/bash
# METADATA_URL="http://169.254.169.254/latest/meta-data"
# IP_V4=$(curl -H "$TOKEN_HEADER" -s $METADATA_URL/public-ipv4)

# sudo yum update
# sudo yum install -y git

# sudo chmod a+w /tmp

# echo "$IP_V4" | sudo tee /tmp/ec2_ip_address.txt

# rm -rf a5-WeronikaMagdalena
# git clone git@github.com:pwr-cloudprogramming/a5-WeronikaMagdalena.git
# cd a5-WeronikaMagdalena

# sudo yum install -y stress-ng

# sudo systemctl start docker
# sudo groupadd docker
# sudo usermod -aG docker $USER
# newgrp docker
# sudo curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)"  -o /usr/local/bin/docker-compose
# sudo mv /usr/local/bin/docker-compose /usr/bin/docker-compose
# sudo chmod +x /usr/bin/docker-compose

# docker-compose build --build-arg ip="$IP_V4" --no-cache

# docker-compose up -d
