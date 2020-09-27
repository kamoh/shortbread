FROM ruby:2.7

WORKDIR /tools

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

WORKDIR /build

COPY go.mod .
COPY go.sum .

RUN go mod download
COPY . .
RUN go build -o ad-server .
WORKDIR /dist
RUN cp /build/ad-server .
RUN rm -fr /build

RUN mkdir -p config && touch config/test.yml
COPY ./entrypoint.sh .
RUN chmod +x entrypoint.sh

EXPOSE 8080
CMD ./entrypoint.sh
