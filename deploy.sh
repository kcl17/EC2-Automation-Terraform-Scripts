#!/bin/bash

set -e

# Log function
log() {
    echo -e "\033[1;32m[INFO]\033[0m $1"
}

# Step 1: Install Terraform
log "Installing Terraform..."
if ! command -v terraform &> /dev/null; then
    sudo apt-get update -y
    sudo apt-get install -y wget unzip
    wget https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip
    unzip terraform_1.5.7_linux_amd64.zip
    sudo mv terraform /usr/local/bin/
    rm terraform_1.5.7_linux_amd64.zip
else
    log "Terraform already installed."
fi

log "Terraform version:"
terraform -v

# Step 2: Configure AWS Credentials
log "Configuring AWS credentials..."
if ! command -v aws &> /dev/null; then
    log "Installing AWS CLI..."
    sudo apt-get install -y awscli
fi
aws configure

# Step 3: Create Terraform project directory
log "Setting up Terraform project..."
PROJECT_DIR="terraform-ec2"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Step 4: Write main.tf configuration
log "Writing Terraform configuration to main.tf..."
cat > main.tf <<EOF
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"

  tags = {
    Name = "MyTerraformInstance"
  }
}
EOF

# Step 5: Initialize Terraform
log "Initializing Terraform..."
terraform init

# Step 6: Validate and plan
log "Validating Terraform configuration..."
terraform validate

log "Planning Terraform changes..."
terraform plan

# Step 7: Apply configuration
log "Applying Terraform configuration..."
terraform apply -auto-approve

# Step 8: Verify the instance
log "Verifying EC2 instance..."
aws ec2 describe-instances \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]' \
  --output table

log "Deployment complete! EC2 instance created successfully."
