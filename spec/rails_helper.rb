# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
#require_relative '../config/environment'
require_relative 'dummy/config/environment'
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
#require 'factory_bot'
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end
RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  #config.include FactoryBot::Syntax::Methods
end

SE_DIR = File.join(File.dirname(__FILE__), 'shared_examples', '**', '*.rb')
Dir[SE_DIR].sort.each { |f| require f }

# Map the migrations in the dummy app to the engine:
ENGINE_ROOT = File.join(File.dirname(__FILE__), '../')
begin
  ActiveRecord::Migrator.migrations_paths = File.join(ENGINE_ROOT, 'spec/dummy/db/migrate')
  ActiveRecord::Migration.maintain_test_schema!
end

