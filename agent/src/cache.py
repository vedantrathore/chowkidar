import os

class CacheManager():
    def __init__(self, file_name='.cache'):
        self.file = file_name
        if not os.path.exists(self.file):
            with open(self.file, 'w+'): pass

    def get(self):
        with open(self.file, 'r') as fp:
            return fp.read()

    def put(self, value):
        with open(self.file, 'w') as fp:
            fp.write(value)
