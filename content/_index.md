# Automatic static site deployment on Kubernetes with GitHub actions

Welcome to my project!

This is a project work for the [Cloud Computing course](https://didattica.polito.it/pls/portal30/gap.pkg_guide.viewGap?p_cod_ins=01TYDSM) at Politecnico di Torino.

The main goal is providing an **automatic deploy of a web site starting from a GitHub repository**.

The GitHub repository is converted into website content using Hugo, an open-source static site generator. The content is packaged in a Docker image, which is used to create a pod deployment hosted on a Kubernetes cluster.

All the flow is automated using a GitHub action that is triggered on every push event.
In this way, the website content can be directly updated from within the GitHub repository by simply editing or adding markdown files. All is obtained without writing html/css pages or programming code.

This web site has been created following these steps and it is running on the Kubernetes cluster provided by the [Netgroup](http://netgroup.polito.it) at Politecnico di Torino.
