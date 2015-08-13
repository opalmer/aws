import sys
assert sys.version_info[0] == 3

from setuptools import setup, find_packages

setup(
    license="MIT",
    author="Oliver Palmer",
    name="awsutil",
    version="0.0.0",
    packages=find_packages(include=("awsutil", )),
    include_package_data=True,
    package_data={
        "": ["*.ini"]
    },
    install_requires=[
        "boto",
        "awscli"
    ],
    entry_points={
        "console_scripts": {
            "cloudformation = awsutil.cloudformation:main"
        }
    }
)
