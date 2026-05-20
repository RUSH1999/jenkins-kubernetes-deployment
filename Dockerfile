# Stage 1: Build the React application
FROM node:20-alpine AS build
WORKDIR /app

# Install dependencies using npm ci (clean install for speed & reliability)
COPY package.json package-lock.json ./
RUN npm ci

# Copy source and build static distribution files
COPY . .
RUN npm run build

# Stage 2: Serve using an ultra-lightweight Nginx engine
FROM nginx:1.25-alpine AS production

ENV PORT=3000

# Copy custom configuration if needed, otherwise copy files directly to default path
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]