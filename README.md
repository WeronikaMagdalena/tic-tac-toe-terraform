# Weronika Wójcik - Terraform, EC2, TicTacToe report

- Course: *Cloud programming*
- Group: Remotely
- Date: 04/06/2024

## Environment architecture

### Description
This project deploys a TicTacToe game application on AWS using Terraform. The infrastructure consists of the following components:

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
  - *aws_secretsmanager_secret_version*: Associates a secret version with the created secret, retrieving the secret string from a file named "repo_key".

- **EC2 Instance**: An EC2 instance named "tf-web-server" is provisioned with the specified AMI and instance type. It is launched in the public subnet and associated with the security group allowing SSH and HTTP traffic. User data script "setup.sh" is provided for instance initialization.

## Preview

Screenshots of configured AWS services. Screenshots of your application running.

![Sample image](img/sample-image.png)

## Reflections

- What did you learn?\
    *Patience*
- What obstacles did you overcome?\
    *Nothing working.*
- What did you help most in overcoming obstacles?\
    *Following the example of the lab for running basic app in the instance and applying those steps*
    *for my application.*
- Was that something that surprised you?\
    *That after doing it once it is actually quite easy but to do it for the first time it takes ages.*
