# Define provider
provider "aws" {
  region = "ap-south-1"
}

# Create a security group allowing SSH and Docker ports
resource "aws_security_group" "docker_sg" {
  name        = "docker_sg"
  description = "Allow SSH and Docker ports"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2376
    to_port     = 2377
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

# Launch EC2 instance
resource "aws_instance" "docker_instance" {
  ami             = "ami-0f58b397bc5c1f2e8"
  instance_type   = "t2.small"
  security_groups = [aws_security_group.docker_sg.name]

  tags = {
    Name = "DockerInstance"
  }

  # Provisioning script to install Docker and run the container
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install docker -y
              service docker start
              docker run -d -p 80:80 your-docker-image:tag
              EOF
}
