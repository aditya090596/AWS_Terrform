## to generate key pair- ssh-keygen -t rsa

resource "aws_vpc" "terraform_vpc" {
  cidr_block = var.cidr_block
   tags = {
    Name = "terraform_vpc"
  }
  
}
resource "aws_key_pair" "key-value" {
  key_name   = "terraform-key"
  public_key = file("/workspaces/AWS_Terrform/.devcontainer/project2/key.pub") # Reads the public key file
}
resource "aws_subnet" "subnet_id" {
  vpc_id     = aws_vpc.terraform_vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform_subnet"
  }
}
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "terraform-igw"
  }
}
resource "aws_route_table" "internet_access" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "public_route_table"
  }
}
# Associate the route table with the public subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.subnet_id.id
  route_table_id = aws_route_table.internet_access.id
}

resource "aws_security_group" "terraform_sg" {
  name        = "terraform_sg"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.terraform_vpc.id

  tags = {
    Name = "terraform_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_ipv4" {
  security_group_id = aws_security_group.terraform_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.terraform_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.terraform_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_instance" "ec2_instance" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name      = aws_key_pair.key-value.key_name
  vpc_security_group_ids = [aws_security_group.terraform_sg.id]
  subnet_id              = aws_subnet.subnet_id.id

 user_data = <<-EOF
  #!/bin/bash
  dnf update -y
  dnf install -y httpd
  sleep 5  # Ensure package installation completes before starting service

  systemctl start httpd
  systemctl enable httpd

  mkdir -p /var/www/html/Images  # Ensure the directory exists before copying files
  chown -R ec2-user:ec2-user /var/www/html
  chmod -R 755 /var/www/html/Images
  chmod -R 755 /var/www/html # Set proper permissions
EOF

tags = {
  Name = "TerraformWebServer"
}

# Ensure the directory is available before copying files
provisioner "remote-exec" {
  inline = [
    "sudo mkdir -p /var/www/html/Images",
    "sudo chown ec2-user:ec2-user /var/www/html",
    "sudo chmod -R 777 /var/www/html/Images",  # Grant full permissions before copying
    "sudo chown -R ec2-user:ec2-user /var/www/html/Images"
  ]
}

# Copy HTML file
provisioner "file" {
  source      = "/workspaces/AWS_Terrform/.devcontainer/project2/index2.html"
  destination = "/var/www/html/index2.html"
}

# Copy Images directory
provisioner "file" {
  source      = "/workspaces/AWS_Terrform/.devcontainer/project2/Images/"
  destination = "/var/www/html/Images"
}

# Ensure permissions & restart Apache properly
provisioner "remote-exec" {
  inline = [
    "sudo chmod -R 755 /var/www/html",
    "sudo systemctl restart httpd",
    "sudo mv /var/www/html/index2.html /var/www/html/index.html"

 #   systemctl start httpd
 # systemctl enable httpd
    #"sudo systemctl restart httpd || sudo systemctl start httpd"  # Restart or start if needed
  ]
}


  connection {
    type        = "ssh"
    user        = "ec2-user"  # Replace with the appropriate username for your EC2 instance
    private_key = file("/workspaces/AWS_Terrform/.devcontainer/project2/key.pem")  # Replace with the path to your private key
    host        = self.public_ip
  }
  depends_on = [aws_instance.ec2_instance]
}