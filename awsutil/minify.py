"""
Simple module for minimizing json content and stripping out
comments.
"""

from json import loads, dumps

from awsutil.logger import logger


def minify(path):
    """Minify a json document and remove any comments."""
    json_data = ""
    original_size = 0

    with open(path, "r") as source:
        for line in source:
            original_size += len(line)
            if not line.strip().startswith("//"):
                json_data += line

    # Dump the json data with no spaces between separators and sorted
    # keys.  Without the key sorting you can end up with different key order
    # between runs.
    try:
        json_data = dumps(
            loads(json_data),
            separators=(",", ":"), sort_keys=True
        )
    except Exception as error:
        logger.error("Failed to convert %s: %s", path, error)
        raise 
    logger.debug("minify(%r): %s -> %s", path, original_size, len(json_data))
    return json_data.encode("utf-8")
