# Staging environment configuration
environment = "staging"

# Regional Configuration
aws_region = "us-east-1"
aws_secondary_region = "us-west-2"
gcp_region = "us-east4"
gcp_secondary_region = "us-west1"
azure_location = "eastus"
azure_secondary_location = "westus"

# Network Configuration
vpc_cidr = "10.30.0.0/16"
subnet_cidrs = {
  private = ["10.30.1.0/24", "10.30.2.0/24"]
  public = ["10.30.101.0/24", "10.30.102.0/24"]
  database = ["10.30.201.0/24", "10.30.202.0/24"]
}

# Node Pool Configuration
node_pool_config = {
  min_nodes = 3
  max_nodes = 6
  instance_type = "t3.xlarge"
  disk_size_gb = 100
  labels = {
    environment = "staging"
  }
  taints = []
}

# Cost Management
cost_management = {
  budget_amount = 5000
  alert_threshold = 85
  spot_enabled = false
  spot_max_price = 0
}

# Security Configuration
compliance_config = {
  log_retention_days = 90
  audit_enabled = true
  compliance_standards = ["SOC2", "ISO27001", "PCI"]
  encryption_required = true
}

# Service Mesh Configuration
service_mesh_config = {
  enabled = true
  mtls_enabled = true
  tracing_enabled = true
  mesh_policy = "strict"
  retention_days = 30
}
