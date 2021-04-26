---
title: "Kubernetes"
date: 2021-04-11T19:50:14Z
weight: 5
draft: false
---
{{% children depth="2" %}}
The following is the manifest file which will create 3 resources:
- Deployment (with 2 replicas)
- Service (type ClusterIP)
- Ingress

```
---
# Deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hugo-site
spec:
  selector:
    matchLabels:
      app: hugo-site
  replicas: 2
  template:
    metadata:
      labels:
        app: hugo-site
    spec:
      automountServiceAccountToken: false
      containers:
      - name: hugo-site
        image: paolabelmonte/hugo-site:${IMG_TAG}
        ports:
        - containerPort: 80
---
# Service of type ClusterIP
apiVersion: v1
kind: Service
metadata:
  name: hugo-site
  labels:
    app: hugo-site
spec:
  selector:
    app: hugo-site
  ports:
    - protocol: "TCP"
      port: 80
      targetPort: 80
  type: ClusterIP
---
# Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hugo-site
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-production
spec:
  tls:
  - hosts:
    - hugosite.crownlabs.polito.it
    secretName: hugo-site-cert
  rules:
  - host: hugosite.crownlabs.polito.it
    http:
      paths:
        - pathType: Prefix
          path: "/"
          backend:
            service:
              name: hugo-site
              port:
                number: 80
```

