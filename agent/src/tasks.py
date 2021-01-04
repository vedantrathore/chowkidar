from __future__ import absolute_import

from src.celery_app import app

@app.task
def add(x, y):
    return x + y
