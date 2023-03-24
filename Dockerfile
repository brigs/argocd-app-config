FROM ubuntu:23.04
WORKDIR dynamic_manifests
#Install curl , jq, nodejs and npm
RUN apt-get update && apt-get install --yes curl jq nodejs npm

#Install jk
RUN curl -Lo jk https://github.com/jkcfg/jk/releases/download/0.4.0/jk-linux-amd64 && chmod +x jk && mv jk /usr/local/bin/
COPY dynamic-manifests/package.json .
COPY dynamic-manifests/package-lock.json .
COPY dynamic-manifests/index.js .
COPY dynamic-manifests/kustomization.yaml .
COPY dynamic-manifests/base/deployment.yaml base/deployment.yaml
RUN npm install

ENTRYPOINT ["npm","run", "generate"]
