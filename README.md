# Foreman/Katello Create Errata
Create RPM repository containing Errata for Foreman to sync and provide to clients

This project was a fork that was created to run a Docker image that built the errata and hosted it within the container or pushed it to an S3 bucket.  The original did not account for credentials to authenticate to AWS S3 and required passing the S3 URI as a build_arg.  

We wanted to abstract the credentials into a secret and run this as a CronJob in our Kubernetes cluster.  The Docker file was modified to abstract the actual errata build and upload process into the entrypoint script.

You can then simply add the S3 URL to Katello/Foreman as a yum repository.

## How to use 

- Create an S3 bucket that will host your errata.  Depending on your use case, you can leave the bucket private and create an IAM user to grant permissions to upload to the bucket.
- Edit the secret-erratabuilder.yml file to add your S3 URI (format: s3://yourbucket/), IAM User access key, and default region. 
- Edit the erratabuilder.yaml file to modify the schedule to suit your needs.  It is configured to run at 12AM on Sundays.  The job is configured to be suspended by default.  Edit the file to set suspend: false if wanted.
- kubectl apply the yaml files

## What

This tool is a way to create a repository containing Errata for CentOS 7
Foreman/Katello can then read and sync this repository to provide errata information to all of its clients

This is heavily based on 2 opensource projects : 
- This project is a fork of https://github.com/loitho/katello-create-errata
  - Provided the initial scripts and Dockerfile
- CEFS project [http://cefs.steve-meier.de]
  - provides for free Errata information about CentOS packages
- https://github.com/vmfarms/generate_updateinfo
  - makes us able to transform the XML provided by CEFS into a an updateinfo.xml file usable by a YUM repository
  

## Manual Build instruction 

The image has already been built and is hosted at globalspecllc/it-katello-erratabuilder

If you want to build the Docker image yourself
```
git clone https://github.com/globalspec-it/centos-errata-builder.git
cd katello-create-errata
```

I built the container using VMWare's BuildKit for Kubernetes
https://github.com/vmware-tanzu/buildkit-cli-for-kubectl

Create a secret file for the registery in your K8S namespace, then build the image.  
This will push the image directly to your container registery.
```
read -s REG_SECRET
kubectl create secret docker-registry mysecret --docker-server='<registry hostname>' --docker-username=<user name> --docker-password=$REG_SECRET
kubectl build --push --registry-secret mysecret -t <registry hostname>/<namespace>/<repo>:<tag> -f Dockerfile ./
```

