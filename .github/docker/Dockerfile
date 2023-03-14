FROM alpine:3.17@sha256:69665d02cb32192e52e07644d76bc6f25abeb5410edc1c7a81a10ba3f0efb90a

LABEL description="For building static sites with Hugo."
LABEL maintainer="Nianjun Sun <sunnianjun@apache.org>"

ENV HUGO_VERSION=0.70.0

COPY ./bin/hugo_0.70.0_Linux-64bit/hugo /usr/local/bin/hugo
COPY hugo.sh /
RUN chmod 777 /hugo.sh \
    && chmod 777 /usr/local/bin/hugo && ln -s /usr/local/bin/hugo /

RUN apk update \
    && apk upgrade \
    && apk add --no-cache bash \
    && echo "export PATH=$PATH:/bin/bash" > ~/.bashrc \
    && source ~/.bashrc

VOLUME /opt/input
WORKDIR /opt/input
ENTRYPOINT ["sh", "/build.sh"]

EXPOSE 1313
