from watchdog.events import FileSystemEventHandler

class SSHAuthEventHandler(FileSystemEventHandler):
    def __init__(self, processor):
        self.processor = processor

    def on_modified(self, event):
        self.process(event)

    def process(self, event):
        self.processor.trigger_event()
