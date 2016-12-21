module StoresInMongo
  module DocumentMethods
    def mongo_class_name
      if self.stores_in_mongo_options[:polymorphic]
        self.public_send(mongo_class_column) or raise RuntimeError, "No mongo type specified in #{mongo_class_column} for #{self}! Initialize your model with a value or use a column default."
      else
        self.stores_in_mongo_options[:class_name]
      end
    end

    def mongo_class
      if self.stores_in_mongo_options[:use_sessions]
        mongo_class_name.constantize.with(session: mongo_session)
      else
        mongo_class_name.constantize
      end
    end

    def mongo_key
      self.public_send(mongo_key_column)
    end

    def mongo_class_column
      self.stores_in_mongo_options[:polymorphic] && self.stores_in_mongo_options[:class_name]
    end

    def mongo_key_column
      stores_in_mongo_options[:foreign_key]
    end

    def reload(*args)
      clear_mongo_cache
      super
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
      # We can't easily determine in-place data modification, so always mark as dirty if data has been loaded
      # TODO: only mark as dirty if data has actually changed. Clear dirty on a fresh load.
      mark_mongo_owner_as_dirty
      @mongo_document = mongo_document
      set_mongo_document_id
      return mongo_document
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

    def clear_mongo_cache
      @mongo_document = nil
    end

    def set_mongo_document_id
      assign_attributes(stores_in_mongo_options[:class_name] => mongo_document.class.name) if self.stores_in_mongo_options[:polymorphic]
      assign_attributes(stores_in_mongo_options[:foreign_key] => mongo_document.id)
      return mongo_key
    end

    def mongo_document(reload = false)
      return @mongo_document if !reload && mongo_document_loaded?
      self.mongo_document = fetch_mongo_document || initialize_mongo_document
    end

    def fetch_mongo_document
      mongo_class.where(id: mongo_key).first
    end

    def initialize_mongo_document
      mongo_class.new
    end

    def save_mongo_document
      return true if !mongo_document_loaded?
      mongo_document.save!
      set_mongo_document_id
      return true
    end

    def destroy_mongo_document
      return true if !mongo_document_loaded?
      mongo_document.destroy
    end      
  end
end