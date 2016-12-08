module StoresInMongo
  class Builder

    def initialize(model)
      @model = model
      @class_given = @model.stores_in_mongo_options[:class_name].present?
    end

    def build(&blk)
      if !@class_given
        klass = build_mongo_class
        @model.stores_in_mongo_options[:class_name] = klass.name
      end
      @model.stores_in_mongo_options[:foreign_key] ||= @model.stores_in_mongo_options[:class_name].foreign_key
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
      @model.stores_in_mongo_options[:class_name].constantize.field field_name, :type => data_type, default: data_type.try(:new) if !@class_given

      @model::MongoDocumentMethods.instance_exec(field_name) do |field_name|
        # getter
        define_method(field_name) do
          mongo_document.public_send(field_name)
        end

        # setter
        define_method("#{field_name}=") do |data|
          mongo_document.public_send("#{field_name}=", data)
        end

      end
    end

    def define_session(&blk)
      @model::MongoDocumentMethods.instance_exec(blk) do |blk|
        define_method("mongo_session") do
          instance_exec(&blk)
        end
      end
    end

  end
end
