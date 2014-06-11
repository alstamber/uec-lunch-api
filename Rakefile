task :exec do
  desc "start server"
  if ENV['RACK_ENV'] == 'production'
    sh "bundle exec thin start -C config/thin.yml --socket /tmp/thin/sinatra.sock"
  else
    sh "rackup -o 0.0.0.0"
  end
end

task :stop do
  desc "stop server"
  sh "bundle exec thin stop -C config/thin.yml --socket /tmp/thin/sinatra.sock"
end

task :default => :exec

require 'sinatra/activerecord/rake'

