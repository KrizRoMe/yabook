FROM node:20-bullseye-slim AS base

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash -s -- --version 1.2.19 && \
    mv /root/.bun/bin/bun /usr/local/bin/bun

# Create npm alias for compatibility with existing scripts (optional)
RUN ln -s /usr/local/bin/bun /usr/local/bin/npm

WORKDIR /app

# ========================
# Dependencies stage
# ========================
FROM base AS deps
COPY bun.lockb package.json ./
RUN bun install --frozen-lockfile

# ========================
# Build stage
# ========================
FROM base AS builder
WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Generate Prisma client
RUN bunx prisma generate

# Fix permissions for Prisma engines
RUN mkdir -p /app/node_modules/@prisma/engines && chmod -R 777 /app/node_modules/@prisma/engines

# Build the application
RUN bun run build

# ========================
# Production stage
# ========================
FROM base AS runner
WORKDIR /app

ENV NODE_ENV=production

# Create non-root user
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy necessary files from build
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/node_modules ./node_modules

USER nextjs

EXPOSE 3000
ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# Run database migration and start the app with Bun
CMD ["sh", "-c", "bun run migrate:prod && node server.js"]
