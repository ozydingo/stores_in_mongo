module StoresInMongo
  module DocumentMethods
    def mongo_class_name
      if self.stores_in_mongo_options[:polymorphic]
        self.public_send(self.stores_in_mongo_options[:class_name])
      else
        self.stores_in_mongo_options[:class_name]
      end
    end

    def mongo_class
      mongo_class_name.constantize
    end

    def mongo_key
      self.public_send(stores_in_mongo_options[:foreign_key])
    end

    def reload(*args)
      super
      mongo_document(true) if mongo_document_loaded?
      return self
    end

    def deep_dup(*args)
      copy = super
      copy.mongo_document = mongo_document.deep_dup
      return copy
    end

    def changed?
      @mongo_dirty || super
    end

    protected

    def mongo_document=(mongo_document)
      @mongo_document = mongo_document
    end

    private

    def mark_mongo_owner_as_dirty
      @mongo_dirty = true
      return true
    end

    def clear_mongo_owner_dirty
      @mongo_dirty = false
      return true
    end

    def mongo_document_loaded?
      @mongo_document.present?
    end

    def mongo_document(reload = false)
      return @mongo_document if !reload && mongo_document_loaded?
      @mongo_document = fetch_mongo_document || initialize_mongo_document
    end

    def fetch_mongo_document
      mongo_class.where(id: mongo_key).first
    end

    def initialize_mongo_document
      mongo_class.new
    end

    def save_mongo_document
      return true if !mongo_document_loaded?
      mongo_document.save
      mongo_key = mongo_document.id
      mark_mongo_owner_as_dirty
    end

    def destroy_mongo_document
      return true if !mongo_document_loaded?
      mongo_document.destroy
    end      
  end
end