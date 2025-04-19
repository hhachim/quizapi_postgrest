FROM node:18-alpine AS deps
WORKDIR /app
# Copier package.json depuis le répertoire app
COPY app/package.json ./
RUN npm install

FROM node:18-alpine AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY app/ .
RUN npm run build

FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV production

COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 3000
ENV PORT 3000

#CMD ["node", "server.js"]
CMD ["npm", "run", "dev"]
#CMD ["node_modules/.bin/next2", "dev"]