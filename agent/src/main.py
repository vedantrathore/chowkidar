import sys
from cache import CacheManager
from processor import SSHAuthFileProcessor
from watcher import SSHAuthWatcher
from env import auth_log_file_path

if __name__ == "__main__":
    try:
        cache = CacheManager()
        processor = SSHAuthFileProcessor(auth_log_file_path, cache=cache)
        handler = SSHAuthEventHandler(processor)
        SSHAuthWatcher(auth_log_file_path, handler).run()
    except CalledProcessError:
        print('Cannot fetch the last line')
        sys.exit(1)
