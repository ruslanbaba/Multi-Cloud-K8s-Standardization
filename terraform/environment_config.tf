# Environment-specific configuration defaults
locals {
  # Environment configurations
  environment_configs = {
    dev = {
      cluster_config = {
        node_pools = {
          min_nodes = 2
          max_nodes = 5
          instance_types = {
            aws = "t3.large"
            gcp = "n2-standard-2"
            azure = "Standard_D2s_v3"
          }
        }
        autoscaling = {
          enabled = true
          cpu_threshold = 70
          memory_threshold = 80
        }
        backup = {
          enabled = true
          retention_days = 7
        }
      }
      monitoring = {
        retention_period = "7d"
        sampling_rate = 0.3
        log_level = "DEBUG"
      }
      security = {
        mfa_required = false
        ip_whitelist = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
        audit_level = "WRITE_ONLY"
        network_policies = {
          default_deny = true
          allowed_namespaces = ["kube-system", "monitoring", "logging"]
        }
        pod_security = {
          enforce_non_root = true
          read_only_filesystem = true
          drop_capabilities = ["ALL"]
        }
      }
    }
    staging = {
      cluster_config = {
        node_pools = {
          min_nodes = 3
          max_nodes = 7
          instance_types = {
            aws = "t3.xlarge"
            gcp = "n2-standard-4"
            azure = "Standard_D4s_v3"
          }
        }
        autoscaling = {
          enabled = true
          cpu_threshold = 75
          memory_threshold = 85
        }
        backup = {
          enabled = true
          retention_days = 14
        }
      }
      monitoring = {
        retention_period = "14d"
        sampling_rate = 0.5
        log_level = "INFO"
      }
      security = {
        mfa_required = true
        ip_whitelist = ["10.0.0.0/8", "172.16.0.0/12"]
        audit_level = "ALL"
        network_policies = {
          default_deny = true
          allowed_namespaces = ["kube-system", "monitoring", "logging"]
          egress_restrictions = true
        }
        pod_security = {
          enforce_non_root = true
          read_only_filesystem = true
          drop_capabilities = ["ALL"]
          seccomp_profile = "runtime/default"
        }
      }
    }
    prod = {
      cluster_config = {
        node_pools = {
          min_nodes = 5
          max_nodes = 20
          instance_types = {
            aws = "m6i.2xlarge"
            gcp = "n2-standard-8"
            azure = "Standard_D8s_v3"
          }
        }
        autoscaling = {
          enabled = true
          cpu_threshold = 80
          memory_threshold = 90
        }
        backup = {
          enabled = true
          retention_days = 30
        }
      }
      monitoring = {
        retention_period = "30d"
        sampling_rate = 1.0
        log_level = "WARN"
      }
      security = {
        mfa_required = true
        ip_whitelist = ["10.0.0.0/8"]
        audit_level = "ALL"
        network_policies = {
          default_deny = true
          allowed_namespaces = ["kube-system", "monitoring", "logging"]
          egress_restrictions = true
          micro_segmentation = true
        }
        pod_security = {
          enforce_non_root = true
          read_only_filesystem = true
          drop_capabilities = ["ALL"]
          seccomp_profile = "runtime/default"
          selinux_enabled = true
        }
        runtime_security = {
          falco_enabled = true
          syscall_monitoring = true
          file_integrity_monitoring = true
        }
      }
    }
  }

  # Infrastructure enhancement defaults
  infrastructure_config = {
    high_availability = {
      multi_az_enabled = true
      zone_spread = 3
      min_availability_zones = 3
      failover = {
        automated = true
        rto_minutes = 15
        rpo_minutes = 5
      }
    }
    spot_instances = {
      enabled = true
      max_price_percentage = 70
      instance_pools = 3
      fallback_types = {
        aws = ["m6i.2xlarge", "m6a.2xlarge", "m5.2xlarge"]
        gcp = ["n2-standard-8", "n1-standard-8", "c2-standard-8"]
        azure = ["Standard_D8s_v3", "Standard_F8s_v2", "Standard_E8s_v3"]
      }
    }
    networking = {
      vpc_peering = {
        enabled = true
        routes = ["10.0.0.0/8"]
        allowed_services = ["monitoring", "logging", "backup"]
        encryption_in_transit = true
      }
      transit_gateway = {
        enabled = true
        bandwidth = "1Gbps"
        route_propagation = true
        encryption = true
      }
      zero_trust = {
        enabled = true
        mutual_tls = true
        identity_verification = true
        continuous_validation = true
      }
    }
  }

  # Extended compliance controls
  compliance_config = {
    pci_dss = {
      enabled = true
      requirements = {
        encryption_at_rest = true
        encryption_in_transit = true
        audit_logging = true
        access_control = true
        network_segmentation = true
        vulnerability_scanning = true
        penetration_testing = true
      }
      scanning_schedule = "0 0 * * *"
      report_retention = "365d"
    }
    hipaa = {
      enabled = true
      requirements = {
        phi_encryption = true
        access_auditing = true
        backup_encryption = true
        disaster_recovery = true
        access_controls = true
        audit_trails = true
      }
      audit_retention = "6y"
    }
    gdpr = {
      enabled = true
      requirements = {
        data_encryption = true
        data_lifecycle = true
        right_to_forget = true
        data_portability = true
        consent_management = true
        breach_notification = true
      }
      data_retention = {
        logs = "90d"
        backups = "365d"
        audit_trails = "5y"
      }
    }
    soc2 = {
      enabled = true
      controls = {
        security = true
        availability = true
        processing_integrity = true
        confidentiality = true
        privacy = true
      }
      evidence_collection = "daily"
    }
  }

  # Extended APM configuration
  apm_extended_config = {
    distributed_tracing = {
      enabled = true
      sampling_rate = 1.0
      retention_days = 30
      exporters = ["jaeger", "zipkin", "datadog"]
      correlation = {
        enabled = true
        context_propagation = "w3c"
      }
      custom_attributes = ["user_id", "tenant_id", "region"]
    }
    real_user_monitoring = {
      enabled = true
      session_replay = true
      error_tracking = true
      performance_monitoring = {
        page_load_timing = true
        ajax_timing = true
        resource_timing = true
        js_errors = true
      }
    }
    synthetic_monitoring = {
      enabled = true
      check_intervals = {
        api = 60
        web = 300
      }
      locations = ["us-east", "us-west", "eu-central", "ap-southeast"]
      alert_thresholds = {
        availability = 99.9
        response_time = 1000
      }
    }
  }

  # Mobile and Web App extended settings
  application_extended_config = {
    mobile_apps = {
      api_gateway = {
        rate_limiting = {
          per_ip = "1000r/m"
          per_user = "2000r/m"
          burst = 50
        }
        caching = {
          enabled = true
          default_ttl = "5m"
          max_ttl = "1h"
          cache_key_parameters = ["user_id", "device_id"]
        }
        security = {
          oauth2_enabled = true
          jwt_validation = true
          api_key_rotation = "30d"
          rate_limiting_by_user = true
        }
      }
      offline_support = {
        enabled = true
        sync_interval = "15m"
        conflict_resolution = "last_write_wins"
        max_offline_storage = "100MB"
        encryption = true
      }
      performance = {
        image_optimization = {
          enabled = true
          formats = ["webp", "avif"]
          quality = 85
          max_dimensions = "2048x2048"
        }
        network = {
          prefetching = true
          compression = true
          connection_pooling = true
          http2_enabled = true
        }
      }
    }
    web_apps = {
      edge_computing = {
        enabled = true
        regions = ["us-east", "us-west", "eu-central", "ap-southeast"]
        functions = {
          image_processing = true
          authentication = true
          api_proxying = true
        }
      }
      security = {
        csp = {
          enabled = true
          report_only = false
          directives = {
            default_src = ["'self'"]
            script_src = ["'self'"]
            style_src = ["'self'", "'unsafe-inline'"]
            img_src = ["'self'", "data:", "https:"]
            connect_src = ["'self'"]
            font_src = ["'self'"]
            object_src = ["'none'"]
            frame_ancestors = ["'none'"]
          }
        }
        authentication = {
          oauth_providers = ["google", "github", "azure_ad"]
          mfa_required = true
          session_management = {
            max_age = "24h"
            refresh_threshold = "1h"
            idle_timeout = "30m"
            secure_cookies = true
          }
        }
      }
      optimization = {
        bundling = {
          code_splitting = true
          tree_shaking = true
          minification = true
          compression = true
        }
        caching = {
          browser_cache = "7d"
          cdn_cache = "30d"
          api_cache = "5m"
        }
      }
    }
  }
}
