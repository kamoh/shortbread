FROM ruby:2.7-buster

WORKDIR /tools

ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

ENV USER_ID 1000
ENV GROUP_ID 1000


RUN addgroup --gid $GROUP_ID shrtbred
RUN adduser --disabled-password --gecos '' --uid $USER_ID --gid $GROUP_ID shrtbred
ENV RAILS_ENV production
ENV SHRTBRED_DATABASE_NAME shrtbred
ENV SHRTBRED_DATABASE_USER shrtbred
ENV SHRTBRED_DATABASE_PORT 5432
ENV SHRTBRED_DATABASE_PASSWORD shrtbred
ENV SHRTBRED_DATABASE_HOST localhost
ENV SHRTBRED_PORT 3000

RUN mkdir -p /opt/app
COPY . /opt/app
RUN gem install rails bundler
WORKDIR /opt/app
RUN bundle install

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs
COPY ./entrypoint.sh .
RUN chmod +x ./entrypoint.sh
USER $USER_ID
CMD ["bash","-c","./entrypoint.sh"]