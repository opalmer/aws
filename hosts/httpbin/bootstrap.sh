#!/bin/bash -ex

apt-get -y install python-dev uwsgi uwsgi-plugin-python nginx python-pip
pip install awscli httpbin

curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/httpbin/files/etc/nginx/sites-enabled/default -o /etc/nginx/sites-enabled/default
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/httpbin/files/etc/uwsgi/apps-enabled/httpbin.ini -o /etc/uwsgi/apps-enabled/httpbin.ini
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/httpbin/files/etc/ssl/certs/httpbin.pem -o /etc/ssl/certs/httpbin.pem
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/httpbin/files/etc/hostname -o /etc/hostname
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/httpbin/files/etc/hosts -o /etc/hosts
aws s3 cp s3://opalmer/aws/ssl/httpbin.key /etc/ssl/private/httpbin.key
openssl dhparam -out /etc/ssl/dhparams.pem 2048

hostname -F /etc/hostname
service nginx restart
service uwsgi restart
