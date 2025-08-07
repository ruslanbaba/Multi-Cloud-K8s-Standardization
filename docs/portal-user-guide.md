# Multi-Cloud K8s Portal User Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Cluster Management](#cluster-management)
4. [Deployments](#deployments)
5. [Monitoring](#monitoring)
6. [Templates](#templates)
7. [Troubleshooting](#troubleshooting)

## Introduction

The Multi-Cloud K8s Portal is a self-service platform for managing Kubernetes deployments across multiple cloud providers (AWS, GCP, and Azure). This guide will help you navigate the portal's features and capabilities.

## Getting Started

### First-Time Setup

1. Access the portal at `https://portal.example.com`
2. Log in with your credentials
3. Set up your profile and preferences
4. Configure cloud provider access (if required)

### Navigation

The portal consists of five main sections:
- Dashboard: Overview of all resources
- Clusters: Manage Kubernetes clusters
- Deployments: Manage applications
- Templates: Pre-configured application templates
- Monitoring: Metrics and alerts

## Cluster Management

### Viewing Clusters

1. Navigate to the Clusters page
2. View cluster status, resources, and health
3. Click on a cluster for detailed information

### Creating a New Cluster

1. Click "Create Cluster"
2. Select cloud provider (AWS, GCP, or Azure)
3. Choose region and configuration
4. Set node pool specifications
5. Configure networking and security
6. Review and create

### Cluster Operations

- Scale nodes
- Update Kubernetes version
- Configure auto-scaling
- Manage access control
- View logs and metrics

## Deployments

### Creating a Deployment

1. Navigate to Deployments
2. Click "New Deployment"
3. Choose deployment method:
   - From template
   - Custom configuration
   - Import existing
4. Configure resources and scaling
5. Set environment variables
6. Deploy

### Managing Deployments

- Scale replicas
- Update configurations
- Roll back changes
- View logs
- Monitor performance

## Monitoring

### Dashboard Views

- Cluster health
- Resource utilization
- Application metrics
- Cost analytics

### Alerts

1. Configure alert rules
2. Set thresholds
3. Configure notifications
4. View and manage active alerts

### Metrics

- CPU and memory usage
- Network traffic
- Response times
- Error rates
- Custom metrics

## Templates

### Using Templates

1. Browse template catalog
2. Select template
3. Customize configuration
4. Deploy to selected cluster

### Creating Templates

1. Navigate to Templates
2. Click "Create Template"
3. Define template structure
4. Set variables and defaults
5. Add documentation
6. Save and publish

## Troubleshooting

### Common Issues

1. Connection Problems
   - Check network connectivity
   - Verify cloud provider credentials
   - Confirm cluster access

2. Deployment Failures
   - Check logs
   - Verify resource availability
   - Review configuration

3. Performance Issues
   - Monitor resource usage
   - Check scaling configurations
   - Review network policies

### Getting Help

- Check documentation
- Contact support
- Submit bug reports
- Join community forums

## Best Practices

### Security

1. Access Control
   - Use role-based access
   - Implement least privilege
   - Regular credential rotation

2. Network Security
   - Configure network policies
   - Enable encryption
   - Regular security audits

### Performance

1. Resource Management
   - Set resource limits
   - Configure auto-scaling
   - Monitor usage patterns

2. Cost Optimization
   - Use spot instances
   - Implement auto-scaling
   - Regular cost reviews

## API Integration

### REST API

```bash
# Authentication
curl -X POST https://portal-api.example.com/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "user", "password": "pass"}'

# List Clusters
curl -X GET https://portal-api.example.com/clusters \
  -H "Authorization: Bearer $TOKEN"

# Create Deployment
curl -X POST https://portal-api.example.com/deployments \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d @deployment.json
```

### CLI Tool

```bash
# Install CLI
npm install -g multi-cloud-k8s-cli

# Login
mck login

# List clusters
mck clusters list

# Create deployment
mck deploy -f deployment.yaml
```

## Appendix

### Resource Limits

| Environment | CPU | Memory | Storage |
|-------------|-----|---------|----------|
| Development | 2   | 4Gi     | 20Gi     |
| Staging     | 4   | 8Gi     | 50Gi     |
| Production  | 8   | 16Gi    | 100Gi    |

### Supported Versions

- Kubernetes: 1.24+
- Cloud Providers:
  - AWS EKS: 1.24+
  - GCP GKE: 1.24+
  - Azure AKS: 1.24+
