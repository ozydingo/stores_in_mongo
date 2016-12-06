module StoresInMongo
  class Builder

    def initialize(model, mongo_class_name, foreign_key)
      @model = model
      @mongo_class = mongo_class_name.present? ? mongo_class_name.constantize : build_mongo_class
      @foreign_key = foreign_key || @mongo_class.name.foreign_key
    end

    def build(&blk)
      @model.mongo_class = @mongo_class
      @model.mongo_key = @foreign_key
      @model.include(get_document_methods_module)

      Interpreter.new(self).instance_exec(&blk)
    end

    def build_mongo_class
      klass = @model.const_set("MongoDocument", Class.new)
      klass.include Mongoid::Document
      klass.include Mongoid::Timestamps
      return klass
    end

    def get_document_methods_module
      @model.const_set("MongoDocumentMethods", Module.new)
      @model::MongoDocumentMethods.include(StoresInMongo::DocumentMethods)
      @model::MongoDocumentMethods.extend ActiveSupport::Concern
      @model::MongoDocumentMethods.included do
        before_save :save_mongo_document
        after_save :clear_mongo_owner_dirty
        before_destroy :destroy_mongo_document
      end
      return @model::MongoDocumentMethods
    end

    def add_field(field_name, data_type)
      @model.mongo_class.field field_name, :type => data_type, default: data_type.try(:new) unless @model.mongo_class.fields.keys.include?(field_name.to_s)

      @model::MongoDocumentMethods.instance_exec(field_name) do |field_name|
        # getter
        define_method(field_name) do
          mongo_document[field_name]
        end

        # setter
        define_method("#{field_name}=") do |data|
          mongo_document[field_name] = data
        end

      end
    end

  end
end
