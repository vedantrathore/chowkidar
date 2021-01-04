from environs import Env

env = Env()
env.read_env(".env.sample", recurse=False)

AUTH_LOG_FILE_PATH = env("SSH_AUTH_LOG_FILE_NAME")
SERVER_WEBHOOK_URL = env("SERVER_WEBHOOK_URL")
CELERY_BROKER_URL = env("CELERY_BROKER_URL")
CELERY_BACKEND_URL = env("CELERY_BACKEND_URL")
