import logging

logger = logging.getLogger("awsutil")
formatter = logging.Formatter("%(levelname)-07s - %(message)s")
handler = logging.StreamHandler()
handler.setFormatter(formatter)
logger.propagate = 0
logger.setLevel(logging.INFO)
logger.addHandler(handler)

