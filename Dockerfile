# Stage 1: Build with pnpm
FROM node:20-alpine AS builder
WORKDIR /opt/app
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY pnpm-lock.yaml package.json ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

# Stage 2: Lightweight runtime
FROM node:20-alpine AS runner
WORKDIR /opt/app
RUN corepack enable && corepack prepare pnpm@latest --activate
COPY pnpm-lock.yaml package.json ./
RUN pnpm install --prod --frozen-lockfile
COPY --from=builder /opt/app/dist ./dist
COPY ./server.js ./
EXPOSE 1337
CMD ["node", "server.js"]

