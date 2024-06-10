terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name        = "ticatctoe-vpc"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name        = "public-subnet"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name        = "my-vpc-igw"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name        = "public-route-table"
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "tictactoe_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "tf-web-server" {
  ami                         = "ami-00beae93a2d981137"
  instance_type               = "t2.micro"
  key_name                    = "vockey"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.tictactoe_sg.id]

user_data = <<-EOF
#!/bin/bash
METADATA_URL="http://169.254.169.254/latest/meta-data"
IP_V4=$(curl -H "$TOKEN_HEADER" -s $METADATA_URL/public-ipv4)

sudo yum update
sudo yum install -y git

sudo chmod a+w /tmp

echo "$IP_V4" | sudo tee /tmp/ec2_ip_address.txt

rm -rf a5-WeronikaMagdalena
git clone git@github.com:pwr-cloudprogramming/a5-WeronikaMagdalena.git
cd a5-WeronikaMagdalena

sudo yum install -y stress-ng

sudo systemctl start docker
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
sudo curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)"  -o /usr/local/bin/docker-compose
sudo mv /usr/local/bin/docker-compose /usr/bin/docker-compose
sudo chmod +x /usr/bin/docker-compose

docker-compose build --build-arg ip="$IP_V4" --no-cache

docker-compose up -d
EOF

  user_data_replace_on_change = true

  tags = {
    Name = "TicTacToe-Web-Server"
  }
}
