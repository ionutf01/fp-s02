#!/bin/bash
# Install Terraform in AWS CloudShell
# Run: bash install-terraform.sh

set -e

VERSION="1.14.7"

echo "Installing Terraform v${VERSION}..."
wget -q "https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip"
mkdir -p ~/bin
unzip -o "terraform_${VERSION}_linux_amd64.zip" -d ~/bin/
rm -f "terraform_${VERSION}_linux_amd64.zip"

echo ""
terraform -version
echo ""
echo "Done! Terraform is ready."
