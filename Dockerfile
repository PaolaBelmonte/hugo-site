#Install OS for the container 
FROM ubuntu:latest as HUGOINSTALL

# Update repository and install Hugo
RUN apt-get update
RUN apt-get install hugo -y
RUN hv=$(hugo version)
RUN echo $hv

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
#RUN chown nginx:nginx /usr/share/nginx/html/*

# The NGINX container will listen on port TCP 80
EXPOSE 80
