provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "strapi_server" {
  ami           = "ami-05206bf8aecfc7ae6"
  instance_type = "t2.large"         
  key_name      = "keypair2"
  associate_public_ip_address = true
  root_block_device {
    volume_size = 30
    volume_type = "gp3"
   }
  security_groups = [aws_security_group.strapi_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
              yum install -y nodejs git
              npm install -g yarn pm2
              git clone https://github.com/richards28/strapi.git /home/ec2-user/strapi
              cd /home/ec2-user/strapi
              yarn install
              yarn build
              pm2 start yarn --name strapi -- start
              pm2 save
              pm2 startup
 
              EOF

  tags = {
    Name = "Strapi-Server"
  }
}

resource "aws_security_group" "strapi_sg" {
  name        = "strapi-sg"
  description = "Allow SSH and Strapi ports"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # you can restrict to your IP
  }

  ingress {
    description = "Strapi"
    from_port   = 1337
    to_port     = 1337
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # open Strapi admin panel
  }
  ingress {
    description = "https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
