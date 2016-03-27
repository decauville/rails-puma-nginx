FROM ubuntu:14.04
MAINTAINER Alican Erdogan <aerdogan07@gmail.com>

# INSTALL NGINX, GIT AND ZIP
RUN apt-get update && \
    apt-get install -y nginx zip git

# INSTALL ESSENTIAL LIBRARIES
RUN apt-get update && apt-get install -y git-core curl zlib1g-dev \
    build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev \
    sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev \
    python-software-properties libffi-dev libpq-dev

# INSTALL RBENV
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv && \
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build && \
    git clone https://github.com/rbenv/rbenv-gem-rehash.git ~/.rbenv/plugins/rbenv-gem-rehash

## CONFIGURE PATH FOR RBENV
ENV PATH /root/.rbenv/bin:/root/.rbenv/plugins/ruby-build/bin:/root/.rbenv/shims:$PATH

RUN	rbenv install 2.2.3 && \
    rbenv global 2.2.3

# INSTALL RAILS
RUN gem install bundler --no-ri --no-rdoc && \
    gem install rails -v 4.2.4 --no-ri --no-rdoc && \
    rbenv rehash

## INSTALL RBENV-VARS
RUN mkdir -p /root/.rbenv/plugins
WORKDIR /root/.rbenv/plugins
RUN git clone https://github.com/rbenv/rbenv-vars.git

# NODEJS INSTALL
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash - && \
    apt-get install -y nodejs

### ARGUMENTS
ENV APP_ROOT=/root/app
ARG APP_URL=https://github.com/alicanerdogan/Rails4Sample.git
ARG DATABASE_USER=postgres
ARG DATABASE_PASSWORD=postgres
ARG DATABASE_HOST=postgres_db

# Required for Bundler Install Error issues
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"

# APP DEPLOYMENT
WORKDIR $APP_ROOT
RUN git clone $APP_URL . && \
    bundle install

WORKDIR $APP_ROOT
RUN echo -n "SECRET_KEY_BASE=" >> .rbenv-vars && \
    rake secret >> .rbenv-vars && \
    echo -n "DATABASE_USER=" >> .rbenv-vars && \
    echo $DATABASE_USER >> .rbenv-vars && \
    echo -n "DATABASE_PASSWORD=" >> .rbenv-vars && \
    echo $DATABASE_PASSWORD >> .rbenv-vars && \
    echo -n "DATABASE_HOST=" >> .rbenv-vars && \
    echo $DATABASE_HOST >> .rbenv-vars && \
    rbenv vars

# PUMA CONFIGURATION
RUN gem install puma --no-ri --no-rdoc
WORKDIR $APP_ROOT
COPY puma.rb config/

WORKDIR $APP_ROOT
RUN mkdir -p shared/pids shared/sockets shared/log
COPY puma.conf /etc/init
COPY puma-manager.conf /etc/init
RUN echo $APP_ROOT >> /etc/puma.conf

# NGINX CONFIGURATION
COPY default /etc/nginx/sites-available/
RUN sed -i -e 's/APP_ROOT/\/root\/app/g' /etc/nginx/sites-available/default
COPY nginx.conf /etc/nginx/

COPY docker-entrypoint.sh $APP_ROOT
WORKDIR $APP_ROOT
RUN chmod u+x docker-entrypoint.sh

ENTRYPOINT ./docker-entrypoint.sh
