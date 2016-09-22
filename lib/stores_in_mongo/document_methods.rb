module StoresInMongo
  module DocumentMethods
    def reload
      super
      find_or_initialize_document if document_loaded?
      return self
    end

    def dup
      copy = super
      copy.document = document.dup if document_loaded?
      return copy
    end

    private

    def document_loaded?
      @document.present?
    end

    def document(reload = false)
      return @document if !reload && document_loaded?
      @document = find_or_initialize_document
    end

    def save_document
      return true if document.nil?
      document.save
      self.document_id = document.id
    end

    def destroy_document
      return true if document.nil?
      document.destroy
    end      

    def find_or_initialize_document
      @document = fetch_document || self.class::MongoDocument.new
    end

    def fetch_document
      self.class::MongoDocument.where(id: self.document_id).first
    end
  end
end