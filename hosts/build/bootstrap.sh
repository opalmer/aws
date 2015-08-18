#!/bin/bash -ex

# Configure hostname
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/hostname -o /etc/hostname
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/hosts -o /etc/hosts
hostname -F /etc/hostname

# Updates, core packages and dependencies
apt-get update
apt-get -y upgrade
apt-get -y install python-dev python-pip python-virtualenv git
pip install --upgrade pip

# Configure nginx
rm -f /etc/nginx/sites-*/default
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/nginx/sites-enabled/build -o /etc/nginx/sites-enabled/build
[ -f /etc/ssl/dhparams.pem ] || openssl dhparam -out /etc/ssl/dhparams.pem 2048

# SSL (public)
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/ssl/certs/build.pem -o /etc/ssl/certs/build.pem

# SSL (private)
pip install awscli
aws s3 cp s3://opalmer/aws/ssl/build.key /etc/ssl/private/build.key

# Restart services
service nginx restart
service buildmaster restart

# Update Public IP addresses
pip install boto
curl https://raw.githubusercontent.com/opalmer/aws/master/scripts/aws_set_public_a_record -o /usr/bin/aws_set_public_a_record
chmod +x /usr/bin/aws_set_public_a_record
/usr/bin/aws_set_public_a_record build.opalmer.com.

