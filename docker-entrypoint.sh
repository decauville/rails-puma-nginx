#!/bin/bash
set -e

cd $APP_ROOT
RAILS_ENV=production bundle exec puma -C config/puma.rb config.ru -d
exec service nginx start
