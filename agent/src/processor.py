import os
import hashlib
import subprocess

class SSHAuthFileProcessor():
    def __init__(self, file_path, cache):
        self.file = file_path
        self.cache = cache
        self.last_line_read = self.cache.get()
        if len(self.last_line_read) == 0:
            self.__update_cache()

    def __gen_hash(self, data):
        return hashlib.sha1(data.encode()).hexdigest()

    def __get_last_line_read(self):
        return self.__gen_hash(
            subprocess.check_output(['tail', '-1', self.file])
                .decode('utf-8')
                .strip()
        )

    def __update_cache(self):
        self.last_line_read = self.__get_last_line_read()
        self.cache.put(self.last_line_read)

    # subroutine to read lines in reverse from a file
    def __read_reverse(self, buf_size=8192):
        with open(self.file) as fh:
            segment = None
            offset = 0
            fh.seek(0, os.SEEK_END)
            file_size = remaining_size = fh.tell()
            while remaining_size > 0:
                offset = min(file_size, offset + buf_size)
                fh.seek(file_size - offset)
                buffer = fh.read(min(remaining_size, buf_size))
                remaining_size -= buf_size
                lines = buffer.split('\n')
                if segment is not None:
                    if buffer[-1] != '\n':
                        lines[-1] += segment
                    else:
                        yield segment
                segment = lines[0]
                for index in range(len(lines) - 1, 0, -1):
                    if lines[index]:
                        yield lines[index]
            # Don't yield None if the file was empty
            if segment is not None:
                yield segment

    def trigger_event(self):
        producer = self.__read_reverse()
        try:
            event_lines = []
            while True:
                line = next(producer)
                lhash = self.__gen_hash(line)
                if lhash != self.last_line_read:
                    event_lines.append(line)
                    continue
                self.__update_cache()
                break
            pprint(event_lines.reverse())
            event_lines = []
        except StopIteration:
            print("File read completely")