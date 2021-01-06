# -*- coding : utf-8 -*-
from __future__ import absolute_import

import requests

from celery_app import app
from celery.utils.log import get_task_logger
from env import SERVER_WEBHOOK_URL
from pprint import pprint

logger = get_task_logger(__name__)

@app.task
def trigger_webhook(data):
    r = requests.post(SERVER_WEBHOOK_URL, json=data)
    logger.info(r.json())
