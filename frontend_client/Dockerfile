FROM node:18-alpine AS deps
WORKDIR /app
COPY quiz-frontend/package.json ./
RUN npm install

FROM node:18-alpine AS runner
WORKDIR /app
ENV NODE_ENV development

COPY --from=deps /app/node_modules ./node_modules
COPY quiz-frontend/ .

EXPOSE 3000
ENV PORT 3000

# En mode développement, utilisez simplement la commande dev sans build préalable
CMD ["npm", "run", "dev"]