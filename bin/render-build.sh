#!/usr/bin/env bash
# exit on error
set -o errexit
bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rake db:schema:load
bundle exec rails db:migrate
#bundle exec rails db:migrate RAILS_ENV=production
