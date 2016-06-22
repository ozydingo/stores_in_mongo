require "base.rb"
require "document_methods.rb"

ActiveRecord::Base.extend(StoresInMongo::Base)
