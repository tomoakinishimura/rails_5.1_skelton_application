FROM ruby:2.4.0

RUN apt-get update -qq && apt-get install -y build-essential libpq-dev vim less
RUN apt-get install -y nodejs npm && \
    npm install -g n && \
    n stable && \
    ln -s /usr/bin/nodejs /usr/bin/node
    # npm install -g yarn && \

RUN apt-get install -y locales locales-all
RUN apt-get install -y nginx

# Nginx
ADD nginx.conf /etc/nginx/sites-available/app.conf
RUN rm -f /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/app.conf /etc/nginx/sites-enabled/app.conf

# Rails environment setting
ARG rails_env="development"
ENV RAILS_ENV ${rails_env}

RUN mkdir /app
WORKDIR /app
ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install

# RUN bundle config build.nokogiri --use-system-libraries && \
#     bundle config build.mysql2 --use-system-libraries && \
#     bundle install --jobs 20 --retry 5

ADD . /app
RUN mkdir -p tmp/sockets

# RUN npm install

# RUN RAILS_ENV=${rails_env} bundle exec rake assets:precompile
CMD bundle exec puma -d && \
    /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
