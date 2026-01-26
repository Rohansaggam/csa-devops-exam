#!/bin/bash
set -e
# Update and Install NGINX
sudo apt-get update -y
sudo apt-get install -y nginx
# Retrieve Metadata
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/local-ipv4)
# Configure Index Page
echo "CSA DevOps Exam – Instance IP: $PRIVATE_IP" | sudo tee /var/www/html/index.html
# Start NGINX
sudo systemctl enable nginx
sudo systemctl restart nginx
sudo systemctl status nginx
