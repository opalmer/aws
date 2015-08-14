#!/bin/bash -ex

apt-get -y install python-dev uwsgi uwsgi-plugin-python nginx python-pip
pip install awscli httpbin

rm -f /etc/nginx/sites-enable/default
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/nginx/sites-enabled/httpbin.pyfarm.net -o /etc/nginx/sites-enabled/httpbin.pyfarm.net
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/nginx/sites-enabled/pyfarm.net -o /etc/nginx/sites-enabled/pyfarm.net
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/uwsgi/apps-enabled/httpbin.ini -o /etc/uwsgi/apps-enabled/httpbin.ini
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/ssl/certs/pyfarm.pem -o /etc/ssl/certs/pyfarm.pem
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/hostname -o /etc/hostname
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/hosts -o /etc/hosts
aws s3 cp s3://opalmer/aws/ssl/pyfarm.key /etc/ssl/private/pyfarm.key
openssl dhparam -out /etc/ssl/dhparams.pem 2048

hostname -F /etc/hostname
service nginx restart
service uwsgi restart
