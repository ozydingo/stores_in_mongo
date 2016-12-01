module StoresInMongo
  module DocumentMethods
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

    protected

    def mongo_document=(mongo_document)
      @mongo_document = mongo_document
    end

    private

    def mongo_document_loaded?
      @mongo_document.present?
    end

    def mongo_document(reload = false)
      return @mongo_document if !reload && mongo_document_loaded?
      @mongo_document = fetch_mongo_document || initialize_mongo_document
    end

    def fetch_mongo_document
      self.mongo_class.where(id: self[self.mongo_key]).first
    end

    def initialize_mongo_document
      self.class::MongoDocument.new
    end

    def save_mongo_document
      return true if !mongo_document_loaded?
      mongo_document.save
      self[self.mongo_key] = mongo_document.id
    end

    def destroy_mongo_document
      return true if !mongo_document_loaded?
      mongo_document.destroy
    end      
  end
end