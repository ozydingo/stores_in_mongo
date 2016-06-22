module StoresInMongo
  module Base
    def stores_in_mongo(field)
      class_attribute :mongo_data_field
      self.mongo_data_field = field.to_s
      include StoresInMongo::DocumentMethods

      before_save :save_document
      before_destroy :destroy_document

      klass = const_set("MongoDocument", Class.new)
      klass.include Mongoid::Document
      klass.include Mongoid::Timestamps
      klass.field self.mongo_data_field.to_sym, :type => Hash, default: {}

      # TODO: allow customization `document` name
      define_method(self.mongo_data_field) do |reload = false|
        document(reload)[self.mongo_data_field]
      end

      define_method(self.mongo_data_field + "=") do |data|
        document[self.mongo_data_field] = data
      end
    end
  end
end