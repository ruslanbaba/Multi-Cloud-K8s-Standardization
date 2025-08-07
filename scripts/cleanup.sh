#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to print status messages
print_status() {
    echo -e "${YELLOW}[*] $1${NC}"
}

print_success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

print_error() {
    echo -e "${RED}[✗] $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check required tools
print_status "Checking required tools..."

if ! command_exists terraform; then
    print_error "Terraform is not installed. Please install it first."
    exit 1
fi

# Confirm destruction
echo -e "${RED}"
echo "⚠️  WARNING: This will destroy all resources in all cloud providers!"
echo "    This action is irreversible!"
echo -e "${NC}"
read -p "Are you sure you want to continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Cleanup cancelled."
    exit 0
fi

# Initialize Terraform
print_status "Initializing Terraform..."
terraform init

# Destroy resources
print_status "Destroying all resources..."
terraform destroy -auto-approve

if [ $? -eq 0 ]; then
    print_success "All resources have been destroyed successfully!"
else
    print_error "Error occurred while destroying resources. Please check the logs."
    exit 1
fi

# Clean up local files
print_status "Cleaning up local files..."
rm -rf .terraform/
rm -f .terraform.lock.hcl
rm -f terraform.tfstate*

print_success "Cleanup completed successfully!"
