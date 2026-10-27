
FROM node:22-alpine

# Update npm and its bundled undici dependency
RUN npm install --global npm@latest \
    && npm install --global undici@6.29.1

WORKDIR /app

COPY --chown=node:node app.js package.json ./

ENV NODE_ENV=production
ENV PORT=3000

USER node

EXPOSE 3000

CMD ["node", "app.js"]
