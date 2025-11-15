# syntax=docker/dockerfile:1.6

# Base image with pnpm enabled
FROM node:22-alpine AS base
WORKDIR /app
ENV PNPM_HOME="/pnpm" \
	PATH="$PNPM_HOME:$PATH"
RUN corepack enable pnpm

# Install production dependencies using pnpm and prepare deployable artifact
FROM base AS builder
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
RUN pnpm fetch --prod
COPY . .
RUN --mount=type=cache,target=/pnpm/store pnpm install --prod --offline \
 && mkdir -p /opt/deploy \
 && pnpm deploy /opt/deploy --prod --filter docusaurus-example

# Final runtime image with trimmed dependencies
FROM node:22-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /opt/deploy/ ./
EXPOSE 3000
CMD ["node", "index.js"]
