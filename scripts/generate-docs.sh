#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "Generating API documentation..."

# Check if redoc-cli is installed
if ! command -v redoc-cli &> /dev/null; then
    echo "Installing redoc-cli..."
    npm install -g redoc-cli
fi

# Generate static HTML documentation
redoc-cli bundle docs/api/openapi.yaml \
    --title "Multi-Cloud K8s Portal API Documentation" \
    --template docs/api/template.hbs \
    --output docs/api/index.html

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ API documentation generated successfully${NC}"
    echo "Documentation available at docs/api/index.html"
else
    echo -e "${RED}✗ Failed to generate API documentation${NC}"
    exit 1
fi

# Validate OpenAPI specification
if ! command -v swagger-cli &> /dev/null; then
    echo "Installing swagger-cli..."
    npm install -g @apidevtools/swagger-cli
fi

echo "Validating OpenAPI specification..."
swagger-cli validate docs/api/openapi.yaml

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ OpenAPI specification is valid${NC}"
else
    echo -e "${RED}✗ OpenAPI specification validation failed${NC}"
    exit 1
fi
