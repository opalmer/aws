import argparse
import hashlib
import os
from fnmatch import filter
from os.path import join, isfile, abspath

import boto

from awsutil.config import config
from awsutil.logger import logger
from awsutil.minify import minify

cloud_formation = boto.connect_cloudformation()
s3 = boto.connect_s3()


def source_templates():
    """Iterator which outputs absolute paths to all template files"""
    root_dir = config.get("cloudformation", "template_source_path")
    for root, dirs, files in os.walk(root_dir):
        for name in filter(files, "*.template"):
            yield join(root, name)


def parsed_args():
    parser = argparse.ArgumentParser(
        description="Utility wrapper around cloud formation tools and template "
                    "handling."
    )
    parser.set_defaults(command=None)

    subparsers = parser.add_subparsers(
        help="Additional commands this tool can run"
    )

    validate = subparsers.add_parser(
        "validate",
        help="Validates individual cloud formation templates.  If no templates "
             "are provided then all templates under %s will be "
             "validated." % config.get("cloudformation", "template_source_path")
    )
    validate.set_defaults(command="validate")

    upload = subparsers.add_parser(
        "upload",
        help="Uploads modified templates to Amazon S3"
    )
    upload.set_defaults(command="upload")

    upload = subparsers.add_parser(
        "sync",
        help="Uploads any modified templates to S3 and removes any keys in "
             "S3 that no longer exist in the template source path."
    )
    upload.set_defaults(command="sync")

    parser.add_argument(
        "files", nargs="*",
        help="Optional set of templates to work with."
    )

    return parser, parser.parse_args()


def validate(filepaths):
    assert isinstance(filepaths, (list, tuple))
    for path in filepaths:
        logger.info("Validating %s", path)
        template_body = minify(path)
        cloud_formation.validate_template(template_body=template_body)


def filepath_to_key_path(path):
    """Converts a file path to an S3 key path"""
    return config.get(
        "cloudformation", "template_s3_prefix") + path.replace(
        config.get("cloudformation", "template_source_path"),
        ""
    )


def get_key(path, validate=True):
    """
    Retrieves a key from S3 for the given file path or None if it
    does not exist.
    """
    key_path = filepath_to_key_path(path)
    bucket = s3.get_bucket(config.get("cloudformation", "bucket"))
    key = bucket.get_key(key_path, validate=validate)
    logger.debug("get_key(%r) -> %r", key_path, key)
    return key


def delete_extra_templates():
    """
    Iterates over all cloudformation keys in S3 and deletes any
    that not under source control locally.
    """
    bucket = s3.get_bucket(config.get("cloudformation", "bucket"))
    prefix = config.get("cloudformation", "template_s3_prefix")
    source_path = config.get("cloudformation", "template_source_path")

    for key in bucket.list(prefix=prefix):
        source_file = join(source_path, key.name.replace(prefix, ""))
        if not isfile(source_file):
            logger.info("Removing old template %s from S3", key.name)
            key.delete()


def get_url_for_key(key):
    """Returns a url for a given key object"""
    return "https://s3.amazonaws.com/{bucket_name}/{key_path}".format(
        bucket_name=key.bucket.name,
        key_path=key.key
    )


def upload(filepaths):
    """
    For each path in file paths:

        * Determine if a key in S3 exists for the given template.  If not,
          create it.
        * If the key does exist, check to see if we need to update the key.  If
          not, do nothing.
    """
    assert isinstance(filepaths, (list, tuple))
    for path in filepaths:
        key = get_key(path)
        template_data = minify(path)

        if key is None:
            validate([path])
            key = get_key(path, validate=False)
            key.set_contents_from_string(template_data)
            key.change_storage_class("REDUCED_REDUNDANCY")
            url = get_url_for_key(key)
            logger.info("Uploaded new template %s", url)

        else:
            md5 = hashlib.md5(template_data)

            if md5.hexdigest() != key.etag.replace('"', ""):
                validate([path])
                url = get_url_for_key(key)
                logger.info("Uploading %s", url)
                key.set_contents_from_string(template_data)
                key.change_storage_class("REDUCED_REDUNDANCY")


def main():
    parser, args = parsed_args()
    filepaths = list(map(abspath, args.files))

    if not filepaths:
        filepaths = list(source_templates())

    if args.command == "validate":
        validate(filepaths)

    elif args.command == "upload":
        upload(filepaths)

    elif args.command == "sync":
        upload(filepaths)
        delete_extra_templates()

    else:
        parser.error("Please provide a command")

