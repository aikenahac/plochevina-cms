FROM oven/bun:1 AS build
RUN apt-get update && apt-get install -y \
  build-essential \
  autoconf \
  automake \
  libz-dev \
  libpng-dev \
  libvips-dev \
  && rm -rf /var/lib/apt/lists/*
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/app
COPY package.json bun.lock ./
RUN bun install
COPY . .
RUN bun run build

FROM oven/bun:1
RUN apt-get update && apt-get install -y libvips-dev && rm -rf /var/lib/apt/lists/*
ARG NODE_ENV=production
ENV NODE_ENV=${NODE_ENV}

WORKDIR /opt/app
COPY package.json bun.lock ./
RUN bun install --production --frozen-lockfile
COPY --from=build /opt/app/dist ./dist

RUN chown -R bun:bun /opt/app
USER bun
EXPOSE 1337
CMD ["bun", "start"]

