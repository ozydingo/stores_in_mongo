module StoresInMongo
  module Base
    def stores_in_mongo(field, data_type = Hash)
      ::StoresInMongo::Builder.new(self, field, data_type).build
    end
  end
end