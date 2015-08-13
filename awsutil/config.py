from os.path import expanduser
from configparser import ConfigParser
from pkg_resources import resource_filename
from awsutil.logger import logger

config = ConfigParser()
LOADED_CONFIGS = config.read([
    resource_filename("awsutil", "awsutil.ini"),
    expanduser("~/.awsutil.ini"),
    ".awsutil.ini"
])

logger.debug("Loaded config(s): %s", LOADED_CONFIGS)

