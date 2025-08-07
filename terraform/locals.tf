# Default values for Multi-Cloud K8s Configuration

locals {
  # Environment-specific configuration integration
  current_env_config = lookup(local.environment_configs, var.environment, local.environment_configs["dev"])
  
  # Regional defaults with environment-specific overrides
  default_regions = {
    aws = {
      primary   = lookup(local.current_env_config.cluster_config.regions.aws, "primary", "us-west-2")
      secondary = lookup(local.current_env_config.cluster_config.regions.aws, "secondary", "us-east-1")
    }
    gcp = {
      primary   = lookup(local.current_env_config.cluster_config.regions.gcp, "primary", "us-central1")
      secondary = lookup(local.current_env_config.cluster_config.regions.gcp, "secondary", "us-east1")
    }
    azure = {
      primary   = lookup(local.current_env_config.cluster_config.regions.azure, "primary", "eastus")
      secondary = lookup(local.current_env_config.cluster_config.regions.azure, "secondary", "westus2")
    }
  }

  # Network configuration defaults
  default_subnet_cidrs = {
    aws = {
      private  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
      public   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
      database = ["10.0.201.0/24", "10.0.202.0/24", "10.0.203.0/24"]
    }
    gcp = {
      private  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
      public   = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
      database = ["10.1.201.0/24", "10.1.202.0/24", "10.1.203.0/24"]
    }
    azure = {
      private  = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
      public   = ["10.2.101.0/24", "10.2.102.0/24", "10.2.103.0/24"]
      database = ["10.2.201.0/24", "10.2.202.0/24", "10.2.203.0/24"]
    }
  }

  # Database configuration defaults
  default_database_config = {
    aws = {
      instance_class     = "db.r6g.xlarge"
      engine_version     = "14.5"
      storage_gb        = 100
      multi_az          = true
      backup_window     = "03:00-04:00"
      maintenance_window = "Mon:04:00-Mon:05:00"
    }
    gcp = {
      instance_class     = "db-custom-8-32768"
      engine_version     = "POSTGRES_14"
      storage_gb        = 100
      multi_az          = true
      backup_window     = "03:00-04:00"
      maintenance_window = "Mon:04:00-Mon:05:00"
    }
    azure = {
      instance_class     = "GP_Gen5_8"
      engine_version     = "14"
      storage_gb        = 100
      multi_az          = true
      backup_window     = "03:00-04:00"
      maintenance_window = "Mon:04:00-Mon:05:00"
    }
  }

  # Node pool configuration defaults with environment-specific overrides
  default_node_pool_config = {
    aws = {
      min_nodes     = lookup(local.current_env_config.cluster_config.node_pools, "min_nodes", 3)
      max_nodes     = lookup(local.current_env_config.cluster_config.node_pools, "max_nodes", 10)
      instance_type = lookup(local.current_env_config.cluster_config.node_pools.instance_types, "aws", "m6g.2xlarge")
      disk_size_gb  = lookup(local.current_env_config.cluster_config.node_pools, "disk_size_gb", 100)
      labels = merge(
        {
          environment = var.environment
          platform    = "aws"
        },
        lookup(local.current_env_config.cluster_config.labels, "aws", {})
      )
      taints = lookup(local.current_env_config.cluster_config.taints, "aws", [])
      spot_config = local.infrastructure_config.spot_instances.enabled ? {
        enabled = true
        max_price_percentage = local.infrastructure_config.spot_instances.max_price_percentage
        instance_pools = local.infrastructure_config.spot_instances.instance_pools
        fallback_types = local.infrastructure_config.spot_instances.fallback_types.aws
      } : null
    }
    gcp = {
      min_nodes     = lookup(local.current_env_config.cluster_config.node_pools, "min_nodes", 3)
      max_nodes     = lookup(local.current_env_config.cluster_config.node_pools, "max_nodes", 10)
      instance_type = lookup(local.current_env_config.cluster_config.node_pools.instance_types, "gcp", "n2-standard-8")
      disk_size_gb  = lookup(local.current_env_config.cluster_config.node_pools, "disk_size_gb", 100)
      labels = merge(
        {
          environment = var.environment
          platform    = "gcp"
        },
        lookup(local.current_env_config.cluster_config.labels, "gcp", {})
      )
      taints = lookup(local.current_env_config.cluster_config.taints, "gcp", [])
      spot_config = local.infrastructure_config.spot_instances.enabled ? {
        enabled = true
        max_price_percentage = local.infrastructure_config.spot_instances.max_price_percentage
        instance_pools = local.infrastructure_config.spot_instances.instance_pools
        fallback_types = local.infrastructure_config.spot_instances.fallback_types.gcp
      } : null
    }
    azure = {
      min_nodes     = lookup(local.current_env_config.cluster_config.node_pools, "min_nodes", 3)
      max_nodes     = lookup(local.current_env_config.cluster_config.node_pools, "max_nodes", 10)
      instance_type = lookup(local.current_env_config.cluster_config.node_pools.instance_types, "azure", "Standard_D8s_v3")
      disk_size_gb  = lookup(local.current_env_config.cluster_config.node_pools, "disk_size_gb", 100)
      labels = merge(
        {
          environment = var.environment
          platform    = "azure"
        },
        lookup(local.current_env_config.cluster_config.labels, "azure", {})
      )
      taints = lookup(local.current_env_config.cluster_config.taints, "azure", [])
      spot_config = local.infrastructure_config.spot_instances.enabled ? {
        enabled = true
        max_price_percentage = local.infrastructure_config.spot_instances.max_price_percentage
        instance_pools = local.infrastructure_config.spot_instances.instance_pools
        fallback_types = local.infrastructure_config.spot_instances.fallback_types.azure
      } : null
    }
  }

  # WAF rules configuration defaults
  default_waf_rules = {
    sql_injection = {
      priority = 1
      action   = "block"
      rules    = ["SQLi_BODY", "SQLi_QUERYSTRING"]
    }
    xss = {
      priority = 2
      action   = "block"
      rules    = ["XSS_BODY", "XSS_QUERYSTRING"]
    }
    rate_limit = {
      priority = 3
      action   = "block"
      rules    = ["RATE_LIMIT"]
    }
  }

  # High availability configuration defaults
  default_ha_config = {
    multi_region     = true
    failover_regions = [local.default_regions.aws.secondary, local.default_regions.gcp.secondary, local.default_regions.azure.secondary]
    rpo_minutes     = 15
    rto_minutes     = 30
    disaster_recovery = {
      backup_strategy = "continuous"
      backup_frequency_minutes = 5
      cross_region_replication = true
      failover_automation = true
      health_check_interval = 10
      recovery_priority_classes = ["critical", "high", "medium", "low"]
    }
    availability_zones = {
      aws = ["a", "b", "c"]
      gcp = ["b", "c", "d"]
      azure = [1, 2, 3]
    }
    load_balancing = {
      algorithm = "least_connections"
      health_check_path = "/health"
      health_check_interval = 5
      health_check_timeout = 3
      healthy_threshold = 2
      unhealthy_threshold = 3
      cross_zone_enabled = true
      session_affinity = true
    }
  }

  # Service mesh configuration defaults
  default_service_mesh_config = {
    enabled         = true
    mtls_enabled    = true
    tracing_enabled = true
    mesh_policy     = "STRICT"
    retention_days  = 30
    istio_config = {
      version = "1.18"
      ingress_gateway_replicas = 3
      auto_injection = true
      sidecar_resources = {
        requests = {
          cpu = "100m"
          memory = "128Mi"
        }
        limits = {
          cpu = "200m"
          memory = "256Mi"
        }
      }
      monitoring = {
        metrics_retention = "15d"
        trace_sampling = 100
        access_logging = true
      }
      security = {
        authorization_policy = "DENY_ALL"
        jwt_policy = "THIRD_PARTY_JWT"
        peer_authentication = "STRICT"
      }
    }
    circuit_breaker = {
      max_connections = 1000
      max_pending_requests = 100
      max_requests = 1000
      max_retries = 3
    }
  }

  # CDN configuration defaults
  default_cdn_config = {
    enabled          = true
    cache_policy     = "CachingOptimized"
    retention_days   = 30
    ssl_certificate  = "default"
    edge_locations   = ["us-east-1", "us-west-2", "eu-west-1", "ap-southeast-1"]
    advanced_config = {
      origin_shield = true
      ddos_protection = true
      web_application_firewall = true
      bot_protection = true
      image_optimization = true
      cache_compression = true
      origin_failover = {
        enabled = true
        failover_criteria = ["5xx", "timeout"]
        secondary_origin = "dr-origin"
      }
      custom_headers = {
        security_headers = true
        cors_config = {
          allowed_origins = ["*"]
          allowed_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
          allowed_headers = ["*"]
          expose_headers = ["ETag"]
          max_age = 86400
        }
      }
    }
  }

  # Cost management defaults
  default_cost_management = {
    budget_amount   = 10000
    alert_threshold = 80
    spot_enabled    = true
    spot_max_price  = 0.5
    advanced_controls = {
      auto_scaling_optimization = true
      idle_resource_cleanup = true
      reserved_instance_coverage = 80
      cost_allocation = {
        enabled = true
        tag_keys = ["team", "project", "environment"]
      }
      budget_notifications = {
        email_contacts = ["devops@example.com"]
        slack_webhook = true
        forecast_enabled = true
        forecast_threshold = 110
      }
      spot_strategy = {
        interruption_handling = true
        max_spot_percentage = 80
        fallback_instance_types = ["m6g.xlarge", "m6i.xlarge"]
      }
    }
  }

  # Performance optimization defaults
  default_performance_config = {
    autoscaling = {
      cpu_target_utilization = 70
      memory_target_utilization = 80
      custom_metrics_enabled = true
      scale_down_delay = "10m"
      scale_up_delay = "3m"
    }
    caching = {
      redis_config = {
        instance_type = "cache.r6g.xlarge"
        num_replicas = 2
        auto_failover = true
        multi_az = true
        encryption_at_rest = true
        backup_retention = 7
      }
      memcached_config = {
        instance_type = "cache.m6g.large"
        num_nodes = 3
      }
    }
    database_optimization = {
      connection_pooling = true
      max_connections = 1000
      statement_timeout = 30000
      idle_timeout = 300
      pg_bouncer = {
        enabled = true
        pool_mode = "transaction"
        max_client_conn = 10000
      }
    }
  }

  # Advanced monitoring configuration with environment-specific settings and APM integration
  default_monitoring_config = {
    prometheus_config = {
      retention_period = lookup(local.current_env_config.monitoring, "retention_period", "30d")
      storage_size = lookup(local.current_env_config.monitoring, "storage_size", "100Gi")
      scrape_interval = lookup(local.current_env_config.monitoring, "scrape_interval", "15s")
      evaluation_interval = "15s"
      replica_count = 2
      remote_write = {
        enabled = true
        endpoint = "thanos-receiver:19291"
      }
      rules = {
        recording_rules = true
        alerting_rules = true
      }
      high_availability = {
        enabled = true
        replica_external_labels = {
          cluster = "primary"
          replica = "replica-$(POD_NAME)"
        }
      }
    }
    grafana_config = {
      persistence_enabled = true
      storage_size = "20Gi"
      admin_password_rotation = "30d"
      dashboards_auto_import = true
      sso_enabled = true
      alerting = {
        enabled = true
        alert_managers = ["alertmanager:9093"]
        notification_channels = ["slack", "email", "pagerduty"]
      }
    }
    logging_config = {
      elasticsearch = {
        version = "7.17.0"
        node_count = 3
        master_nodes = 3
        data_nodes = 3
        hot_warm_architecture = true
        retention = {
          hot = "7d"
          warm = "30d"
          cold = "90d"
        }
        snapshot_repository = "s3-backup"
      }
      fluentd = {
        aggregator_replicas = 3
        buffer_size = "256Mi"
        forward_timeout = "60s"
      }
      kibana = {
        replicas = 2
        resources = {
          requests = {
            cpu = "1"
            memory = "2Gi"
          }
          limits = {
            cpu = "2"
            memory = "4Gi"
          }
        }
      }
    }
    apm_config = {
      elastic_apm = {
        enabled = true
        replicas = 2
        memory_limit = "1Gi"
        sampling_rate = 1.0
      }
      jaeger = {
        enabled = true
        storage_type = "elasticsearch"
        collector_replicas = 2
        agent_daemonset = true
      }
    }
  }

  # Enhanced security controls
  default_security_config = {
    network_policies = {
      default_deny = true
      allowed_namespaces = ["kube-system", "monitoring"]
      egress_rules = {
        dns = {
          ports = ["53"]
          protocol = "UDP"
        }
        https = {
          ports = ["443"]
          protocol = "TCP"
        }
      }
      namespace_isolation = {
        enabled = true
        exceptions = ["monitoring", "logging"]
      }
      ingress_whitelist = {
        enabled = true
        cidrs = ["10.0.0.0/8"]
        load_balancers = true
      }
    }
    pod_security = {
      privileged = false
      allow_privilege_escalation = false
      read_only_root_filesystem = true
      run_as_non_root = true
      seccomp_profile = "runtime/default"
      selinux_options = {
        level = "s0"
        role = "system_r"
        type = "container_t"
        user = "system_u"
      }
      psp_policies = {
        root_prevention = true
        host_namespace_prevention = true
        privilege_escalation_prevention = true
        capabilities_restriction = true
      }
    }
    secret_management = {
      vault_config = {
        ha_enabled = true
        auto_unseal = true
        audit_log_enabled = true
        key_rotation_period = "30d"
        dynamic_secrets = true
        auth_methods = ["kubernetes", "aws", "gcp", "azure"]
        policies = {
          strict_secret_lifecycle = true
          auto_revocation = true
        }
      }
      sealed_secrets = {
        enabled = true
        key_renewal_period = "30d"
      }
      cert_manager = {
        enabled = true
        acme_dns01_solver = true
        vault_issuer = true
        self_signed = false
        trust_anchors = ["letsencrypt-prod"]
      }
    }
    container_security = {
      image_scanning = {
        enabled = true
        block_critical = true
        block_high = true
        trusted_registries = ["docker.io", "gcr.io", "azure.io"]
      }
      runtime_security = {
        falco_enabled = true
        seccomp_enabled = true
        apparmor_enabled = true
        audit_logging = true
      }
      compliance = merge(local.compliance_config, {
        pci_dss = local.compliance_config.pci_dss.enabled
        hipaa = local.compliance_config.hipaa.enabled
        soc2 = local.compliance_config.soc2.enabled
        gdpr = local.compliance_config.gdpr.enabled
        scanning_schedule = "0 0 * * *"
        requirements = merge(
          local.compliance_config.pci_dss.requirements,
          local.compliance_config.hipaa.requirements,
          local.compliance_config.gdpr.requirements
        )
        audit_retention = max(
          try(local.compliance_config.hipaa.audit_retention, "365d"),
          try(local.compliance_config.gdpr.data_retention.audit_trails, "365d")
        )
      })
    }
  }

  # Application-specific configurations with environment overrides
  default_application_config = merge(local.application_extended_config, {
    mobile_apps = merge(local.application_extended_config.mobile_apps, {
      api_rate_limiting = merge(local.application_extended_config.mobile_apps.api_gateway.rate_limiting, {
        default_rate = lookup(local.current_env_config.app_config.mobile, "default_rate", "1000r/m")
        burst_size = lookup(local.current_env_config.app_config.mobile, "burst_size", 20)
        client_tracking = "ip"
      })
      caching_strategy = {
        api_cache_ttl = "5m"
        static_cache_ttl = "24h"
        redis_cache_size = "2Gi"
      }
      cdn_configuration = {
        image_optimization = true
        video_streaming = true
        geo_replication = true
      }
      push_notifications = {
        enabled = true
        providers = ["fcm", "apns"]
        batch_size = 1000
        retry_attempts = 3
      }
      authentication = {
        jwt_lifetime = "24h"
        refresh_token_lifetime = "7d"
        mfa_enabled = true
        biometric_support = true
      }
    }
    web_apps = {
      frontend_config = {
        cdn_enabled = true
        spa_routing = true
        ssr_enabled = true
        compression = true
        cache_control = {
          static = "public, max-age=31536000"
          dynamic = "no-cache"
        }
      }
      security_headers = {
        hsts_enabled = true
        csp_enabled = true
        xss_protection = true
        frame_options = "DENY"
      }
      performance = {
        lazy_loading = true
        code_splitting = true
        minification = true
        image_optimization = true
      }
      monitoring = {
        real_user_monitoring = true
        error_tracking = true
        performance_tracking = true
      }
    }
  }
}
