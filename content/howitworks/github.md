---
title: "GitHub action"
date: 2021-04-11T23:15:54Z
weight: 6
draft: false
---
I have tried 2 workflows:

1. Using an existing action found in the Marketplace from a contributor ([link](https://github.com/mr-smithers-excellent/docker-build-push))
2. Using the official Docker GitHub actions ([link](https://github.com/docker/build-push-action))

**Workflow 1**

This is the workflow, triggered on every push event. It uses an existing action found in the Marketplace from a contributor.

```yaml
# Workflow to create a Docker image of a Hugo site
# and deploy it on a K8s cluster
# Version using github.sha as tag for Docker image
# and non official action for build/push steps

name: Build and publish Hugo site

on:
  push:
    branches: [ main ]

jobs:

  build-publish:

    runs-on: ubuntu-latest

    steps:
    
    # Use action to checkout repo
    # Hugo themes are git submodules: "submodules: true" needed
    - name: Check out code
      uses: actions/checkout@v2
      with:
        submodules: true
          
    # Use unofficial action and github.sha as tag for Docker image
    - name: Build and push Docker image
      uses: mr-smithers-excellent/docker-build-push@v5
      with:
        image: paolabelmonte/hugo-site
        tags: ${{ github.sha }}
        registry: docker.io
        dockerfile: Dockerfile
        username: ${{ secrets.DOCKERHUB_USER }}
        password: ${{ secrets.DOCKERHUB_PSW }}
    
    # Use action to perform replacement of IMG_TAG in template-deploy.yaml
    # after replacement save the file as my-deploy.yaml
    - name: Generate deploy yaml
      uses: danielr1996/envsubst-action@1.0.0
      with:
        input: template-deploy.yaml
        output: my-deploy.yaml
      env:
        IMG_TAG: ${{ github.sha }}
    
    # Use action to apply my-deploy.yaml to a K8s cluster
    # secrets.KUBECONFIG stores kubeconfig file with all cluster information
    - name: Deploy website on K8s cluster
      uses: giorio94/kubectl-oidc-action@1.1.0
      with:
        kubeconfig: ${{ secrets.KUBECONFIG }}
        args: apply -f my-deploy.yaml --namespace=project-github-website
```

**Workflow 2**

This is the workflow, triggered on every push event. It uses the official Docker GitHub actions.

```yaml
# Workflow to create a Docker image of a Hugo site
# and deploy it on a K8s cluster
# Version using github.sha as tag for Docker image
# and Docker official actions for build/push steps

name: Build and publish Hugo site

on:
  push:
    branches: [ main ]

jobs:

  build-publish:

    runs-on: ubuntu-latest

    steps:
    
    # Use action to checkout repo
    # Hugo themes are git submodules: "submodules: true" needed
    - name: Check out code
      uses: actions/checkout@v2
      with:
        submodules: true
          
    # Use official action to setup Docker Buildx (needed for following steps)
    # Docker Buildx is needed for docker/build-push-action
    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v1
    
    # Use official action to login to Docker Hub
    - name: Login to DockerHub
      uses: docker/login-action@v1 
      with:
        username: ${{ secrets.DOCKERHUB_USER }}
        password: ${{ secrets.DOCKERHUB_PSW }}
        
    # Use official action to build and push Docker image
    - name: Build and push Docker image
      id: docker_build
      uses: docker/build-push-action@v2
      with:
        push: true
        tags: paolabelmonte/hugosite:${{ github.sha }}
    
    # Show Docker image digest using output of previous actions
    - name: Image digest
      run: echo ${{ steps.docker_build.outputs.digest }}
    
    # Use action to perform replacement of IMG_TAG in template-deploy.yaml
    # after replacement save the file as my-deploy.yaml
    - name: Generate deploy yaml
      uses: danielr1996/envsubst-action@1.0.0
      with:
        input: template-deploy.yaml
        output: my-deploy.yaml
      env:
        IMG_TAG: ${{ github.sha }}
    
    # Use action to apply my-deploy.yaml to a K8s cluster
    # secrets.KUBECONFIG stores kubeconfig file with all cluster information
    - name: Deploy website on K8s cluster
      uses: giorio94/kubectl-oidc-action@1.1.0
      with:
        kubeconfig: ${{ secrets.KUBECONFIG }}
        args: apply -f my-deploy.yaml --namespace=project-github-website
```
