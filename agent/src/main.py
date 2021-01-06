# -*- coding : utf-8 -*-
import sys

from subprocess import CalledProcessError
from cache import CacheManager
from processor import SSHAuthFileProcessor
from handler import SSHAuthEventHandler
from watcher import SSHAuthWatcher
from env import AUTH_LOG_FILE_PATH

if __name__ == "__main__":
    try:
        cache = CacheManager()
        processor = SSHAuthFileProcessor(AUTH_LOG_FILE_PATH, cache=cache)
        handler = SSHAuthEventHandler(processor)
        SSHAuthWatcher(AUTH_LOG_FILE_PATH, handler).run()
    except CalledProcessError:
        print('Cannot fetch the last line')
        sys.exit(1)
