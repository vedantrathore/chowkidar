import requests

from __future__ import absolute_import
from src.celery_app import app
from src.env import SERVER_WEBHOOK_URL

@app.task
def trigger_webhook(data):
    r = requests.post(SERVER_WEBHOOK_URL, data=data)
    print(r.json())
