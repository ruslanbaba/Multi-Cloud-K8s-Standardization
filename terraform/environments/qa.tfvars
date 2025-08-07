# QA environment configuration
environment = "qa"

# Regional Configuration
aws_region = "us-east-2"
aws_secondary_region = "us-west-2"
gcp_region = "us-central1"
gcp_secondary_region = "us-west1"
azure_location = "eastus2"
azure_secondary_location = "westus2"

# Network Configuration
vpc_cidr = "10.20.0.0/16"
subnet_cidrs = {
  private = ["10.20.1.0/24", "10.20.2.0/24"]
  public = ["10.20.101.0/24", "10.20.102.0/24"]
  database = ["10.20.201.0/24", "10.20.202.0/24"]
}

# Node Pool Configuration
node_pool_config = {
  min_nodes = 2
  max_nodes = 4
  instance_type = "t3.large"
  disk_size_gb = 50
  labels = {
    environment = "qa"
  }
  taints = []
}

# Cost Management
cost_management = {
  budget_amount = 2000
  alert_threshold = 80
  spot_enabled = true
  spot_max_price = 0.08
}

# Security Configuration
compliance_config = {
  log_retention_days = 60
  audit_enabled = true
  compliance_standards = ["SOC2", "ISO27001"]
  encryption_required = true
}

# Service Mesh Configuration
service_mesh_config = {
  enabled = true
  mtls_enabled = true
  tracing_enabled = true
  mesh_policy = "strict"
  retention_days = 14
}
