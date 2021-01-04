from pprint import pprint

from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer

from env import auth_log_file_path


class SSHAuthWatcher:
    def __init__(self, src_path):
        self.__src_path = src_path
        self.__event_handler = SSHAuthEventHandler()
        self.__event_observer = Observer()

    def run(self):
        self.start()
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            self.stop()

    def start(self):
        self.__schedule()
        self.__event_observer.start()

    def stop(self):
        self.__event_observer.stop()
        self.__event_observer.join()

    def __schedule(self):
        self.__event_observer.schedule(
            self.__event_handler, self.__src_path, recursive=True
        )


class SSHAuthEventHandler(FileSystemEventHandler):
    def on_any_event(self, event):
        self.process(event)

    def process(self, event):
        # filename, ext = os.path.splitext(event.src_path)
        pprint(filename)
        filename
        # filename = f"{filename}_thumbnail.jpg"

        # image = Image.open(event.src_path)
        # image = grayscale(image)
        # image.thumbnail(self.THUMBNAIL_SIZE)
        # image.save(filename)


if __name__ == "__main__":
    SSHAuthWatcher(auth_log_file_path).run()
