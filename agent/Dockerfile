FROM python:3.8-slim-buster

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

RUN apt-get update \
  # dependencies for building Python packages
  && apt-get install -y build-essential \
  # cleaning up unused files
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && rm -rf /var/lib/apt/lists/*WORKDIR /app

RUN addgroup --system chowkidar-agent \
    && adduser --system --ingroup chowkidar-agent chowkidar-agent

# Requirements are installed here to ensure they will be cached.
COPY ./src/requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt \
  && rm -rf /requirements.txt

COPY --chown=chowkidar-agent:chowkidar-agent ./scripts/start-watcher /start-watcher
RUN sed -i 's/\r$//g' /start-watcher
RUN chmod +x /start-watcher

COPY --chown=chowkidar-agent:chowkidar-agent ./scripts/start-celery /start-celery
RUN sed -i 's/\r$//g' /start-celery
RUN chmod +x /start-celery

# Bundle app source
COPY --chown=chowkidar-agent:chowkidar-agent . /app

USER chowkidar-agent

WORKDIR /app

ENTRYPOINT ["./scripts/entrypoint"]
