# Multi-stage build for security
FROM node:18-alpine as dependencies

# Create app directory and user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

WORKDIR /app

# Install dependencies as root, then switch
COPY package*.json ./
RUN npm ci --only=production && \
    npm cache clean --force && \
    npm audit fix

# Production stage
FROM node:18-alpine as production

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 -G nodejs

# Security hardening
RUN apk --no-cache add dumb-init && \
    rm -rf /var/cache/apk/*

WORKDIR /app

# Copy dependencies from previous stage
COPY --from=dependencies --chown=nodejs:nodejs /app/node_modules ./node_modules
COPY --chown=nodejs:nodejs package*.json ./
COPY --chown=nodejs:nodejs . .

# Build the application
RUN npm run build && \
    rm -rf src/

# Switch to non-root user
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node healthcheck.js || exit 1

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Expose port
EXPOSE 3000

# Start the application
CMD ["node", "dist/index.js"]
