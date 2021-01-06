# -*- coding : utf-8 -*-
from __future__ import absolute_import

from celery import Celery

from env import CELERY_BACKEND_URL, CELERY_BROKER_URL

app = Celery('chowkidar-agent',
             broker=CELERY_BROKER_URL,
             backend=CELERY_BACKEND_URL,
             include=['tasks'])

if __name__ == '__main__':
    app.start()
