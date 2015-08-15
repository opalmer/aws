#!/bin/bash -ex

# Configure hostname
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/hostname -o /etc/hostname
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/hosts -o /etc/hosts
hostname -F /etc/hostname

# Updates, core packages and dependencies
apt-get update
apt-get -y upgrade
apt-get -y install python-dev uwsgi uwsgi-plugin-python nginx python-pip

# Configure the httpbin web application
pip install httpbin
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/uwsgi/apps-enabled/httpbin.ini -o /etc/uwsgi/apps-enabled/httpbin.ini

# Configure nginx
rm -f /etc/nginx/sites-*/default
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/nginx/sites-enabled/httpbin -o /etc/nginx/sites-enabled/httpbin
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/nginx/sites-enabled/pyfarm -o /etc/nginx/sites-enabled/pyfarm
[ -f /etc/ssl/dhparams.pem ] || openssl dhparam -out /etc/ssl/dhparams.pem 2048

# SSL (public)
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/ssl/certs/pyfarm.pem -o /etc/ssl/certs/pyfarm.pem
curl https://raw.githubusercontent.com/opalmer/aws/master/hosts/pyfarm/files/etc/ssl/certs/httpbin.pem -o /etc/ssl/certs/httpbin.pem

# SSL (private)
pip install awscli
aws s3 cp s3://opalmer/aws/ssl/pyfarm.key /etc/ssl/private/pyfarm.key
aws s3 cp s3://opalmer/aws/ssl/httpbin.key /etc/ssl/private/httpbin.key

# Restart services
service uwsgi restart
service nginx restart

# Update Public IP address
public_ip=$(ec2metadata | grep public-ipv4 | awk '{print $2}')

aws --region us-east-1 cloudformation update-stack \
    --stack-name pyfarm-dns --template-url https://s3.amazonaws.com/opalmer/aws/cloud_formation/pyfarm/dns.template \
    --parameters ParameterKey=PublicIP,ParameterValue=$public_ip

