#CSA-DevOps-Exam
-------------------------------------------------------------------------------------------------------------------------------------
#CSA-DevOps-Exam is a production-ready automation framework that leverages Jenkins, Terraform, and AWS to provision infrastructure and deploy applications securely.
-------------------------------------------------------------------------------------------------------------------------------------
The solution emphasizes:

Least-privilege IAM access

SSM-based EC2 management (no SSH)

Remote Terraform state in S3

CI/CD pipeline automation

It is designed to be generic, reusable, and secure, suitable for DevOps, platform engineering, and automation teams.

#Key Features
-------------------------------------------------------------------------------------------------------------------------------------
Jenkins-driven Terraform execution

Secure EC2 management via AWS Systems Manager (SSM)

Remote Terraform state stored securely in S3

Automated NGINX installation and validation

No hard-coded credentials, secrets, or IP addresses

GitHub-based CI/CD triggers

#Architecture
-------------------------------------------------------------------------------------------------------------------------------------
Components Overview

Component	             Description
Jenkins Server	         Runs Terraform and manages CI/CD pipelines
Terraform	             Provisioning of EC2, networking, and IAM resources
AWS IAM Roles	         Role-based access instead of static credentials
SSM Agent	             Enables remote command execution without SSH
S3 Backend	             Secure Terraform state storage
NGINX Server	         Deployed on provisioned EC2 instance

Repository Structure

#CI/CD

Jenkinsfile - Defines pipeline stages: Plan → Apply → Validate

              Pulls code from GitHub using fine-grained PAT

              Executes Terraform commands and validates deployment

Terraform Files

backend.tf – Configures remote S3 backend

provider.tf – AWS provider configuration

variables.tf – Centralized variables

terraform.tfvars – Environment-specific inputs

ec2.tf – EC2 provisioning logic

iam.tf – IAM roles and instance profile references

outputs.tf – Exposes instance ID, public IP, and private IP

Installation Script

install_nginx.sh – Installs and starts NGINX on target EC2
-------------------------------------------------------------------------------------------------------------------------------------
# All files are in the root directory for simplicity and easy access.
-------------------------------------------------------------------------------------------------------------------------------------
# IAM & Security Model

Jenkins IAM Role

Attached to Jenkins EC2 instance via instance profile

Permissions include:

Terraform resource creation

S3 backend access

SSM command execution

Target EC2 IAM Role

Uses AmazonSSMManagedInstanceCore

Eliminates need for inbound SSH

S3 Backend Policy

Bucket created via backend

Restricted permissions: aws cli

s3:ListBucket

s3:GetObject, s3:PutObject, s3:DeleteObject

# Scoped to Terraform state path only
-------------------------------------------------------------------------------------------------------------------------------------
# CI/CD Flow

Code pushed to GitHub triggers Jenkins job

Jenkins authenticates using IAM role

Terraform initializes S3 backend

Terraform executes plan → apply

EC2 instance is provisioned

Instance details retrieved via Terraform outputs

NGINX installed using SSM commands

Deployment validated via HTTP request

Public URL and IP displayed in Jenkins output

Validation

EC2 instance health verified

NGINX availability validated via HTTP request

No direct SSH access or hard-coded IPs

# Prerequisites
-------------------------------------------------------------------------------------------------------------------------------------
AWS account with necessary IAM roles

Jenkins EC2 instance with attached IAM role

S3 bucket for Terraform backend

GitHub fine-grained PAT configured in Jenkins

# Best Practices
-------------------------------------------------------------------------------------------------------------------------------------
Infrastructure as Code (IaC)

Immutable deployments

Least-privilege IAM

Secure remote state management

SSM-based EC2 management (no SSH)

Secrets-free code

Configure environment variables and terraform.tfvars

Ensure IAM roles are attached to Jenkins and target EC2

Run the Jenkins pipeline

# Notes

S3 bucket creation is out of Terraform scope – manage manually via AWS Console or CLI

Supports extension to multi-environment deployments
-------------------------------------------------------------------------------------------------------------------------------------
# jenkins & terraform  setup commands 

create jenkins_install.sh file and copy below commands and run 

-------------------------------------------------------------------------------------------------------------------------------------

#!/bin/bash

# =================================================================
# jenkins_install.sh
# Description: Install Jenkins (latest LTS), Java 17, Git, Terraform
# on Amazon Linux 2 and enable Jenkins service
# =================================================================

set -e

echo "=== Updating system packages ==="
sudo yum update -y

echo "=== Installing required tools ==="
sudo amazon-linux-extras enable java-openjdk17 -y
sudo yum install -y java-17-amazon-corretto git wget unzip

# Export JAVA_HOME for current session and persist
echo "=== Setting JAVA_HOME ==="
JAVA_PATH=$(dirname $(dirname $(readlink -f $(which java))))
echo "export JAVA_HOME=${JAVA_PATH}" | sudo tee /etc/profile.d/java.sh
echo "export PATH=\$JAVA_HOME/bin:\$PATH" | sudo tee -a /etc/profile.d/java.sh
# Apply immediately
source /etc/profile.d/java.sh

echo "JAVA_HOME is set to: $JAVA_HOME"
echo "Java version: $(java -version)"

echo "=== Adding Jenkins repo ==="
sudo wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

echo "=== Installing Jenkins ==="
sudo yum install -y jenkins

echo "=== Starting and enabling Jenkins service ==="
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "=== Installing Terraform ==="
# Define Terraform version
TERRAFORM_VERSION="1.6.4"
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

echo "=== Jenkins Installation Completed ==="

echo "Jenkins is running at: http://$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):8080"

echo "To get the initial admin password:"

echo "sudo cat /var/lib/jenkins/secrets/initialAdminPassword"

-------------------------------------------------------------------------------------------------------------------------------------
