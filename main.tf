terraform {
required_providers {
aws = {
source = "hashicorp/aws"
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
    Name       = "ticatctoe-vpc"
    Terraform  = "true"
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

# # Associate the route table with the public subnet
# resource "aws_route_table_association" "public_subnet_association" {
#   subnet_id      = aws_subnet.public_subnet.id
#   route_table_id = aws_route_table.public_rt.id
# }

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
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8081
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

# # Create an EC2 instance
# resource "aws_instance" "tictactoe_instance" {
#   ami                         = "ami-00b535e0e5fc28916"
#   instance_type               = "t2.micro"
#   key_name                    = "vockey"
#   subnet_id                   = aws_subnet.public_subnet.id
#   vpc_security_group_ids      = [aws_security_group.tictactoe_sg.id]
#   associate_public_ip_address = true

#   user_data = <<-EOF
#               #!/bin/bash
#               apt-get update
#               apt-get install -y docker.io docker-compose
#               systemctl start docker
#               systemctl enable docker
#               docker-compose up -d
#               EOF
              
#   tags = {
#     Name = "Tic-Tac-Toe-Instance"
#   }
# }

resource "aws_instance" "tf-web-server" {
ami = "ami-080e1f13689e07408"
instance_type = "t2.micro"
key_name = "vockey"
subnet_id = aws_subnet.public_subnet.id
associate_public_ip_address = "true"
vpc_security_group_ids = [aws_security_group.tictactoe_sg.id]
user_data = <<-EOF
              #!/bin/bash
              
              # Retrieve IP address using metadata script
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
              
              echo "$IP_V4" > /tmp/ec2_ip_address.txt
              
              echo "-----BEGIN OPENSSH PRIVATE KEY-----" > ~/.ssh/myrepokey
              echo "-----END OPENSSH PRIVATE KEY-----" >> ~/.ssh/myrepokey
              echo "Host github.com-app-repo" > ~/.ssh/config
              echo "    Hostname github.com" >> ~/.ssh/config
              echo "    IdentityFile=/root/.ssh/myrepokey" >> ~/.ssh/config
              chmod 600 ~/.ssh/myrepokey
              chmod 600 ~/.ssh/config

              git clone https://github.com/pwr-cloudprogramming/a5-WeronikaMagdalena.git

              sudo curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)"  -o /usr/local/bin/docker-compose
              sudo mv /usr/local/bin/docker-compose /usr/bin/docker-compose
              sudo chmod +x /usr/bin/docker-compose

              cd A5
			
              docker-compose build --build-arg IP="$IP_V4" --no-cache

              docker-compose up -d
EOF
user_data_replace_on_change = true
tags = {
Name = "TicTacToe-Web-Server"
}
}