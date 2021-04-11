---
title: GitHub action
date: 2021-04-11T23:15:54Z
draft: false
---
This is the workflow for the GitHub action, which is triggered on every push event.

```
# Test workflow Paola
name: Docker build and publish

on:
  push:
    branches: [ main ]
  #pull_request:
    #branches: [ main ]

jobs:

  build:

    runs-on: ubuntu-latest

    steps:
    - name: Check out code
      uses: actions/checkout@v2
      with:
        submodules: true
          
    # Uso come numero di versione il github.run_number
    - name: Generate deploy yaml
      uses: danielr1996/envsubst-action@1.0.0
      with:
        input: template-deploy.yaml
        output: my-deploy.yaml
      env:
        IMG_TAG: ${{ github.run_number }}
    
    - name: Build and push Docker image
      uses: mr-smithers-excellent/docker-build-push@v5
      with:
        image: paolabelmonte/hugo-site
        tags: ${{ github.run_number }}
        registry: docker.io
        dockerfile: Dockerfile
        username: ${{ secrets.DOCKERHUB_USER }}
        password: ${{ secrets.DOCKERHUB_PSW }}
                
    - name: Deploy website
      uses: giorio94/kubectl-oidc-action@1.1.0
      with:
        kubeconfig: ${{ secrets.KUBECONFIG }}
        args: apply -f my-deploy.yaml
```
