require "stores_in_mongo/base.rb"
require "stores_in_mongo/builder.rb"
require "stores_in_mongo/document_methods.rb"
require "stores_in_mongo/interpreter.rb"

class StoresInMongo::RuntimeError < RuntimeError; end

ActiveRecord::Base.include(StoresInMongo::Base)
