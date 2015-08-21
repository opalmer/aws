# aws
This repository is meant to store my own configuration files, scripts, tools
and other related information.  If you happen to find something useful, you're 
more than welcome to modify it for your own purposes or ask for some help in
doing so.

# Project Structure

- **awsutil/**: Contains some basic modules for working with aws
- **cloud_formation/**:  CloudFormation (CF) templates.
    - /build: CF template for build.opalmer.com
    - /winbuild: CF templates for building the windows build machine.
    - /common: Common CF templates shared by other stacks
    - /pyfarm: CF templates for pyfarm.net and httpbin.pyfarm.net
- **hosts/**: Contains files for use by individual hosts for CF templates.

# Useful Links

* https://cloud-images.ubuntu.com/locator/ec2/
* https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html
* https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-windows-stacks-bootstrapping.html 
