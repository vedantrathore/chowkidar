from environs import Env

env = Env()
env.read_env(".env.sample", recurse=False)

auth_log_file_path = env("SSH_LOG_MOUNTED_PATH")
server_webhook_url = env("SERVER_WEBHOOK_URL")
