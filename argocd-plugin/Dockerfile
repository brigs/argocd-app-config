FROM node

USER root
#Install jq
RUN apt-get update && apt-get install --yes jq

#Install jk
RUN curl -Lo jk https://github.com/jkcfg/jk/releases/download/0.4.0/jk-linux-amd64
RUN chmod +x jk
RUN mv jk /usr/local/bin/

RUN mkdir /home/npm
RUN chown -R 999:0 "/home/npm"
RUN npm_config_cache=/home/npm
RUN mkdir "/.npm"
RUN chown -R 999:0 "/.npm"

#Install az
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

USER 999