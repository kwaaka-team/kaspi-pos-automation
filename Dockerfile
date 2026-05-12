# Kaspi POS Automation — production image for Coolify / Docker
# Coolify: set TOKEN_SECRET_KEY (openssl rand -hex 32), optional PORT.
# Mount persistent storage at /data so keypair/device/webhooks survive redeploys.

FROM node:22-bookworm-slim AS runtime

ENV NODE_ENV=production
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force

COPY server.js ./
COPY public ./public
COPY src ./src
COPY scripts ./scripts

ENV APP_DATA_DIR=/data
RUN mkdir -p /data && chown node:node /data

USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD node -e "fetch('http://127.0.0.1:'+(process.env.PORT||3000)+'/health').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"

VOLUME ["/data"]

CMD ["node", "server.js"]
