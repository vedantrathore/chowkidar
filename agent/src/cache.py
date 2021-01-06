import os

class CacheManager():
    def __init__(self, file_name='.cache'):
        self.file = file_name
        if not os.path.exists(self.file):
            with open(self.file, 'w+'):
                pass

    def get(self):
        with open(self.file, 'r') as file_pointer:
            return file_pointer.read()

    def put(self, value):
        with open(self.file, 'w') as file_pointer:
            file_pointer.write(value)
