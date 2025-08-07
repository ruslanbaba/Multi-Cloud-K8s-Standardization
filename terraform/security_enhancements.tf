# Additional security and networking components for Multi-Cloud K8s

# AWS Additional Security Components
resource "aws_shield_protection" "eks_protection" {
  name         = "eks-shield-protection"
  resource_arn = module.aws_network_security.vpc_arn
}

resource "aws_guardduty_detector" "main" {
  enable = true
}

resource "aws_securityhub_account" "main" {
  enable_security_hub = true
}

# AWS Network Firewall
resource "aws_networkfirewall_firewall" "main" {
  name                = "eks-network-firewall"
  vpc_id              = module.aws_network_security.vpc_id
  subnet_mapping {
    subnet_id = module.aws_network_security.private_subnets[0]
  }
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
}

# AWS Transit Gateway for cross-region communication
resource "aws_ec2_transit_gateway" "main" {
  description = "Transit Gateway for cross-region k8s communication"
  
  tags = {
    Name = "k8s-transit-gateway"
  }
}

# GCP Additional Security Components
resource "google_compute_firewall" "allow_health_checks" {
  name    = "allow-health-checks"
  network = google_compute_network.gke_network.name
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["gke-node"]
}

# Cloud KMS for GKE
resource "google_kms_key_ring" "gke_keyring" {
  name     = "gke-keyring"
  location = var.gcp_region
}

resource "google_kms_crypto_key" "gke_key" {
  name     = "gke-key"
  key_ring = google_kms_key_ring.gke_keyring.id
  
  lifecycle {
    prevent_destroy = true
  }
}

# Azure Additional Security Components
resource "azurerm_network_security_group" "aks_nsg" {
  name                = "aks-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "allow-api-server"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range         = "*"
    destination_port_range    = "443"
    source_address_prefix     = "*"
    destination_address_prefix = "*"
  }
}

# Azure Private DNS Zone
resource "azurerm_private_dns_zone" "aks_dns" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = var.resource_group_name
}

# Database Security and High Availability
# AWS RDS with Multi-AZ
resource "aws_db_instance" "postgres_primary" {
  identifier           = "eks-postgres-primary"
  engine              = "postgres"
  engine_version      = "14.5"
  instance_class      = "db.r6g.large"
  allocated_storage   = 100
  storage_encrypted   = true
  kms_key_id         = var.kms_key_arn
  multi_az           = true
  
  backup_retention_period = var.backup_retention_days
  backup_window          = "03:00-04:00"
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  
  performance_insights_enabled = true
  monitoring_interval         = 1
  
  deletion_protection = true
}

# GCP Cloud SQL with HA
resource "google_sql_database_instance" "postgres_gcp" {
  name             = "gke-postgres-ha"
  database_version = "POSTGRES_14"
  region           = var.gcp_region

  settings {
    tier = "db-custom-4-15360"
    availability_type = "REGIONAL"
    backup_configuration {
      enabled = true
      start_time = "03:00"
      backup_retention_settings {
        retained_backups = var.backup_retention_days
      }
    }
    ip_configuration {
      ipv4_enabled = false
      private_network = google_compute_network.gke_network.id
    }
    insights_config {
      query_insights_enabled = true
      query_plans_per_minute = 5
    }
  }
}

# Azure Database for PostgreSQL
resource "azurerm_postgresql_flexible_server" "postgres_azure" {
  name                = "aks-postgres-ha"
  resource_group_name = var.resource_group_name
  location            = var.location
  version            = "14"
  
  delegated_subnet_id = azurerm_subnet.aks_subnet.id
  private_dns_zone_id = azurerm_private_dns_zone.postgres.id
  
  administrator_login    = "psqladmin"
  administrator_password = random_password.postgres_password.result
  
  storage_mb = 32768
  
  sku_name   = "GP_Standard_D4s_v3"
  
  high_availability {
    mode = "ZoneRedundant"
  }
  
  backup_retention_days = var.backup_retention_days
}

# RBAC and IAM Enhancements
# AWS IAM for Service Accounts
resource "aws_iam_openid_connect_provider" "eks" {
  url = module.eks.cluster_oidc_issuer_url
  
  client_id_list = ["sts.amazonaws.com"]
  
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
}

# GCP Workload Identity
resource "google_service_account" "k8s_workload" {
  account_id   = "k8s-workload"
  display_name = "K8s Workload Identity"
}

# Azure Pod Identity
resource "azurerm_user_assigned_identity" "aks_pod_identity" {
  name                = "aks-pod-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
}

# Monitoring and Logging Enhancements
# AWS CloudWatch
resource "aws_cloudwatch_log_group" "eks_logs" {
  name              = "/aws/eks/${module.eks.cluster_id}/cluster"
  retention_in_days = 30
}

# GCP Cloud Logging
resource "google_logging_project_sink" "gke_logs" {
  name        = "gke-logs-sink"
  destination = "storage.googleapis.com/${google_storage_bucket.gke_logs.name}"
  filter      = "resource.type=k8s_cluster"
  
  unique_writer_identity = true
}

# Azure Monitor
resource "azurerm_log_analytics_workspace" "aks" {
  name                = "aks-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                = "PerGB2018"
  retention_in_days   = 30
}

# Network Performance Optimizations
# AWS Global Accelerator
resource "aws_globalaccelerator_accelerator" "k8s" {
  name            = "k8s-accelerator"
  ip_address_type = "IPV4"
  enabled         = true
}

# GCP Cloud CDN
resource "google_compute_backend_bucket" "cdn" {
  name        = "k8s-cdn"
  bucket_name = google_storage_bucket.cdn.name
  enable_cdn  = true
}

# Azure Front Door
resource "azurerm_frontdoor" "k8s" {
  name                = "k8s-front-door"
  resource_group_name = var.resource_group_name
  
  routing_rule {
    name               = "k8s-routing"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    frontend_endpoints = ["k8s-frontend"]
    forwarding_configuration {
      forwarding_protocol = "HttpsOnly"
      backend_pool_name   = "k8s-backend"
    }
  }
}
