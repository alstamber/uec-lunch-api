task :exec do
  desc "start server"
  sh "bundle exec thin start -C config/thin.yml --socket /tmp/thin/sinatra.sock"
end

task :stop do
  desc "stop server"
  sh "bundle exec thin stop -C config/thin.yml --socket /tmp/thin/sinatra.sock"
end

task :default => :exec

require 'sinatra/activerecord/rake'
require './app/main'

