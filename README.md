# Jenkins Lambda Pipeline

## Description





## Dockerfile

Dockerfile is used to build up  our own custom image with specific requirements. The Docker image builds up with base ubuntu:latestversion, This Dockerfile will install Git, Python3.7, Databricks-cli, jq, curl and also the latest verion of pip. Then we build up the image and pushed to Dockerhub using below docker commands.

`docker build -t test/python3-pip-databricks:1 .` 

'.' represents the Dockerfile is present in current directory and -t represents tag name.Then after building up the image we have to push to Dockerhub.Before pushing to the Dockerhub we have to login Dockerhub with your credentials in local machine where the image is build.

`docker login --username Username --password Password`

This will login to your Dockerhub and provide access to push the images we build up locally.

`docker push test/python3-pip-databricks:1`

Finally this will push our image to Dockerhub
