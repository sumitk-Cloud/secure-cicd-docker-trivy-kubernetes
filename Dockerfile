```dockerfile
FROM node:22-alpine

RUN npm install --global npm@latest \
    && npm install --prefix /usr/local/lib/node_modules/npm undici@6.29.1 \
    && node -p "require('/usr/local/lib/node_modules/npm/node_modules/undici/package.json').version"

WORKDIR /app

COPY --chown=node:node app.js package.json ./

ENV NODE_ENV=production
ENV PORT=3000

USER node

EXPOSE 3000

CMD ["node", "app.js"]
```
