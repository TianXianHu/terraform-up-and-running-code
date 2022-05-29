terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}


variable "security_group_name" {
  description = "The name of my security group"
  type        = string
  default     = "terraform-example-instance"
}

resource "aws_security_group" "myinstances" {

  name = var.security_group_name

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-example" 
    }
  
}

resource "aws_instance" "example_web_server" {
  ami                    = "ami-0fb653ca2d3203ac1"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.myinstances.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  tags = {
    Name = "terraform-example"
  }
}

output "public_ip" {
  value       = aws_instance.example_web_server.public_ip
  description = "The public IP of created web-server Instance"
}
