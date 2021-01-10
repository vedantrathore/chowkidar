FROM node:12-alpine 

RUN addgroup --system chowkidar-server \
    && adduser --system --ingroup chowkidar-server chowkidar-server 

WORKDIR /app

COPY --chown=chowkidar-server:chowkidar-server package*.json ./

RUN npm install && npm cache clean --force --loglevel=error

COPY --chown=chowkidar-server:chowkidar-server . /app

USER chowkidar-server

EXPOSE 3030

ENTRYPOINT [ "npx" ]

CMD [ "nodemon", "src/server.js" ]
