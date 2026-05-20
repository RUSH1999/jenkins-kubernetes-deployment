# ─────────────────────────────────────────
# Stage 1: Build  (node:18-alpine keeps the
#           image lean during the build step)
# ─────────────────────────────────────────
FROM node:18-alpine AS builder

WORKDIR /app

# Copy dependency manifests first for better layer caching
COPY package*.json ./

# Install only production-needed build deps; clean cache immediately
RUN npm ci --prefer-offline && npm cache clean --force

# Copy source and build the production bundle
COPY . .
RUN npm run build

# ─────────────────────────────────────────
# Stage 2: Serve  (nginx:alpine ≈ 23 MB)
# ─────────────────────────────────────────
FROM nginx:alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy build output from Stage 1
COPY --from=builder /app/build /usr/share/nginx/html

# Lightweight nginx config (SPA-friendly)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]