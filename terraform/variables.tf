# Variables for Multi-Cloud K8s Standardization

# Regional Configuration
variable "aws_region" {
  description = "AWS region for primary deployment"
  type        = string
}

variable "aws_secondary_region" {
  description = "AWS region for disaster recovery"
  type        = string
}

variable "gcp_region" {
  description = "GCP region for primary deployment"
  type        = string
}

variable "gcp_secondary_region" {
  description = "GCP region for disaster recovery"
  type        = string
}

variable "azure_location" {
  description = "Azure location for primary deployment"
  type        = string
}

variable "azure_secondary_location" {
  description = "Azure location for disaster recovery"
  type        = string
}

# Environment Configuration
variable "environment" {
  description = "Environment (prod, staging, dev)"
  type        = string
  validation {
    condition     = contains(["prod", "staging", "dev"], var.environment)
    error_message = "Environment must be prod, staging, or dev."
  }
}

# Network Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  description = "CIDR blocks for subnets"
  type = map(object({
    private = list(string)
    public  = list(string)
    database = list(string)
  }))
}

variable "transit_gateway_routes" {
  description = "Routes for Transit Gateway"
  type = list(object({
    destination_cidr = string
    target_region   = string
  }))
}

# Security Configuration
variable "admin_ip_ranges" {
  description = "Admin IP ranges for cluster access"
  type        = list(string)
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "ssl_policy" {
  description = "SSL policy for load balancers"
  type = object({
    min_protocol_version = string
    ciphers             = list(string)
  })
  default = {
    min_protocol_version = "TLSv1.2"
    ciphers             = ["ECDHE-ECDSA-AES128-GCM-SHA256", "ECDHE-RSA-AES128-GCM-SHA256"]
  }
}

variable "waf_rules" {
  description = "WAF rules configuration"
  type = map(object({
    priority = number
    action   = string
    rules    = list(string)
  }))
}

# Database Configuration
variable "database_config" {
  description = "Database configuration for each cloud"
  type = map(object({
    instance_class    = string
    engine_version    = string
    storage_gb        = number
    multi_az         = bool
    backup_window    = string
    maintenance_window = string
  }))
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 30
}

# Monitoring and Alerting
variable "monitoring_notification_arn" {
  description = "SNS topic ARN for monitoring alerts"
  type        = string
}

variable "alert_thresholds" {
  description = "Monitoring alert thresholds"
  type = object({
    cpu_utilization    = number
    memory_utilization = number
    disk_utilization   = number
    error_rate        = number
    latency_threshold  = number
  })
  default = {
    cpu_utilization    = 80
    memory_utilization = 80
    disk_utilization   = 85
    error_rate        = 5
    latency_threshold  = 500
  }
}

# Performance Configuration
variable "max_pods_per_node" {
  description = "Maximum number of pods per node"
  type        = number
  default     = 110
}

variable "node_pool_config" {
  description = "Node pool configuration for each cloud"
  type = map(object({
    min_nodes     = number
    max_nodes     = number
    instance_type = string
    disk_size_gb  = number
    labels        = map(string)
    taints       = list(string)
  }))
}

# High Availability Configuration
variable "ha_config" {
  description = "High availability configuration"
  type = object({
    multi_region     = bool
    failover_regions = list(string)
    rpo_minutes     = number
    rto_minutes     = number
  })
}

# Service Mesh Configuration
variable "service_mesh_config" {
  description = "Service mesh configuration"
  type = object({
    enabled           = bool
    mtls_enabled      = bool
    tracing_enabled   = bool
    mesh_policy       = string
    retention_days    = number
  })
}

# Cost Management
variable "cost_management" {
  description = "Cost management configuration"
  type = object({
    budget_amount     = number
    alert_threshold   = number
    spot_enabled      = bool
    spot_max_price    = number
  })
}

# Compliance and Audit
variable "compliance_config" {
  description = "Compliance and audit configuration"
  type = object({
    log_retention_days = number
    audit_enabled     = bool
    compliance_standards = list(string)
    encryption_required = bool
  })
}

# CDN and Edge Configuration
variable "cdn_config" {
  description = "CDN and edge configuration"
  type = object({
    enabled           = bool
    cache_policy     = string
    retention_days   = number
    ssl_certificate  = string
    edge_locations   = list(string)
  })
}
