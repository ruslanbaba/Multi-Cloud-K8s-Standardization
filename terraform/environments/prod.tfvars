# Production environment configuration
environment = "prod"

# Regional Configuration
aws_region = "us-east-1"
aws_secondary_region = "us-west-2"
gcp_region = "us-east4"
gcp_secondary_region = "us-west1"
azure_location = "eastus"
azure_secondary_location = "westus"

# Network Configuration
vpc_cidr = "10.40.0.0/16"
subnet_cidrs = {
  private = ["10.40.1.0/24", "10.40.2.0/24"]
  public = ["10.40.101.0/24", "10.40.102.0/24"]
  database = ["10.40.201.0/24", "10.40.202.0/24"]
}

# Node Pool Configuration
node_pool_config = {
  min_nodes = 5
  max_nodes = 10
  instance_type = "t3.2xlarge"
  disk_size_gb = 200
  labels = {
    environment = "prod"
  }
  taints = []
}

# High Availability Configuration
ha_config = {
  multi_region = true
  failover_regions = ["us-west-2", "eu-west-1"]
  rpo_minutes = 15
  rto_minutes = 30
}

# Cost Management
cost_management = {
  budget_amount = 10000
  alert_threshold = 90
  spot_enabled = false
  spot_max_price = 0
}

# Security Configuration
compliance_config = {
  log_retention_days = 365
  audit_enabled = true
  compliance_standards = ["SOC2", "ISO27001", "PCI", "HIPAA"]
  encryption_required = true
}

# Service Mesh Configuration
service_mesh_config = {
  enabled = true
  mtls_enabled = true
  tracing_enabled = true
  mesh_policy = "strict"
  retention_days = 90
}
