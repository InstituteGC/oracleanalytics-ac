# Automate the deployment of Oracle Analytics on-prem into EC2

This repository is designed to stand up a test Oracle Analytics Instance on an EC2 VM instance in AWS.

IT IS NOT PRODUCTION-READY AND SHOULD BE TREATED AS POTENTIALLY VULNERABLE.

## Deployment

* Install Terraform and Ansible.

* Download the following files into `vendor/`. These will probably need an Oracle SSO ID:

    * [Oracle JDK 8 for Linux x64, `.tar.gz` version](https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html)
 
    * Oracle Analytics 7.0.0 Server, comprised of two zip files. These can be downloaded by searching through [here](https://edelivery.oracle.com/osdc/faces/SoftwareDelivery):
 
        * Oracle Analytics Server Linux 7.0.0, 4.6 GB
     
        * Oracle Fusion Middleware 12c (12.2.1.4.0) Infrastructure, 1.5 GB

* Copy `.envrc.template` to `.envrc`, populate with an AWS access key capable of deploying EC2 and S3. Source using [direnv](https://direnv.net/).

* Run `make terraform`.

* Run `make ansible`.
