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
ADD nginx.conf /etc/nginx/sites-available/cotabi.conf
RUN rm -f /etc/nginx/sites-enabled/default && \
    ln -s /etc/nginx/sites-available/cotabi.conf /etc/nginx/sites-enabled/cotabi.conf

# Rails environment setting
ARG rails_env="development"
ENV RAILS_ENV ${rails_env}
ENV SECRET_KEY_BASE 962abf4fe3fec768b115018da7c5d9ad6d3bdd215df27fe9abe82c3e24156afff68eed781404633157bb80182fff9938e4a3bb18549671434a4c5731aa3fff77

RUN mkdir /cotabi
WORKDIR /cotabi
ADD Gemfile /cotabi/Gemfile
ADD Gemfile.lock /cotabi/Gemfile.lock
# RUN bundle install

RUN bundle config build.nokogiri --use-system-libraries && \
    bundle config build.mysql2 --use-system-libraries && \
    bundle install --jobs 20 --retry 5

ADD . /cotabi
RUN mkdir -p tmp/sockets

# RUN npm install

# RUN RAILS_ENV=${rails_env} bundle exec rake assets:precompile
CMD bundle exec puma -d && \
    /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
