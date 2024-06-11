terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.101.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  tags = {
    Name = "allow-ssh-http"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # all ports
}
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 8080
  to_port           = 8081
}
resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh_http.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}


resource "aws_instance" "tf-web-server" {
  ami                         = "ami-08a0d1e16fc3f61ea"
  instance_type               = "t2.micro"
  key_name                    = "vockey"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = "true"
  vpc_security_group_ids      = [aws_security_group.allow_ssh_http.id]
  user_data                   = <<-EOF
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
# echo "$IP_V4" > /tmp/ec2_ip_address.txt

rm -rf a5-WeronikaMagdalena
git clone https://github.com/pwr-cloudprogramming/a5-WeronikaMagdalena

cd a5-WeronikaMagdalena

docker-compose build --build-arg ip="$IP_V4" --no-cache

docker-compose up -d

EOF
  user_data_replace_on_change = true
  tags = {
    Name = "TicTacToe-WW"
  }
}