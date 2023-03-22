FROM ubuntu
#Install curl , jq, nodejs and npm
RUN apt-get update && apt-get install --yes curl jq nodejs npm

#Install jk
RUN curl -Lo jk https://github.com/jkcfg/jk/releases/download/0.4.0/jk-linux-amd64
RUN chmod +x jk
RUN mv jk /usr/local/bin/