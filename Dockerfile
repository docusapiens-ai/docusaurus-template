# syntax=docker/dockerfile:1.6

# Base image with Bun
FROM oven/bun:1 AS base
WORKDIR /app

# Install production dependencies
FROM base AS builder
COPY package.json bun.lockb* ./
RUN bun install --production --frozen-lockfile
COPY . .

# Final runtime image
FROM oven/bun:1-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=builder /app/ ./
EXPOSE 3000
CMD ["bun", "run", "serve"]
