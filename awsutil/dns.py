import boto
import argparse

try:
    import urllib2
except ImportError:  # Python 3
    import urllib.request as urllib2

from awsutil.logger import logger

def set_public_record():
    parser = argparse.ArgumentParser(description="Updates DNS records")
    parser.add_argument(
        "--address",
        default=urllib2.urlopen(
            "http://169.254.169.254/latest/meta-data/public-ipv4",
            timeout=120
        ).read()
    )
    parser.add_argument(
        "hostname",
        help="The hostname to establish the DNS record for"
    )
    args = parser.parse_args()

    if not args.hostname.endswith("."):
        parser.error("Expected record to end with '.'")

    zone_name = ".".join(list(filter(bool, args.hostname.split(".")))[-2:])
    route53 = boto.connect_route53()
    zone = route53.get_zone(zone_name)

    record = zone.get_a(args.hostname)
    if record is None:
        logger.info("Creating A %s %s", args.hostname, args.address)
        zone.add_a(args.hostname, args.address, ttl=60)
    else:
        logger.info("Updating A %s %s", args.hostname, args.address)
        zone.update_record(record, args.address, new_ttl=60)
