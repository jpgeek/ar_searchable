module ArSearchable
end

require "ar_searchable/version"
require "ar_searchable/searchable_struct"
require "ar_searchable/search_methods"
require 'active_support/concern'
require "ar_searchable/railtie" if defined?(Rails::Railtie)
