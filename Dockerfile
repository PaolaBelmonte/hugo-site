#Install the container's OS
FROM ubuntu:latest as HUGOINSTALL

# Install Hugo
RUN apt-get update
RUN apt-get install hugo -y

# Copy the contents of the current working directory to the hugo-site
# directory. The directory will be created if it doesn't exist.
COPY . /hugo-site

# Use Hugo to build the static site files.
RUN hugo -v --source=/hugo-site --destination=/hugo-site/public

# Install NGINX and deactivate NGINX's default index.html file.
# Move the static site files to NGINX's html directory.
# This directory is where the static site files will be served from by NGINX.
FROM nginx:stable-alpine
RUN mv /usr/share/nginx/html/index.html /usr/share/nginx/html/old-index.html
COPY --from=HUGOINSTALL /hugo-site/public/ /usr/share/nginx/html/

# The container will listen on port 80 using the TCP protocol.
EXPOSE 80

# Example from
# https://www.linode.com/docs/guides/deploy-container-image-to-kubernetes
