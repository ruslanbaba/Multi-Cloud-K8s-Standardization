# Terraform main configuration for Multi-Cloud Kubernetes Standardization

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region
}

# AWS Network Security Components
module "aws_network_security" {
  source = "terraform-aws-modules/vpc/aws"
  name = "eks-vpc"
  cidr = "10.0.0.0/16"
  
  # Multiple AZ deployment for high availability
  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # Enable NAT Gateway for private subnet access
  enable_nat_gateway = true
  single_nat_gateway = false
  
  # VPC Flow Logs for network monitoring
  enable_flow_log = true
  flow_log_destination_type = "cloud-watch-logs"
  
  # VPC Endpoints for secure service access
  enable_s3_endpoint = true
  enable_dynamodb_endpoint = true
}

# AWS WAF for EKS ALB/NLB
resource "aws_wafv2_web_acl" "eks_waf" {
  name        = "eks-waf"
  description = "WAF rules for EKS cluster"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # SQL injection protection
  rule {
    name     = "SQLInjectionRule"
    priority = 1
    statement {
      sql_injection_match_statement {
        field_to_match {
          body {}
        }
        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }
      }
    }
    action {
      block {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "SQLInjectionMetric"
      sampled_requests_enabled  = true
    }
  }

  # Rate limiting
  rule {
    name     = "RateLimitRule"
    priority = 2
    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }
    action {
      block {}
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "RateLimitMetric"
      sampled_requests_enabled  = true
    }
  }
}

# GCP Provider Configuration
provider "google" {
  region = var.gcp_region
}

# GCP Network Security Components
resource "google_compute_network" "gke_network" {
  name                    = "gke-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke_subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.1.0.0/16"
  network       = google_compute_network.gke_network.id
  region        = var.gcp_region

  # Enable flow logs
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling       = 0.5
    metadata           = "INCLUDE_ALL_METADATA"
  }

  # Enable private Google access
  private_ip_google_access = true
}

# Cloud Armor (WAF) for GKE
resource "google_compute_security_policy" "gke_policy" {
  name = "gke-security-policy"

  # DDoS protection
  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss')"
      }
    }
    description = "XSS protection"
  }

  # Rate limiting
  rule {
    action   = "rate_based_ban"
    priority = "2000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      rate_limit_threshold {
        count        = 100
        interval_sec = 60
      }
      conform_action = "allow"
      exceed_action  = "deny(429)"
    }
  }
}

# Azure Provider Configuration
provider "azurerm" {
  features {}
}

# Azure Network Security Components
resource "azurerm_virtual_network" "aks_vnet" {
  name                = "aks-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = ["10.2.0.0/16"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes     = ["10.2.1.0/24"]

  # Service endpoints for secure service access
  service_endpoints = [
    "Microsoft.KeyVault",
    "Microsoft.ContainerRegistry"
  ]
}

# Azure Application Gateway with WAF
resource "azurerm_application_gateway" "aks_waf" {
  name                = "aks-waf"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  waf_configuration {
    enabled                  = true
    firewall_mode           = "Prevention"
    rule_set_type          = "OWASP"
    rule_set_version       = "3.2"
    file_upload_limit_mb   = 100
    max_request_body_size_kb = 128
  }
}

# EKS Cluster with enhanced security
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  
  cluster_name    = "secure-eks-cluster"
  vpc_id         = module.aws_network_security.vpc_id
  subnet_ids     = module.aws_network_security.private_subnets

  # Security group rules
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description = "Node to node communication"
      protocol    = "tcp"
      from_port   = 1025
      to_port     = 65535
      type        = "ingress"
      cidr_blocks = module.aws_network_security.private_subnets_cidr_blocks
    }
  }

  # Enable network policies
  enable_network_policy = true

  # Enable encryption
  cluster_encryption_config = [{
    provider_key_arn = var.kms_key_arn
    resources        = ["secrets"]
  }]
}

# GKE Cluster with enhanced security
module "gke" {
  source = "terraform-google-modules/kubernetes-engine/google"
  
  name     = "secure-gke-cluster"
  network  = google_compute_network.gke_network.name
  subnetwork = google_compute_subnetwork.gke_subnet.name

  # Security features
  enable_binary_authorization = true
  enable_network_policy      = true
  enable_private_nodes       = true
  enable_private_endpoint    = true
  master_authorized_networks_config = {
    cidr_blocks = [{
      cidr_block   = var.admin_ip_ranges
      display_name = "Admin IPs"
    }]
  }

  # Node pool security
  node_pools = [{
    name               = "secure-pool"
    machine_type       = "e2-standard-4"
    min_count         = 1
    max_count         = 5
    service_account   = var.gke_sa_email
    workload_metadata_config = {
      node_metadata = "GKE_METADATA_SERVER"
    }
  }]
}

# AKS Cluster with enhanced security
module "aks" {
  source = "Azure/aks/azurerm"
  
  cluster_name           = "secure-aks-cluster"
  resource_group_name    = var.resource_group_name
  vnet_subnet_id        = azurerm_subnet.aks_subnet.id

  # Security features
  private_cluster_enabled = true
  network_policy         = "calico"
  network_plugin         = "azure"

  # Azure AD integration
  enable_azure_active_directory = true
  azure_active_directory_managed = true

  # Enable pod security policies
  enable_pod_security_policy = true

  # Node pool security
  default_node_pool = {
    name                = "secure"
    node_count          = 3
    vm_size            = "Standard_DS2_v2"
    os_disk_type       = "Managed"
    enable_auto_scaling = true
    min_count          = 1
    max_count          = 5
    max_pods           = 30
  }
}
