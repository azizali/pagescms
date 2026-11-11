# Pages CMS production image (Next.js, `next start`). Build from the repo root.
FROM node:24-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
# Build-time placeholders only: the real values come from the container's environment at runtime.
ENV NEXT_TELEMETRY_DISABLED=1 NODE_ENV=production
RUN BASE_URL=https://cms.ilovecoding.org \
    DATABASE_URL=postgresql://build:build@localhost:5432/build \
    BETTER_AUTH_SECRET=build-placeholder CRYPTO_KEY=build-placeholder \
    npx next build

FROM node:24-slim
LABEL org.opencontainers.image.source=https://github.com/azizali/pagescms
WORKDIR /app
ENV NODE_ENV=production NEXT_TELEMETRY_DISABLED=1 PORT=3000
# Full install kept on purpose: drizzle-kit (a dev dependency) runs migrations from this same image.
COPY --from=build /app /app
COPY deploy/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh && chown -R node:node /app
USER node
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s --start-period=20s CMD node -e "fetch('http://localhost:3000/').then(r=>process.exit(r.status<500?0:1)).catch(()=>process.exit(1))"
ENTRYPOINT ["entrypoint.sh"]
CMD ["npm", "run", "start"]
