# Secure Terraform Backend Configuration
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.0"
    }
  }

  # Multi-cloud backend configuration with encryption
  backend "s3" {
    # AWS S3 Backend (Primary)
    bucket                  = "multi-cloud-k8s-terraform-state"
    key                     = "terraform/state/terraform.tfstate"
    region                  = "us-west-2"
    encrypt                 = true
    kms_key_id             = "arn:aws:kms:us-west-2:ACCOUNT-ID:key/KEY-ID"
    dynamodb_table         = "terraform-state-locks"
    
    # Security configurations
    versioning            = true
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          kms_master_key_id = "arn:aws:kms:us-west-2:ACCOUNT-ID:key/KEY-ID"
          sse_algorithm     = "aws:kms"
        }
      }
    }
    
    # Access controls
    public_access_block_configuration {
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }
    
    # Lifecycle configuration
    lifecycle_rule {
      id      = "terraform_state_retention"
      enabled = true
      
      noncurrent_version_expiration {
        days = 90
      }
      
      noncurrent_version_transition {
        days          = 30
        storage_class = "STANDARD_IA"
      }
      
      noncurrent_version_transition {
        days          = 60
        storage_class = "GLACIER"
      }
    }
    
    # Logging
    logging {
      target_bucket = "multi-cloud-k8s-access-logs"
      target_prefix = "terraform-state-access-logs/"
    }
    
    # Tags
    tags = {
      Environment   = "production"
      Project       = "multi-cloud-k8s"
      ManagedBy     = "terraform"
      Security      = "encrypted"
      Compliance    = "required"
    }
  }
  
  # Alternative: Google Cloud Storage Backend
  # backend "gcs" {
  #   bucket                 = "multi-cloud-k8s-terraform-state-gcp"
  #   prefix                 = "terraform/state"
  #   encryption_key         = "your-kms-key"
  #   storage_class          = "REGIONAL"
  #   uniform_bucket_level_access = true
  # }
  
  # Alternative: Azure Storage Backend
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "terraformstatestorage"
  #   container_name       = "terraform-state"
  #   key                  = "terraform.tfstate"
  #   encryption_key       = "vault_key"
  # }
}

# State lock configuration (DynamoDB)
resource "aws_dynamodb_table" "terraform_locks" {
  name           = "terraform-state-locks"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  server_side_encryption {
    enabled     = true
    kms_key_arn = var.kms_key_arn
  }
  
  point_in_time_recovery {
    enabled = true
  }
  
  tags = {
    Name          = "Terraform State Lock Table"
    Environment   = var.environment
    Project       = "multi-cloud-k8s"
    ManagedBy     = "terraform"
  }
}

# S3 bucket for Terraform state with enhanced security
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "multi-cloud-k8s-terraform-state-${random_id.bucket_suffix.hex}"
  force_destroy = false
  
  tags = {
    Name        = "Terraform State Bucket"
    Environment = var.environment
    Project     = "multi-cloud-k8s"
    ManagedBy   = "terraform"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy for secure access
resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureConnections"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.terraform_state.arn,
          "${aws_s3_bucket.terraform_state.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid       = "DenyUnencryptedUploads"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.terraform_state.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      }
    ]
  })
}

# Lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    id     = "terraform_state_retention"
    status = "Enabled"
    
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    
    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }
    
    noncurrent_version_transition {
      noncurrent_days = 60
      storage_class   = "GLACIER"
    }
  }
}

# Logging bucket
resource "aws_s3_bucket" "access_logs" {
  bucket        = "multi-cloud-k8s-access-logs-${random_id.bucket_suffix.hex}"
  force_destroy = false
}

resource "aws_s3_bucket_logging" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  
  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "terraform-state-access-logs/"
}

# CloudTrail for state file access auditing
resource "aws_cloudtrail" "terraform_state_audit" {
  name           = "terraform-state-audit-trail"
  s3_bucket_name = aws_s3_bucket.access_logs.id
  s3_key_prefix  = "cloudtrail-logs/"
  
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail        = true
  enable_log_file_validation   = true
  
  kms_key_id = var.kms_key_arn
  
  event_selector {
    read_write_type                 = "All"
    include_management_events       = true
    exclude_management_event_sources = []
    
    data_resource {
      type   = "AWS::S3::Object"
      values = ["${aws_s3_bucket.terraform_state.arn}/*"]
    }
    
    data_resource {
      type   = "AWS::S3::Bucket"
      values = [aws_s3_bucket.terraform_state.arn]
    }
  }
  
  tags = {
    Name        = "Terraform State Audit Trail"
    Environment = var.environment
    Project     = "multi-cloud-k8s"
  }
}