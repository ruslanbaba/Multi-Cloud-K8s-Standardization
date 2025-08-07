# Development environment configuration
environment = "dev"

# Regional Configuration
aws_region = "us-west-2"
aws_secondary_region = "us-west-1"
gcp_region = "us-west1"
gcp_secondary_region = "us-west2"
azure_location = "westus2"
azure_secondary_location = "westus"

# Network Configuration
vpc_cidr = "10.10.0.0/16"
subnet_cidrs = {
  private = ["10.10.1.0/24", "10.10.2.0/24"]
  public = ["10.10.101.0/24", "10.10.102.0/24"]
  database = ["10.10.201.0/24", "10.10.202.0/24"]
}

# Node Pool Configuration
node_pool_config = {
  min_nodes = 1
  max_nodes = 3
  instance_type = "t3.medium"
  disk_size_gb = 30
  labels = {
    environment = "dev"
  }
  taints = []
}

# Cost Management
cost_management = {
  budget_amount = 1000
  alert_threshold = 80
  spot_enabled = true
  spot_max_price = 0.05
}

# Security Configuration
compliance_config = {
  log_retention_days = 30
  audit_enabled = true
  compliance_standards = ["SOC2"]
  encryption_required = true
}

# Service Mesh Configuration
service_mesh_config = {
  enabled = true
  mtls_enabled = true
  tracing_enabled = true
  mesh_policy = "permissive"
  retention_days = 7
}
