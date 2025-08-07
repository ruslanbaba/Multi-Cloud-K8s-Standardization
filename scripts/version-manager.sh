#!/bin/bash

# Version management script for Multi-Cloud K8s Standardization

# Usage function
usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -v, --version VERSION    New version to create (e.g., v1.0.0)"
    echo "  -t, --track TRACK        Release track (stable, beta, alpha)"
    echo "  -e, --environment ENV    Target environment (dev, qa, staging, prod)"
    echo "  -r, --rollback VERSION   Rollback to specific version"
    echo "  -h, --help              Show this help message"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -v|--version)
        VERSION="$2"
        shift
        shift
        ;;
        -t|--track)
        TRACK="$2"
        shift
        shift
        ;;
        -e|--environment)
        ENVIRONMENT="$2"
        shift
        shift
        ;;
        -r|--rollback)
        ROLLBACK="$2"
        shift
        shift
        ;;
        -h|--help)
        usage
        ;;
        *)
        echo "Unknown option $1"
        usage
        ;;
    esac
done

# Validate environment
validate_environment() {
    if [[ ! "$1" =~ ^(dev|qa|staging|prod)$ ]]; then
        echo "Error: Invalid environment. Must be dev, qa, staging, or prod"
        exit 1
    fi
}

# Validate version format
validate_version() {
    if [[ ! "$1" =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+)?$ ]]; then
        echo "Error: Invalid version format. Must be like v1.0.0 or v1.0.0-beta"
        exit 1
    fi
}

# Create new version
create_version() {
    validate_version "$VERSION"
    validate_environment "$ENVIRONMENT"
    
    # Create git tag
    git tag -a "$VERSION" -m "Release $VERSION for $ENVIRONMENT"
    git push origin "$VERSION"
    
    # Update ArgoCD application
    kubectl patch applicationset multi-cloud-k8s-apps -n argocd --type merge \
        -p "{\"spec\":{\"template\":{\"spec\":{\"source\":{\"targetRevision\":\"$VERSION\"}}}}}"
    
    echo "Version $VERSION created and deployed to $ENVIRONMENT"
}

# Rollback to previous version
rollback_version() {
    validate_version "$ROLLBACK"
    validate_environment "$ENVIRONMENT"
    
    # Update ArgoCD application to previous version
    kubectl patch applicationset multi-cloud-k8s-apps -n argocd --type merge \
        -p "{\"spec\":{\"template\":{\"spec\":{\"source\":{\"targetRevision\":\"$ROLLBACK\"}}}}}"
    
    echo "Rolled back to version $ROLLBACK in $ENVIRONMENT"
}

# Main execution
if [ ! -z "$ROLLBACK" ]; then
    rollback_version
elif [ ! -z "$VERSION" ]; then
    create_version
else
    usage
fi
