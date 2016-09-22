require "stores_in_mongo/base.rb"
require "stores_in_mongo/builder.rb"
require "stores_in_mongo/document_methods.rb"

ActiveRecord::Base.extend(StoresInMongo::Base)
