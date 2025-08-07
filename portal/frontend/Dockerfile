# Build stage
FROM node:18-alpine as build

# Create non-root user for build
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force && \
    npm audit fix

# Copy source and build
COPY --chown=nodejs:nodejs . .
USER nodejs
RUN npm run build

# Production stage
FROM nginx:alpine as production

# Security hardening for nginx
RUN apk --no-cache add dumb-init && \
    rm -rf /var/cache/apk/* && \
    # Create nginx user
    addgroup -g 101 -S nginx || true && \
    adduser -S nginx -u 101 -G nginx || true && \
    # Remove default nginx content
    rm -rf /usr/share/nginx/html/*

# Copy built application
COPY --from=build --chown=nginx:nginx /app/build /usr/share/nginx/html

# Copy secure nginx configuration
COPY --chown=nginx:nginx nginx.conf /etc/nginx/conf.d/default.conf
COPY --chown=nginx:nginx nginx-security.conf /etc/nginx/conf.d/security.conf

# Set proper permissions
RUN chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# Switch to non-root user
USER nginx

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Use dumb-init
ENTRYPOINT ["dumb-init", "--"]

# Expose port (non-privileged)
EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
