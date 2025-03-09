Project Overview
This Terraform configuration sets up an AWS environment with a VPC, subnet, internet gateway, route table, security group, EC2 instance, and necessary networking configurations. The goal is to deploy a web server on an EC2 instance inside a public subnet, configure security groups, and provision files (HTML and images) to serve a webpage.

Create VPC
A VPC (Virtual Private Cloud) is created to define a private network within AWS.
It uses a CIDR block defined in Terraform variables (e.g., 10.0.0.0/16).
This is the base network where all resources will be deployed.

Create a Key Pair
A key pair is created to allow secure SSH access to the EC2 instance.
The public key is read from a file, ensuring we can SSH into the instance later.

Create a Public Subnet
A subnet is created inside the VPC to allocate a portion of the network.
CIDR block is specified (e.g., 10.0.1.0/24).
map_public_ip_on_launch = true ensures that instances launched in this subnet get a public IP automatically.
This will act as a public subnet since we will associate it with a route table that has internet access.

Create an Internet Gateway
An Internet Gateway (IGW) is created to allow internet access to resources in the VPC.
This is necessary for the EC2 instance to be publicly accessible.

Create a Route Table for Internet Access
A route table is created for internet access.
It has a route that directs all traffic (0.0.0.0/0) to the Internet Gateway.

Associate Route Table with Public Subnet
The public subnet is linked to the route table that provides internet access.
This ensures that any instance launched in this subnet can connect to the internet.

 Create a Security Group
A security group acts as a firewall to control inbound and outbound traffic.

Define Security Group Rules
Allow http access
This allows HTTP (port 80) traffic from anywhere (0.0.0.0/0), making the web server accessible.

Allow SSH access
This allows SSH (port 22) access from anywhere.

Allow all Outbound access
This allows all outbound traffic, ensuring the instance can access the internet.

Launch an Ec2 Access
An EC2 instance is created inside the public subnet.
It uses the specified AMI and instance type from variables.
It is assigned the previously created security group.

Install Apache and Configure Web Server
Apache (httpd) is installed automatically on the instance.
The web server starts on boot.

 Provision Files & Configure Web Server
The index2.html file is copied to the web server.
Later, it is renamed to index.html, making it the default webpage.

SSH Configuration for Remote Execution
Defines an SSH connection for Terraform to run commands inside the instance.

Issues Faced and Solutions
Issue: Apache Server Not Starting Properly
Fix: Added a sleep delay (sleep 5) after installation to ensure it starts.
Issue: Permission Errors for /var/www/html

Fix: Used chmod -R 755 and chown -R ec2-user:ec2-user to set proper permissions.
Issue: Files Not Being Copied Correctly

Fix: Used Terraform file provisioner and ensured /var/www/html/Images was created before copying.

Summary
This Terraform project sets up a VPC, subnet, internet access, security groups, and an EC2 instance. The EC2 instance is configured as a web server using Apache and hosts a simple HTML webpage. The instance is accessible over the internet via HTTP, and files are copied using Terraform's provisioners.

