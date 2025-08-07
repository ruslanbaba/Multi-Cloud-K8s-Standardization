# Common variables across all environments
enable_monitoring = true
enable_logging = true
enable_alerts = true

# Default node pool configurations
default_node_pool_config = {
  min_nodes = 2
  max_nodes = 5
  instance_type = "Standard_DS2_v2"
  disk_size_gb = 50
}

# Security defaults
ssl_policy = {
  min_protocol_version = "TLSv1.2"
  ciphers = [
    "ECDHE-ECDSA-AES128-GCM-SHA256",
    "ECDHE-RSA-AES128-GCM-SHA256"
  ]
}

# Backup configuration
backup_retention_days = 30

# Monitoring configuration
alert_thresholds = {
  cpu_utilization    = 80
  memory_utilization = 80
  disk_utilization   = 85
  error_rate        = 5
  latency_threshold  = 500
}
