#!/usr/bin/env bash -ex

apt-get -y install python-dev uwsgi uwsgi-plugin-python nginx python-pip
pip install httpbin awscli

curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/httpbin/etc/nginx/sites-enabled/default -o /etc/nginx/sites-enabled/default
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/httpbin/etc/uwsgi/apps-enabled/httpbin.ini -o /etc/uwsgi/apps-enabled/httpbin.ini
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/httpbin/etc/ssl/certs/httpbin.pem /etc/ssl/certs/httpbin.pem
aws s3 cp s3://opalmer/aws/ssl/httpbin.key /etc/ssl/private/httpbin.key
