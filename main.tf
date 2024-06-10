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

resource "aws_secretsmanager_secret" "github_key" {
  name = "myproject/privkey"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "github_key_value" {
secret_id = aws_secretsmanager_secret.github_key.id
secret_string = file("repo_key")
}

resource "aws_instance" "webserver" {
  ami                         = "ami-00beae93a2d981137"
  instance_type               = "t2.micro"
  key_name                    = "vockey"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.tictactoe_sg.id]

  user_data_replace_on_change = true

  tags = {
    Name = "TicTacToe-Web-Server"
  }
  
  # This resource contains arguments related to instruction only
  iam_instance_profile = "LabInstanceProfile"
  user_data = file("setup.sh")
}
