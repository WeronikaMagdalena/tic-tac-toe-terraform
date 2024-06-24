# Weronika Wójcik - Terraform, EC2, TicTacToe report

- Course: *Cloud programming*
- Group: Remotely
- Date: 10/05/2024

## Environment architecture

### Description
This project deploys a TicTacToe game application in EC2 instance using Terraform.

### Scheme
- **VPC (Virtual Private Cloud)**: Provides an isolated network environment for the deployment of resources. The VPC is configured with a CIDR block of "10.0.0.0/16" to accommodate the required resources.

- **Subnet**: Within the VPC, a public subnet is created with the CIDR block "10.0.101.0/24" in the "us-east-1b" availability zone. This subnet is associated with the internet gateway for external internet access.

- **Internet Gateway (IGW)**: Enables communication between instances in the VPC and the internet. It is attached to the VPC to allow outbound internet access for the deployed application.

- **Route Table**: A public route table is defined and associated with the VPC. It includes a route to the internet gateway to enable internet-bound traffic from the public subnet.

- **Security Groups**: Two security groups are created:
  - *allow_ssh_http*: Allows SSH and HTTP inbound traffic and all outbound traffic. Ingress rules are defined to permit TCP traffic on port 22 (SSH) and ports 8080-8081 (HTTP). Egress rule allows all traffic.
  - *allow_all_traffic_ipv4*: This egress rule allows all IPv4 traffic outbound from the security group.

- **Secrets Management**: 
  - *aws_secretsmanager_secret*: Creates a secret named "myproject/privkey" in AWS Secrets Manager with a recovery window of 0 days.
  - *aws_secretsmanager_secret_version*: Associates a secret version with the created secret, retrieving the secret string from file "repo_key".

- **EC2 Instance**: An EC2 instance named "tf-web-server" is provisioned with the specified AMI and instance type. It is launched in the public subnet and associated with the security group allowing SSH and HTTP traffic. User data script "setup.sh" is provided for instance initialization.

## Preview

Screenshots of configured AWS services. Screenshots of your application running.

![Start](img/ss2.PNG)
![Game](img/ss1.PNG)
![EC2](img/vpc.PNG)
![EC2](img/subnet.PNG)
![EC2](img/igw.PNG)
![EC2](img/rt.PNG)

## Reflections

- What did you learn?\
    *How to deal with obstacles that appear on every step.*\
    *How terraform file works and it's structure.*\
    *How to move efficiently in AWS.*\
    *How to use bash script and run it on virtual machine through terraform in provisioned enviroment in a way it works run all at once.*\
    *How to connect with instance from my machine.*\
    *How to write readme files.*
- What obstacles did you overcome?\
    *Nothing working.*\
    *Bash script caused me many problems, mainly with accessing private repo, operating on Docker and changing permissions.*
    *Problems related with AWS like volume.*
- What did you help most in overcoming obstacles?\
    *Following the example of the lab for running simple app in the instance and applying those steps for my application as well as additional materials on e-portal, Zuzanna Aszkiełowicz and ✨chat-gpt✨.*
- Was that something that surprised you?\
    *That after doing it once it is actually quite easy but to do it for the first time it takes ages.*
