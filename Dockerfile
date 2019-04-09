FROM busybox as builder
ARG HUGO_VERSION=0.53
ARG hugo_args=''
RUN wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -O /hugo.tar.gz
RUN tar -xvf /hugo.tar.gz
COPY . /site
RUN cd /site \
 && /hugo ${hugo_args}


FROM golang:1.12.3-alpine as httpd
RUN apk -U add git
COPY httpd/ /go/src/httpd
WORKDIR  /go/src/httpd/
ENV GO111MODULE=on
RUN go build -v -tags netgo


FROM scratch
COPY --from=builder /site/public /www
COPY --from=httpd /go/src/httpd/httpd /httpd
EXPOSE 80
ENTRYPOINT ["/httpd"]
