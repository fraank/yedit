FROM ubuntu:16.04
MAINTAINER Frank Cieslik

# Update Ubuntu Software repository
RUN apt-get update

# install ruby basics
RUN apt-get --assume-yes install ruby ruby-dev make gcc git
RUN apt-get --assume-yes install libxml2 build-essential g++
RUN apt-get --assume-yes install zlib1g-dev 
RUN gem install bundler

ENV APP_HOME /srv/www/editor

# make gems loading static
# ENV BUNDLE_PATH /srv/www/editor/usr/tmp/gems
ENV BUNDLE_JOBS=2 \
  BUNDLE_PATH=/bundle

WORKDIR $APP_HOME

COPY Gemfile $APP_HOME/Gemfile
COPY Gemfile.lock $APP_HOME/Gemfile.lock

RUN /bin/bash -l -c "bundle install"