module StoresInMongo
  class MongoStore
    attr_reader :name, :klass, :foreign_key

    def initialize(klass, foreign_key)
      @klass = klass
      @foreign_key = foreign_key      
    end

    def find_or_initialize_for(owner)
      owner[@foreign_key].present? && @klass.where(id: owner[@foreign_key]).first || @klass.new
    end
  end
end
