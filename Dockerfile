FROM n8nio/n8n:latest

USER root

RUN apk add --no-cache \
    curl \
    wget \
    git \
    python3 \
    py3-pip \
    nodejs \
    npm \
    ca-certificates \
    postgresql-client

RUN mkdir -p /home/node/.n8n
RUN chown -R node:node /home/node/.n8n

USER node

WORKDIR /home/node

EXPOSE 5678

ENV N8N_HOST=0.0.0.0
ENV N8N_PORT=5678
ENV N8N_PROTOCOL=http
ENV WEBHOOK_URL=http://localhost:5678/
ENV N8N_LOG_LEVEL=info
ENV N8N_DISABLE_PRODUCTION_MAIN_PROCESS=true
ENV EXECUTIONS_PROCESS=main

VOLUME ["/home/node/.n8n"]

CMD ["n8n", "start"]