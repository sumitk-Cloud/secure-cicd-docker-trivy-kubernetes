FROM node:22-alpine

WORKDIR /app

COPY --chown=node:node app.js package.json ./

ENV NODE_ENV=production
ENV PORT=3000

USER node

EXPOSE 3000

CMD ["node", "app.js"]