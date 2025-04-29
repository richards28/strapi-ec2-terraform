provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_instance" "strapi_server" {
  ami           = "ami-026c39f4021df9abe"
  instance_type = "t2.medium"         
  key_name      = "keypair2"           

  security_groups = [aws_security_group.strapi_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y nodejs npm
              npm install -g yarn
              curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
              apt-get install -y nodejs
              git clone https://github.com/richards28/strapi.git
              cd /home/ubuntu/strapi-app
              yarn install
              yarn build
              yarn start
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
