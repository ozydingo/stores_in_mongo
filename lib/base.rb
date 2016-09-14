module StoresInMongo
  module Base
    def stores_in_mongo(field)
      ::StoresInMongo::Builder.new(self, field).build
    end
  end
end