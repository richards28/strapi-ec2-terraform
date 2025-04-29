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
