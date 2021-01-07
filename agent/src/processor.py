# -*- coding : utf-8 -*-

import os
import re
import hashlib
import subprocess
from tasks import trigger_webhook

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
        with open(self.file) as file_handler:
            segment = None
            offset = 0
            file_handler.seek(0, os.SEEK_END)
            file_size = remaining_size = file_handler.tell()
            while remaining_size > 0:
                offset = min(file_size, offset + buf_size)
                file_handler.seek(file_size - offset)
                buffer = file_handler.read(min(remaining_size, buf_size))
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

    def process_trigger(self):
        producer = self.__read_reverse()
        try:
            while True:
                line = next(producer)
                lhash = self.__gen_hash(line)
                if lhash != self.last_line_read and 'sshd' in line:
                    yield line
                    continue
                self.__update_cache()
                break
        except StopIteration:
            print("File read completely")

    def process_message(self, message):
        try:
            tokens = message.split(' ')
            log_time = ' '.join(tokens[0:4])
            log_host = tokens[4]
            log_pid = re.search(r'sshd\[(\d+)\]',tokens[5]).group(1)
            log_msg = tokens[6: ]
            log_type = ''
            log_connection_type = ''
            log_user = ''
            log_remote_ip = ''
            log_remote_port = ''
            if 'Accepted' in log_msg:
                log_type = 'connected'
                log_connection_type = tokens[7]
                log_user = tokens[9]
                log_remote_ip = tokens[11]
                log_remote_port = tokens[13]
            elif 'Disconnected' in log_msg:
                log_type = 'disconnected'
                log_connection_type = ''
                log_user = tokens[9]
                log_remote_ip = tokens[10]
                log_remote_port = tokens[12]
            return {
                'pid': log_pid,
                'time': log_time,
                'host': log_host,
                'type': log_type,
                'user': log_user,
                'remote_ip': log_remote_ip,
                'remote_port': log_remote_port,
                'connection_type': log_connection_type
            }
        except Exception as e:
            print(e)
