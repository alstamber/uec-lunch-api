require 'rack/test'
require 'rspec'
require 'factory_girl'
require 'database_cleaner'

FactoryGirl.definition_file_paths = %w{./factories ./test/factories ./spec/factories}
FactoryGirl.find_definitions

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.before(:suite) do
    ActiveRecord::Base.configurations = YAML.load_file('config.yml')['database']
    ActiveRecord::Base.establish_connection(:test)
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
