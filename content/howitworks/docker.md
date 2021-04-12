---
title: "Docker image"
date: 2021-04-11T12:00:54Z
weight: 1
draft: false
---
{{% children depth="2" %}}
The goal is building a Docker image and obtain an NGINX server containing the Hugo website.

This is the Dockerfile: 

```
#Install OS for the container 
FROM ubuntu:latest as HUGOINSTALL

# Update repository and install Hugo
RUN apt-get update
RUN apt-get install hugo -y

# Copy to the hugo-site the working directory content
# (if it doesn't exist, it will be created)
COPY . /hugo-site

# Run Hugo to build the static site
RUN hugo -v --source=/hugo-site --destination=/hugo-site/public

# Install NGINX and rename default index.html file
FROM nginx:stable-alpine
RUN mv /usr/share/nginx/html/index.html /usr/share/nginx/html/old-index.html
# Copy the static site created by Hugo to NGINX's html serve directory
COPY --from=HUGOINSTALL /hugo-site/public/ /usr/share/nginx/html/

# The NGINX container will listen on port TCP 80
EXPOSE 80

```

It is possible to test the image locally.

- Build it and give it a tag:

```
sudo docker build -t paolabelmonte/hugo-site:v1 .
```

- Run a local container:

```
sudo docker run --name testhugo -d -p 8080:80 paolabelmonte/hugo-site:v1
```

- Open a browser and point to *http://_myhostname_:8080*.
