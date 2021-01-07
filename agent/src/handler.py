# -*- coding : utf-8 -*-

from datetime import datetime
import socket
from watchdog.events import FileSystemEventHandler
from tasks import trigger_webhook

class SSHAuthEventHandler(FileSystemEventHandler):
    def __init__(self, processor):
        self.ip = socket.gethostbyname(socket.gethostname())
        self.processor = processor

    def on_modified(self, event):
        self.process(event)

    def process(self, event):
        for data in self.processor.process_trigger():
            message_data = self.processor.process_message(data)
            trigger_webhook.delay({
                'ip': self.ip,
                'message': message_data,
                'time': datetime.utcnow().isoformat()
            })
